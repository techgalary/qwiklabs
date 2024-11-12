


## 🚀 Create and Manage AlloyDB Instances: Challenge Lab | [GSP395](https://www.cloudskillsboost.google/focuses/50123?parent=catalog)


## 🌐 **Quick Start Guide:**

 **Launch Cloud Shell:**  
   Start your Google CloudShell session by [``clicking here``](https://console.cloud.google.com/home/dashboard?project=&pli=1&cloudshell=true).

curl -LO raw.githubusercontent.com/techgalary/qwiklabs/refs/heads/main/scripts/managealloydb.sh
sudo chmod +x managealloydb.sh

./managealloydb.sh
```
---

Set the following environment variable, replacing ALLOYDB_ADDRESS with the Private IP address of the AlloyDB instance.
```bash
export ALLOYDB=
```
Run the following command to store the Private IP address of the AlloyDB instance on the AlloyDB client VM so that it will persist throughout the lab.
```bash
echo $ALLOYDB  > alloydbip.txt 
```
Use the following command to launch the PostgreSQL (psql) client. You will be prompted to provide the postgres user's password (``Change3Me``) which you entered when you created the cluster.
```bash
psql -h $ALLOYDB -U postgres
```


Run the following system query to see details 
```bash
CREATE TABLE regions (
    region_id bigint NOT NULL,
    region_name varchar(25)
) ;
ALTER TABLE regions ADD PRIMARY KEY (region_id);
```

```bash
CREATE TABLE countries (
    country_id char(2) NOT NULL,
    country_name varchar(40),
    region_id bigint
) ;
ALTER TABLE countries ADD PRIMARY KEY (country_id);
```

```bash
CREATE TABLE departments (
    department_id smallint NOT NULL,
    department_name varchar(30),
    manager_id integer,
    location_id smallint
) ;
ALTER TABLE departments ADD PRIMARY KEY (department_id);
```

```bash
INSERT INTO regions VALUES ( 1, 'Europe' );
INSERT INTO regions VALUES ( 2, 'Americas' );
INSERT INTO regions VALUES ( 3, 'Asia' );
INSERT INTO regions VALUES ( 4, 'Middle East and Africa' );

```

```bash
INSERT INTO countries VALUES ('IT', 'Italy', 1 );
INSERT INTO countries VALUES ('JP', 'Japan', 3  );
INSERT INTO countries VALUES ('US', 'United States of America', 2  );
INSERT INTO countries VALUES ('CA', 'Canada', 2  );
INSERT INTO countries VALUES ('CN', 'China', 3  );
INSERT INTO countries VALUES ('IN', 'India', 3 );
INSERT INTO countries VALUES ('AU', 'Australia', 3  );
INSERT INTO countries VALUES ('ZW', 'Zimbabwe', 4  );
INSERT INTO countries VALUES ('SG', 'Singapore', 3 );
```

```bash
INSERT INTO departments VALUES (10, 'Administration', 200, 1700 );
INSERT INTO departments VALUES (20, 'Marketing', 201, 1800);
INSERT INTO departments VALUES (30, 'Purchasing', 114, 1700 );
INSERT INTO departments VALUES (40, 'Human Resources', 203, 2400);
INSERT INTO departments VALUES (50, 'Shipping', 121, 1500);
INSERT INTO departments VALUES (60, 'IT', 103, 1400);
```


---
---

## 🎉 **Lab Completed!**

You've successfully demonstrated your skills and determination by completing the lab. **Well done!**

### 🌟 **Stay Connected!**

- 🔔 **Join our [Telegram Channel](https://t.me/quiccklab)** for the latest updates.
- 🗣 **Participate in the [Discussion Group](https://t.me/Quicklabchat)** and engage with fellow learners.
- 💬 **Join our [Discord Server](https://discord.gg/7fAVf4USZn)** for more interactive discussions.
- 💼 **Follow us on [LinkedIn](https://www.linkedin.com/company/quicklab-linkedin/)** to stay updated with the latest news and opportunities.
  
---

**Keep up the great work and continue your learning journey!**

# [QUICKLAB☁️](https://www.youtube.com/@quick_lab) - Don't Forgot to Subscribe!

---
