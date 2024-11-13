
## 🚀 Create and Manage AlloyDB Instances: Challenge Lab | [GSP395](https://www.cloudskillsboost.google/focuses/50123?parent=catalog)


## 🌐 **Quick Start Guide to Complete the Challenge Lab:**

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
export READPOOL_INSTANCE_NAME=""   # Replace with the Readpool instance name from the lab
export BACKUP_ID="SAMPLE-BACKUP_ID"  # Replace with the Backup ID provided in the lab
export CPU_COUNT=2                 # Adjust the CPU count if necessary
```
### Download and Execute the Script to Create Cluster and Instance-Task 1 ###
```bash
# Download the script from the repository
curl -LO raw.githubusercontent.com/techgalary/qwiklabs/refs/heads/main/scripts/instancecreation.sh

# Make the script executable
sudo chmod +x instancecreation.sh

# Run the script
./instancecreation.sh
```
### SET ENV Variable ####
```bash
export ALLOYDB_ADDRESS="YOUR_ALLOYDB_ADDRESS"  # Replace with the private IP address of the AlloyDB instance
echo $ALLOYDB > alloydbip.txt
```
### Task2, 3 and 4 ###
``` bash
psql -h $ALLOYDB -U postgres
```
## Create the Tables ##
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
## Load Data to Regions Table ##
``` bash
INSERT INTO regions VALUES 
(1, 'Europe'), 
(2, 'Americas'), 
(3, 'Asia'), 
(4, 'Middle East and Africa');
```





