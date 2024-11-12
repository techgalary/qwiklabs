


## 🚀 Create and Manage AlloyDB Instances: Challenge Lab | [GSP395](https://www.cloudskillsboost.google/focuses/50123?parent=catalog)


## 🌐 **Quick Start Guide:**

 **Launch Cloud Shell:**  
   Start your Google CloudShell session by [``clicking here``](https://console.cloud.google.com/home/dashboard?project=&pli=1&cloudshell=true).

### Set the Environment Variables #######
CLUSTER_NAME="lab-cluster"  **Replace with the Cluster name in Task1**
REGION="us-east-1"         **Replace the region mentioned in the lab**
NETWORK="peering-network"           
PROJECT_ID="QWIKLABS_PROJECT_ID"   **Replace the QWIKLABS_PROJECT_ID with correct name**
PASSWORD="Change3Me"         
PRIMARY_INSTANCE_NAME="lab-instance"  #Replace with the instance name mentioned in Task1
READPOOL_INSTANCE_NAME="" #Replace with the Readpool instance name mentioned in the lab
BACKUP_ID="SAMPLE-BACKUP_ID"      #Replace with the Backup id name provided in the lab 
CPU_COUNT=2                        

curl -LO raw.githubusercontent.com/techgalary/qwiklabs/refs/heads/main/scripts/managealloydb.sh
sudo chmod +x managealloydb.sh

./managealloydb.sh


