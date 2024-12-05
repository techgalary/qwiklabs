# Build and Deploy a Docker Image to a Kubernetes Cluster: Challenge Lab || [GSP304](https://www.cloudskillsboost.google/focuses/1738?parent=catalog) ||

## Youtube Solution Video [here](https://www.youtube.com/watch?v=LEwH2rqMJJw)


### Task 1. Create a Kubernetes cluster ###

#### Set Environment Variables ###
``` bash
export REGION=us-east1
export ZONE=us-east1-c 
export PROJECT_ID=qwiklabs-gcp-01-40a4f90f7908
```

#### Create Cluster ####
```
gcloud container clusters create echo-cluster \
    --num-nodes=1 \
    --zone=$ZONE \
    --machine-type=e2-standard-2 \
    --enable-ip-alias

```
```
gcloud container clusters list
```

### Task 2. Build a tagged Docker image ###
#### Download the archive file from the Cloud Storage Bucket ####

```
gsutil cp gs://${PROJECT_ID}/echo-web.tar.gz .
```
#### Extract the Archive ####
```
tar -xvzf echo-web.tar.gz

```
#### Build the Docker image ####
```
docker build -t echo-app:v1 .
```
```
docker images
```

### Task 3. Push the image to the Google Container Registry ###
#### Tag the Docker Image for GCR ####

```
docker tag echo-app:v1 gcr.io/${PROJECT_ID}/echo-app:v1
```

```
docker push gcr.io/${PROJECT_ID}/echo-app:v1
```
#### Verifying if image is uploaded to GCR ####
```
gcloud container images list --repository=gcr.io/${PROJECT_ID}
```
### Task 4. Deploy the application to the Kubernetes cluster ###

#### Create the deployment ####
```
kubectl create deployment echo-web --image=gcr.io/${PROJECT_ID}/echo-app:v1
```
```
gcloud container clusters get-credentials echo-cluster --zone=$ZONE
```
#### Expose the deployment ####
```
kubectl expose deployment echo-web \
    --type=LoadBalancer \
    --port=80 \
    --target-port=8000

```
```
kubectl get service echo-web
```
