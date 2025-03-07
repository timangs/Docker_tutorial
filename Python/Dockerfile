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


COPY . .

RUN python3 -m pip install Django && \
    django-admin startproject web && \
    pip install gunicorn 

WORKDIR /usr/src/app/web

# COPY requirements.txt ./
# RUN pip install -r requirements.txt

EXPOSE 8080/tcp 
ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8080", "web.wsgi:application"]


# docker build -t docker-ubuntu:django ./Python
# docker run -it -p 8088:8088 --name instance01 ubunut-django:1.0