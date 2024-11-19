## 🚀Get Started with Looker: Challenge Lab | [ARC107](https://www.cloudskillsboost.google/focuses/61470?parent=catalog)


## 🌐 **Guide to Complete the Challenge Lab:**

### Task 1. Create a new report in Looker Studio ###

* Create a new report named `Online Sales` [Looker Studio](http://lookerstudio.google.com/)

### Task 2. Create a new view in Looker ####
#### Paste the below code under users_region like below

```
view: users_region {
  sql_table_name: cloud-training-demos.looker_ecomm.users ;;
  
  dimension: id {
    type: number
    sql: ${TABLE}.id ;;
    primary_key: yes
  }
  
  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }
  
  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }
  
  measure: count {
    type: count
    drill_fields: [id, state, country]
  }
}
```
#### After update it should look like below ####
<img width="448" alt="image" src="https://github.com/user-attachments/assets/461ae3fb-2c80-4098-bd6f-61ed4ab82a49">

### Join the View to the Existing Events Explore ###
#### Add a join statement to include the new users_region view in training_ecommerce.model file ####
Like below <img width="451" alt="image" src="https://github.com/user-attachments/assets/82683538-45ac-45b3-bfee-bcc25933a16a">

```
  join: users_region {
    relationship: one_to_one
    sql_on: ${events.user_id} = ${users_region.id} ;;
  }

```
#### Commit and Deploy the Changes to Production ####

### Task 3. Create a new dashboard in Looker ###
```
1.Use your new view named users_region to create a bar chart of the top 3 event types based on the highest number of users.
 Navigate to Explore > Events > Select Event type
 Navigate to Users Region > Click on Count
2. Under Data update the rows to 3
3. Under Visualization click on bar then click on run
4. Under settings Click on Save > New Dashboard
```
<img width="458" alt="image" src="https://github.com/user-attachments/assets/ae439325-9f82-44c4-ac6c-394902f78c45">


