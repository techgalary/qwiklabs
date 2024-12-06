# Migrate a MySQL Database to Google Cloud SQL: Challenge Lab || [GSP306](https://www.cloudskillsboost.google/focuses/1740?parent=catalog) ||

### Task 1: Create a New Cloud SQL Instance ###

#### Set Variables ####
```bash
export INSTANCE_ID="wordpress-db-instance"
export REGION="us-east1"
export ZONE="us-east1-c"
export ROOT_PASSWORD="admin123"
```
#### Create Cloud SQL Instance ####

```
gcloud sql instances create $INSTANCE_ID \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=$REGION \
    --root-password=$ROOT_PASSWORD \
    --storage-size=10GB
```
### Task 2: Configure the New Database ###
#### Set Variables ####
``` bash
DB_NAME="wordpress_db"
DB_USER="wp_user"
DB_PASSWORD="<wp_user_password>"
```
#### Create Database ####
```
gcloud sql databases create $DB_NAME --instance=$INSTANCE_ID
```
#### Create New Database user ####
```
gcloud sql users create $DB_USER \
    --instance=$INSTANCE_ID \
    --password=$DB_PASSWORD
```
#### Verify the configuration ####
```
gcloud sql databases list --instance=$INSTANCE_ID
gcloud sql users list --instance=$INSTANCE_ID
```
### Task 3: Perform a Database Dump and Import the Data ###
#### Export the Current database ####
```
mysqldump -u root -p wordpress_db > wordpress_db.sql
```

#### Upload the SQL Dump to a GCS Bucket ####
```
BUCKET_NAME="<your_bucket_name>"
gsutil cp wordpress_db.sql gs://$BUCKET_NAME/
```
#### Import the SQL Dump into Cloud SQL ####
```
gcloud sql import sql $INSTANCE_ID gs://$BUCKET_NAME/wordpress_db.sql \
    --database=$DB_NAME
```
#### Connect to the database and check if tables are imported ####
```
gcloud sql connect $INSTANCE_ID --user=$DB_USER
```
### Task 4: Reconfigure the WordPress Installation ###
#### Update wp-config.php: Locate and edit the wp-config.php file on your WordPress server ####
```
vi /var/www/html/wp-config.php
```
#### update the db details with following ####
```
define('DB_NAME', 'wordpress_db');
define('DB_USER', 'wp_user');
define('DB_PASSWORD', '<wp_user_password>');
define('DB_HOST', '<CLOUD_SQL_INSTANCE_PUBLIC_IP>');
```
#### Restart the webserver ####
```
sudo systemctl restart apache2
```
### Task 5: Validate and Troubleshoot ###

#### Test database connectivity ####
```
gcloud sql connect $INSTANCE_ID --user=$DB_USER
```
#### Check logs for errors in WordPress ####
```
tail -f /var/log/apache2/error.log
```

#### Ensure the WordPress server is authorized to access the database ####
```
gcloud sql instances patch $INSTANCE_ID \
    --authorized-networks=<WORDPRESS_SERVER_PUBLIC_IP>
```
