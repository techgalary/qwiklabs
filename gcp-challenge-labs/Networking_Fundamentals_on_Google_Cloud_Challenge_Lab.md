## 🚀 Networking Fundamentals on Google Cloud: Challenge Lab | [ARC124](https://partner.cloudskillsboost.google/catalog_lab/6528)

## 🌐 **Guide to Complete the Challenge Lab:**

### Export the Variables ###
```
export REGION="us-central1"
export ZONE="us-central1-b"
```
### Task 1. Create multiple web server instances ###
```
gcloud compute instances create web1 \
--zone=$ZONE \
--machine-type=e2-small \
--tags=network-lb-tag \
--image-family=debian-11 \
--image-project=debian-cloud \
--metadata=startup-script='#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo "<h3>Web Server: web1</h3>" | tee /var/www/html/index.html'
```
```
gcloud compute instances create web2 \
--zone=$ZONE \
--machine-type=e2-small \
--tags=network-lb-tag \
--image-family=debian-11 \
--image-project=debian-cloud \
--metadata=startup-script='#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo "<h3>Web Server: web2</h3>" | tee /var/www/html/index.html'
```
```
gcloud compute instances create web3 \
--zone=$ZONE \
--machine-type=e2-small \
--tags=network-lb-tag \
--image-family=debian-11 \
--image-project=debian-cloud \
--metadata=startup-script='#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo "<h3>Web Server: web3</h3>" | tee /var/www/html/index.html'
```
#### Create Firewall Rule ####
```
gcloud compute firewall-rules create www-firewall-network-lb --allow tcp:80 --target-tags network-lb-tag
```
### Task 2. Configure the load balancing service ###
#### Create Static External IP Address ####
```
gcloud compute addresses create network-lb-ip-1 \
    --region=$REGION
```
#### Create Health Check ####
```
gcloud compute http-health-checks create basic-check
```
#### Create target pool by the name www-pool ####
```
 gcloud compute target-pools create www-pool \
    --region=$REGION  --http-health-check basic-check
```
#### Add Instances into the target pool ####
```
gcloud compute target-pools add-instances www-pool \
    --instances web1,web2,web3 --zone=$ZONE
```
#### Create forwarding rules ####
```
gcloud compute forwarding-rules create www-rule \
    --region=$REGION \
    --ports 80 \
    --address network-lb-ip-1 \
    --target-pool www-pool
```
```
IPADDRESS=$(gcloud compute forwarding-rules describe www-rule --region=$REGION  --format="json" | jq -r .IPAddress)
```
### Task 3. Create an HTTP load balancer ###
#### Create Backend Template ####

```
gcloud compute instance-templates create lb-backend-template \
   --region=$REGION \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --machine-type=e2-medium \
   --image-family=debian-11 \
   --image-project=debian-cloud \
   --metadata=startup-script='#!/bin/bash
     apt-get update
     apt-get install apache2 -y
     a2ensite default-ssl
     a2enmod ssl
     vm_hostname="$(curl -H "Metadata-Flavor:Google" \
     http://169.254.169.254/computeMetadata/v1/instance/name)"
     echo "Page served from: $vm_hostname" | \
     tee /var/www/html/index.html
     systemctl restart apache2'
```
#### Create Managed instance group ####
```
gcloud compute instance-groups managed create lb-backend-group \
   --template=lb-backend-template --size=2 --zone=$ZONE 
```
#### Create Firewall rules ####
```

gcloud compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80
```
#### Create external ip address ####
```
gcloud compute addresses create lb-ipv4-1 \
  --ip-version=IPV4 \
  --global

```
#### Create Health Check ####
```
gcloud compute health-checks create http http-basic-check \
  --port 80
```
#### Create Backend Service ####
```
gcloud compute backend-services create web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-basic-check \
  --global

```
#### Attach Instance group to the backend service ####
```
gcloud compute backend-services add-backend web-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone=$ZONE \
  --global

```
#### Create URL maps ####
```
gcloud compute url-maps create web-map-http \
    --default-service web-backend-service

```
#### Create HTTP proxy ####
```
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http

```
#### Create the forwarding rules ####
```
gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1\
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80
```
