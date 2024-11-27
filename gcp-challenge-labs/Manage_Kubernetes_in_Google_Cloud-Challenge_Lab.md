# Manage Kubernetes in Google Cloud: Challenge Lab || [GSP510](https://www.cloudskillsboost.google/catalog_lab/5978) 

### Set Environment Variables ###
```
export REPO_NAME=
export CLUSTER_NAME=
export ZONE=
export NAMESPACE=
export INTERVAL=
export SERVICE_NAME=
```
### Task 1. Create a GKE cluster ###

#### Set Configuration ####
```
gcloud auth login
gcloud config set project [PROJECT_ID]
```
#### Enable API ####
```
gcloud services enable container.googleapis.com
```
#### Execute below command to create Cluster ####
```
gcloud container clusters create hello-world-4jzt \
    --zone us-west1-a \
    --release-channel regular \
    --cluster-version 1.27.8 \
    --enable-autoscaling \
    --num-nodes 3 \
    --min-nodes 2 \
    --max-nodes 6
```
#### Execute below command to verify the cluster ####
```
gcloud container clusters describe hello-world-4jzt --zone us-west1-a
```

### Task 2. Enable Managed Prometheus on the GKE cluster ###

#### Enable the service for prometheus ####
```
gcloud container clusters update hello-world-4jzt \
    --zone us-west1-a \
    --enable-managed-prometheus
```
#### Create the Namespace ####
```
kubectl create namespace gmp-awp5
```
### Deploy the Sample Prometheus App ###
#### Download the manifest file ####
```
gsutil cp gs://spls/gsp510/prometheus-app.yaml .
```
#### Update prometheus-app.yaml with below code snippet ####
```
containers:
- image: nilebox/prometheus-example-app:latest
  name: prometheus-test
  ports:
  - containerPort: 8080
    name: metrics

```
#### Deploy the application on the gmp-awp5 namespace ####
```
kubectl apply -f prometheus-app.yaml --namespace=gmp-awp5

```
#### Verify the deployment ####
```
kubectl get pods --namespace=gmp-awp5

```
#### Apply Pod Monitoring ####
#### Download the pod-monitoring.yaml file ####
```
gsutil cp gs://spls/gsp510/pod-monitoring.yaml .
```
#### Update the todo section in pod-monitoring.yaml ####
```
metadata:
  name: prometheus-test
  labels:
    app.kubernetes.io/name: prometheus-test
spec:
  selector:
    matchLabels:
      app: prometheus-test
  endpoints:
  - port: metrics
    interval: 30s
```
#### Apply the pod monitoring resource ####
```
kubectl apply -f pod-monitoring.yaml --namespace=gmp-awp5
```
#### Verify the pod monitoring ####
```
kubectl get podmonitoring --namespace=gmp-awp5
```
### Task 3. Deploy an application onto the GKE cluster ###

#### Download the deployment manifest files ####
```
gsutil cp -r gs://spls/gsp510/hello-app/ .

```
#### Deploy the Application ####
```
cd hello-app/manifests
kubectl apply -f helloweb-deployment.yaml --namespace=gmp-awp5
```
#### Verify the deployment ####
```
kubectl get deployments --namespace=gmp-awp5

```
#### Inspect the Error ####
```
kubectl describe deployment helloweb --namespace=gmp-awp5
```
#### Create Logs-Based Metric ####
##### Enable logging for the GKE cluster #####
```
gcloud services enable logging.googleapis.com
```
### Create a logs-based metric ###
###### Go to Logging > Logs Explorer.
Create a query to find logs related to the invalid image name error
######
```
resource.type="k8s_container"
textPayload:"invalid image name"
```
###### Click Save Query and then Create Metric.
Name the metric invalid_image_name_errors and save it.
######

### Task 4. Create a logs-based metric and alerting policy ###
```
```
### Task 5. Update and re-deploy your app ###
```
```
### Task 6. Containerize your code and deploy it onto the cluster ###
```
```

