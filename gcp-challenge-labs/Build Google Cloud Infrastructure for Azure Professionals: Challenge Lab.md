## [Build Google Cloud Infrastructure for Azure Professionals: Challenge Lab - GSP512](https://cloudskillsboost.google/focuses/60393?parent=catalog)
```
gcloud auth list
```
```
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_ID=$DEVSHELL_PROJECT_ID
gcloud config set compute/zone $ZONE
export REGION=${ZONE%-*}
gcloud config set compute/region $REGION
```
### Task 1. Create development VPC manually ###
```
gcloud compute networks create griffin-dev-vpc --project=$DEVSHELL_PROJECT_ID --subnet-mode custom && gcloud compute networks subnets create griffin-dev-wp --project=$DEVSHELL_PROJECT_ID --region=$REGION --range=192.168.16.0/20 --network=griffin-dev-vpc && gcloud compute networks subnets create griffin-dev-mgmt --project=$DEVSHELL_PROJECT_ID --region=$REGION --network=griffin-dev-vpc --range=192.168.32.0/20
```

### Task 2. Create production VPC manually ###
```
gcloud compute networks create griffin-prod-vpc --project=$DEVSHELL_PROJECT_ID --subnet-mode custom && gcloud compute networks subnets create griffin-prod-wp --project=$DEVSHELL_PROJECT_ID --region=$REGION --range=192.168.48.0/20 --network=griffin-prod-vpc && gcloud compute networks subnets create griffin-prod-mgmt --project=$DEVSHELL_PROJECT_ID --region=$REGION --network=griffin-prod-vpc --range=192.168.64.0/20
```
### Task 3. Create bastion host ###
```
gcloud compute instances create bastion --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --network-interface=network=griffin-dev-vpc,subnet=griffin-dev-mgmt --network-interface=network=griffin-prod-vpc,subnet=griffin-prod-mgmt --tags=ssh && gcloud compute firewall-rules create fw-ssh-dev --project=$DEVSHELL_PROJECT_ID --target-tags ssh --allow=tcp:22 --network=griffin-dev-vpc --source-ranges=0.0.0.0/0 && gcloud compute firewall-rules create fw-ssh-prod --project=$DEVSHELL_PROJECT_ID --target-tags ssh --allow=tcp:22 --network=griffin-prod-vpc --source-ranges=0.0.0.0/0
```

### Task 4. Create and configure Cloud SQL Instance ###
```
gcloud sql instances create griffin-dev-db --project=$DEVSHELL_PROJECT_ID  --region=$REGION --database-version=MYSQL_5_7 --root-password="techcps"
```
```
gcloud sql databases create wordpress --instance=griffin-dev-db --project=$DEVSHELL_PROJECT_ID
```
```
gcloud sql users create wp_user --instance=griffin-dev-db --instance=griffin-dev-db --password=stormwind_rules && gcloud sql users set-password wp_user --instance=griffin-dev-db --instance=griffin-dev-db --password=stormwind_rules && gcloud sql users list --instance=griffin-dev-db --instance=griffin-dev-db --format="value(name)" --filter="host='%'"

```
### Task 5. Create Kubernetes cluster ###
```
gcloud container clusters create griffin-dev --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type e2-standard-4 --network griffin-dev-vpc --subnetwork griffin-dev-wp --num-nodes 2 && gcloud container clusters get-credentials griffin-dev --project=$DEVSHELL_PROJECT_ID --zone=$ZONE
```

### Task 6. Prepare the Kubernetes cluster ###
```
cd ~/
gsutil cp -r gs://cloud-training/gsp321/wp-k8s .
```

```
cat > wp-k8s/wp-env.yaml <<EOF_CP
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: wordpress-volumeclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200Gi
---
apiVersion: v1
kind: Secret
metadata:
  name: database
type: Opaque
stringData:
  username: wp_user
  password: stormwind_rules

EOF_CP

```
```
cd wp-k8s
kubectl create -f wp-env.yaml
```
```
gcloud iam service-accounts keys create key.json \
    --iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
```
```
kubectl create secret generic cloudsql-instance-credentials \
    --from-file key.json
```
```
INSTANCE_ID=$(gcloud sql instances describe griffin-dev-db --project=$DEVSHELL_PROJECT_ID --format='value(connectionName)')

```
### Task 7. Create a WordPress deployment ###
```
cat > wp-deployment.yaml <<EOF_CP
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
        - image: wordpress
          name: wordpress
          env:
          - name: WORDPRESS_DB_HOST
            value: 127.0.0.1:3306
          - name: WORDPRESS_DB_USER
            valueFrom:
              secretKeyRef:
                name: database
                key: username
          - name: WORDPRESS_DB_PASSWORD
            valueFrom:
              secretKeyRef:
                name: database
                key: password
          ports:
            - containerPort: 80
              name: wordpress
          volumeMounts:
            - name: wordpress-persistent-storage
              mountPath: /var/www/html
        - name: cloudsql-proxy
          image: gcr.io/cloudsql-docker/gce-proxy:1.33.2
          command: ["/cloud_sql_proxy",
                    "-instances=$INSTANCE_ID=tcp:3306",
                    "-credential_file=/secrets/cloudsql/key.json"]
          securityContext:
            runAsUser: 2  # non-root user
            allowPrivilegeEscalation: false
          volumeMounts:
            - name: cloudsql-instance-credentials
              mountPath: /secrets/cloudsql
              readOnly: true
      volumes:
        - name: wordpress-persistent-storage
          persistentVolumeClaim:
            claimName: wordpress-volumeclaim
        - name: cloudsql-instance-credentials
          secret:
            secretName: cloudsql-instance-credentials

EOF_CP

```
```

kubectl create -f wp-deployment.yaml
kubectl create -f wp-service.yaml
```
### Task 8. Enable monitoring ###
```
cat > techcps.tf << "EOF_CP"
variable "devsell_project_id" {
  description = "The project ID"
}

variable "external_ip" {
  description = "The external IP address"
}

provider "google" {
  project = var.devsell_project_id
}

resource "google_monitoring_uptime_check_config" "example" {
  display_name = "techcps"
  timeout      = "60s"

  http_check {
    port           = "80"
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.devsell_project_id
      host       = var.external_ip  # Replace with your external IP
    }
  }

  checker_type = "STATIC_IP_CHECKERS"
}

EOF_CP
```
```
terraform init
terraform apply --auto-approve
```
### Task 9. Provide access for an additional engineer ###
#### Check the video for this step completion ####
