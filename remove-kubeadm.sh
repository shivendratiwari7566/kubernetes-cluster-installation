sudo kubeadm reset
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config
sudo apt remove kubeadm
sudo apt remove kubelet
sudo apt remove kubectl
