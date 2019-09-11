#!/bin/bash

apt-get update && apt-get install curl python3 python3-pip apt-transport-https ca-certificates software-properties-common -y && curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh && usermod -aG docker "$USER" && pip3 install docker-compose && chmod +x volumes/factomd/bootstrap.sh