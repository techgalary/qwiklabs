##  Use Machine Learning APIs on Google Cloud: Challenge Lab| [GSP329](https://www.cloudskillsboost.google/focuses/12704?parent=catalog)

## Youtube [Link](https://youtu.be/ZKCWD0GZIZM)

## 🌐 **Guide to Complete the Challenge Lab:**

 **Launch Cloud Shell:**  
   Start your Google CloudShell session by [``clicking here``](https://console.cloud.google.com/home/dashboard?project=&pli=1&cloudshell=true).
### Export Environment Variables ###
```bash
export LANGUAGE=<Update as per lab>
export LOCALE=<Update as per lab>
export BIGQUERY_ROLE=<Update as per lab>
export CLOUD_STORAGE_ROLE=<Update as per lab>
export SERVICE_ACCOUNT=<provide some name here>
```
### Task 1. Configure a service account to access the Machine Learning APIs, BigQuery, and Cloud Storage ###
``` bash

gcloud iam service-accounts create $SERVICE_ACCOUNT
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role=$BIGQUERY_ROLE

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role=$CLOUD_STORAGE_ROLE

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role=roles/serviceusage.serviceUsageConsumer

```
### Task 2. Create and download a credential file for your service account ###

``` bash


gcloud iam service-accounts keys create $SERVICE_ACCOUNT-key.json --iam-account $SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS=${PWD}/$SERVICE_ACCOUNT-key.json

```
### Task 3. Modify the Python script to extract text from image files & Task 4. Modify the Python script to translate the text using the Translation API ####
```bash


gsutil cp gs://qwiklabs-gcp-01-5c7412d19782/analyze-images-v2.py . 
NOTE:  [You can also run wget https://raw.githubusercontent.com/techgalary/qwiklabs/main/challenge-labs/Integrate_With_Machine_Learning_Challenge_Lab-Solution/analyze-images-v2.py] - This contains updated Python file

sed -i "s/'en'/'${LOCAL}'/g" analyze-images-v2.py

python3 analyze-images-v2.py $DEVSHELL_PROJECT_ID <PROVIDE BUCKET NAME HERE>

```
### Task 5 ###

```bash

bq query --use_legacy_sql=false "SELECT locale,COUNT(locale) as lcount FROM image_classification_dataset.image_text_detail GROUP BY locale ORDER BY lcount DESC"

```
