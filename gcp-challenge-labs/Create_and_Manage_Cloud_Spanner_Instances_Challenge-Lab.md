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
vi table.sql
```
#### paste below ddl statement here ####
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
```
chmod u+x table.sql
```
#### Execute the table.sql file using command ####
```
gcloud spanner databases ddl update banking-ops-db \
    --instance=banking-ops-instance \
    --ddl="$(cat table.sql)"
```
#### Verify the tables ####
```
gcloud spanner databases ddl describe banking-ops-db \
    --instance=banking-ops-instance
```
### Task 4. Load simple datasets into tables ###

#### DML Commands for Loading Data ####
##### Load Data into the Portfolio Table #####
```
 vi portfolio.sql
```
##### paste below snippet in this file #####
```
INSERT INTO Portfolio (PortfolioId, Name, ShortName, PortfolioInfo) VALUES
  (1, "Banking", "Bnkg", "All Banking Business"),
  (2, "Asset Growth", "AsstGrwth", "All Asset Focused Products"),
  (3, "Insurance", "Insurance", "All Insurance Focused Products");
```
##### Load Data into the Category Table #####
``` 
vi category.sql
 ```
##### paste below snippet in this file #####
```
INSERT INTO Category (CategoryId, PortfolioId, CategoryName, PortfolioInfo) VALUES
  (1, 1, "Cash", NULL),
  (2, 2, "Investments - Short Return", NULL),
  (3, 2, "Annuities", NULL),
  (4, 3, "Life Insurance", NULL);
```
##### Load Data into the Product Table #####
```
vi product.sql
 ```
##### paste below snippet in this file #####
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
##### Execute all files now #####
```
gcloud spanner databases execute-sql banking-ops-db \
    --instance=banking-ops-instance \
    --sql="$(cat portfolio.sql)"
```
```
gcloud spanner databases execute-sql banking-ops-db \
    --instance=banking-ops-instance \
    --sql="$(cat category.sql)"

```
```
gcloud spanner databases execute-sql banking-ops-db \
    --instance=banking-ops-instance \
    --sql="$(cat product.sql)"
```
### Task 5. Load a complex dataset ###
#### Download the csv file ####
```
gsutil cp gs://cloud-training/OCBL375/Customer_List_500.csv .
```
#### Convert CSV to SQL Insert Statement using script ####
``` 
vi customer_inserts.sql 
```
```
import csv

with open("Customer_List_500.csv", "r") as csvfile, open("customer_inserts.sql", "w") as sqlfile:
    reader = csv.reader(csvfile)
    for row in reader:
        sqlfile.write(
            f"INSERT INTO Customer (CustomerId, Name, Location) VALUES ('{row[0]}', '{row[1]}', '{row[2]}');\n"
        )
```
##### Verify the data #####
```
SELECT COUNT(*) FROM Customer;

```

### Task 6. Add a new column to an existing table ###
```
gcloud spanner databases ddl update banking-ops-db \
--instance=banking-ops-instance \
--ddl="ALTER TABLE Category ADD COLUMN MarketingBudget INT64;"

```
##### verify the data #####
```
gcloud spanner databases ddl describe banking-ops-db --instance=banking-ops-instance
```
