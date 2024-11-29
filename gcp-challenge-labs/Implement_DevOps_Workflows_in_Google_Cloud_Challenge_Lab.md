## 🚀 Implement DevOps Workflows in Google Cloud: Challenge Lab | [GCP330](https://www.cloudskillsboost.google/catalog_lab/2889)

## 🌐 **Guide to Complete the Challenge Lab:**

### Set Environment Variables ###
```
export REGION=us-east1
export ZONE=us-east1-c
export CLUSTER_NAME=hello-cluster
```
### Task 1. Create the lab resources ###
#### Enable APIs ####
```
gcloud services enable container.googleapis.com \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com
```
#### Add the Kubernetes Developer role for the Cloud Build service account ####
```
curl -sS https://webi.sh/gh | sh
gh auth login
gh api user -q ".login"
GITHUB_USERNAME=$(gh api user -q ".login")
git config --global user.name "${GITHUB_USERNAME}"
git config --global user.email "${USER_EMAIL}"
echo ${GITHUB_USERNAME}
```
#### Run the following commands to configure Git and GitHub in Cloud Shell ####
```
curl -sS https://webi.sh/gh | sh
gh auth login
gh api user -q ".login"
GITHUB_USERNAME=$(gh api user -q ".login")
git config --global user.name "${GITHUB_USERNAME}"
git config --global user.email "${USER_EMAIL}"
echo ${GITHUB_USERNAME}
```
#### Create an Artifact Registry Docker repository named my-repository ####
```
gcloud artifacts repositories create my-repository \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for storing container images"
```
#### Verify the repository ####
```
gcloud artifacts repositories list --location=$REGION
```
#### Configure Docker Authentication ####
```
gcloud auth configure-docker $REGION-docker.pkg.dev

```
#### Create a GKE Standard cluster ####
```
gcloud container clusters create $CLUSTER_NAME \
--zone $ZONE \
--release-channel regular \
--cluster-version 1.35 \
--enable-autoscaling \
--num-nodes 3 \
--min-nodes 2 \
--max-nodes 6 \
--enable-ip-alias

```
#### Create Prod and Dev Namespace ####
```
kubectl create namespace prod
kubectl create namespace dev
```

### Task 2. Create a repository in Github Repositories ###

#### Create the GitHub Repository ####
```
gh auth login
gh repo create sample-app --public --source=. --remote=origin --confirm
```
#### Clone the repo ####
```
git clone https://github.com/$GITHUB_USERNAME/sample-app.git
cd sample-app
```
#### Copy Sample code ####
```
gsutil cp -r gs://spls/gsp330/sample-app/* .
```
#### Replace Zone and Region Placeholders ####
```
for file in cloudbuild-dev.yaml cloudbuild.yaml; do
    sed -i "s/$REGION/${REGION}/g" "$file"
    sed -i "s/$ZONE/${ZONE}/g" "$file"
done
```
####  Commit and Push Changes ####
```
git add .
git commit -m "Initial commit with sample code"
git branch -M main
git push -u origin main
```
#### Create the Dev Branch ####
```
git checkout -b dev
git push -u origin dev
```
### Task 3. Create the Cloud Build Triggers ###
#### Configure GitHub Repository ####
```
gcloud builds triggers create github \
    --repo-name="sample-app" \
    --repo-owner="$GITHUB_USERNAME" \
    --branch-pattern="^master$" \
    --name="sample-app-prod-deploy" \
    --build-config="cloudbuild.yaml"
```

#### Create the Trigger for the dev Branch ####
```
gcloud builds triggers create github \
    --repo-name="sample-app" \
    --repo-owner="$GITHUB_USERNAME" \
    --branch-pattern="^dev$" \
    --name="sample-app-dev-deploy" \
    --build-config="cloudbuild-dev.yaml"
```
### Task 4. Deploy the first versions of the application ###
#### Build the First Development Deployment ####

#### Inspect and Update cloudbuild-dev.yaml ####
```
sed -i "s/<version>/v1.0/g" sample-app/cloudbuild-dev.yaml
```
#### Update dev/deployment.yaml: Replace <todo> and PROJECT_ID with the actual container image name and project ID: ####
```
sed -i "s|<todo>|gcr.io/$PROJECT_ID/sample-app:v1.0|g" sample-app/dev/deployment.yaml
sed -i "s|PROJECT_ID|$PROJECT_ID|g" sample-app/dev/deployment.yaml
```
#### Commit and Push Changes to dev Branch ####
```
cd sample-app
git checkout dev
git add cloudbuild-dev.yaml dev/deployment.yaml
git commit -m "Update dev deployment with version v1.0"
git push origin dev
```
#### Check the deployment in the dev namespace ####
```
kubectl get deployments -n dev
```
#### Expose the Development Deployment ####
``` 
kubectl expose deployment development-deployment \
    --type=LoadBalancer \
    --name=dev-deployment-service \
    --port=8080 \
    --target-port=<target-port> \
    -n dev
```
#### Verify the Application ####
```
kubectl get service dev-deployment-service -n dev
```
#### Test the Application ####
```
http://<EXTERNAL_IP>:8080/blue
```
#### Build the First Production Deployment ####
#### Inspect and Update cloudbuild.yaml ####
```
sed -i "s/<version>/v1.0/g" sample-app/cloudbuild.yaml
```
#### Update prod/deployment.yaml: Replace <todo> and PROJECT_ID with the actual container image name and project ID ####
```
sed -i "s|<todo>|gcr.io/YOUR_PROJECT_ID/sample-app:v1.0|g" sample-app/prod/deployment.yaml
sed -i "s|PROJECT_ID|YOUR_PROJECT_ID|g" sample-app/prod/deployment.yaml
```

#### Commit and Push Changes to master Branch ####
```
git checkout master
git add cloudbuild.yaml prod/deployment.yaml
git commit -m "Update production deployment with version v1.0"
git push origin master
```

#### Verify Build and Deployment ####

#### Check the build status in Cloud Build ####
```
gcloud builds list
```
#### Check the deployment in the prod namespace ####
```
kubectl get deployments -n prod
```
#### Expose the Production Deployment ####
```
kubectl expose deployment production-deployment \
    --type=LoadBalancer \
    --name=prod-deployment-service \
    --port=8080 \
    --target-port=<target-port> \
    -n prod
```
#### Replace <target-port> with the port specified in the Dockerfile (e.g., 8080) ####

#### Verify Application ####

#### Retrieve the external IP ####
```
kubectl get service prod-deployment-service -n prod
```

#### Test the application by visiting ####
```
http://<EXTERNAL_IP>:8080/blue
```

### Task 5. Deploy the second versions of the application ###
#### Build the Second Development Deployment #### 
#### Switch to the dev Branch ####
```
cd sample-app
git checkout dev
```

#### Update the main.go File: Add the updated main() function and the new redHandler function ####
```
echo 'func main() {
    http.HandleFunc("/blue", blueHandler)
    http.HandleFunc("/red", redHandler)
    http.ListenAndServe(":8080", nil)
}

func redHandler(w http.ResponseWriter, r *http.Request) {
    img := image.NewRGBA(image.Rect(0, 0, 100, 100))
    draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{255, 0, 0, 255}}, image.ZP, draw.Src)
    w.Header().Set("Content-Type", "image/png")
    png.Encode(w, img)
}' > main.go
```

#### Update cloudbuild-dev.yaml: Change the Docker image version to v2.0 ####
```
sed -i "s/v1.0/v2.0/g" cloudbuild-dev.yaml
```

#### Update dev/deployment.yaml: Update the container image name to use version v2.0 ####
```
sed -i "s|v1.0|v2.0|g" dev/deployment.yaml
```

#### Commit and Push Changes ####
```
git add main.go cloudbuild-dev.yaml dev/deployment.yaml
git commit -m "Update dev deployment to version v2.0 with redHandler"
git push origin dev
```

#### Verify Build and Deployment ####

#### Check build status in Cloud Build ####
```
gcloud builds list
```
#### Check the deployment in the dev namespace ####
```
kubectl get deployments -n dev
```
#### Test the Application ####
#### Get the LoadBalancer IP ####
```
kubectl get service dev-deployment-service -n dev
```
#### In browser access below link ####
```
http://<EXTERNAL_IP>:8080/red
```

#### Build the Second Production Deployment ####
#### Switch to the master Branch ####
```
git checkout master
```
#### Update the main.go File: Use the same updated main() function and redHandler function as in the dev branch ####

#### Update cloudbuild.yaml: Change the Docker image version to v2.0 ####
```
sed -i "s/v1.0/v2.0/g" cloudbuild.yaml
```
#### Update prod/deployment.yaml: Update the container image name to use version v2.0 ####
```
sed -i "s|v1.0|v2.0|g" prod/deployment.yaml
```

#### Commit and Push Changes ####
```
git add main.go cloudbuild.yaml prod/deployment.yaml
git commit -m "Update production deployment to version v2.0 with redHandler"
git push origin master
```

#### Verify Build and Deployment ####

#### Check build status in Cloud Build ####
```
gcloud builds list
```
#### Check the deployment in the prod namespace ####
```
kubectl get deployments -n prod
```
#### Test the Application ####

#### Get the LoadBalancer IP ####
```
kubectl get service prod-deployment-service -n prod
```
#### In browser access below link ####
```
http://<EXTERNAL_IP>:8080/red
```
### Task 6. Roll back the production deployment ###
#### Inspect the Cloud Build History ####
#### List the Cloud Build history ####
```
gcloud builds list
```
#### Look for the build ID corresponding to the v1.0 deployment of the production application ####
```
gcr.io/$PROJECT_ID/sample-app:v1.0
```
#### Update the Deployment in the prod Namespace ####
#### Edit the Deployment Manifest: If the prod/deployment.yaml file was used to deploy, edit the file to use the v1.0 container image ####
```
sed -i "s|v2.0|v1.0|g" prod/deployment.yaml
```
#### Apply the Updated Deployment ####
```
kubectl apply -f prod/deployment.yaml -n prod
```

#### Verify the Rollback: Check the rollout status ####
```
kubectl rollout status deployment production-deployment -n prod
```
#### Verify the Application ####
#### Get the Load Balancer IP for the production service ####
```
kubectl get service prod-deployment-service -n prod
```
#### In browser access the link ####

```
http://<EXTERNAL_IP>:8080/red
```
#### Rebuild the v1.0 image using Cloud Build ####
```
gcloud builds submit --config cloudbuild.yaml --substitutions=_VERSION=v1.0
```

#### Update the deployment to use the rebuilt image ####
```
kubectl set image deployment/production-deployment \
production-container=gcr.io/$PROJECT_ID/sample-app:v1.0 -n prod
```
#### Verify the rollout ####
```
kubectl rollout status deployment production-deployment -n prod
```

#### Test the /red endpoint as described earlier to confirm the 404 response ####

