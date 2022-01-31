#!/bin/bash

ip_address="$(ip address show eth0 | grep 'inet ' | tr -s ' ' | cut -d ' ' -f 3 | cut -d '/' -f 1)"

sudo kubeadm init --pod-network-cidr 10.10.0.0/16 --apiserver-advertise-address $ip_address

mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr     -d '\n')"
