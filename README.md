# Docker Command

## 정보 조회 기능

### docker images

> Docker에 설치되어 있는 Images를 확인

```
# docker images
REPOSITORY      TAG       IMAGE ID       CREATED          SIZE  
ubunut-django   1.0       e71fbe615aa3   22 minutes ago   1.05GB
```

### docker ps -a

> Docker에 모든 컨테이너를 조회<br>
> -a 옵션을 제거하면 실행 중인 컨테이너만 조회

```
CONTAINER ID   IMAGE                   COMMAND       CREATED          STATUS                      PORTS     NAMES
0a60b768bb40   docker-ubuntu:latest   "/bin/bash"   52 minutes ago   Exited (0) 14 minutes ago             docker-ubuntu-instance1
```

## Docker Image 빌드

### docker build -t ubunut-django:1.0 ./Python

> /Python 디렉터리안에 있는 Dockerfile에 따라 Docker Image를 생성<br>
> -t 옵션은 tag로 <REPOSITORY>:<TAG> 형식으로 이미지를 생성

```
[+] Building 10.4s (12/12) FINISHED                                                                                                                                                                        docker:desktop-linux 
 => [internal] load build definition from Dockerfile                                                                                                                                                                       0.0s 
 => => transferring dockerfile: 743B                                                                                                                                                                                       0.0s 
 => [internal] load metadata for docker.io/library/ubuntu:24.04                                                                                                                                                            1.4s 
 => [auth] library/ubuntu:pull token for registry-1.docker.io                                                                                                                                                              0.0s 
 => [internal] load .dockerignore                                                                                                                                                                                          0.0s 
 => [1/6] FROM docker.io/library/ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782                                                                                                      0.0s 
 => => resolve docker.io/library/ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782                                                                                                      0.0s 
 => => transferring context: 778B                                                                                                                                                                                          0.0s 
 => CACHED [2/6] WORKDIR /usr/src/app                                                                                                                                                                                      0.0s 
 => CACHED [3/6] RUN apt-get update &&     apt-get install -y --no-install-recommends &&     apt-get install -y python3.12-full &&     apt-get install -y python3-pip &&     python3 -m venv venv &&     rm -rf /var/lib/  0.0s 
 => [5/6] RUN python3 -m pip install Django &&     django-admin startproject web &&     pip install gunicorn                                                                                                               3.8s 
 => [6/6] WORKDIR /usr/src/app/web                                                                                                                                                                                         0.1s 
 => exporting to image                                                                                                                                                                                                     5.0s 
 => => exporting layers                                                                                                                                                                                                    1.2s 
 => => exporting manifest sha256:445c6d46db58c83657dd8be9b1330a3e2ff3af8221ad579d655225b2d9a51b04                                                                                                                          0.0s 
 => => exporting config sha256:c14c75b618adae3e9ee81553842c41afd254707603e212e285fb84ac6b4e6a95                                                                                                                            0.0s 
 => => exporting attestation manifest sha256:8fff300f109d6d07f710d1a54e4de2f2ab8c227b0c0ab73147d3f393c6776b85                                                                                                              0.0s 
 => => exporting manifest list sha256:e71fbe615aa35f644fc12d500b64d94f7a3f7108d34a6d3ed9ace52457554d79                                                                                                                     0.0s 
 => => unpacking to docker.io/library/ubunut-django:1.0                                                       
```

### docker run -it -p 8080:8080 --name instance01 ubunut-django:1.0

> **docker run** 실행<br>
> **-it** --interactive --tty로 대화형 쉘로 실행 / -d (--detach)일 경우 백그라운드로 실행<br>
> **--name ${NAMES}** 컨테이너의 NAMES을 설정<br>
> **ubunut-django:1.0** <Docker-Image>:<Tag> 로 컨테이너로 생성될 이미지를 선택

```
[2025-03-07 06:36:06 +0000] [1] [INFO] Starting gunicorn 23.0.0
[2025-03-07 06:36:06 +0000] [1] [INFO] Listening at: http://0.0.0.0:8080 (1)
[2025-03-07 06:36:06 +0000] [1] [INFO] Using worker: sync
[2025-03-07 06:36:06 +0000] [7] [INFO] Booting worker with pid: 7
```
