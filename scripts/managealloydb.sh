#!/bin/bash

# Task 1: Creation of AlloyDB cluster
gcloud beta alloydb clusters create "$CLUSTER_NAME" \
    --password="$PASSWORD" \
    --network="$NETWORK" \
    --region="$REGION" \
    --project="$PROJECT_ID"

if [ $? -eq 0 ]; then
    echo "AlloyDB cluster $CLUSTER_NAME created successfully."
else
    echo "Failed to create AlloyDB cluster $CLUSTER_NAME. Check for errors and try again."
    exit 1
fi

# Task 1: Create the primary instance
gcloud beta alloydb instances create "$PRIMARY_INSTANCE_NAME" \
    --instance-type=PRIMARY \
    --cpu-count="$CPU_COUNT" \
    --region="$REGION" \
    --cluster="$CLUSTER_NAME" \
    --project="$PROJECT_ID"

if [ $? -eq 0 ]; then
    echo "Primary instance $PRIMARY_INSTANCE_NAME created successfully."
else
    echo "Failed to create primary instance $PRIMARY_INSTANCE_NAME. Check for errors and try again."
    exit 1
fi

# Task 2: Connect to the AlloyDB instance and create tables
echo "Connecting to AlloyDB instance to create tables..."
export ALLOYDB="$ALLOYDB_ADDRESS"
echo $ALLOYDB > alloydbip.txt

psql -h $ALLOYDB -U postgres <<EOF
-- Create tables
CREATE TABLE regions (
    region_id bigint NOT NULL,
    region_name varchar(25),
    PRIMARY KEY (region_id)
);

CREATE TABLE countries (
    country_id char(2) NOT NULL,
    country_name varchar(40),
    region_id bigint,
    PRIMARY KEY (country_id)
);

CREATE TABLE departments (
    department_id smallint NOT NULL,
    department_name varchar(30),
    manager_id integer,
    location_id smallint,
    PRIMARY KEY (department_id)
);
EOF

if [ $? -eq 0 ]; then
    echo "Tables created successfully."
else
    echo "Failed to create tables. Check for errors and try again."
    exit 1
fi

# Task 3: Load simple datasets into tables
echo "Loading data into tables..."

psql -h $ALLOYDB -U postgres <<EOF
-- Insert data into regions
INSERT INTO regions VALUES 
(1, 'Europe'), 
(2, 'Americas'), 
(3, 'Asia'), 
(4, 'Middle East and Africa');

-- Insert data into countries
INSERT INTO countries VALUES 
('IT', 'Italy', 1), 
('JP', 'Japan', 3), 
('US', 'United States of America', 2), 
('CA', 'Canada', 2), 
('CN', 'China', 3), 
('IN', 'India', 3), 
('AU', 'Australia', 3), 
('ZW', 'Zimbabwe', 4), 
('SG', 'Singapore', 3);

-- Insert data into departments
INSERT INTO departments VALUES 
(10, 'Administration', 200, 1700), 
(20, 'Marketing', 201, 1800), 
(30, 'Purchasing', 114, 1700), 
(40, 'Human Resources', 203, 2400), 
(50, 'Shipping', 121, 1500), 
(60, 'IT', 103, 1400);
EOF

if [ $? -eq 0 ]; then
    echo "Data loaded successfully into tables."
else
    echo "Failed to load data into tables. Check for errors and try again."
    exit 1
fi

# Task 4: Create a Read Pool instance
gcloud beta alloydb instances create $READPOOL_INSTANCE_NAME \
    --instance-type=READ_POOL \
    --cpu-count=2 \
    --read-pool-node-count=2 \
    --region="$REGION" \
    --cluster="$CLUSTER_NAME" \
    --project="$PROJECT_ID"

if [ $? -eq 0 ]; then
    echo "Read pool instance $READPOOL_NAME created successfully."
else
    echo "Failed to create read pool instance $READPOOL_NAME. Check for errors and try again."
    exit 1
fi

# Task 5: Create a backup
gcloud beta alloydb backups create "$BACKUP_ID" \
    --cluster="$CLUSTER_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID"

if [ $? -eq 0 ]; then
    echo "Backup $BACKUP_ID created successfully."
else
    echo "Failed to create backup $BACKUP_ID. Check for errors and try again."
    exit 1
fi
