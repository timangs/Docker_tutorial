# load_balancer.tf (또는 원하는 파일명 사용)

# --- 내부 ALB 용 보안 그룹 생성 ---
resource "aws_security_group" "elasticsearch_lb_sg" {
  name        = "elasticsearch-lb-sg"
  description = "Security group for internal Elasticsearch ALB"
  vpc_id      = var.vpc_id # 실제 사용 중인 VPC ID로 변경 필요

  # 예시: VPC 내부에서 오는 9200 포트 트래픽 허용
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks] # VPC CIDR 블록으로 변경 또는 특정 보안 그룹 ID 사용
    # 또는 Kibana 서비스가 사용할 보안 그룹 ID를 지정할 수 있습니다.
    # security_groups = [aws_security_group.kibana_sg.id]
  }

  # 아웃바운드는 기본적으로 모두 허용 (필요시 제한)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ElasticsearchLBSecurityGroup"
    Project = "LogMonitoring"
  }
}

# --- 내부 Application Load Balancer (ALB) 생성 ---
resource "aws_lb" "elasticsearch_lb" {
  name               = "elasticsearch-internal-lb" # 원하는 LB 이름으로 변경 가능
  internal           = true # 내부 로드 밸런서로 설정
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elasticsearch_lb_sg.id] # 위에서 생성한 보안 그룹 연결

  # 로드 밸런서가 위치할 서브넷 ID 목록 (Private 서브넷 권장)
  subnets            = var.subnets # 실제 서브넷 ID 목록으로 변경 필요 (최소 2개 AZ의 서브넷)

  # (선택 사항) 유휴 제한 시간 등 추가 설정
  # idle_timeout               = 60
  # enable_deletion_protection = false

  tags = {
    Name    = "ElasticsearchInternalLB"
    Project = "LogMonitoring"
  }
}

# --- ALB 대상 그룹 (Target Group) 생성 ---
# Elasticsearch Task들이 등록될 대상 그룹
resource "aws_lb_target_group" "elasticsearch_tg" {
  name        = "elasticsearch-tg" # 원하는 대상 그룹 이름으로 변경 가능
  port        = 9200             # Elasticsearch 컨테이너 포트
  protocol    = "HTTP"
  vpc_id      = var.vpc_id  # 실제 사용 중인 VPC ID로 변경 필요
  target_type = "ip"             # awsvpc 네트워크 모드 사용 시 'ip'

  # 상태 확인 설정
  health_check {
    enabled             = true
    interval            = 30    # 상태 확인 간격 (초)
    path                = "/"   # Elasticsearch 루트 경로 확인 (또는 _cluster/health)
    port                = "traffic-port" # 대상 포트(9200) 사용
    protocol            = "HTTP"
    timeout             = 5     # 응답 대기 시간 (초)
    healthy_threshold   = 3     # 정상 판단 횟수
    unhealthy_threshold = 3     # 비정상 판단 횟수
    matcher             = "200" # HTTP 응답 코드 200이면 정상
  }

  tags = {
    Name    = "ElasticsearchTargetGroup"
    Project = "LogMonitoring"
  }
}

# --- ALB 리스너 (Listener) 생성 ---
# 로드 밸런서의 9200 포트로 들어오는 요청을 대상 그룹으로 전달
resource "aws_lb_listener" "elasticsearch_listener" {
  load_balancer_arn = aws_lb.elasticsearch_lb.arn # 위에서 생성한 LB ARN 참조
  port              = 9200                      # 리스너 포트
  protocol          = "HTTP"

  # 기본 동작: 요청을 Elasticsearch 대상 그룹으로 전달
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elasticsearch_tg.arn # 위에서 생성한 대상 그룹 ARN 참조
  }
}

# (선택 사항) 생성된 로드 밸런서의 DNS 이름 출력
output "elasticsearch_lb_dns_name" {
  description = "생성된 내부 ALB의 DNS 이름"
  value       = aws_lb.elasticsearch_lb.dns_name
}

output "elasticsearch_target_group_arn" {
  description = "생성된 Elasticsearch 대상 그룹의 ARN"
  value       = aws_lb_target_group.elasticsearch_tg.arn
}
