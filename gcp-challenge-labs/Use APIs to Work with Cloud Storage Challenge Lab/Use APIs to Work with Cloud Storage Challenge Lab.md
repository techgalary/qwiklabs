# Use APIs to Work with Cloud Storage: Challenge Lab || [ARC125](https://www.cloudskillsboost.google/focuses/65991?parent=catalog) ||

## Solution [here](https://youtu.be/zqbE3OmnwIA)

### Task 1. Create two Cloud Storage buckets ###
#### Create bucket1.json ####
```
cat > bucket1.json <<EOF
{  
   "name": "$DEVSHELL_PROJECT_ID-bucket-1",
   "location": "us",
   "storageClass": "multi_regional"
}
EOF
```
#### Use curl to call the JSON API to create the bucket1 ####
```
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data-binary @bucket1.json "https://storage.googleapis.com/storage/v1/b?project=$DEVSHELL_PROJECT_ID"
```

#### Create bucket2.json
```
cat > bucket2.json <<EOF
{  
   "name": "$DEVSHELL_PROJECT_ID-bucket-2",
   "location": "us",
   "storageClass": "multi_regional"
}
EOF
```
#### Use curl to call the JSON API to create the bucket2
```
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data-binary @bucket2.json "https://storage.googleapis.com/storage/v1/b?project=$DEVSHELL_PROJECT_ID"
```
### Task 2. Upload an image file to a Cloud Storage Bucket ###
```
curl -LO https://raw.githubusercontent.com/techgalary/qwiklabs/tree/main/gcp-challenge-labs/Use%20APIs%20to%20Work%20with%20Cloud%20Storage%20Challenge%20Lab/world.jpeg
```

#### Use curl to call the JSON API that uploads the file to the bucket
```
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: image/jpeg" --data-binary @world.jpeg "https://storage.googleapis.com/upload/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o?uploadType=media&name=world.jpeg"
```
### Task 3. Copy a file to another bucket
```
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data '{"destination": "$DEVSHELL_PROJECT_ID-bucket-2"}' "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/world.jpeg/copyTo/b/$DEVSHELL_PROJECT_ID-bucket-2/o/world.jpeg"
```
### Task 4. Make an object (file) publicly accessible
#### Create a JSON file that has the following code
```
cat > public_access.json <<EOF
{
  "entity": "allUsers",
  "role": "READER"
}
EOF

```
#### Use curl to call the JSON API and make the object (file) publicly accessible.
```
curl -X POST --data-binary @public_access.json -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/world.jpeg/acl"
```
### Task 5. Delete the object file and a Cloud Storage bucket (Bucket 1)
#### Delete the image from bucket1
```
curl -X DELETE -H "Authorization: Bearer $(gcloud auth print-access-token)" "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/world.jpeg"
```
#### Delete bucket1
```
curl -X DELETE -H "Authorization: Bearer $(gcloud auth print-access-token)" "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1"
```
