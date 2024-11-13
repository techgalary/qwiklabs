
## 🚀 Create and Manage AlloyDB Instances: Challenge Lab | [GSP395](https://www.cloudskillsboost.google/focuses/50123?parent=catalog)


## 🌐 **Guide to Complete the Challenge Lab:**

 **Launch Cloud Shell:**  
   Start your Google CloudShell session by [``clicking here``](https://console.cloud.google.com/home/dashboard?project=&pli=1&cloudshell=true).

### Set the Environment Variables #######
```bash

export CLUSTER_NAME="lab-cluster" # Replace with the Cluster name from Task 1
export REGION="us-east-1"          # Replace with the region specified in the lab
export NETWORK="peering-network"   # Replace with the network name as needed
export PROJECT_ID="QWIKLABS_PROJECT_ID"  # Replace with your Qwiklabs Project ID
export PASSWORD="Change3Me"        # Replace with your password as needed
export PRIMARY_INSTANCE_NAME="lab-instance"  # Replace with the instance name from Task 1
export READPOOL_INSTANCE_NAME="lab-instance-rp1"   # Replace with the Readpool instance name from the lab
export BACKUP_ID="lab-backup"  # Replace with the Backup ID provided in the lab
export CPU_COUNT=2                 # Adjust the CPU count if necessary
```
### Task 1. Download and Execute the Script to Create Cluster and Instance ###
```bash
# Download the script from the repository
curl -LO raw.githubusercontent.com/techgalary/qwiklabs/refs/heads/main/scripts/instancecreation.sh

# Make the script executable
sudo chmod +x instancecreation.sh

# Run the script
./instancecreation.sh
```
### Or Execute Below commands to create Cluster and Instance ###
```bash
gcloud beta alloydb clusters create $CLUSTER_NAME \
    --password=$PASSWORD \
    --network=$NETWORK \
    --region=$REGION \
    --project=$PROJECT_ID
```
```bash
gcloud beta alloydb instances create $PRIMARY_INSTANCE_NAME \
    --instance-type=PRIMARY \
    --cpu-count=2 \
    --region=$REGION  \
    --cluster=$CLUSTER_NAME \
    --project=$PROJECT_ID
```
### SET ENV Variable ####
```bash
export ALLOYDB_ADDRESS="YOUR_ALLOYDB_ADDRESS"  # Replace with the private IP address of the AlloyDB instance
echo $ALLOYDB > alloydbip.txt
```
### Connect to postgres client ###
``` bash
psql -h $ALLOYDB -U postgres
```
### Task 2. Create tables in your instance ###
``` bash
CREATE TABLE regions (
    region_id bigint NOT NULL,
    region_name varchar(25)
);
ALTER TABLE regions ADD PRIMARY KEY (region_id);
```
```bash
CREATE TABLE countries (
    country_id char(2) NOT NULL,
    country_name varchar(40),
    region_id bigint
);
ALTER TABLE countries ADD PRIMARY KEY (country_id);
```
```bash
CREATE TABLE departments (
    department_id smallint NOT NULL,
    department_name varchar(30),
    manager_id integer,
    location_id smallint
);
ALTER TABLE departments ADD PRIMARY KEY (department_id);
```
## Verifying Table Creation ##
```bash
/dt
```
## Task 3. Load simple datasets into tables ##
``` bash
### Load Data to Regions Table ###
INSERT INTO regions VALUES 
(1, 'Europe'), 
(2, 'Americas'), 
(3, 'Asia'), 
(4, 'Middle East and Africa');
```
```bash
### Load Data to Countries Table ###
INSERT INTO countries VALUES 
('IT', 'Italy', 1), 
('JP', 'Japan', 3), 
('US', 'United States of America', 2), 
('CA', 'Canada', 2), 
('CN', 'China', 3), 
('IN', 'India', 3), 
('AU', 'Australia', 3), 
('ZW', 'Zimbabwe', 4), 
('SG', 'Singapore', 3);
```
```bash
### Load data into the departments table ###
INSERT INTO departments VALUES 
(10, 'Administration', 200, 1700), 
(20, 'Marketing', 201, 1800), 
(30, 'Purchasing', 114, 1700), 
(40, 'Human Resources', 203, 2400), 
(50, 'Shipping', 121, 1500), 
(60, 'IT', 103, 1400);
```

### Verify the Data Loaded into Table ###
```bash
### Check regions table ###
SELECT * FROM regions;
```
```bash
### Check countries table ###
SELECT * FROM countries;
```
```bash
### Check departments table ###
SELECT * FROM departments;
```
### Task 4. Create a Read Pool instance ###
```bash
gcloud beta alloydb instances create "$READPOOL_INSTANCE_NAME" \
  --cluster="$CLUSTER_NAME" \
  --instance-type=READ_POOL \
  --read-pool-node-count=2 \
  --region="$REGION" \
  --cpu-count=2 \
  --project="$PROJECT_ID"
```
### Task 5. Create a backup ###
``` bash
gcloud beta alloydb backups create "$BACKUP_ID" \
    --cluster="$CLUSTER_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID"
```




