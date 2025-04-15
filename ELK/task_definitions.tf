# task_definitions.tf (또는 원하는 파일명 사용)

# --- Elasticsearch Task Definition ---
resource "aws_ecs_task_definition" "elasticsearch_task" {
  # Task Definition 패밀리 이름 설정
  family                   = "elasticsearch-task" # 원하는 이름으로 변경 가능
  # 네트워크 모드 설정 (Fargate 사용 시 awsvpc 권장)
  network_mode             = "awsvpc"
  # Task 실행 역할 ARN (ECS Agent가 ECR 이미지 가져오기, CloudWatch Logs 전송 등을 위해 필요)
  # 미리 생성된 역할 ARN을 사용하거나, Terraform으로 역할을 생성하여 참조합니다.
  # 예시: execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = "arn:aws:iam::248189921892:role/ecsTaskExecutionRole" # 실제 역할 ARN으로 변경 필요

  # Task 역할 ARN (컨테이너가 다른 AWS 서비스에 접근할 필요가 있을 경우 설정)
  # 예: task_role_arn = aws_iam_role.elasticsearch_task_role.arn
  # task_role_arn            = "<your_optional_task_role_arn>" # 필요시 역할 ARN으로 변경

  # Fargate 시작 유형 사용 시 필요
  requires_compatibilities = ["FARGATE"]
  # Task 레벨 CPU 설정 (Fargate vCPU 단위)
  cpu                      = "1024" # 예시 값 (1 vCPU), 필요에 따라 조정 (예: "2048" for 2 vCPU)
  # Task 레벨 메모리 설정 (Fargate MiB 단위)
  memory                   = "2048" # 예시 값 (2 GB), 필요에 따라 조정 (ES_JAVA_OPTS 와 연관)

  # 컨테이너 정의 (JSON 형식)
  # Terraform 0.12 이상에서는 jsonencode 함수 사용 권장
  container_definitions = jsonencode([
    {
      # 컨테이너 이름
      name      = "elasticsearch-container" # 원하는 이름으로 변경 가능
      # 사용할 Docker 이미지 (ECR에 푸시한 이미지 URI)
      image     = "248189921892.dkr.ecr.ap-northeast-2.amazonaws.com/elasticsearch/integration_log:es01" # 실제 ECR URI로 변경 필요
      # 컨테이너 레벨 CPU 유닛 (선택 사항, Task 레벨 설정과 조율)
      # cpu       = 512
      # 컨테이너 레벨 메모리 제한 (Hard Limit, MiB 단위)
      # memory    = 1536 # 예시 값, Task 메모리보다 작아야 함 (ES_JAVA_OPTS 고려)
      # 컨테이너 레벨 메모리 예약 (Soft Limit, MiB 단위, 선택 사항)
      # memoryReservation = 1024

      # 필수 설정 여부
      essential = true
      # 포트 매핑
      portMappings = [
        {
          containerPort = 9200 # Elasticsearch HTTP 포트
          hostPort      = 9200 # awsvpc 모드에서는 hostPort와 containerPort 동일하게 설정
          protocol      = "tcp"
        },
        {
          containerPort = 9300 # Elasticsearch Transport 포트
          hostPort      = 9300
          protocol      = "tcp"
        }
      ]
      # 환경 변수 설정 (docker-compose.yml 내용 참고)
      environment = [
        { name = "node.name", value = "es01" },
        { name = "cluster.name", value = "es-docker-cluster" },
        { name = "discovery.type", value = "single-node" },
        { name = "bootstrap.memory_lock", value = "true" },
        # ES_JAVA_OPTS: Task/컨테이너 메모리 설정과 맞게 조정 필요
        { name = "ES_JAVA_OPTS", value = "-Xms1g -Xmx1g" } # 예시: 1GB (컨테이너 메모리 고려)
        # { name = "xpack.security.enabled", value = "false" } # 보안 비활성화 시 (기본값 false)
      ]
      # ulimits 설정 (memory locking)
      ulimits = [
        {
          name      = "memlock"
          softLimit = -1
          hardLimit = -1
        }
      ]
      # 로그 설정 (예: CloudWatch Logs)
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/elasticsearch-task" # CloudWatch Log Group 이름 (자동 생성 또는 기존 그룹 사용)
          "awslogs-region"        = "ap-northeast-2"       # CloudWatch Logs 리전
          "awslogs-stream-prefix" = "es"                      # 로그 스트림 접두사
        }
      }
      # 볼륨 마운트 설정
      mountPoints = [
        {
          sourceVolume  = "esdata01"      # 아래 volumes 에서 정의한 이름
          containerPath = "/usr/share/elasticsearch/data" # 컨테이너 내부 경로
          readOnly      = false
        }
      ]
    }
  ])

  # Task에서 사용할 볼륨 정의
  volume {
    name = "esdata01" # 컨테이너 정의의 mountPoints 와 연결될 볼륨 이름
    # Fargate 사용 시에는 host_path 를 지정할 수 없습니다.
    # 데이터를 영구적으로 보존하려면 EFS(Elastic File System) 등을 연동해야 합니다.
    # 아래는 Fargate에서 임시 스토리지 볼륨을 정의하는 예시입니다. (Task 중지 시 데이터 사라짐)
    # EFS를 사용하려면 efs_volume_configuration 블록을 사용합니다.
  }

  # 태그 설정 (선택 사항)
  tags = {
    Name        = "ElasticsearchTaskDefinition"
    Environment = "Development"
    Project     = "LogMonitoring"
  }
}

# (선택 사항) 생성된 Task Definition ARN 출력
output "elasticsearch_task_definition_arn" {
  description = "생성된 Elasticsearch Task Definition의 ARN"
  value       = aws_ecs_task_definition.elasticsearch_task.arn
}

# --- 필요한 IAM 역할 정의 (예시) ---
# (실제 환경에서는 기존 역할을 사용하거나 더 상세하게 권한을 설정해야 합니다.)

# ECS Task 실행 역할 (ECS Agent가 ECR 접근, CloudWatch 접근 등)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-integration-log" # 원하는 역할 이름

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Project = "LogMonitoring"
  }
}

# ECS Task 실행 역할에 필요한 기본 정책 연결
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# (선택 사항) Elasticsearch Task 역할 (컨테이너 내부에서 다른 AWS 서비스 접근 시)
# resource "aws_iam_role" "elasticsearch_task_role" {
#   name = "elasticsearchTaskRole-integration-log"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#       },
#     ]
#   })
#
#   # 여기에 필요한 권한 정책을 추가합니다. (예: S3 접근 권한 등)
#
#   tags = {
#     Project = "LogMonitoring"
#   }
# }

# task_definitions.tf (또는 Elasticsearch Task Definition과 같은 파일에 추가)

# --- Kibana Task Definition ---
resource "aws_ecs_task_definition" "kibana_task" {
  # Task Definition 패밀리 이름 설정
  family                   = "kibana-task" # 원하는 이름으로 변경 가능
  # 네트워크 모드 설정 (Fargate 사용 시 awsvpc 권장)
  network_mode             = "awsvpc"
  # Task 실행 역할 ARN (Elasticsearch와 동일한 역할 사용 가능)
  # 예시: execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = "arn:aws:iam::248189921892:role/ecsTaskExecutionRole" # 실제 역할 ARN으로 변경 필요 (Elasticsearch와 동일한 값 사용 가능)

  # Task 역할 ARN (Kibana 컨테이너가 다른 AWS 서비스에 접근할 필요가 있을 경우 설정)
  # task_role_arn            = "<your_optional_kibana_task_role_arn>" # 필요시 역할 ARN으로 변경

  # Fargate 시작 유형 사용 시 필요
  requires_compatibilities = ["FARGATE"]
  # Task 레벨 CPU 설정 (Fargate vCPU 단위)
  cpu                      = "512"  # 예시 값 (0.5 vCPU), Kibana는 보통 ES보다 적게 필요
  # Task 레벨 메모리 설정 (Fargate MiB 단위)
  memory                   = "1024" # 예시 값 (1 GB), 필요에 따라 조정

  # 컨테이너 정의 (JSON 형식)
  container_definitions = jsonencode([
    {
      # 컨테이너 이름
      name      = "kibana-container" # 원하는 이름으로 변경 가능
      # 사용할 Docker 이미지 (ECR에 푸시한 이미지 URI)
      image     = "248189921892.dkr.ecr.ap-northeast-2.amazonaws.com/elasticsearch/integration_log:kibana" # 실제 ECR URI로 변경 필요
      # 컨테이너 레벨 CPU 유닛 (선택 사항)
      # cpu       = 256
      # 컨테이너 레벨 메모리 제한/예약 (선택 사항, MiB 단위)
      # memory    = 768
      # memoryReservation = 512

      # 필수 설정 여부
      essential = true
      # 포트 매핑
      portMappings = [
        {
          containerPort = 5601 # Kibana 기본 포트
          hostPort      = 5601 # awsvpc 모드에서는 hostPort와 containerPort 동일하게 설정
          protocol      = "tcp"
        }
      ]
      # 환경 변수 설정
      environment = [
        # Kibana가 연결할 Elasticsearch 주소 설정
        # 중요: "<elasticsearch_endpoint>:9200" 부분은 나중에 생성될
        # Elasticsearch ECS Service의 엔드포인트(예: 내부 DNS 이름 또는 로드 밸런서 주소)로 변경해야 합니다.
        { name = "ELASTICSEARCH_HOSTS", value = "[\"http://${aws_lb.elasticsearch_lb.dns_name}:9200\"]" }
      ]
      # 로그 설정 (예: CloudWatch Logs)
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/kibana-task"      # CloudWatch Log Group 이름
          "awslogs-region"        = "ap-northeast-2"     # CloudWatch Logs 리전
          "awslogs-stream-prefix" = "kibana"                # 로그 스트림 접두사
        }
      }
      # Kibana는 일반적으로 상태를 저장하지 않으므로 볼륨 마운트 불필요
    }
  ])

  # 태그 설정 (선택 사항)
  tags = {
    Name        = "KibanaTaskDefinition"
    Environment = "Development"
    Project     = "LogMonitoring"
  }
  depends_on = [ aws_lb.elasticsearch_lb ]
}

# (선택 사항) 생성된 Task Definition ARN 출력
output "kibana_task_definition_arn" {
  description = "생성된 Kibana Task Definition의 ARN"
  value       = aws_ecs_task_definition.kibana_task.arn
}
