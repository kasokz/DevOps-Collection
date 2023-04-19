# Single Node Control Plane Cluster
kubeadm init --pod-network-cidr=10.244.0.0/16
# HA Control Plane Cluster <LOAD_BALANCER_IP:PORT> must point to a loadbalancer targeting all control plane nodes
kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint <LOAD_BALANCER_IP:PORT>
rm -rf ~/.kube
mkdir -p ~/.kube
cp -i /etc/kubernetes/admin.conf ~/.kube/config
chown 1000:1000 ~/.kube/config
export KUBECONFIG=~/.kube/config
