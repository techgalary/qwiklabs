# Create and Manage Bigtable Instances: Challenge Lab || [GSP380](https://www.cloudskillsboost.google/focuses/92500?parent=catalog) 

### Task 1. Create a new Bigtable instance ###
```
gcloud bigtable instances create ecommerce-recommendations \
  --cluster=ecommerce-recommendations-c1 \
  --cluster-zone=us-west1-b \
  --cluster-autoscaling \
  --cluster-min-nodes=1 \
  --cluster-max-nodes=5 \
  --cluster-cpu-utilization-target=60 \
  --display-name="Ecommerce Recommendations" \
  --storage-type=SSD
```
### Task 2. Create and populate Bigtable tables ###
#### Create and Populate the SessionHistory Table ####
##### Step 1 Create the SessionHistory Table #####
```
gcloud bigtable tables create SessionHistory \
  --instance=ecommerce-recommendations \
  --column-families=Engagements=1,Sales=1
```
##### Step 2 Create a Dataflow Job to Load Data #####
```
gcloud dataflow jobs run import-sessions \
  --gcs-location gs://dataflow-templates/latest/SequenceFile-to-Cloud-Bigtable \
  --region us-west1 \
  --parameters \
inputFile=gs://cloud-training/OCBL377/retail-engagements-sales-00000-of-00001,\
bigtableInstanceId=ecommerce-recommendations,\
bigtableTableId=SessionHistory,\
bigtableProjectId=$(gcloud config get-value project)

```
#### Part 2 Create and Populate the PersonalizedProducts Table ####

##### Step 1 Create the PersonalizedProducts Table #####
```
gcloud bigtable tables create PersonalizedProducts \
  --instance=ecommerce-recommendations \
  --column-families=Recommendations=1
```

##### Step 2 Create a Dataflow Job to Load Data #####
```
gcloud dataflow jobs run import-recommendations \
  --gcs-location gs://dataflow-templates/latest/SequenceFile-to-Cloud-Bigtable \
  --region us-west1 \
  --parameters \
inputFile=gs://cloud-training/OCBL377/retail-recommendations-00000-of-00001,\
bigtableInstanceId=ecommerce-recommendations,\
bigtableTableId=PersonalizedProducts,\
bigtableProjectId=$(gcloud config get-value project)

```
### Task 3 Configure replication in Bigtable ###
```
gcloud bigtable clusters create ecommerce-recommendations-c2 \
  --instance=ecommerce-recommendations \
  --zone=us-west1-c \
  --cluster-autoscaling \
  --cluster-min-nodes=1 \
  --cluster-max-nodes=5 \
  --cluster-cpu-utilization-target=60
```
### Task 4 Back up and restore data in Bigtable ###
```
gcloud bigtable backups create PersonalizedProducts_7 \
  --instance=ecommerce-recommendations \
  --cluster=ecommerce-recommendations-c1 \
  --table=PersonalizedProducts \
  --expire-time=$(date -u -d "+7 days" '+%Y-%m-%dT%H:%M:%SZ')
```
#### Restore the Backup ####
```
gcloud bigtable backups restore PersonalizedProducts_7 \
  --instance=ecommerce-recommendations \
  --cluster=ecommerce-recommendations-c1 \
  --table=PersonalizedProducts_7_restored
```
### Task 5 Delete Bigtable data ###

##### Delete each table #####
```
gcloud bigtable tables delete SessionHistory \
  --instance=ecommerce-recommendations

gcloud bigtable tables delete PersonalizedProducts \
  --instance=ecommerce-recommendations

gcloud bigtable tables delete PersonalizedProducts_7_restored \
  --instance=ecommerce-recommendations
```

##### Delete All Backups #####
```
gcloud bigtable backups delete PersonalizedProducts_7 \
  --instance=ecommerce-recommendations \
  --cluster=ecommerce-recommendations-c1
```
##### Delete the Bigtable Instance #####

```
gcloud bigtable instances delete ecommerce-recommendations
```
