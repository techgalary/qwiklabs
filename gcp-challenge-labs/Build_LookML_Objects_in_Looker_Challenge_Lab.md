# Build LookML Objects in Looker: Challenge Lab || [GSP361](https://www.cloudskillsboost.google/focuses/25703?parent=catalog) ||

### Guide to Complete the Lab ###

### Task 1. Create dimensions and measures & Task 2. Create a persistent derived table ###
#### Step 1. Inside of the order_items view file paste the following code into the file ####

```
view: order_items_challenge {
  sql_table_name: cloud-training-demos.looker_ecomm.order_items’  ;;
  drill_fields: [order_item_id]
  dimension: order_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: is_search_source {
    type: yesno
    sql: ${users.traffic_source} = "Search" ;;
  }


  measure: sales_from_complete_search_users {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_search_source: "Yes", order_items.status: "Complete"]
  }

  measure: total_gross_margin {
    type: sum
    sql: ${TABLE}.sale_price - ${inventory_items.cost} ;;
  }

  dimension: return_days {
    type: number
    sql: DATE_DIFF(${order_items.delivered_date}, ${order_items.returned_date}, DAY);;
  }

```

#### Step 2: Create the `user_details` View and paste the below code into the file ####

```
view: user_details {
  derived_table: {
    explore_source: order_items {
      column: order_id {}
      column: user_id {}
      column: total_revenue {}
      column: age { field: users.age }
      column: city { field: users.city }
      column: state { field: users.state }
    }
  }
  dimension: order_id {
    description: ""
    type: number
  }
  dimension: user_id {
    description: ""
    type: number
  }
  dimension: total_revenue {
    description: ""
    value_format: "$#,##0.00"
    type: number
  }
  dimension: age {
    description: ""
    type: number
  }
  dimension: city {
    description: ""
  }
  dimension: state {
    description: ""
  }
}
```

### Task 3. Use Explore filters ###
#### 3. Copy and paste the following in `training_ecommerce` model and update the VALUE_1 and VALUE_2 ####

```
connection: "bigquery_public_data_looker"

# include all the views
include: "/views/*.view"
include: "/z_tests/*.lkml"
include: "/**/*.dashboard"

datagroup: training_ecommerce_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: training_ecommerce_default_datagroup

label: "E-Commerce Training"

explore: order_items {



  sql_always_where: ${sale_price} >= VALUE_1 ;;


  conditionally_filter: {

    filters: [order_items.shipped_date: "2018"]

    unless: [order_items.status, order_items.delivered_date]

  }


  sql_always_having: ${average_sale_price} > VALUE_2 ;;

  always_filter: {
    filters: [order_items.status: "Shipped", users.state: "California", users.traffic_source:
      "Search"]
  }



  join: user_details {

    type: left_outer

    sql_on: ${order_items.user_id} = ${user_details.user_id} ;;

    relationship: many_to_one

  }


  join: order_items_challenge {
    type: left_outer
    sql_on: ${order_items.order_id} = ${order_items_challenge.order_id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }



  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: events {
  join: event_session_facts {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_facts.session_id} ;;
    relationship: many_to_one
  }
  join: event_session_funnel {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_funnel.session_id} ;;
    relationship: many_to_one
  }
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}
```
#### Commit and Push the changes ####

### Step 4: Customize Datagroup for `order_items_challenge`###
#### 1. Add the following to the `training_ecommerce.model` file and update the NUM hours ####

```looker
datagroup: order_items_challenge_datagroup {
  sql_trigger: SELECT MAX(order_item_id) FROM order_items ;;
  max_cache_age: "NUM hours"
}

persist_with: order_items_challenge_datagroup
```
#### Commit and Push the changes ####



