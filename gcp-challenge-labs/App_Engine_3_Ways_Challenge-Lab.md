## 🚀 App Engine: 3 Ways: Challenge Lab| [ARC112](https://www.cloudskillsboost.google/catalog_lab/6413)


## 🌐 **Guide to Complete the Challenge Lab:**

 **Launch Cloud Shell:**  
   Start your Google CloudShell session by [``clicking here``](https://console.cloud.google.com/home/dashboard?project=&pli=1&cloudshell=true).

### TASK 1 - Enable the Google App Engine Admin API #######
```bash
gcloud services enable appengine.googleapis.com
```
### TASK 2 - Download the Hello World app #######
```bash
gcloud compute ssh VM_INSTANCE_NAME --zone VM_ZONE
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
cd python-docs-samples/helloworld
```
#### To download PHP ###
```bash
git clone https://github.com/GoogleCloudPlatform/php-docs-samples.git
cd php-docs-samples/helloworld
```
#### To download Golang ###
```bash
git clone https://github.com/GoogleCloudPlatform/golang-samples.git
cd golang-samples/helloworld
```
### Task 3- Deploy your application ###
```bash
gcloud config set project PROJECT_ID #Set the project ID
gcloud config set app/region us-east4 #Set the region as per lab
cd python-docs-samples/helloworld #Path containing Python files
gcloud app deploy   # Deploy the App to App engine
gcloud app browse   # Confirm the App deployment
gcloud app browse   # Verify App Deployment
```
### Task 4- Deploy updates to your application ###

#### Edit the Application Code ####
1. Navigate to the directory containing the  app's code 
2. Open the source code file

##### 
For Python (main.py), Find the line that says "Hello, World!" and change it to "Hello, Cruel World!".
fmt.Fprintln(w, "Hello, Cruel World!")
For PHP (index.php): Locate the "Hello, World!" message and change it:
#####




