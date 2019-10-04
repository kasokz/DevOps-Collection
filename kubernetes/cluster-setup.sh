# Pod Network Add-On
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Init helm
kubectl apply -f ./helm
helm init --service-account tiller --upgrade

# Metrics server
helm install --name metrics-server --namespace kube-system --values ./metrics-server/values.yaml stable/metrics-server

# Dashboard
helm install --name dashboard --namespace kube-system --values ./dashboard/values.yaml stable/kubernetes-dashboard
kubectl apply -f ./dashboard/user.yaml

# Ingress
helm install --name ingress --values ./ingress-controller/values.yaml --namespace ingress-controller stable/nginx-ingress

# Let's Encrypt for Ingresses
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.10.1/cert-manager.yaml
sleep 5
kubectl label namespace ingress-controller certmanager.k8s.io/disable-validation=true
helm install --name cert-manager --namespace ingress-controller jetstack/cert-manager --version v0.10.1
sleep 5
kubectl apply -f ./ingress-controller/cert-manager

# Prometheus
helm install --namespace monitoring --name prometheus-operator --values ./monitoring/prometheus-operator/values.yaml stable/prometheus-operator