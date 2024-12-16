## 🚀 Implement Cloud Security Fundamentals on Google Cloud: Challenge Lab | [GSP342](https://www.cloudskillsboost.google/catalog_lab/3123)

## Youtube link [Here]()

## 🌐 **Guide to Complete the Challenge Lab**

### EXPORT ENV VARIABLES ###
```bash
export CUSTOM_SECURIY_ROLE=orca_storage_editor_839
export SERVICE_ACCOUNT=orca-private-cluster-117-sa
export CLUSTER_NAME=orca-cluster-539
export VPC_NAME=orca-build-vpc
export SUBNET_NAME=orca-build-subnet
export JUMPHOST_NAME=orca-jumphost
export ZONE=europe-west1-c
```

### Task 1. Create a custom security role ###
```
gcloud config set compute/zone $ZONE
```
```
vi role-definition.yaml
```
```
title: "Custom-Security-Role"
description: "Permissions"
stage: "ALPHA"
includedPermissions:
- storage.buckets.get
- storage.objects.get
- storage.objects.list
- storage.objects.update
- storage.objects.create
```
```
gcloud iam roles create $CUSTOM_SECURIY_ROLE --project $DEVSHELL_PROJECT_ID --file role-definition.yaml
```

### Task 2. Create a service account ###
```
gcloud iam service-accounts create $SERVICE_ACCOUNT --display-name "Orca Private Cluster Service Account"
```
### Task 3. Bind a custom security role to a service account ###
```
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/monitoring.viewer
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/monitoring.metricWriter
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/logging.logWriter
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role projects/$DEVSHELL_PROJECT_ID/roles/$CUSTOM_SECURIY_ROLE
```

### Task 4. Create and configure a new Kubernetes Engine private cluster ###
```
gcloud container clusters create $CLUSTER_NAME --num-nodes 1 --master-ipv4-cidr=172.16.0.64/28 --network $VPC_NAME --subnetwork $SUBNET_NAME --enable-master-authorized-networks --master-authorized-networks 192.168.10.2/32 --enable-ip-alias --enable-private-nodes --enable-private-endpoint --service-account $SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --zone $ZONE

```

### Task 5. Deploy an application to a private Kubernetes Engine cluster ###
```
gcloud compute ssh --zone $ZONE $JUMPHOST_NAME
```
```
gcloud config set compute/zone europe-west1-c
```
```
gcloud container clusters get-credentials $CLUSTER_NAME --internal-ip
```
```
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
```
```
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
```
```
kubectl expose deployment hello-server --name orca-hello-service --type LoadBalancer --port 80 --target-port 8080
```

