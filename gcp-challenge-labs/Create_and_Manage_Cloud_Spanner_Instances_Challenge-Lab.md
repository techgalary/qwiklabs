## 🚀 Create and Manage Cloud Spanner Instances: Challenge Lab| [GSP381](https://www.cloudskillsboost.google/catalog_lab/5731)


## 🌐 **Guide to Complete the Challenge Lab:**

### Task 1. Create a Cloud Spanner instance ###
```
gcloud spanner instances create banking-ops-instance \
    --config=regional-us-east4 \
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

```
-- Create Portfolio Table
CREATE TABLE Portfolio (
  PortfolioId INT64 NOT NULL,
  Name STRING(MAX),
  ShortName STRING(MAX),
  PortfolioInfo STRING(MAX)
) PRIMARY KEY (PortfolioId);

-- Create Category Table
CREATE TABLE Category (
  CategoryId INT64 NOT NULL,
  PortfolioId INT64 NOT NULL,
  CategoryName STRING(MAX),
  PortfolioInfo STRING(MAX)
) PRIMARY KEY (CategoryId);

-- Create Product Table
CREATE TABLE Product (
  ProductId INT64 NOT NULL,
  CategoryId INT64 NOT NULL,
  PortfolioId INT64 NOT NULL,
  ProductName STRING(MAX),
  ProductAssetCode STRING(25),
  ProductClass STRING(25)
) PRIMARY KEY (ProductId);

-- Create Customer Table
CREATE TABLE Customer (
  CustomerId STRING(36) NOT NULL,
  Name STRING(MAX) NOT NULL,
  Location STRING(MAX) NOT NULL
) PRIMARY KEY (CustomerId);

```

### ###
