## 🚀 Implement DevOps Workflows in Google Cloud: Challenge Lab | [GCP330](https://www.cloudskillsboost.google/catalog_lab/2889)

## 🌐 **Guide to Complete the Challenge Lab:**
gcloud container clusters create hello-cluster \
--zone us-east1-c \
--release-channel regular \
--cluster-version 1.29 \
--enable-autoscaling \
--num-nodes 3 \
--min-nodes 2 \
--max-nodes 6 \
--enable-ip-alias

kubectl create namespace prod
kubectl create namespace dev

gcloud container clusters get-credentials hello-cluster --zone us-east1-c --project qwiklabs-gcp-03-8c9d0209dade

kubectl expose deployment development-deployment --namespace=dev \
--name=dev-deployment-service --type=LoadBalancer \
--port=8080 --target-port=8080

kubectl get service dev-deployment-service --namespace=dev

kubectl expose deployment production-deployment --namespace=prod \
--name=prod-deployment-service --type=LoadBalancer \
--port=8080 --target-port=8080

kubectl get service prod-deployment-service --namespace=prod
