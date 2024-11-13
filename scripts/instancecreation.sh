#!/bin/bash

# Task 1: Creation of AlloyDB cluster
gcloud beta alloydb clusters create "$CLUSTER_NAME" \
    --password="$PASSWORD" \
    --network="$NETWORK" \
    --region="$REGION" \
    --project="$PROJECT_ID"

if [ $? -eq 0 ]; then
    echo "AlloyDB cluster $CLUSTER_NAME created successfully."
else
    echo "Failed to create AlloyDB cluster $CLUSTER_NAME. Check for errors and try again."
    exit 1
fi

# Task 1: Create the primary instance
gcloud beta alloydb instances create "$PRIMARY_INSTANCE_NAME" \
    --instance-type=PRIMARY \
    --cpu-count="$CPU_COUNT" \
    --region="$REGION" \
    --cluster="$CLUSTER_NAME" \
    --project="$PROJECT_ID"

if [ $? -eq 0 ]; then
    echo "Primary instance $PRIMARY_INSTANCE_NAME created successfully."
else
    echo "Failed to create primary instance $PRIMARY_INSTANCE_NAME. Check for errors and try again."
    exit 1
fi
