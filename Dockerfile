FROM public.ecr.aws/lambda/python:3.13

RUN yum -y update && yum -y install libjpeg-turbo-devel zlib-devel

WORKDIR /opt

RUN python3 -m pip install --target=/opt/python Pillow