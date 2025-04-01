# EC2 인스턴스 리소스 정의
resource "aws_instance" "docker" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "Instance-key" # 실제 사용하는 키 이름으로 변경하세요.
  # iam_instance_profile      = data.aws_iam_instance_profile.ec2_admin_profile.name # 필요시 주석 해제

  tags = {
    Name = "docker"
  }

  # user_data 설정: Base64 인코딩 사용
  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    # 파일 내용을 Base64로 인코딩하여 전달
    docker_compose_b64 = base64encode(file("${path.module}/docker-compose.yml"))
  })

  user_data_replace_on_change = true
}

output "aws_instance_docker_instance_id" {
  value = aws_instance.docker.id
}
output "aws_instance_docker_public_ip" {
  value = aws_instance.docker.public_ip
}