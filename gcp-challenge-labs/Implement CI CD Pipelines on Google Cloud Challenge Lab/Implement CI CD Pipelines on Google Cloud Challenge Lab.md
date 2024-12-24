# Implement CI/CD Pipelines on Google Cloud: Challenge Lab || [GSP393](https://www.cloudskillsboost.google/focuses/52826?parent=catalog) ||

## Solution [here](https://youtu.be/_e1Dmp2uemo)

### Task 1. Prework - Set up environment, enable APIs and create clusters ###
```
export PROJECT_ID=qwiklabs-gcp-04-ea647f33de83
export REGION=europe-west1
gcloud config set compute/region $REGION
gcloud config set project $PROJECT_ID
```
#### 2. Enable Service API's ####
```
gcloud services enable \
container.googleapis.com \
clouddeploy.googleapis.com \
artifactregistry.googleapis.com \
cloudbuild.googleapis.com \
clouddeploy.googleapis.com
```
#### 3. Enable permissions for both Kubernetes and Cloud Deploy using the following commands ####
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
--format="value(projectNumber)")-compute@developer.gserviceaccount.com \
--role="roles/clouddeploy.jobRunner"

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
--format="value(projectNumber)")-compute@developer.gserviceaccount.com \
--role="roles/container.developer"
```

#### 4. Create an Artifact Repository ####
```
gcloud artifacts repositories create cicd-challenge \
--description="Image registry for tutorial web app" \
--repository-format=docker \
--location=$REGION
```
#### 5. Create the Google Kubernetes Engine clusters ####
```
gcloud container clusters create cd-staging --node-locations=$ZONE --num-nodes=1 --async
gcloud container clusters create cd-production --node-locations=$ZONE --num-nodes=1 --async
```
### Task 2. Build the images and upload to the repository ###
``` 
cd ~/
git clone https://github.com/GoogleCloudPlatform/cloud-deploy-tutorials.git
cd cloud-deploy-tutorials
git checkout c3cae80 --quiet
cd tutorials/base
```
#### Create the skaffold.yaml configuration using the command below ####
```
envsubst < clouddeploy-config/skaffold.yaml.template > web/skaffold.yaml
```
```
cat web/skaffold.yaml
```
#### Run the skaffold command to build the application and deploy the container image to the Artifact Registry repository previously created ####
```
cd web
skaffold build --interactive=false \
--default-repo $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/cicd-challenge \
--file-output artifacts.json
cd ..
```

### Task 3. Create the Delivery Pipeline ###
#### 1. Create the delivery-pipeline resource using the delivery-pipeline.yaml file ####
``` 
cp clouddeploy-config/delivery-pipeline.yaml.template clouddeploy-config/delivery-pipeline.yaml
sed -i "s/targetId: staging/targetId: cd-staging/" clouddeploy-config/delivery-pipeline.yaml
sed -i "s/targetId: prod/targetId: cd-production/" cloud deploy-config/delivery-pipeline.yaml
sed -i "/targetId: test/d" clouddeploy-config/delivery-pipeline.yaml
```
#### 2. Set the deployment region using the deploy/region configuration parameter ####
``` 
gcloud config set deploy/region $REGION

```
#### 3. Apply the pipeline configuration you created above using the gcloud beta deploy command ####
``` 
gcloud beta deploy apply --file=clouddeploy-config/delivery-pipeline.yaml
```
#### 4. Verify the deployment ####
``` 
gcloud beta deploy delivery-pipelines describe web-app
```
### Configure the deployment targets ###

#### Get the status of the clusters ####
``` 
gcloud container clusters list --format="csv(name,status)"
```

#### Create a context for each cluster ####
```
CONTEXTS=("cd-staging" "cd-production" )
for CONTEXT in ${CONTEXTS[@]}
do
    gcloud container clusters get-credentials ${CONTEXT} --region ${REGION}
    kubectl config rename-context gke_${PROJECT_ID}_${REGION}_${CONTEXT} ${CONTEXT}
done
```

#### Create a namespace in each cluster ####
```
for CONTEXT in ${CONTEXTS[@]}
do
    kubectl --context ${CONTEXT} apply -f kubernetes-config/web-app-namespace.yaml
done
```

#### Create the delivery pipeline targets and Apply the target files to Cloud Deploy ####
``` 
for CONTEXT in ${CONTEXTS[@]}
do
    envsubst < clouddeploy-config/target-$CONTEXT.yaml.template > clouddeploy-config/target-$CONTEXT.yaml
    gcloud beta deploy apply --file clouddeploy-config/target-$CONTEXT.yaml
done

```
### Task 4. Create a Release ###
```
gcloud beta deploy releases create web-app-001 \
--delivery-pipeline web-app \
--build-artifacts web/artifacts.json \
--source web/
```
#### Verify that your application has been deployed to the staging environment ####
```
gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001
```
### Task 5. Promote your application to production ###

```
gcloud beta deploy releases promote \
--delivery-pipeline web-app \
--release web-app-001 \
--quiet

```
#### Approve the deployment ####
``` 
gcloud beta deploy rollouts approve web-app-001-to-cd-production-0001 \
--delivery-pipeline web-app \
--release web-app-001 \
--quiet
```

### Task 6. Make a change to the application and redeploy it ###
```
gcloud services enable cloudbuild.googleapis.com
```
#### Build the application and push to the Artifact Registry ####
```
cd web
skaffold build --interactive=false \
--default-repo $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/cicd-challenge \
--file-output artifacts.json
cd ..
```

#### Create a new release on the pipeline you created earlier. Name the release web-app-002 ####
```
gcloud beta deploy releases create web-app-002 \
--delivery-pipeline web-app \
--build-artifacts web/artifacts.json \
--source web/
```
#### Verify the new version has been deployed to the staging environment ####
```
gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-002
```
### Task 7. Rollback The Change ###
```
gcloud deploy targets rollback cd-staging \
   --delivery-pipeline=web-app \
   --quiet
```
