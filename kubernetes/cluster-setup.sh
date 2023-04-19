helm repo add stable https://charts.helm.sh/stable

# Hetzner Cloud Controller Manager (Adjust placeholders!)
kubectl apply -f ./setup/hcloud-controller-manager-secrets.yaml
helm repo add hcloud https://charts.hetzner.cloud
helm repo update hcloud
helm upgrade --install hccm hcloud/hcloud-cloud-controller-manager -n kube-system

# Hetzner CSI
kubectl apply -f https://raw.githubusercontent.com/hetznercloud/csi-driver/v2.2.0/deploy/kubernetes/hcloud-csi.yml

# Pod Network Add-On
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl -n kube-system patch deployment coredns --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'

# Untaint master nodes if workload should run on them (be careful of resource pressure)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl label nodes --all node.kubernetes.io/exclude-from-external-load-balancers-

# Metrics server
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server --namespace kube-system --values ./metrics-server/values.yaml

# Dashboard
kubectl create ns kubernetes-dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install dashboard kubernetes-dashboard/kubernetes-dashboard --namespace kubernetes-dashboard --values ./dashboard/values.yaml --create-namespace

# Ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create namespace ingress
helm upgrade --install ingress ingress-nginx/ingress-nginx --namespace ingress --values ./ingress-controller/values.yaml
# Let's Encrypt for Ingresses
helm repo add jetstack https://charts.jetstack.io
sleep 5
kubectl label namespace ingress certmanager.k8s.io/disable-validation=true
helm upgrade --install cert-manager jetstack/cert-manager --namespace ingress --set installCRDs=true
sleep 5
kubectl apply -f ./ingress-controller/cert-manager

# Prometheus
helm upgrade --install prometheus-operator stable/prometheus-operator --namespace monitoring --values ./monitoring/prometheus-operator/values.yaml

# Gitlab-Runner
helm upgrade --install gitlab-runner gitlab/gitlab-runner -f ./gitlab-runner/values.yaml --set runnerRegistrationToken="<TOKEN>" -n gitlab-resources