# --- 인터페이스 엔드포인트용 보안 그룹 생성 ---
# ECR API, ECR DKR 인터페이스 엔드포인트에 적용될 보안 그룹
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-sg"
  description = "Security group for VPC interface endpoints (ECR)"
  vpc_id      = var.vpc_id # VPC ID 변수 참조

  # ECS Task 보안 그룹으로부터 HTTPS(443) 인바운드 트래픽 허용
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    # 이전에 정의한 ECS Task 보안 그룹 ID를 참조합니다.
    security_groups = [aws_security_group.ecs_task_sg.id] # ecs_task_sg 리소스 참조
  }

  # 아웃바운드는 기본적으로 모두 허용 (필요시 제한)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "VPCEndpointSecurityGroup"
    Project = "LogMonitoring"
  }
}

# --- S3 Gateway Endpoint 생성 ---
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = var.vpc_id # VPC ID 변수 참조
  service_name      = "com.amazonaws.${var.region}.s3" # 현재 리전의 S3 서비스 이름 사용
  vpc_endpoint_type = "Gateway"

  # 이 엔드포인트를 사용할 라우팅 테이블 ID 목록 지정
  # ECS Task가 실행되는 Private 서브넷들이 사용하는 라우팅 테이블 ID를 지정해야 합니다.
  # route_table_ids = ["<your_private_route_table_id_1>", "<your_private_route_table_id_2>"] # 실제 라우팅 테이블 ID 목록으로 변경 필요
  # 또는 변수 사용:
  route_table_ids = var.private_route_table_ids # Private 라우팅 테이블 ID 목록 변수 참조

  tags = {
    Name    = "S3GatewayEndpoint"
    Project = "LogMonitoring"
  }
}

# --- ECR API Interface Endpoint 생성 ---
resource "aws_vpc_endpoint" "ecr_api_endpoint" {
  vpc_id              = var.vpc_id # VPC ID 변수 참조
  service_name        = "com.amazonaws.${var.region}.ecr.api" # 현재 리전의 ECR API 서비스 이름 사용
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true                    # 프라이빗 DNS 이름 사용 활성화

  # 엔드포인트 네트워크 인터페이스가 생성될 서브넷 ID 목록
  # ECS Task가 실행되는 서브넷과 동일하거나 통신 가능한 서브넷 지정
  subnet_ids          = var.subnets # 서브넷 ID 목록 변수 참조

  # 엔드포인트 네트워크 인터페이스에 적용할 보안 그룹 ID 목록
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id] # 위에서 생성한 엔드포인트 보안 그룹 참조

  tags = {
    Name    = "ECR-API-InterfaceEndpoint"
    Project = "LogMonitoring"
  }
}

# --- ECR DKR Interface Endpoint 생성 ---
resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
  vpc_id              = var.vpc_id # VPC ID 변수 참조
  service_name        = "com.amazonaws.${var.region}.ecr.dkr" # 현재 리전의 ECR DKR 서비스 이름 사용
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true                    # 프라이빗 DNS 이름 사용 활성화

  # 엔드포인트 네트워크 인터페이스가 생성될 서브넷 ID 목록
  # ECS Task가 실행되는 서브넷과 동일하거나 통신 가능한 서브넷 지정
  subnet_ids          = var.subnets # 서브넷 ID 목록 변수 참조

  # 엔드포인트 네트워크 인터페이스에 적용할 보안 그룹 ID 목록
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id] # 위에서 생성한 엔드포인트 보안 그룹 참조

  tags = {
    Name    = "ECR-DKR-InterfaceEndpoint"
    Project = "LogMonitoring"
  }
}