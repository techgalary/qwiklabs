# Monitor and Log with Google Cloud Observability: Challenge Lab || [GSP338](https://www.cloudskillsboost.google/focuses/13786?parent=catalog) ||
## Solution [here]()
### Run the following Commands in CloudShell
## Task 1: Setup and VM Configuration
```bash
# Set your VALUE variable (check lab instructions for the threshold value)
export VALUE=
```
```bash
gcloud services enable monitoring.googleapis.com
```
```bash
export ZONE=$(gcloud compute instances list video-queue-monitor --format 'csv[no-heading](zone)')
export REGION="${ZONE%-*}"
export INSTANCE_ID=$(gcloud compute instances describe video-queue-monitor --project="$DEVSHELL_PROJECT_ID" --zone="$ZONE" --format="get(id)")
```
```bash
gcloud compute instances stop video-queue-monitor --zone $ZONE
```
```bash
cat > startup-script.sh <<EOF_START
#!/bin/bash
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
## Install Golang
sudo apt update && sudo apt -y
sudo apt-get install wget -y
sudo apt-get -y install git
sudo chmod 777 /usr/local/
sudo wget https://go.dev/dl/go1.22.8.linux-amd64.tar.gz 
sudo tar -C /usr/local -xzf go1.22.8.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
# Install ops agent 
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
sudo service google-cloud-ops-agent start
# Create go working directory and add go path
mkdir /work
mkdir /work/go
mkdir /work/go/cache
export GOPATH=/work/go
export GOCACHE=/work/go/cache
# Install Video queue Go source code
cd /work/go
mkdir video
gsutil cp gs://spls/gsp338/video_queue/main.go /work/go/video/main.go
# Get Cloud Monitoring (stackdriver) modules
go get go.opencensus.io
go get contrib.go.opencensus.io/exporter/stackdriver
# Configure env vars for the Video Queue processing application
export MY_PROJECT_ID=$DEVSHELL_PROJECT_ID
export MY_GCE_INSTANCE_ID=$INSTANCE_ID
export MY_GCE_INSTANCE_ZONE=$ZONE
# Initialize and run the Go application
cd /work
go mod init go/video/main
go mod tidy
go run /work/go/video/main.go
EOF_START
```
```bash
gcloud compute instances add-metadata video-queue-monitor \
  --zone $ZONE \
  --metadata-from-file startup-script=startup-script.sh
```
```bash
gcloud compute instances start video-queue-monitor --zone $ZONE
```
---
## Task 2: Create Log-Based Metric for Input Queue Size
```bash
export METRIC=input_queue_size
```
```bash
gcloud logging metrics create $METRIC \
    --description="Metric for video input queue size" \
    --log-filter='textPayload=("file_format=4K" OR "file_format=8K")'
```
---
## Task 3: Create Log-Based Metric for High Resolution Video Upload Rate
This custom metric tracks the rate at which high resolution video files (4K or 8K) are uploaded to the Cloud Function.
```bash
export METRIC=big_video_upload_rate
```
```bash
gcloud logging metrics create $METRIC \
    --description="Metric for high resolution video uploads" \
    --log-filter='textPayload=("file_format=4K" OR "file_format=8K")'
```
---
## Task 4: Add Custom Metrics to Media Dashboard
Add two charts to the **Media_Dashboard** for custom metrics:
1. Video input queue length (from OpenCensus Go application)
2. High resolution video upload rate (from log-based metric created in Task 3)
```bash
# Use the metric from Task 3
export METRIC=big_video_upload_rate
# Step 1: Get the Media_Dashboard ID
export DASHBOARD_ID=$(gcloud monitoring dashboards list \
    --filter='displayName:"Media_Dashboard"' \
    --format='value(name)')
echo "Dashboard ID: $DASHBOARD_ID"
```
```bash
# Step 2: Get the current dashboard with etag included
gcloud monitoring dashboards describe $DASHBOARD_ID --format=json > current-dashboard.json
```
```bash
# Step 3: Extract the etag (you'll need jq or manually copy it)
# If you have jq installed:
export ETAG=$(jq -r '.etag' current-dashboard.json)
echo "Current etag: $ETAG"
# If you don't have jq, manually look at the file:
cat current-dashboard.json | grep etag
```
```bash
# Step 4: Create the updated dashboard JSON WITH the etag
cat > media-dashboard-updated.json <<EOF
{
  "displayName": "Media_Dashboard",
  "etag": "$ETAG",
  "gridLayout": {
    "widgets": [
      {
        "title": "Video Input Queue Length",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/opencensus/my.videoservice.org/measure/input_queue_size\" resource.type=\"gce_instance\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN"
                  }
                }
              },
              "plotType": "LINE",
              "targetAxis": "Y1"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "Queue Length",
            "scale": "LINEAR"
          }
        }
      },
      {
        "title": "High Resolution Video Upload Rate",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"logging.googleapis.com/user/$METRIC\" resource.type=\"global\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              },
              "plotType": "LINE",
              "targetAxis": "Y1"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "Upload Rate",
            "scale": "LINEAR"
          }
        }
      }
    ]
  }
}
EOF
```
```bash
# Step 5: Update the dashboard with the etag
gcloud monitoring dashboards update $DASHBOARD_ID \
    --config-from-file=media-dashboard-updated.json
```
---
## Task 5: Create Cloud Operations Alert Based on High Resolution Video Upload Rate
Create a custom alert that triggers when the upload rate for high resolution videos (4K or 8K) exceeds the specified threshold.
```bash
# Ensure we're using the correct metric from Task 3
export METRIC=big_video_upload_rate
# Create email notification channel
cat > email-channel.json <<EOF_END
{
  "type": "email",
  "displayName": "quickgcplab",
  "description": "Awesome",
  "labels": {
    "email_address": "$USER_EMAIL"
  }
}
EOF_END
```
```bash
gcloud beta monitoring channels create --channel-content-from-file="email-channel.json"
```
```bash
# Get the notification channel ID
email_channel_info=$(gcloud beta monitoring channels list)
email_channel_id=$(echo "$email_channel_info" | grep -oP 'name: \K[^ ]+' | head -n 1)
```
```bash
# Create the alert policy JSON
cat > quickgcplab.json <<EOF_END
{
  "displayName": "quickgcplab",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "VM Instance - logging/user/big_video_upload_rate",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"logging.googleapis.com/user/$METRIC\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": $VALUE
      }
    }
  ],
  "alertStrategy": {
    "notificationPrompts": [
      "OPENED"
    ]
  },
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [
    "$email_channel_id"
  ],
  "severity": "SEVERITY_UNSPECIFIED"
}
EOF_END
```
```bash
# Create the alert policy
gcloud alpha monitoring policies create --policy-from-file=quickgcplab.json
```
