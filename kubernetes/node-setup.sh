#!/bin/bash
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
apt-get update

mkdir /etc/systemd/system/kubelet.service.d

# Default kubelet config
cat <<EOF >/etc/systemd/system/kubelet.service.d/20-hetzner-cloud.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--cloud-provider=external"
EOF

# For static CPU Manager Policy
# cat <<EOF >/etc/systemd/system/kubelet.service.d/20-hetzner-cloud.conf
# [Service]
# Environment="KUBELET_EXTRA_ARGS=--cloud-provider=external --cpu-manager-policy=static --kube-reserved=cpu=100m,memory=1Gi,ephemeral-storage=1Gi --system-reserved=cpu=100m,memory=1Gi,ephemeral-storage=1Gi"
# EOF

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg >> /etc/apt/trusted.gpg.d/kubernetes.gpg
cat <<EOF >/etc/apt/sources.list.d/docker-and-kubernetes.list
        deb http://packages.cloud.google.com/apt/ kubernetes-xenial main
EOF
apt-get update &&
        apt-get install -y containerd kubelet=1.27.0-00 kubeadm=1.27.0-00 kubectl=1.27.0-00 &&
        apt-mark hold containerd kubelet kubeadm kubectl

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i '/SystemdCgroup /s/=.*$/= true/' /etc/containerd/config.toml
systemctl restart containerd

cat <<EOF >>/etc/sysctl.conf
# Allow IP forwarding for kubernetes
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
EOF
sysctl -p

cat << EOF >> /etc/crictl.yaml
runtime-endpoint: "unix:///run/containerd/containerd.sock"
image-endpoint: "unix:///run/containerd/containerd.sock"
EOF