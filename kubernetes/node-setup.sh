#!/bin/bash
swapoff -a
apt-get update

mkdir /etc/systemd/system/kubelet.service.d
cat <<EOF >/etc/systemd/system/kubelet.service.d/20-hetzner-cloud.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--cloud-provider=external"
EOF

# For static CPU Manager Policy
# mkdir /etc/systemd/system/kubelet.service.d
# cat <<EOF >/etc/systemd/system/kubelet.service.d/20-hetzner-cloud.conf
# [Service]
# Environment="KUBELET_EXTRA_ARGS=--cloud-provider=external --cpu-manager-policy=static --kube-reserved=cpu=100m,memory=1Gi,ephemeral-storage=1Gi --system-reserved=cpu=100m,memory=1Gi,ephemeral-storage=1Gi"
# EOF

mkdir /etc/systemd/system/docker.service.d
cat <<EOF >/etc/systemd/system/docker.service.d/00-cgroup-systemd.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd
EOF
systemctl daemon-reload

apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/docker-and-kubernetes.list
        deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
        deb http://packages.cloud.google.com/apt/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y docker-ce kubelet=1.17.3-00 kubeadm=1.17.3-00 kubectl=1.17.3-00
apt-mark hold docker-ce kubelet kubeadm kubectl

cat <<EOF >>/etc/sysctl.conf
# Allow IP forwarding for kubernetes
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
EOF
sysctl -p