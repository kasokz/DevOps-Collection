kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans 10.98.0.2 # Internal IP
rm -rf ~/.kube
mkdir -p ~/.kube
cp -i /etc/kubernetes/admin.conf ~/.kube/config
chown 1000:1000 ~/.kube/config
export KUBECONFIG=~/.kube/config
