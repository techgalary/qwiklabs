# Deploy Kubernetes Applications on Google Cloud: Challenge Lab || [GSP318](https://www.skills.google/focuses/10457?parent=catalog) ||

## Youtube Solution [here](https://youtu.be/11O5xdOb1es)

### Set the Variables 

```
export REPO=valkyrie-docker
export DOCKER_IMAGE=valkyrie-app
export TAG=v0.0.1
export ZONE=us-central1-f
export REGION=us-central1
```

### Task 1. Create a Docker image and store the Dockerfile ###
```
source <(gsutil cat gs://spls/gsp318/script.sh)
```
#### copy the valkyrie-app source code into the ~/valkyrie-app directory ####
```
gsutil cp gs://spls/gsp318/valkyrie-app.tgz .
tar -xzf valkyrie-app.tgz
cd valkyrie-app
```

#### Create valkyrie-app/Dockerfile and add the configuration below ####
```
FROM golang:1.10
WORKDIR /go/src/app
COPY source .
RUN go install -v
ENTRYPOINT ["app","-single=true","-port=8080"]

```
#### Build the docker image ####
```
docker build -t $DOCKER_IMAGE:$TAG .
```

```
docker images
```
#### Check the lab completion progress
```
cd ..
cd marking
./step1_v2.sh
```
### Task 2. Test the created Docker image ###
```
cd ..
cd valkyrie-app
```
#### Launch a container using the image ####
```
docker run -p 8080:8080 $DOCKER_IMAGE:$TAG &
```
#### Check the lab completion progress
```
cd ..
cd marking
./step2_v2.sh
bash ~/marking/step2_v2.sh
```
### Task 3. Push the Docker image to the Artifact Registry ###
```
cd ..
cd valkyrie-app
```
#### Create a repository named Repository Name in Artifact Registry ####
```
gcloud artifacts repositories create $REPO \
    --repository-format=docker \
    --location=$REGION \
    --description="awesome lab" \
    --async 
```
#### Configure Docker to use the Google Cloud CLI to authenticate requests to Artifact Registry ####
```
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
```
```
Image_ID=$(docker images --format='{{.ID}}')
```
#### Re-tag the container to be able push it to the repository. ####
```
docker tag $Image_ID $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO/$DOCKER_IMAGE:$TAG
```
```
docker push $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO/$DOCKER_IMAGE:$TAG
```
### Task 4. Create and expose a deployment in Kubernetes ###
```
sed -i s#IMAGE_HERE#$REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO/$DOCKER_IMAGE:$TAG#g k8s/deployment.yaml
```
```
gcloud container clusters get-credentials valkyrie-dev --zone $ZONE
```
```
kubectl create -f k8s/deployment.yaml
```
```
kubectl create -f k8s/service.yaml
```
