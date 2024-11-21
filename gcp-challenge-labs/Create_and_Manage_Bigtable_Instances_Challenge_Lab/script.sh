#!/bin/bash

# Variables
PROJECT_ID="qwiklabs-gcp-01-b053cd48733d"
INSTANCE_ID="ecommerce-recommendations"
CLUSTER_ID_C1="ecommerce-recommendations-c1"
CLUSTER_ID_C2="ecommerce-recommendations-c2"
REGION="us-west1"
ZONE_C1="us-west1-b"
ZONE_C2="us-west1-c" # Change if necessary
TABLE_SESSION="SessionHistory"
TABLE_PERSONALIZED="PersonalizedProducts"
RESTORED_TABLE="PersonalizedProducts_7_restored"
BACKUP_ID="PersonalizedProducts_7"
SESSIONS_FILE="gs://cloud-training/OCBL377/retail-engagements-sales-00000-of-00001"
RECOMMENDATIONS_FILE="gs://cloud-training/OCBL377/retail-recommendations-00000-of-00001"

echo "Task 1: Creating Bigtable instance and cluster..."
gcloud bigtable instances create $INSTANCE_ID \
  --project=$PROJECT_ID \
  --cluster=$CLUSTER_ID_C1 \
  --cluster-zone=$ZONE_C1 \
  --display-name="Ecommerce Recommendations" \
  --instance-type=PRODUCTION \
  --cluster-storage-type=SSD

echo "Task 2: Creating and populating Bigtable tables..."
# Create SessionHistory table with column families
gcloud bigtable tables create $TABLE_SESSION --instance=$INSTANCE_ID \
  --column-families=Engagements,Sales

# Load data into SessionHistory table
gcloud dataflow jobs run import-sessions \
  --gcs-location=gs://dataflow-templates-us/latest/SequenceFile-to-Bigtable \
  --region=$REGION \
  --staging-location=gs://$PROJECT_ID/temp/ \
  --parameters=\
bigtableProjectId=$PROJECT_ID,\
bigtableInstanceId=$INSTANCE_ID,\
bigtableTableId=$TABLE_SESSION,\
inputFilePattern=$SESSIONS_FILE

# Create PersonalizedProducts table with column families
gcloud bigtable tables create $TABLE_PERSONALIZED --instance=$INSTANCE_ID \
  --column-families=Recommendations

# Load data into PersonalizedProducts table
gcloud dataflow jobs run import-recommendations \
  --gcs-location=gs://dataflow-templates-us/latest/SequenceFile-to-Bigtable \
  --region=$REGION \
  --staging-location=gs://$PROJECT_ID/temp/ \
  --parameters=\
bigtableProjectId=$PROJECT_ID,\
bigtableInstanceId=$INSTANCE_ID,\
bigtableTableId=$TABLE_PERSONALIZED,\
inputFilePattern=$RECOMMENDATIONS_FILE

echo "Task 3: Configuring replication for Bigtable..."
gcloud bigtable clusters create $CLUSTER_ID_C2 \
  --instance=$INSTANCE_ID \
  --zone=$ZONE_C2 \
  --autoscaling-min-nodes=1 \
  --autoscaling-max-nodes=5 \
  --autoscaling-cpu-target=60 \
  --storage-type=SSD

echo "Task 4: Backing up and restoring data..."
# Create a backup for PersonalizedProducts table
gcloud bigtable backups create $BACKUP_ID \
  --instance=$INSTANCE_ID \
  --cluster=$CLUSTER_ID_C1 \
  --table=$TABLE_PERSONALIZED \
  --expiration-date=$(date -u -d "+7 days" '+%Y-%m-%dT%H:%M:%SZ')

# Restore the backup to a new table
gcloud bigtable backups restore $BACKUP_ID \
  --instance=$INSTANCE_ID \
  --cluster=$CLUSTER_ID_C1 \
  --destination-table=$RESTORED_TABLE

echo "Task 5: Deleting Bigtable data and instance..."
# Delete tables
gcloud bigtable tables delete $TABLE_SESSION --instance=$INSTANCE_ID --quiet
gcloud bigtable tables delete $TABLE_PERSONALIZED --instance=$INSTANCE_ID --quiet
gcloud bigtable tables delete $RESTORED_TABLE --instance=$INSTANCE_ID --quiet

# Delete backup
gcloud bigtable backups delete $BACKUP_ID \
  --instance=$INSTANCE_ID \
  --cluster=$CLUSTER_ID_C1 --quiet

# Delete instance
gcloud bigtable instances delete $INSTANCE_ID --quiet

echo "All tasks completed successfully."
