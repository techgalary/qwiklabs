# Monitor Environments with Google Cloud Managed Service for Prometheus: Challenge Lab || [GSP364](https://www.cloudskillsboost.google/focuses/33337?parent=catalog) ||

## Youtube [link]

#### Set Environment Variables ####

```
export ZONE=us-east-1-a
```
### Task 1. Deploy a GKE cluster ###
```
gcloud container clusters create gcprom-cluster --num-nodes=3 --zone=$ZONE
```
```
gcloud container clusters get-credentials  gcprom-cluster --zone=$ZONE
```
```
kubectl create ns  gcprom-test
```

### Task 2. Deploy a managed collection ###

```
kubectl -n  gcprom-test apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/v0.2.3/manifests/setup.yaml

kubectl -n  gcprom-test apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/v0.2.3/manifests/operator.yaml
```
### Task 3. Deploy an example application ###
```
kubectl -n  gcprom-test apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/v0.2.3/examples/example-app.yaml
```

### Task 4. Filter exported metrics ###
```
cat > op-config.yaml <<'EOF_END'
apiVersion: monitoring.googleapis.com/v1alpha1
collection:
  filter:
    matchOneOf:
    - '{job="prom-example"}'
    - '{__name__=~"job:.+"}'
kind: OperatorConfig
metadata:
  annotations:
    components.gke.io/layer: addon
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"monitoring.googleapis.com/v1alpha1","kind":"OperatorConfig","metadata":{"annotations":{"components.gke.io/layer":"addon"},"labels":{"addonmanager.kubernetes.io/mode":"Reconcile"},"name":"config","namespace":" gcprom-public"}}
  creationTimestamp: "2022-03-14T22:34:23Z"
  generation: 1
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
  name: config
  namespace:  gcprom-public
  resourceVersion: "2882"
  uid: 4ad23359-efeb-42bb-b689-045bd704f295
EOF_END
```
```
export PROJECT=$(gcloud config get-value project)
```
```
gsutil mb -p $PROJECT gs://$PROJECT

gsutil cp op-config.yaml gs://$PROJECT

gsutil -m acl set -R -a public-read gs://$PROJECT
```
