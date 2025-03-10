FROM ubuntu:24.04
# FROM ubuntu:lastest

WORKDIR /usr/src/app

RUN apt-get update && \
    apt-get install -y --no-install-recommends && \
    apt-get install -y python3.12-full && \
    apt-get install -y python3-pip && \
    python3 -m venv venv && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/src/app/venv/bin:$PATH"

# RUN python3 -m pip install Django && \
#     pip install gunicorn && \
#     pip freeze > requirements.txt 
# requirements.txt 파일 생성

COPY . .
RUN pip install -r requirements.txt


WORKDIR /usr/src/app/web

EXPOSE 8080/tcp 
# ENTRYPOINT [ "/bin/bash" ]
ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8080", "web.wsgi:application"]

# docker build -t docker-ubuntu:django ./Python
# docker run -it -p 8080:8080 --name instance01 test:test
#docker cp instance01:/usr/src/app/requirements.txt ./requirements.txt
