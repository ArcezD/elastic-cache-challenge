## base image
FROM python:3.9.2-alpine

## install dependencies
RUN apk update && \
    apk add --virtual build-deps gcc python3-dev musl-dev && \
    apk add postgresql-dev

## set environment variables

## set working directory
WORKDIR /usr/src/app

## add user
RUN adduser -D acg
RUN chown -R acg:acg /usr/src/app && chmod -R 755 /usr/src/app

## add and install requirements
RUN pip install --upgrade pip
COPY ./requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

## switch to non-root user
USER acg

## add app
COPY . /usr/src/app

## run server
CMD python app.py run -h 0.0.0.0
