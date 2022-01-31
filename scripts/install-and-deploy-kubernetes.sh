#!/bin/bash

# TOOD: perhaps parameters
ARCH="amd64"
CNI_VERSION="v0.8.2"
CNI_DIR="/opt/cni/bin"
CRICTL_VERSION="v1.23.0"
CRICTL_DIR="/opt/cri/$CRICTL_VERSION/bin"
KUBERNETES_VERSION="v1.23.3"
KUBERNETES_DIR="/opt/kubernetes/$KUBERNETES_VERSION"

# Install [CNI](https://www.cni.dev/)

sudo mkdir -p $CNI_DIR
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz" | sudo tar -C $CNI_DIR -xz

# Install [CRI](https://kubernetes.io/docs/concepts/architecture/cri/)

sudo mkdir -p $CRICTL_DIR
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $CRICTL_DIR -xz

# Install Kube components

sudo mkdir -p $KUBERNETES_DIR
cd $KUBERNETES_DIR
for component in kubeadm kubectl kubelet; do
  sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/$ARCH/$component
  sudo chmod +x $component
done

# Create symlinks
sudo update-alternatives --install /usr/bin/kubeadm kubeadm $KUBERNETES_DIR/kubeadm 100
sudo update-alternatives --install /usr/bin/kubelet kubelet $KUBERNETES_DIR/kubelet 100
sudo update-alternatives --install /usr/bin/kubectl kubectl $KUBERNETES_DIR/kubectl 100

# Create services, configure, enable and start them

RELEASE_VERSION="v0.4.0"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${KUBERNETES_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${KUBERNETES_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl enable --now kubelet

# Install kubeadm dependencies

sudo apt-get update
sudo apt-get install ethtool socat conntrack

