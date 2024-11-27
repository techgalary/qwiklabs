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

###### Create Alerting Policy ######
######
1. In the Google Cloud Console, navigate to Monitoring > Alerting > Click Create Policy.
2. Add a condition using the invalid_image_name_errors metric: Choose Logs-based Metric and select invalid_image_name_errors.
3. Set the threshold to trigger an alert when the error count exceeds 1.
4. Configure notification channels to send alerts (e.g., email, SMS).
5. Save the alerting policy.
######
##### Fix the Manifest and Redeploy #####
###### Locate the image field and Update the helloweb-deployment.yaml ###### 
```
image: gcr.io/google-samples/hello-app:1.0
```
 ###### Apply the manifest ######
 ```
kubectl apply -f helloweb-deployment.yaml --namespace=gmp-awp5
```
###### Check application status ######
```
kubectl get services --namespace=gmp-awp5
```

##### Test the Alert Policy again #####
###### Reintroduce an invalid image name in the manifest temporarily and redeploy to test the alerting mechanism ###### 
```
image: invalid/image:name
```
###### 
1. Verify that the alert is triggered in the Google Cloud Console.
2. Revert the manifest to the valid image and redeploy.
###### 

### Task 4. Create a logs-based metric and alerting policy ###
##### 
1. Open Logs Explorer in the Google Cloud Console:
2. Navigate to Logging > Logs Explorer.
3. Build the Query:
In the Query Builder, specify the resource type and severity level
#####
```
resource.type="k8s_pod"
severity="ERROR"
textPayload:"InvalidImageName"
```
#####
4. Run the query to confirm it captures logs for errors like:
#####
```
Error: InvalidImageName
Failed to apply default image tag "<todo>": couldn't parse image reference "<todo>": invalid reference format
```
#### Create the Metric ####
#####
1. Click Save Query > Create Metric.
2. In the Create logs-based metric dialog:
    Metric Type: Counter
    Log Metric Name: pod-image-errors
3. Save the metric.

#### Create an Alerting Policy ####
#####
1. Open Monitoring in the Google Cloud Console:
2. Navigate to Monitoring > Alerting.
3. Create a New Alerting Policy:
4. Click Create Policy.
   Add a Condition:
        Click Add Condition and configure it as follows:
        Target: Select the logs-based metric pod-image-errors.
        Configuration:
        Rolling Window: 10 min
        Rolling Window Function: Count
        Time Series Aggregation: Sum
        Condition Type: Threshold
        Threshold Position: Above threshold
        Threshold Value: 0
        Alert Trigger: Any time series violates.
        Save the condition.
5. Skip Notification Channel:
       On the Notifications page, skip adding a notification channel (as per the instructions).
6. Name the Alerting Policy:
       Set the policy name to Pod Error Alert.
7. Review and Save:
       Review your alerting policy and click Save.
#####
####
Verify Your Setup
####
#####
1. Simulate an Error:
   Temporarily deploy a manifest with an invalid image name to generate InvalidImageName errors:
#####
```
    image: invalid/image:name
```
#####
2. Check Logs-Based Metric:
    Go to Logging > Logs-based Metrics and ensure pod-image-errors is capturing the logs.
3. Verify Alert Trigger:
    Navigate to Monitoring > Alerting and ensure the Pod Error Alert policy is active and detecting the error.
4. Fix the Error:
    Revert the manifest to a valid image and redeploy:
#####
```
image: gcr.io/google-samples/hello-app:1.0
```

### Task 5. Update and re-deploy your app ###
```
```
### Task 6. Containerize your code and deploy it onto the cluster ###
```
```

