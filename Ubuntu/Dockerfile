# Dockerfile

# Ubuntu 최신 LTS 버전 이미지를 기반으로 합니다.
FROM ubuntu:latest

# (선택 사항) 컨테이너 내에서 사용할 사용자 정의 명령어를 실행합니다.
# 예시: apt 패키지 목록 업데이트 및 몇 가지 유틸리티 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        vim \
    && rm -rf /var/lib/apt/lists/*

# (선택 사항) 컨테이너 시작 시 실행할 명령어 (기본 셸을 사용하려면 생략 가능)
CMD ["/bin/bash"]

# docker build -t docker-ubuntu:lastest /Ubuntu