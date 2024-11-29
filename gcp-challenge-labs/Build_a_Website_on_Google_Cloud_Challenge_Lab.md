## 🚀 Build a Website on Google Cloud: Challenge Lab | [GSP319](https://partner.cloudskillsboost.google/catalog_lab/2692)

## 🌐 **Guide to Complete the Challenge Lab:**

### Export the Variables ###
```
export ZONE=
export MON_IDENT=
export CLUSTER=
export ORD_IDENT=
export PROD_IDENT=
export FRONT_IDENT=
```
### Task 1. Download the monolith code and build your container ###
```
gcloud config set compute/zone $ZONE
```
#### Enable APIS ####
```
gcloud services enable cloudbuild.googleapis.com container.googleapis.com
```
#### Clone the monolith Repo ####
```
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh
```
#### Confirm the Node Version on CLoud shell ####
```
nvm install --lts
```
#### Build and Push the monolith app to Artifactory ####
```
cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/${MON_IDENT}:1.0.0 .
```

### Task 2. Create a kubernetes cluster and deploy the application ###
#### Create a Cluster ####
```
gcloud container clusters create $CLUSTER --num-nodes 3
```
#### Create and Expose the Deployment ####
```
kubectl create deployment $MON_IDENT --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/$MON_IDENT:1.0.0
```
```
kubectl expose deployment $MON_IDENT --type=LoadBalancer --port 80 --target-port 8080
```

### Task 3. Create new microservices ###
```
cd ~/monolith-to-microservices/microservices/src/orders
```
```
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/$ORD_IDENT:1.0.0 .
```
```
cd ~/monolith-to-microservices/microservices/src/products
```
```
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/$PROD_IDENT:1.0.0 .
```

### Task 4. Deploy the new microservices ###
```
kubectl create deployment $ORD_IDENT --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/$ORD_IDENT:1.0.0
```
```
kubectl expose deployment $ORD_IDENT --type=LoadBalancer --port 80 --target-port 8081
```
```
kubectl create deployment $PROD_IDENT --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/$PROD_IDENT:1.0.0
```
```
kubectl expose deployment $PROD_IDENT --type=LoadBalancer --port 80 --target-port 8082
```
### Task 5. Configure and deploy the Frontend microservice ###
```
cd ~/monolith-to-microservices/react-app
cd ~/monolith-to-microservices/microservices/src/frontend
```

```
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/$FRONT_IDENT:1.0.0 .
```
```
kubectl create deployment $FRONT_IDENT --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/$FRONT_IDENT:1.0.0
```
```
kubectl expose deployment $FRONT_IDENT --type=LoadBalancer --port 80 --target-port 8080
```
