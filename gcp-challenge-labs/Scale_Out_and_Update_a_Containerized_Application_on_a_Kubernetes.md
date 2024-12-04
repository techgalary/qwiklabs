# Scale Out and Update a Containerized Application on a Kubernetes Cluster: Challenge Lab || [GSP305](https://www.cloudskillsboost.google/focuses/1739?parent=catalog) ||

## Solution [here]()
### Task 1. Build and deploy the updated application with a new tag ###
```
gsutil cp gs://$DEVSHELL_PROJECT_ID/echo-web-v2.tar.gz .
tar -xzvf echo-web-v2.tar.gz
```
#### Build the docker image ####
```
docker build -t echo-app:v2 .
```
#### Tag the Image ####
```
docker tag echo-app:v2 gcr.io/<PROJECT_ID>/echo-app:v2
```
### Task 2. Push the image to the Container Registry ###
```
docker push gcr.io/<PROJECT_ID>/echo-app:v2
```
### Task 3: Deploy the Updated Application to the Kubernetes Cluster ###
```
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE
```
#### Deploy the updated application onto Cluster ####
#### Update the Deployment's image ####
```
kubectl set image deployment/echo-web echo-app=gcr.io/qwiklabs-gcp-00-521447a77276/echo-app:v2

```
#### Expose the deployment ####
```
kubectl expose deployment echo-web --type=LoadBalancer --port=80 --target-port=80
```
### Task 4. Scale out the application ###
```
kubectl scale deployment echo-web --replicas=2
```
### Task 5: Confirm the Application is Running ###
```
kubectl get services
```
```
curl http://<EXTERNAL-IP>
```


