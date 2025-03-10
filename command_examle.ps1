
docker build -t docker-ubuntu:django ./Python
docker run -it -p 8088:8088 --name instance01 ubunut-django:1.0
docker cp <names>:/path/requirements.txt ./requirements.txt
docker start [<contaniner_id>|<image>]
docker exec -it [<contaniner_id>|<image>] /bin/bash


docker images
docker ps
docker ps -a



docker rmi [<imageid>|<repository:tag>]
docker rm 