#!/bin/bash

PROJECT_ID="qwiklabs-gcp-00-5a24932f320d"
REGION="us-east1"
TOPIC_NAME="${PROJECT_ID}-topic"
SUBSCRIPTION_NAME="${PROJECT_ID}-topic-sub"
CLOUD_RUN_SERVICE="pubsub-events"
TRIGGER_NAME="pubsub-events-trigger"
IMAGE_NAME="gcr.io/cloudrun/hello"

echo "Setting project to $PROJECT_ID"
gcloud config set project $PROJECT_ID


echo "Creating Pub/Sub topic: $TOPIC_NAME"
gcloud pubsub topics create $TOPIC_NAME


echo "Creating Pub/Sub subscription: $SUBSCRIPTION_NAME"
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic=$TOPIC_NAME


echo "Deploying Cloud Run service: $CLOUD_RUN_SERVICE"
gcloud run deploy $CLOUD_RUN_SERVICE \
  --image=$IMAGE_NAME \
  --platform=managed \
  --region=$REGION \
  --allow-unauthenticated


echo "Creating Pub/Sub event trigger: $TRIGGER_NAME"
gcloud eventarc triggers create $TRIGGER_NAME \
  --destination-run-service=$CLOUD_RUN_SERVICE \
  --destination-run-region=$REGION \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" 
  --transport-topic=projects/$PROJECT_ID/topics/$TOPIC_NAME

echo "Publishing a test message to the Pub/Sub topic: $TOPIC_NAME"
gcloud pubsub topics publish $TOPIC_NAME --message="Hello, Cloud Run!"
