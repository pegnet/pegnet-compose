#!/bin/bash

user=${SUDO_USER:-$(whoami)}
apt-get update && apt-get install curl python3 python3-pip apt-transport-https ca-certificates software-properties-common -y && curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh && usermod -aG docker "$user" && pip3 install docker-compose