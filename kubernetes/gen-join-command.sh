# Use on Master Node to generate join command to be used on new nodes
echo "kubeadm join --token $(kubeadm token create) $(hostname -I | awk '{print $1;}'):6443 --discovery-token-ca-cert-hash sha256:$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //')"