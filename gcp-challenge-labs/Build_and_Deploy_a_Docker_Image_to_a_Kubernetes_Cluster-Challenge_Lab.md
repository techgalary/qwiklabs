# Build and Deploy a Docker Image to a Kubernetes Cluster: Challenge Lab || [GSP304](https://www.cloudskillsboost.google/focuses/1738?parent=catalog) ||

## Solution [here]()


### Task 1. Create a Kubernetes cluster ###

#### Set Environment Variables ###
```
export REGION=
export ZONE=
export PROJECT_ID=
```

#### Create Cluster ####
```
gcloud container clusters create echo-cluster \
    --num-nodes=1 \
    --region=$REGION \
    --machine-type=e2-standard-2 \
    --enable-ip-alias

```
```
gcloud container clusters list
```

### Task 2. Build a tagged Docker image ###
#### Download the archive file from the Cloud Storage Bucket ####
``
gsutil cp gs://${PROJECT_ID}/echo-web.tar.gz .
``
#### Extract the Archive ####
```
tar -xvzf echo-web.tar.gz
cd echo-web
```
#### Build the Docker image ####
```
docker build -t gcr.io/[PROJECT_ID]/echo-web:v1 .
```
```
docker images
```
```
docker tag echo-web:v1 gcr.io/[PROJECT_ID]/echo-web:v1
```
### Task 3. Push the image to the Google Container Registry ###
```
docker push gcr.io/[PROJECT_ID]/echo-web:v1
```
#### Verifying if image is uploaded to GCR ####
```
gcloud container images list --repository=gcr.io/[PROJECT_ID]
```
### Task 4. Deploy the application to the Kubernetes cluster ###

#### Create the deployment ####
```
kubectl create deployment echo-app --image=gcr.io/${PROJECT_ID}/echo-app:v1
```
```
gcloud container clusters get-credentials echo-cluster --zone=$ZONE
```
#### Expose the deployment ####
```
kubectl expose deployment echo-app --name echo-web \
   --type LoadBalancer --port 80 --target-port 8000
```
```
kubectl get service echo-web
```
