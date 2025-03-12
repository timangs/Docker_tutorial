FROM python:3.12

WORKDIR /usr/src/app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

WORKDIR /usr/src/app/web

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--timeout", "60", "--workers", "2", "--worker-class", "gevent","web.wsgi:application"]

# docker build -t docker-ubuntu:django ./Python
# docker run -it -p 8080:8080 --name instance01 test:test
#docker cp instance01:/usr/src/app/requirements.txt ./requirements.txt
