# Connecting Cloud Networks with NCC: Challenge Lab || [GSP528]( )||

## Youtube Solution [here]()

### Task 1. Connect 2 On-prem VPCs with NCC ###

#### Set up environment variables
```
export REGION=us-central1
export PROJECT_ID=$(gcloud config get-value project)
gcloud config set compute/region $REGION
```
#### Step 1: Verify VPN Tunnels

```
gcloud compute vpn-tunnels list

```
#### Step 2: Create Routing VPC
```
gcloud compute networks create routing-vpc \
    --subnet-mode=custom

gcloud compute networks subnets create routing-subnet \
    --network=routing-vpc \
    --region=$REGION \
    --range=10.100.0.0/16
```
#### Step 3: Create NCC Hub
```
gcloud network-connectivity hubs create routing-hub \
    --description="Central NCC Hub for on-prem connectivity"

```
#### Step 4: Create Spokes (VPN Type)
##### On-Prem Office 1

```
gcloud network-connectivity spokes create spoke-office-1 \
    --hub=routing-hub \
    --region=$REGION \
    --vpn-tunnel=vpn-office1-tunnel1,vpn-office1-tunnel2 \
    --description="Spoke connection for On-Prem Office 1"

```
##### On-Prem Office 2
```
gcloud network-connectivity spokes create spoke-office-2 \
    --hub=routing-hub \
    --region=$REGION \
    --vpn-tunnel=vpn-office2-tunnel1,vpn-office2-tunnel2 \
    --description="Spoke connection for On-Prem Office 2"
```
#### Step 5: Verify Setup
```
gcloud network-connectivity spokes list --region=$REGION
```
#### Step 6: Deploy Test VMs
##### On-Prem Office 1
```
gcloud compute instances create vm-office1 \
  --zone=us-central1-a \
  --network=onprem-office1-vpc \
  --subnet=onprem-office1-subnet \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=icmp-allow
```
##### On-Prem Office 2
```
gcloud compute instances create vm-office2 \
  --zone=us-central1-b \
  --network=onprem-office2-vpc \
  --subnet=onprem-office2-subnet \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=icmp-allow
```
#### Step 7: Allow ICMP
```
gcloud compute firewall-rules create allow-icmp-office1 \
  --network=onprem-office1-vpc --allow=icmp

gcloud compute firewall-rules create allow-icmp-office2 \
  --network=onprem-office2-vpc --allow=icmp

```
#### Step 8: Test Connectivity
##### SSH into one VM and ping the other

```
gcloud compute ssh vm-office1 --zone=us-central1-a
ping 10.2.0.5

```
### TASK 2: Connect VPC to VPC using NCC

#### Step 1: Create Workload VPCs

```
gcloud compute networks create workload-vpc-1 --subnet-mode=custom
gcloud compute networks subnets create workload1-subnet \
  --network=workload-vpc-1 --region=$REGION --range=10.10.0.0/16

gcloud compute networks create workload-vpc-2 --subnet-mode=custom
gcloud compute networks subnets create workload2-subnet \
  --network=workload-vpc-2 --region=$REGION --range=10.20.0.0/16

```
#### Step 2: Create NCC Hub
```
gcloud network-connectivity hubs create workload-hub \
  --description="Hub for connecting Workload VPCs"

```
#### Step 3: Create Spokes (VPC Network Type)
##### Workload VPC 1
```
gcloud network-connectivity spokes create spoke-workload-1 \
  --hub=workload-hub \
  --region=$REGION \
  --vpc-network=workload-vpc-1 \
  --description="Spoke for Workload VPC 1"

```
##### Workload VPC 2
```
gcloud network-connectivity spokes create spoke-workload-2 \
  --hub=workload-hub \
  --region=$REGION \
  --vpc-network=workload-vpc-2 \
  --description="Spoke for Workload VPC 2"
```

#### Step 4: Verify
```
gcloud network-connectivity spokes list --region=$REGION

```
#### Step 5: Deploy Test VMs

```
gcloud compute instances create vm-workload1 \
  --zone=us-central1-a \
  --network=workload-vpc-1 \
  --subnet=workload1-subnet \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=icmp-allow

gcloud compute instances create vm-workload2 \
  --zone=us-central1-b \
  --network=workload-vpc-2 \
  --subnet=workload2-subnet \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=icmp-allow

```
#### Step 6: Allow ICMP
```
gcloud compute firewall-rules create allow-icmp-workload1 \
  --network=workload-vpc-1 --allow=icmp

gcloud compute firewall-rules create allow-icmp-workload2 \
  --network=workload-vpc-2 --allow=icmp
```
#### Step 7: Test Connectivity
```
gcloud compute ssh vm-workload1 --zone=us-central1-a
ping 10.20.0.5

```
### TASK 3: Connect On-Prem and Cloud VPC using NCC

#### Step 1: Create NCC Hub
```
gcloud network-connectivity hubs create hybrid-hub \
  --description="Hub for On-Prem and Cloud hybrid connection"

```
#### Step 2: Create Spokes
##### Spoke 1 — On-Prem Office 1 (VPN Type)
```
gcloud network-connectivity spokes create hybrid-office1 \
  --hub=hybrid-hub \
  --region=$REGION \
  --vpn-tunnel=vpn-office1-tunnel1,vpn-office1-tunnel2 \
  --description="Hybrid spoke for On-Prem Office 1"

```
##### Spoke 2 — Workload VPC 1 (VPC Type)
```
gcloud network-connectivity spokes create hybrid-workload1 \
  --hub=hybrid-hub \
  --region=$REGION \
  --vpc-network=workload-vpc-1 \
  --description="Hybrid spoke for Workload VPC 1"

```
#### Step 3: Verify Setup
```
gcloud network-connectivity spokes list --region=$REGION

```
#### Step 4: Deploy Test VMs
```
gcloud compute instances create vm-hybrid-office1 \
  --zone=us-central1-a \
  --network=onprem-office1-vpc \
  --subnet=onprem-office1-subnet \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=icmp-allow

gcloud compute instances create vm-hybrid-workload1 \
  --zone=us-central1-b \
  --network=workload-vpc-1 \
  --subnet=workload1-subnet \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=icmp-allow
```
#### Step 5: Allow ICMP
```
gcloud compute firewall-rules create allow-icmp-hybrid-office1 \
  --network=onprem-office1-vpc --allow=icmp

gcloud compute firewall-rules create allow-icmp-hybrid-workload1 \
  --network=workload-vpc-1 --allow=icmp

```
#### Step 6: Test Connectivity

##### SSH into the On-Prem VM and ping the Workload VM
```
gcloud compute ssh vm-hybrid-office1 --zone=us-central1-a
ping 10.10.0.5
```
