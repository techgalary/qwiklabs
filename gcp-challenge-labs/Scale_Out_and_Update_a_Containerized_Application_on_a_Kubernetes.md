
# Scale Out and Update a Containerized Application on a Kubernetes Cluster: Challenge Lab || [GSP305](https://www.cloudskillsboost.google/focuses/1739?parent=catalog) ||

## Solution [here](https://youtu.be/VHD75dXGk5w)
### Set Env Variables ###
``` bash
export ZONE=us-east4-b
export REGION=us-east4
export PROJECT_ID=qwiklabs-gcp-03-5b9b5f7956d3
export CLUSTER_NAME=echo-cluster
```
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
docker tag echo-app:v2 gcr.io/${PROJECT_ID}/echo-app:v2
```
### Task 2. Push the image to the Container Registry ###
```
docker push gcr.io/${PROJECT_ID}/echo-app:v2
```
### Task 3: Deploy the Updated Application to the Kubernetes Cluster ###
```
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE
```
#### Deploy the updated application onto Cluster ####
#### Update the Deployment's image ####
```
kubectl set image deployment/echo-web echo-app=gcr.io/$PROJECT_ID/echo-app:v2

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


