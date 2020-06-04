# Hetzner Cloud Controller Manager (Adjust placeholders!)
kubectl apply -f ./setup/hcloud-controller-manager.yaml

# Pod Network Add-On
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl -n kube-system patch daemonset kube-flannel-ds-amd64 --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'
kubectl -n kube-system patch deployment coredns --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'

# Untaint master nodes
kubectl taint nodes --all node-role.kubernetes.io/master-

# Hetzner CSI
kubectl apply -f ./setup/csi.yaml

# Loadbalancer using metallb + floating IPs
kubectl create namespace metallb
helm install metallb stable/metallb --namespace metallb
kubectl apply -f ./setup/metallb.yaml

# Floating IP failover
kubectl create namespace fip-controller
kubectl apply -f https://raw.githubusercontent.com/cbeneke/hcloud-fip-controller/master/deploy/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/cbeneke/hcloud-fip-controller/master/deploy/deployment.yaml
kubectl apply -f ./setup/fip.yaml

# Metrics server
helm install metrics-server stable/metrics-server --namespace kube-system --values ./metrics-server/values.yaml

# Dashboard
kubectl create ns kubernetes-dashboard
helm install dashboard kubernetes-dashboard/kubernetes-dashboard --namespace kubernetes-dashboard --values ./dashboard/values.yaml

# Ingress
helm repo add nginx https://helm.nginx.com/stable
kubectl create namespace ingress
helm install ingress stable/nginx-ingress --namespace ingress --values ./ingress-controller/values.yaml
# Let's Encrypt for Ingresses
helm repo add jetstack https://charts.jetstack.io
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml
sleep 5
kubectl label namespace ingress certmanager.k8s.io/disable-validation=true
helm install cert-manager jetstack/cert-manager --namespace ingress
sleep 5
kubectl apply -f ./ingress-controller/cert-manager

# Prometheus
helm install --namespace monitoring --name prometheus-operator --values ./monitoring/prometheus-operator/values.yaml stable/prometheus-operator

# Gitlab-Runner
helm install gitlab-runner gitlab/gitlab-runner -f ./gitlab-runner/values.yaml --set runnerRegistrationToken="<TOKEN>" -n loaddriver