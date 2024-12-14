# Manage Kubernetes in Google Cloud: Challenge Lab || [GSP510](https://www.cloudskillsboost.google/catalog_lab/5978) 

## Youtube[Link](https://www.youtube.com/watch?v=naocMI4hyqE)

### Set Environment Variables ###
```
export REPO_NAME=demo-repo
export CLUSTER_NAME=hello-world-3a3c
export ZONE=us-east4-a
export NAMESPACE=gmp-mw85
export INTERVAL=45s
export SERVICE_NAME=helloweb-service-iqjm
export PROJECT_ID=qwiklabs-gcp-00-ef90497ac793
```
### Task 1. Create a GKE cluster ###

#### Set Configuration ####
```
gcloud auth login
gcloud config set project $PROJECT_ID
```
#### Enable API ####
```
gcloud services enable container.googleapis.com
```
#### Execute below command to create Cluster ####
```
gcloud container clusters create $CLUSTER_NAME \
    --zone $ZONE \
    --release-channel regular \
    --cluster-version 1.30.5 \
    --enable-autoscaling \
    --num-nodes 3 \
    --min-nodes 2 \
    --max-nodes 6
```
#### Execute below command to verify the cluster ####
```
gcloud container clusters describe $CLUSTER_NAME --zone $ZONE
```

### Task 2. Enable Managed Prometheus on the GKE cluster ###

#### Enable the service for prometheus ####
```
gcloud container clusters update $CLUSTER_NAME \
    --zone $ZONE \
    --enable-managed-prometheus
```
#### Create the Namespace ####
```
kubectl create namespace $NAMESPACE
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
#### Deploy the application on the gmp-fdnh namespace ####
```
kubectl apply -f prometheus-app.yaml --namespace=$NAMESPACE

```
#### Verify the deployment ####
```
kubectl get pods --namespace=$NAMESPACE

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
kubectl apply -f pod-monitoring.yaml --namespace=$NAMESPACE
```
#### Verify the pod monitoring ####
```
kubectl get podmonitoring --namespace=$NAMESPACE
```
### Task 3. Deploy an application onto the GKE cluster ###

#### Download the deployment manifest files ####
```
gsutil cp -r gs://spls/gsp510/hello-app/ .

```
#### Deploy the Application ####
```
cd hello-app/manifests
kubectl apply -f helloweb-deployment.yaml --namespace=$NAMESPACE
```
#### Verify the deployment ####
```
kubectl get deployments --namespace=$NAMESPACE

```
#### Inspect the Error ####
```
kubectl describe deployment helloweb --namespace=$NAMESPACE
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
resource.type="k8s_pod"
severity="WARNING"
textPayload:"InvalidImageName"
```
###### Click Save Query and then Create Metric.
1. Click Create Metric at the top of the Logs Explorer.
2. For Metric Type, choose Counter.
3. Enter the metric name: pod-image-errors.
4. Save the metric.
######

###### Create Alerting Policy ######
######
1. Go to Monitoring: Navigate to Monitoring > Alerting in the GCP Console.
2. Create a New Alerting Policy:
Click + Create Policy.
Add a Condition:
Click Add Condition.
Select the logs-based metric pod-image-errors created earlier.
Configure the condition:
Rolling Window: 10 minutes
Rolling Window Function: Count
Time Series Aggregation: Sum
Condition Type: Threshold
Threshold Position: Above threshold
Threshold Value: 0
Alert Trigger: Any time series violates
Save the condition.
Name the Alerting Policy:

Enter the name: Pod Error Alert.
Skip Notification Channels:

Since the instructions specify to disable the notification channel, you can leave this step blank.
Save the Policy: Click Save Policy to finalize.


######
##### Fix the Manifest and Redeploy #####
###### Locate the image field and Update the helloweb-deployment.yaml ###### 
```
image: gcr.io/google-samples/hello-app:1.0
```
 ###### Apply the manifest ######
 ```
kubectl apply -f helloweb-deployment.yaml --namespace=$NAMESPACE
```
###### Check application status ######
```
kubectl get services --namespace=$NAMESPACE
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
severity=WARNING
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

#### Update the Deployment Manifest ####
##### Edit the helloweb-deployment.yaml and replace the image field with below #####
```
image: us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
```
##### Save and close the file #####

#### Delete the Existing Deployment ####
##### Delete the helloweb deployment from the gmp-fdnh namespace #####
```
kubectl delete deployment helloweb --namespace=$NAMESPACE
```
##### Confirm the deployment has been deleted #####
```
kubectl get deployments --namespace=$NAMESPACE
```

#### Deploy the Updated Manifest ####
##### Apply the updated helloweb-deployment.yaml manifest #####
```
kubectl apply -f helloweb-deployment.yaml --namespace=$NAMESPACE
```
##### Verify the deployment #####
```
kubectl get deployments --namespace=$NAMESPACE
```

#### Verify the Deployment ####

##### Check the status of the pods to ensure they are running ##### 
```
kubectl get pods --namespace=$NAMESPACE
```
##### Verify the deployment in the Google Cloud Console ##### 
#####  
    1.Navigate to Kubernetes Engine > Workloads.
    2.Ensure that the helloweb deployment is listed under the gmp-3hp4 namespace with no errors 
##### 

### Task 6. Containerize your code and deploy it onto the cluster ###
#### Update the Application Code ####
##### Navigate to the hello-app directory #####
```
cd hello-app
```
##### Edit the main.go file to update the version #####
```
nano main.go
```
##### On line 49, change the version to Version: 2.0.0 #####
```
fmt.Fprintf(w, "Hello, world!\nVersion: 2.0.0\nHostname: %s", hostname)
```
##### Save and close the file.#####
#### Build the Docker Image ####
##### Authenticate Docker to your Artifact Registry #####
```
gcloud auth configure-docker
```
##### Build the Docker image using the Dockerfile #####
```
docker build -t us-east4-docker.pkg.dev/$PROJECT_ID/sandbox-repo/hello-app:v2 .
```
#### Push the Image to Artifact Registry ####
##### Push the image to your repository #####
```
docker push us-east4-docker.pkg.dev/$PROJECT_ID/sandbox-repo/hello-app:v2
```
#### Update the Deployment to Use the New Image ####
##### Edit the helloweb-deployment.yaml file to use the updated image #####
```
nano helloweb-deployment.yaml
```

##### Update the image field to #####
```
image: us-east4-docker.pkg.dev/$PROJECT_ID/sandbox-repo/hello-app:v2
```

##### Save and close the file #####
##### Apply the updated manifest #####
```
kubectl apply -f helloweb-deployment.yaml --namespace=$NAMESPACE
```

#### Expose the Deployment with a LoadBalancer ####
##### Create a LoadBalancer service named helloweb-service-sk7t #####
```
kubectl expose deployment helloweb \
    --namespace=$NAMESPACE \
    --name=$SERVICE_NAME \
    --type=LoadBalancer \
    --port=8080 \
    --target-port=8080
```
```
kubectl get service $SERVICE_NAME --namespace=$NAMESPACE
```
#### Verify the Deployment ####
##### Navigate to the external IP address in your browser. The page should display #####
```
Hello, world!
Version: 2.0.0
Hostname: helloweb-6fc7476576-cvv5f
```

##### If the page does not load immediately, wait a few minutes for the service to become fully operational #####

