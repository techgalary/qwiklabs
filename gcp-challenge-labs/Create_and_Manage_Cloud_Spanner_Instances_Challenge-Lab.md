## Create and Manage Cloud Spanner Instances: Challenge Lab| [GSP381](https://www.cloudskillsboost.google/catalog_lab/5731)

## Youtube Explanation Video [here](https://youtu.be/GXHFMA3zZL4)

## 🌐 **Guide to Complete the Challenge Lab:**

### Set Environment Variables ###
#### NOTE: UPDATE THE REGION AND BUCKET_NAME as per your lab #####
```
export REGION=us-east1  
export BUCKET_NAME=qwiklabs-gcp-01-026491e087be
```
### Task 1. Create a Cloud Spanner instance ###
```
gcloud spanner instances create banking-ops-instance \
    --config=regional-$REGION \
    --description="Banking Operations Instance" \
    --nodes=1
```
### Task 2. Create a Cloud Spanner database ###
```
gcloud spanner databases create banking-ops-db \
    --instance=banking-ops-instance
```

### Task 3. Create tables in your database ###
#### DDL Statements for Table Creation ####

#### paste below ddl statement in Query and run ####
```

CREATE TABLE Portfolio (
  PortfolioId INT64 NOT NULL,
  Name STRING(MAX),
  ShortName STRING(MAX),
  PortfolioInfo STRING(MAX)
) PRIMARY KEY (PortfolioId);

CREATE TABLE Category (
  CategoryId INT64 NOT NULL,
  PortfolioId INT64 NOT NULL,
  CategoryName STRING(MAX),
  PortfolioInfo STRING(MAX)
) PRIMARY KEY (CategoryId);

CREATE TABLE Product (
  ProductId INT64 NOT NULL,
  CategoryId INT64 NOT NULL,
  PortfolioId INT64 NOT NULL,
  ProductName STRING(MAX),
  ProductAssetCode STRING(25),
  ProductClass STRING(25)
) PRIMARY KEY (ProductId);

CREATE TABLE Customer (
  CustomerId STRING(36) NOT NULL,
  Name STRING(MAX) NOT NULL,
  Location STRING(MAX) NOT NULL
) PRIMARY KEY (CustomerId);
```
### Task 4. Load simple datasets into tables ###

#### DML Commands for Loading Data ####
##### Load Data into the Portfolio Table #####

##### Paste below snippet  #####
```
INSERT INTO Portfolio (PortfolioId, Name, ShortName, PortfolioInfo) VALUES
  (1, "Banking", "Bnkg", "All Banking Business"),
  (2, "Asset Growth", "AsstGrwth", "All Asset Focused Products"),
  (3, "Insurance", "Insurance", "All Insurance Focused Products");
```
##### Load Data into the Category Table #####
##### Paste below snippet #####
```
INSERT INTO Category (CategoryId, PortfolioId, CategoryName, PortfolioInfo) VALUES
  (1, 1, "Cash", NULL),
  (2, 2, "Investments - Short Return", NULL),
  (3, 2, "Annuities", NULL),
  (4, 3, "Life Insurance", NULL);
```
##### Load Data into the Product Table #####
##### Paste below snippet #####
```
INSERT INTO Product (ProductId, CategoryId, PortfolioId, ProductName, ProductAssetCode, ProductClass) VALUES
  (1, 1, 1, "Checking Account", "ChkAcct", "Banking LOB"),
  (2, 2, 2, "Mutual Fund Consumer Goods", "MFundCG", "Investment LOB"),
  (3, 3, 2, "Annuity Early Retirement", "AnnuFixed", "Investment LOB"),
  (4, 4, 3, "Term Life Insurance", "TermLife", "Insurance LOB"),
  (5, 1, 1, "Savings Account", "SavAcct", "Banking LOB"),
  (6, 1, 1, "Personal Loan", "PersLn", "Banking LOB"),
  (7, 1, 1, "Auto Loan", "AutLn", "Banking LOB"),
  (8, 4, 3, "Permanent Life Insurance", "PermLife", "Insurance LOB"),
  (9, 2, 2, "US Savings Bonds", "USSavBond", "Investment LOB");
```

### Task 5. Load a complex dataset ###
#### Download the csv file ####
```
gsutil cp gs://cloud-training/OCBL375/Customer_List_500.csv .
```
#### Enable APIs ####
```
gcloud services enable dataflow.googleapis.com
gcloud services enable spanner.googleapis.com
```
#### Create manifest.json file ####
```
cat > manifest.json << EOF_CP
{
  "tables": [
    {
      "table_name": "Customer",
      "file_patterns": [
        "gs://cloud-training/OCBL375/Customer_List_500.csv"
      ],
      "columns": [
        {"column_name" : "CustomerId", "type_name" : "STRING" },
        {"column_name" : "Name", "type_name" : "STRING" },
        {"column_name" : "Location", "type_name" : "STRING" }
      ]
    }
  ]
}
EOF_CP
```
##### Create S3 bucket #####
```
gcloud storage buckets create gs://$BUCKET_NAME --location=$REGION
gsutil cp manifest.json gs://$BUCKET_NAME

```
#### Run datafow job ####
```
gcloud dataflow jobs run spanner-import-job \
    --gcs-location=gs://dataflow-templates/latest/GCS_Text_to_Cloud_Spanner \
    --region=$REGION\
    --parameters=instanceId="banking-ops-instance",databaseId="banking-ops-db",importManifest="gs://$BUCKET_NAME/manifest.json"
```

### Task 6. Add a new column to an existing table ###
```
gcloud spanner databases ddl update banking-ops-db \
--instance=banking-ops-instance \
--ddl="ALTER TABLE Category ADD COLUMN MarketingBudget INT64;"

```
#### Verify the data ####
```
gcloud spanner databases ddl describe banking-ops-db --instance=banking-ops-instance
```
