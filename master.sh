#!/bin/bash
set -x
for host in $(cat worker-servers.txt)
do
  scp /home/vagrant/scripts/worker.sh vagrant@$host:/tmp/
  ssh vagrant@$host "sh /tmp/worker.sh"
   if  [ $? -eq 0 ]
   then
     echo "worker.sh successfully completed  on the worker server" $host
   else
     echo "Sorry not able to connect with workers " $host
   fi
done

sudo which docker ; "sudo chmod -R 777 /var/run/docker.sock" ; sudo docker version 
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
  #sudo -i
  #swapoff -a && sed -i '/ swap / s/^/#/' /etc/fstab
  #exit
  sudo rm /etc/containerd/config.toml
  systemctl restart containerd
  #sudo touch /etc/docker/daemon.json
  sudo cat << EOF >> /etc/docker/daemon.json
  {
                "exec-opts": ["native.cgroupdriver=systemd"]
  }
EOF
  #sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | tail -2 > updated-tocken.txt
  sudo kubeadm init --apiserver-advertise-address=192.168.33.11 --pod-network-cidr=192.168.0.0/16 | tail -2 > tocken.sh
  #sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | tail -2 > tocken.sh
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml
  sleep 30
  kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml
  sleep 250
  kubectl get pod -A 

 # kubectl taint nodes --all node-role.kubernetes.io/control-plane-
 ########## joining to workers############
 echo "joining to workers..........."


 for host in $(cat worker-servers.txt)
 do
   scp /home/vagrant/scripts/tocken.sh vagrant@$host:/tmp/
   ssh vagrant@$host "sudo sh /tmp/tocken.sh"
     if  [ $? -eq 0 ]
     then
       echo "worker.sh successfully completed  on the worker server" $host
     else
       echo "Sorry not able to connect with worker"  $host
     fi
  done 




  kubectl get nodes
  echo "kubernetes installed successfully....Injoy"
fi
