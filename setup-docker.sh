#!/bin/sh

if [ ! -d /var/lib/docker ]; then sudo mkdir /var/lib/docker; fi
sudo mount /dev/sdb /var/lib/docker
curl -fsSL https://get.docker.com/ | sudo sh
sudo usermod -aG docker centos
sudo systemctl enable docker
sudo systemctl start docker
sudo pip3 install docker-compose
