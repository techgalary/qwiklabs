
## 🚀 Create and Manage AlloyDB Instances: Challenge Lab | [GSP395](https://www.cloudskillsboost.google/focuses/50123?parent=catalog)


## 🌐 **Quick Start Guide to Complete the Challenge Lab:**

 **Launch Cloud Shell:**  
   Start your Google CloudShell session by [``clicking here``](https://console.cloud.google.com/home/dashboard?project=&pli=1&cloudshell=true).

### Set the Environment Variables #######
```bash

CLUSTER_NAME="lab-cluster"  # Replace with the Cluster name from Task 1
REGION="us-east-1"          # Replace with the region specified in the lab
NETWORK="peering-network"   # Replace with the network name as needed
PROJECT_ID="QWIKLABS_PROJECT_ID"  # Replace with your Qwiklabs Project ID
PASSWORD="Change3Me"        # Replace with your password as needed
PRIMARY_INSTANCE_NAME="lab-instance"  # Replace with the instance name from Task 1
READPOOL_INSTANCE_NAME=""   # Replace with the Readpool instance name from the lab
BACKUP_ID="SAMPLE-BACKUP_ID"  # Replace with the Backup ID provided in the lab
CPU_COUNT=2                 # Adjust the CPU count if necessary
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

```
### Download and Execute the Script to Complete Task2, 3 and 4 ###
``` bash
curl -LO raw.githubusercontent.com/techgalary/qwiklabs/refs/heads/main/scripts/managealloydb.sh

# Make the script executable
sudo chmod +x managealloydb.sh

# Run the script
./managealloydb.sh
```



