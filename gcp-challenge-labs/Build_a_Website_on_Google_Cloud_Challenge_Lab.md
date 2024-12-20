## 🚀 Build a Website on Google Cloud: Challenge Lab | [GSP319](https://www.cloudskillsboost.google/catalog_lab/2692)

## Youtube [link](https://youtu.be/Xt2pCDagCM4)

## 🌐 **Guide to Complete the Challenge Lab:**

### Export the Variables ###
```
export ZONE=europe-west4-a
export MON_IDENT=fancy-monolith-117
export CLUSTER=fancy-production-950
export ORD_IDENT=fancy-orders-930
export PROD_IDENT=fancy-products-494
export FRONT_IDENT=fancy-frontend-820
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
