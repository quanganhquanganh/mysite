# Django Docker image

FROM python:3.7.3-stretch

# Install Django ~3.1
RUN pip install django==3.1

WORKDIR /code

# Copy the current directory into the container
ADD . /code/

EXPOSE 8000
