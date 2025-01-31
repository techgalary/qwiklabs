# Develop Serverless Applications on Cloud Run: Challenge Lab || [GSP328](https://www.cloudskillsboost.google/focuses/14744?parent=catalog) ||

##  Solution [here]()

###  Set the Environment Variables in CloudShell ###

```
export PUBLIC_BILLING_SERVICE=public-billing-service-835
export FRONTEND_STAGING_SERVICE=frontend-staging-service-686
export PRIVATE_BILLING_SERVICE=private-billing-service-137
export BILLING_SERVICE_ACCOUNT=billing-service-sa-452
export BILLING_PROD_SERVICE=billing-prod-service-693
export FRONTEND_SERVICE_ACCOUNT=frontend-service-sa-947
export FRONTEND_PRODUCTION_SERVICE=frontend-prod-service-275
```
### Task 1. Enable a public service ###
```
cd ~/pet-theory/lab07/unit-api-billing
gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/billing-staging-api:0.1
gcloud run deploy $PUBLIC_BILLING_SERVICE --image gcr.io/$DEVSHELL_PROJECT_ID/billing-staging-api:0.1 --quiet
```

### Task 2. Deploy a frontend service ###
```
cd ~/pet-theory/lab07/staging-frontend-billing
gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/frontend-staging:0.1
gcloud run deploy $FRONTEND_STAGING_SERVICE --image gcr.io/$DEVSHELL_PROJECT_ID/frontend-staging:0.1 --quiet
```
### Task 3. Deploy a private service ###
```
cd ~/pet-theory/lab07/staging-api-billing
gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/billing-staging-api:0.2
gcloud run deploy $PRIVATE_BILLING_SERVICE --image gcr.io/$DEVSHELL_PROJECT_ID/billing-staging-api:0.2 --quiet
```
### Task 4. Create a billing service account ###
```
gcloud iam service-accounts create $BILLING_SERVICE_ACCOUNT --display-name "Billing Service Account Cloud Run"
```
### Task 5. Deploy the billing service ###
```
cd ~/pet-theory/lab07/prod-api-billing
gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/billing-prod-api:0.1
gcloud run deploy $BILLING_PROD_SERVICE --image gcr.io/$DEVSHELL_PROJECT_ID/billing-prod-api:0.1 --quiet
```
### Task 6. Frontend service account ###
```
gcloud iam service-accounts create $FRONTEND_SERVICE_ACCOUNT --display-name "Billing Service Account Cloud Run Invoker"
```
### Task 7. Redeploy the frontend service ###
```
cd ~/pet-theory/lab07/prod-frontend-billing
gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/frontend-prod:0.1
gcloud run deploy $FRONTEND_PRODUCTION_SERVICE --image gcr.io/$DEVSHELL_PROJECT_ID/frontend-prod:0.1 --quiet
```
