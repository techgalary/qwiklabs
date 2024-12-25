## Optimize Costs for Google Kubernetes Engine: Challenge Lab | [GSP343](https://www.cloudskillsboost.google/focuses/16327?parent=catalog)

## Youtube link [Here]()

## 🌐 **Guide to Complete the Challenge Lab**

#### Set the Environment Variables ####
```
export CLUSTER_NAME=onlineboutique-cluster-431
export POOL_NAME=optimized-pool-7111
export max_replicas=11
export ZONE=us-west1-a
```
### Task 1. Create a cluster and deploy your app ###
```
gcloud container clusters create $CLUSTER_NAME --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-standard-2 --num-nodes=2
```
#### Create Namespace ####
```
kubectl create namespace dev
kubectl create namespace prod
```
#### Clone the repo ####
```
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git &&
cd microservices-demo && kubectl apply -f ./release/kubernetes-manifests.yaml --namespace dev
```

### Task 2. Migrate to an optimized node pool ###
```
gcloud container node-pools create $POOL_NAME --cluster=$CLUSTER_NAME --machine-type=custom-2-3584 --num-nodes=2 --zone=$ZONE
```

#### cordoning off and draining default-pool ####
```
for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=default-pool -o=name); do  kubectl cordon "$node"; done
```
```
for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=default-pool -o=name); do kubectl drain --force --ignore-daemonsets --delete-local-data --grace-period=10 "$node"; done
```
#### Check pod ####
```
kubectl get pods -o=wide --namespace=dev
```
#### Delete the default node pool ####
```
gcloud container node-pools delete default-pool --cluster=$CLUSTER_NAME --project=$DEVSHELL_PROJECT_ID --zone $ZONE --quiet
```

### Task 3. Apply a frontend update ###
```
kubectl create poddisruptionbudget onlineboutique-frontend-pdb --selector app=frontend --min-available 1 --namespace dev
```
```
kubectl patch deployment frontend -n dev --type=json -p '[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/image",
    "value": "gcr.io/qwiklabs-resources/onlineboutique-frontend:v2.1"
  },
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/imagePullPolicy",
    "value": "Always"
  }
]'

```
### Task 4. Autoscale from estimated traffic ###
```
kubectl autoscale deployment frontend --cpu-percent=50 --min=1 --max=$MAX_REPLICAS --namespace dev
```
```
kubectl get hpa --namespace dev
```
```
gcloud beta container clusters update $CLUSTER_NAME --zone=$ZONE --project=$DEVSHELL_PROJECT_ID --enable-autoscaling --min-nodes 1 --max-nodes 6
```
