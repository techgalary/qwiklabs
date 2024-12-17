# Use APIs to Work with Cloud Storage: Challenge Lab || [ARC125](https://www.cloudskillsboost.google/focuses/65991?parent=catalog) ||

## Solution [here]()

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
#### Use curl to call the JSON API to create the bucket1
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
#### Use curl to call the JSON API to create the bucket1
```
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data-binary @bucket2.json "https://storage.googleapis.com/storage/v1/b?project=$DEVSHELL_PROJECT_ID"
```
### Task 2. Upload an image file to a Cloud Storage Bucket ###

curl -LO https://raw.githubusercontent.com/QUICK-GCP-LAB/2-Minutes-Labs-Solutions/refs/heads/main/Use%20APIs%20to%20Work%20with%20Cloud%20Storage%20Challenge%20Lab/world.jpeg

# Step 6: Upload image file to bucket1
echo "${BOLD}${CYAN}Uploading the image file to bucket1...${RESET}"
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: image/jpeg" --data-binary @world.jpeg "https://storage.googleapis.com/upload/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o?uploadType=media&name=world.jpeg"

# Step 7: Copy the image from bucket1 to bucket2
echo "${BOLD}${RED}Copying the image from bucket1 to bucket2...${RESET}"
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" --data '{"destination": "$DEVSHELL_PROJECT_ID-bucket-2"}' "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/world.jpeg/copyTo/b/$DEVSHELL_PROJECT_ID-bucket-2/o/world.jpeg"

# Step 8: Set public access for the image
echo "${BOLD}${GREEN}Setting public access for the image...${RESET}"
cat > public_access.json <<EOF
{
  "entity": "allUsers",
  "role": "READER"
}
EOF


curl -X POST --data-binary @public_access.json -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/world.jpeg/acl"

# Call function to check progress before proceeding
check_progress

# Step 9: Delete the image from bucket1
echo "${BOLD}${CYAN}Deleting the image from bucket1...${RESET}"
curl -X DELETE -H "Authorization: Bearer $(gcloud auth print-access-token)" "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1/o/world.jpeg"

# Step 10: Delete bucket1
echo "${BOLD}${BLUE}Deleting bucket1...${RESET}"
curl -X DELETE -H "Authorization: Bearer $(gcloud auth print-access-token)" "https://storage.googleapis.com/storage/v1/b/$DEVSHELL_PROJECT_ID-bucket-1"

echo
