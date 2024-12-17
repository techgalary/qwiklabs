EXPORT ENV VARIABLES

export CUSTOM_SECURIY_ROLE=

export SERVICE_ACCOUNT=

export CLUSTER_NAME=

export VPC_NAME=orca-build-vpc

export SUBNET_NAME=orca-build-subnet 

export ZONE=us-east1-b

================================================ TASK 1 ===============================================

Task 1. Create a custom security role.

gcloud config set compute/zone us-east1-b

vi role-definition.yaml


title: "Custom-Security-Role"
description: "Permissions"
stage: "ALPHA"
includedPermissions:
- storage.buckets.get
- storage.objects.get
- storage.objects.list
- storage.objects.update
- storage.objects.create


gcloud iam roles create $CUSTOM_SECURIY_ROLE --project $DEVSHELL_PROJECT_ID --file role-definition.yaml

================================================ TASK 2 ===============================================

Task 2. Create a service account.

gcloud iam service-accounts create $SERVICE_ACCOUNT --display-name "Orca Private Cluster Service Account"


================================================ TASK 3 ===============================================

Task 3. Bind a custom security role to a service account.

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/monitoring.viewer


gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/monitoring.metricWriter

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role roles/logging.logWriter

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role projects/$DEVSHELL_PROJECT_ID/roles/$CUSTOM_SECURIY_ROLE


================================================ TASK 4 ===============================================

Task 4. Create and configure a new Kubernetes Engine private cluster

gcloud container clusters create $CLUSTER_NAME --num-nodes 1 --master-ipv4-cidr=172.16.0.64/28 --network $VPC_NAME --subnetwork $SUBNET_NAME --enable-master-authorized-networks --master-authorized-networks 192.168.10.2/32 --enable-ip-alias --enable-private-nodes --enable-private-endpoint --service-account $SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --zone $ZONE



================================================ TASK 5 ===============================================

Task 5. Deploy an application to a private Kubernetes Engine cluster.

gcloud compute ssh --zone "us-east1-b" "orca-jumphost"

export ZONE=us-east1-b

gcloud config set compute/zone $ZONE

export CLUSTER_NAME=
gcloud container clusters get-credentials $CLUSTER_NAME --internal-ip

sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0

kubectl expose deployment hello-server --name orca-hello-service --type LoadBalancer --port 80 --target-port 8080
