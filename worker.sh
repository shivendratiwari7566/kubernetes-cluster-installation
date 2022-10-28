#!/bin/bash
set -x
sudo which docker
if   [ $? -eq 0 ]
then
  echo "Docker is already installed...."
else
  echo "Docker is not available, So going to install latest "
  sudo apt-get update
  sudo apt-get install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo systemctl enable docker
  sudo systemctl start docker
  echo "Docker has installed successfully............."
fi
# installing kubernetes
sudo kubeadm version
if   [ $? -eq 0 ]
then
  echo "kubernetes is already installed Thank You"
else
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
  sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
  #sudo apt install -y kubeadm=1.18.13-00 kubelet=1.18.13-00 kubectl=1.18.13-00
  sudo apt-get install kubeadm kubelet kubectl
  sudo apt-mark hold kubeadm kubelet kubectl
  kubeadm version
  sudo rm /etc/containerd/config.toml
  systemctl restart containerd
  sudo touch /etc/docker/daemon.json
  sudo cat << EOF >> /etc/docker/daemon.json
  {
                "exec-opts": ["native.cgroupdriver=systemd"]
  }
EOF
fi
