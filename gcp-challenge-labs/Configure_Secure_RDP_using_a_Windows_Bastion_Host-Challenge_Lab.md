# Configure Secure RDP using a Windows Bastion Host: Challenge Lab || [GSP303](https://www.cloudskillsboost.google/focuses/1737?parent=catalog) 
## Youtube Solution Video [here](https://youtu.be/iQdhq6gHBWc?si=bWUxCz_mIFi3q7aj)

### Set Variables ###
``` bash
export REGION=europe-west4
export ZONE=europe-west4-b
```
### Task 1. Create the VPC network ###
```
gcloud compute networks create securenetwork --subnet-mode custom
```
#### Create the subnet ####
```
gcloud compute networks subnets create securenetwork-subnet --network=securenetwork --region $REGION --range=192.168.16.0/20
```
#### Create the firewall rule ####
```
gcloud compute firewall-rules create rdp-ingress-fw-rule --allow=tcp:3389 --source-ranges 0.0.0.0/0 --target-tags allow-rdp-traffic --network securenetwork
```
### Task 2. Deploy your Windows instances and configure user passwords ###
```
gcloud compute instances create vm-bastionhost --zone=$ZONE --machine-type=e2-medium --network-interface=subnet=securenetwork-subnet --network-interface=subnet=default,no-address --tags=allow-rdp-traffic --image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220513
```
```
gcloud compute instances create vm-securehost --zone=$ZONE --machine-type=e2-medium --network-interface=subnet=securenetwork-subnet,no-address --network-interface=subnet=default,no-address --tags=allow-rdp-traffic --image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220513
```

#### Password reset ####
```
gcloud compute reset-windows-password vm-bastionhost --user app_admin --zone $ZONE 
```
```
gcloud compute reset-windows-password vm-securehost --user app_admin --zone $ZONE
```
### Task 3. Connect to the secure host and configure Internet Information Server ###
#### Refer the [video](https://youtu.be/iQdhq6gHBWc?si=bWUxCz_mIFi3q7aj) for configuring this

