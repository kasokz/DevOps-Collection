kubectl create ns minio
helm repo add minio https://helm.min.io/
helm repo update
helm install minio minio/minio --values ./values.yaml -n minio