# Pod Network Add-On
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

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
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
sleep 5
kubectl label namespace ingress-controller certmanager.k8s.io/disable-validation=true
helm install --name cert-manager --namespace ingress-controller stable/cert-manager
sleep 5
kubectl apply -f ./ingress-controller/cert-manager

# Prometheus
helm install --namespace monitoring --name prometheus-operator --values ./monitoring/prometheus-operator/values.yaml stable/prometheus-operator