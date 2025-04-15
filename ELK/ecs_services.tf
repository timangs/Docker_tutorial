# ecs_services.tf (또는 원하는 파일명 사용)

# --- Elasticsearch ECS 서비스 생성 ---
resource "aws_ecs_service" "elasticsearch_service" {
  # 서비스 이름 설정
  name            = "elasticsearch-service" # 원하는 이름으로 변경 가능
  # 실행할 ECS 클러스터 ARN 또는 이름 참조
  cluster         = aws_ecs_cluster.integration_log_cluster.id # 이전에 생성한 클러스터 리소스 참조
  # 실행할 Task Definition ARN (Revision 포함) 참조
  task_definition = aws_ecs_task_definition.elasticsearch_task.arn # 이전에 생성한 ES Task Definition 리소스 참조
  # 실행할 Task 개수
  desired_count   = 1 # 단일 노드 구성이므로 1로 설정 (필요시 조정)

  # 시작 유형 (Task Definition과 일치해야 함)
  launch_type     = "FARGATE"

  # 네트워크 설정 (Fargate awsvpc 모드 사용 시 필요)
  network_configuration {
    # Task가 실행될 서브넷 ID 목록 (Private 서브넷 권장)
    subnets = var.subnets # 실제 서브넷 ID 목록으로 변경 필요 (Task Definition과 동일한 AZ의 서브넷 포함)

    # Task에 적용할 보안 그룹 ID 목록
    # 아래에서 생성하는 Task용 보안 그룹 리소스의 ID를 참조합니다.
    security_groups = [aws_security_group.ecs_task_sg.id] # 예시 보안 그룹 참조

    # Public IP 할당 여부 (내부 서비스이므로 false 권장)
    assign_public_ip = false
  }

  # 로드 밸런서 설정
  load_balancer {
    # 연결할 대상 그룹 ARN 참조
    target_group_arn = aws_lb_target_group.elasticsearch_tg.arn # 이전에 생성한 ES 대상 그룹 리소스 참조
    # Task Definition에 정의된 컨테이너 이름
    container_name   = "elasticsearch-container"
    # 대상 그룹과 연결될 컨테이너 포트
    container_port   = 9200
  }

  # (선택 사항) 서비스 배포 설정
  # deployment_maximum_percent         = 200
  # deployment_minimum_healthy_percent = 100

  # (선택 사항) 서비스가 로드 밸런서에 등록될 때까지 기다림
  # health_check_grace_period_seconds = 60

  # Task Definition 또는 로드 밸런서 변경 시 서비스 업데이트 보장
  depends_on = [
    aws_lb_listener.elasticsearch_listener,
    # aws_iam_role_policy_attachment.ecs_task_execution_role_policy # Task 실행 역할 정책이 먼저 적용되도록
  ]

  # 태그 설정 (선택 사항)
  tags = {
    Name        = "ElasticsearchService"
    Environment = "Development"
    Project     = "LogMonitoring"
  }
}

# --- Task용 보안 그룹 생성 예시 ---
# (이 리소스가 다른 파일에 정의되어 있다면 해당 리소스를 참조하면 됩니다.)
resource "aws_security_group" "ecs_task_sg" {
  name        = "ecs-task-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id # 실제 사용 중인 VPC ID로 변경 필요

  # 예시: Elasticsearch ALB 보안 그룹으로부터 9200, 9300 포트 허용
  ingress {
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    # 이전에 생성한 ALB 보안 그룹 리소스의 ID를 참조합니다.
    security_groups = [aws_security_group.elasticsearch_lb_sg.id] # ALB 보안 그룹 ID 참조
  }
  ingress {
    from_port       = 9300
    to_port         = 9300
    protocol        = "tcp"
    # 이전에 생성한 ALB 보안 그룹 리소스의 ID를 참조합니다.
    security_groups = [aws_security_group.elasticsearch_lb_sg.id] # ALB 보안 그룹 ID 참조
  }

  # 아웃바운드는 기본적으로 모두 허용 (필요시 제한)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ECSTaskSecurityGroup"
    Project = "LogMonitoring"
  }
}

# (선택 사항) 생성된 서비스 이름 출력
output "elasticsearch_service_name" {
  description = "생성된 Elasticsearch ECS 서비스의 이름"
  value       = aws_ecs_service.elasticsearch_service.name
}

# ecs_services.tf (또는 Elasticsearch 서비스와 같은 파일에 추가)--------------------------------------------------------------------------------------------

# --- Kibana ECS 서비스 생성 ---
resource "aws_ecs_service" "kibana_service" {
  # 서비스 이름 설정
  name            = "kibana-service" # 원하는 이름으로 변경 가능
  # 실행할 ECS 클러스터 ARN 또는 이름 참조
  cluster         = aws_ecs_cluster.integration_log_cluster.id # 이전에 생성한 클러스터 리소스 참조
  # 실행할 Task Definition ARN (Revision 포함) 참조
  task_definition = aws_ecs_task_definition.kibana_task.arn # 이전에 생성한 Kibana Task Definition 리소스 참조
  # 실행할 Task 개수
  desired_count   = 1 # 보통 1개로 시작 (필요시 조정)

  # 시작 유형 (Task Definition과 일치해야 함)
  launch_type     = "FARGATE"

  # 네트워크 설정 (Fargate awsvpc 모드 사용 시 필요)
  network_configuration {
    # Task가 실행될 서브넷 ID 목록 (Private 서브넷 권장)
    # Elasticsearch Task와 동일한 서브넷 또는 통신 가능한 서브넷 지정
    subnets = var.subnets # 실제 서브넷 ID 목록으로 변경 필요

    # Task에 적용할 보안 그룹 ID 목록
    # Elasticsearch Task와 동일한 보안 그룹을 사용하거나 별도 생성 가능
    # 이 보안 그룹은 Elasticsearch ALB 보안 그룹으로 9200 포트 아웃바운드 트래픽 허용 필요 (현재 예시 SG는 모든 아웃바운드 허용)
    # 사용자가 Kibana UI에 접근해야 한다면, 해당 트래픽(예: 5601 포트)을 허용하는 규칙 추가 필요
    security_groups = [aws_security_group.ecs_task_sg.id] # 예시 보안 그룹 참조 (또는 별도 Kibana용 SG 생성)

    # Public IP 할당 여부 (외부 LB 사용 시 false, 직접 접근 시 true 설정 가능)
    assign_public_ip = false
  }

  # Kibana는 일반적으로 서비스 자체에 로드 밸런서를 직접 연결하지 않음
  # 사용자 접근을 위해서는 별도의 ALB(외부용)를 생성하고 이 서비스의 Task IP를 대상으로 등록하거나,
  # 또는 다른 방법(예: CloudFront + ALB)으로 접근 경로를 구성합니다.
  # load_balancer {} # 블록 생략

  # (선택 사항) 서비스 배포 설정
  # deployment_maximum_percent         = 200
  # deployment_minimum_healthy_percent = 100

  # (선택 사항) 서비스 시작 시 유예 시간
  # health_check_grace_period_seconds = 60

  # Task Definition 변경 시 서비스 업데이트 보장
  depends_on = [
    aws_ecs_service.elasticsearch_service, # Elasticsearch 서비스가 먼저 안정화된 후 시작하도록 (선택적)
    # aws_iam_role_policy_attachment.ecs_task_execution_role_policy
  ]

  # 태그 설정 (선택 사항)
  tags = {
    Name        = "KibanaService"
    Environment = "Development"
    Project     = "LogMonitoring"
  }
}

# (선택 사항) 생성된 서비스 이름 출력
output "kibana_service_name" {
  description = "생성된 Kibana ECS 서비스의 이름"
  value       = aws_ecs_service.kibana_service.name
}

