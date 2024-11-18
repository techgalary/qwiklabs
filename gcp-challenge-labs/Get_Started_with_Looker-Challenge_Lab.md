## 🚀Get Started with Looker: Challenge Lab | [ARC107](https://www.cloudskillsboost.google/focuses/61470?parent=catalog)


## 🌐 **Guide to Complete the Challenge Lab:**

### Task 1. Create a new report in Looker Studio ###

* Create a new report named `Online Sales` [Looker Studio](http://lookerstudio.google.com/)

### Task 2. Create a new view in Looker ####

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
### Join the View to the Existing Events Explore ###
#### Add a join statement to include the new users_region view in training_ecommerce.model file ####
```
  join: users_region {
    relationship: one_to_one
    sql_on: ${events.user_id} = ${users_region.id} ;;
  }

```
Commit and Deploy the Changes to Production

### Task 3. Create a new dashboard in Looker ###
1.Use your new view named users_region to create a bar chart of the top 3 event types based on the highest number of users.
2.Customize your bar chart using any colors and labels of your choice.
3.Save your bar chart to a new dashboard named User Events.


