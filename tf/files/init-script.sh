#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo docker run -d --name nginx -p 80:80 nginx