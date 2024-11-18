## 🚀Get Started with Looker: Challenge Lab | [ARC107](https://www.cloudskillsboost.google/focuses/61470?parent=catalog)


## 🌐 **Guide to Complete the Challenge Lab:**

 **Launch Cloud Shell:**  
   Start your Google CloudShell session by [``clicking here``](https://console.cloud.google.com/home/dashboard?project=&pli=1&cloudshell=true).

### Task 1. Create a new report in Looker Studio ###

* Create a new [Looker Studio](http://lookerstudio.google.com/) report named `Online Sales`

### Create a new view named `users_region` and Paste the following:

```
view: users_region {
sql_table_name: cloud-training-demos.looker_ecomm.users ;;

dimension: id {
primary_key: yes
type: number
sql: ${TABLE}.id ;;
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

### Join the View to the Existing Explore ###
#### Add a join statement to include the new users_region view ####
```
explore: events {
  join: users_region {
    relationship: one_to_one
    sql_on: ${events.user_id} = ${users_region.id} ;;
  }
}
```

### Task 3. Create a new dashboard in Looker ###

* Create a bar chart of the `top 3 event types based on the highest number of users`

* Save your bar chart to a new dashboard named `User Events`


