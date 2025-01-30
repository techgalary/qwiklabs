# Implement Load Balancing on Compute Engine: Challenge Lab || [GSP313](https://www.cloudskillsboost.google/focuses/10258?parent=catalog) ||

## Solution [here](https://youtu.be/8JjC9tv2T-w)

### Set Variables
```
export INSTANCE=nucleus-jumphost-634
export FIREWALL=permit-tcp-rule-648
export ZONE=europe-west4-c
export REGION=europe-west4
```
### Task 1. Create a project jumphost instance ###
```
gcloud compute instances create $INSTANCE \
    --zone=$ZONE \
    --machine-type=e2-micro
```
### Task 2. Set up an HTTP load balancer ###
```
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF
```
```
gcloud compute instance-templates create web-server-template \
        --metadata-from-file startup-script=startup.sh \
        --machine-type e2-medium \
        --region $REGION
```
```
gcloud compute instance-groups managed create web-server-group \
        --base-instance-name web-server \
        --size 2 \
        --template web-server-template \
        --region $REGION
```
```
gcloud compute firewall-rules create $FIREWALL \
        --allow tcp:80 \
        --network default
```
```
gcloud compute http-health-checks create http-basic-check
```
```
gcloud compute instance-groups managed \
        set-named-ports web-server-group \
        --named-ports http:80 \
        --region $REGION
```
```
gcloud compute backend-services create web-server-backend \
        --protocol HTTP \
        --http-health-checks http-basic-check \
        --global
```
```
gcloud compute backend-services add-backend web-server-backend \
        --instance-group web-server-group \
        --instance-group-region $REGION \
        --global
```
```
gcloud compute url-maps create web-server-map \
        --default-service web-server-backend
```
```
gcloud compute target-http-proxies create http-lb-proxy \
        --url-map web-server-map
```
```
gcloud compute forwarding-rules create http-content-rule \
      --global \
      --target-http-proxy http-lb-proxy \
      --ports 80
```
```
gcloud compute forwarding-rules list
```
