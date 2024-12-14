## 🚀 Build a Website on Google Cloud: Challenge Lab | [GSP319](https://www.cloudskillsboost.google/focuses/11765?parent=catalog)


## 🌐 **Guide to Complete the Challenge Lab:**

 **Launch Cloud Shell:**  
   Start your Google CloudShell session by [``clicking here``](https://console.cloud.google.com/home/dashboard?project=&pli=1&cloudshell=true).

### Set the Environment Variables #######
```bash

export MONOLITH_IDENTIFIER=
export CLUSTER_NAME=
export ORDERS_IDENTIFIER=
export PRODUCTS_IDENTIFIER=
export FRONTEND_IDENTIFIER=

```
### Task 1. Download the monolith code and build your container ###
```bash
git clone https://github.com/googlecodelabs/monolith-to-microservices.git

cd ~/monolith-to-microservices
./setup.sh

cd ~/monolith-to-microservices/monolith
npm start
```
```
gcloud services enable cloudbuild.googleapis.com
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/$MONOLITH_IDENTIFIER:1.0.0 .

```
### Task 2. Create a kubernetes cluster and deploy the application ###
```bash
gcloud config set compute/zone us-central1-a
gcloud services enable container.googleapis.com
gcloud container clusters create $CLUSTER_NAME --num-nodes 3
```
```
kubectl create deployment $MONOLITH_IDENTIFIER --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/$MONOLITH_IDENTIFIER:1.0.0
kubectl expose deployment $MONOLITH_IDENTIFIER --type=LoadBalancer --port 80 --target-port 8080
```
###  Task 3. Create new microservices ###
```bash

cd ~/monolith-to-microservices/microservices/src/orders
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/$ORDERS_IDENTIFIER:1.0.0 .
```
```
cd ~/monolith-to-microservices/microservices/src/products
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/$PRODUCTS_IDENTIFIER:1.0.0 .

```
### Task 4. Deploy the new microservices ###
```bash
kubectl create deployment $ORDERS_IDENTIFIER --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/$ORDERS_IDENTIFIER:1.0.0
kubectl expose deployment $ORDERS_IDENTIFIER --type=LoadBalancer --port 80 --target-port 8081
```
```
kubectl create deployment $PRODUCTS_IDENTIFIER --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/$PRODUCTS_IDENTIFIER:1.0.0
kubectl expose deployment $PRODUCTS_IDENTIFIER --type=LoadBalancer --port 80 --target-port 8082
```

### Task 5. Configure and deploy the Frontend microservice ###

```bash
cd ~/monolith-to-microservices/react-app
nano .env

REACT_APP_ORDERS_URL=http://34.132.73.105/api/orders
REACT_APP_PRODUCTS_URL=http://34.170.169.147/api/products
```
```
npm run build
```

### Task 6. Create a containerized version of the Frontend microservice ###
```bash
cd ~/monolith-to-microservices/microservices/src/frontend
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/$FRONTEND_IDENTIFIER:1.0.0 .
```
### Task 7. Deploy the Frontend microservice ###
```bash
kubectl create deployment $FRONTEND_IDENTIFIER --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/$FRONTEND_IDENTIFIER:1.0.0
kubectl expose deployment $FRONTEND_IDENTIFIER --type=LoadBalancer --port 80 --target-port 8080
```
