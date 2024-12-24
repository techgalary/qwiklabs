# Develop Serverless Apps with Firebase: Challenge Lab || [GSP344](https://www.cloudskillsboost.google/focuses/14677?parent=catalog) ||

## Solution [here]()

### Set Variables ###
```
export SERVICE_NAME=netflix-dataset-service
export FRNT_STG_SRV=frontend-staging-service
export FRNT_PRD_SRV=frontend-production-service
export PROJECT_ID=
export REGION=
```
```
gcloud config set project $PROJECT_ID
```
### Enable Service API ###
```
gcloud services enable run.googleapis.com
```
### Task 1. Create a Firestore database ###
```
gcloud firestore databases create --location=$REGION
```
### Task 2. Populate the database ###
#### Clone the repo
```
git clone https://github.com/rosera/pet-theory.git
```
```
cd pet-theory/lab06/firebase-import-csv/solution
```
```
npm install
```
```
node index.js netflix_titles_original.csv
```
### Task 3. Create a REST API ###
```
cd ~/pet-theory/lab06/firebase-rest-api/solution-01
npm install
```
```
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.1
```
```
gcloud beta run deploy $SERVICE_NAME --image gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.1 --allow-unauthenticated --region=$REGION
```
```
cd ~/pet-theory/lab06/firebase-rest-api/solution-02
npm install
```
```
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.2
```
```
gcloud beta run deploy $SERVICE_NAME --image gcr.io/$GOOGLE_CLOUD_PROJECT/rest-api:0.2 --allow-unauthenticated --region=$REGION
```
### Task 4. Firestore API access ###
```
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --platform=managed --region=$REGION --format="value(status.url)")
```
```
curl -X GET $SERVICE_URL/2019
```
```
cd ~/pet-theory/lab06/firebase-frontend/public
```
```
sed -i 's/^const REST_API_SERVICE = "data\/netflix\.json"/\/\/ const REST_API_SERVICE = "data\/netflix.json"/' app.js
```
```
sed -i "1i const REST_API_SERVICE = \"$SERVICE_URL/2020\"" app.js
```
### Task 5. Deploy the Staging Frontend ###
```
npm install
cd ~/pet-theory/lab06/firebase-frontend
```

```
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1
```
```
gcloud beta run deploy $FRNT_STG_SRV --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1 --region=$REGION --quiet
```
### Task 6. Deploy the Production Frontend ###
```
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-production:0.1
```
gcloud beta run deploy $FRNT_PRD_SRV --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-production:0.1 --region=$REGION --quiet
```
