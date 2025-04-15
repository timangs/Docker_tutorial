# main.tf (또는 cluster.tf 등 원하는 파일명 사용)

# --- AWS Provider 설정 ---
# (이미 다른 파일에 provider 설정이 있다면 이 부분은 생략 가능합니다.)
provider "aws" {
  region = "ap-northeast-2" # 사용하려는 AWS 리전 설정
  # AWS 자격증명은 환경 변수, ~/.aws/credentials 파일 등을 통해 설정하는 것을 권장합니다.
}

# --- ECS 클러스터 리소스 정의 ---
resource "aws_ecs_cluster" "integration_log_cluster" {
  # 클러스터 이름 설정
  name = "integration-log-cluster" # 원하는 클러스터 이름으로 변경 가능

  # (선택 사항) 클러스터 설정 추가
  # 예: CloudWatch Container Insights 활성화
  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }

  # 태그 설정 (선택 사항)
  tags = {
    Name        = "IntegrationLogCluster"
    Environment = "Development" # 또는 Production 등 환경에 맞게 설정
    Project     = "LogMonitoring"
  }
}

# (선택 사항) 생성된 클러스터 이름 출력
output "ecs_cluster_name" {
  description = "생성된 ECS 클러스터의 이름"
  value       = aws_ecs_cluster.integration_log_cluster.name
}

