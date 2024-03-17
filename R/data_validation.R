
library(DBI)
library(dplyr)
library(RSQLite)
library(readr)


# 1.Connect to the database
my_connection <- dbConnect(SQLite(), "database/ecommerce.db")

# Get list of CSV files in the ecommerce_data directory
csv_files <- list.files("ecommerce_data", pattern = "\\.csv$", full.names = TRUE)

# Loop through the list of files and load them into their respective tables
for (csv_file in csv_files) {
  table_name <- gsub("\\.csv", "", basename(csv_file))  # Extract table name from file name without extension
  
  # Load data into R environment
  assign(table_name, read_csv(csv_file))
  
  # Load data into SQLite database
  print(paste("Loading file:", csv_file))  # Debugging message
  data <- read_csv(csv_file)
  dbWriteTable(my_connection, table_name, data, append = TRUE)
  print(paste("File", csv_file, "successfully loaded into table", table_name))  # Debugging message
}

# List tables in the database
tables <- dbListTables(my_connection)
print(paste("Tables in the database:", toString(tables)))  # Debugging message
_________________________________________________________________
_________________________________________________________________
missing_values <- apply(is.na(customers_data), 2, sum)

# Check primary key
if (length(unique(customers_data$customer_id)) != nrow(customers_data)) {
  print("Customer ID is not unique.")
}

# Check data types for first_name and last_name
if (!all(sapply(customers_data$first_name, is.character)) || !all(sapply(customers_data$last_name, is.character))) {
  print("First name and last name should be character.")
}

# Check valid gender values
valid_genders <- c("male", "female", "other")
if (any(!customers_data$gender %in% valid_genders)) {
  print("Gender should be male, female, or other.")
}


if(any(!grepl("^\\d{4}-\\d{2}-\\d{2}$", customers_data$date_of_birth))){
  print ("Dates of birth should match the 'YYYY-MM-DD' format.")
}

current_year <- as.integer(format(Sys.Date(), "%Y"))
dob_year <- as.integer(format(customers_data$date_of_birth, "%Y"))
age <- current_year - dob_year
valid_ages <- age >= 18 & age <= 90
# Identify entries with DOB outside the valid age range
if (nrow(customers_data[!valid_ages]) > 0) {
  print("Dates of birth should be inside the 18 to 90 years age range.")
}

# Check email format
if (any(!grepl("^\\S+@\\S+\\.\\S+$", customers_data$email))) {
  print("Invalid email format")
}

# Check password hash
if (any(nchar(customers_data$password_hash) > 255)) {
  print("Password_hash exceeds 255 characters.")
}

# Check membership
valid_membership <-c("yes", "no")
if (any(!customers_data$membership %in% valid_membership)) {
  print("Membership should be yes or no.")
}


# Check Primary Key
if (length(unique(customer_address_data$customer_address_id)) != nrow(customer_address_data)) {
  print("Customer Address ID is not unique.")
}
____________________________________________________________________
____________________________________________________________________

# Checking for missing or empty values in critical fields
mandatory_fields <- c("zip_code", "country", "state", "city", "street")
for (field in mandatory_fields) {
  if (any(is.na(customer_addresses_data[[field]]) | customer_addresses_data[[field]] == "")) {
    print(paste("Missing or empty values detected in", field, "."))
  }
}

# Check length
if (any(nchar(customer_addresses_data$zip_code) > 10)) {
  print("zipcode exceeds 10 characters.")
}

if (any(nchar(customer_addresses_data$country) > 100)) {
  print("country exceeds 100 characters.")
}

if (any(nchar(customer_addresses_data$state) > 50)) {
  print("state exceeds 50 characters.")
}

if (any(nchar(customer_addresses_data$city) > 50)) {
  print("city exceeds 50 characters.")
}

if (any(nchar(customer_addresses_data$street) > 255)) {
  print("street exceeds 255 characters.")
}

__________________________________________________________________
na_order <- apply(is.na(orders_data), 2, sum)

# Check Primary Key
if (length(unique(orders_data$order_id)) != nrow(orders_data)) {
  print("Order ID is not unique.")
}

# Referential Integrity
if (!all(orders_data$customer_id %in% customers_data$customer_id)) {
  print("Invalid customer_id detected in orders table.")
}

# Check data type
if (any(is.na(orders_data$order_date)) | 
    !grepl("^\\d{4}-\\d{2}-\\d{2}$", orders_data$order_date)) {
  print("Invalid or NA values in order_date.")
}

# Check order status
valid_order_statuses <- c('Pending', 'Processing', 'Succeed', 'Cancelled')
if (!all(orders_data$order_status %in% valid_order_statuses)) {
  print("Invalid order_status detected.")
}

# If no errors are found, print a message indicating that the data is valid
if (!any(is.na(na_order)) &&
    all(grepl("^\\d{4}-\\d{2}-\\d{2}$", orders_data$order_date) &&
        !any(is.na(orders_data$order_date)&&
             all(orders_data$customer_id %in% customers_data$customer_id)))) {
  print("Order data is valid.")
  # Load the data into the database
} else {
  print("Order data is not valid. Please correct the errors.")
}

```

# Check Primary key
if (length(unique(order_details_data$order_detail_id)) != nrow(order_details_data)) {
  print("Order Detail ID is not unique.")
}

# Referential Integrity
if (!all(order_details_data$order_id %in% orders_data$order_id)) {
  print("Invalid order_id detected in order_details table.")
}

if (!all(order_details_data$product_id %in% product_data$product_id)) {
  print("Invalid product_id detected in order_details table.")
}

# Non-nullability Checks
if (any(is.na(order_details_data$order_detail_id))) {
  print("Null values found in order_detail_id.")
}

if (any(is.na(order_details_data$order_id))) {
  print("Null values found in order_id.")
}

if (any(is.na(order_details_data$product_id))) {
  print("Null values found in product_id.")
}

if (any(is.na(order_details_data$sub_quantity))) {
  print("Null values found in sub_quantity.")
}

# Data Type and Positive Quantity Checks
if (!all(sapply(order_details_data$sub_quantity, is.numeric))) {
  print("sub_quantity is not numeric.")
}

if (any(order_details_data$sub_quantity <= 0)) {
  stop("Invalid sub_quantity detected. Quantities must be positive.")
}
________________________________________________________________
# Check primary key
if (length(unique(transactions_data$transaction_id)) != nrow(transactions_data)) {
  stop("Transaction ID is not unique.")
}

# Referential Integrity
if (!all(transactions_data$order_id %in% orders_data$order_id)) {
  stop("Invalid order_id detected in transactions table.")
}
if (!all(transactions_data$customer_id %in% customers_data$customer_id)) {
  stop("Invalid customer_id detected in transactions table.")
}

# Validate non-null constraints
if (any(is.na(transactions_data$transaction_id) | 
        is.na(transactions_data$order_id) | 
        is.na(transactions_data$customer_id) | 
        is.na(transactions_data$payment_method) | 
        is.na(transactions_data$transaction_status))) {
  stop("Null values found in non-nullable transaction fields.")
}

# Validate ENUMs for 'payment_method' and 'transaction_status'
valid_payment_methods <- c('Credit card', 'Debit card', 'Paypal')
valid_transaction_statuses <- c('Pending', 'Processing', 'Succeed', 'Cancelled')


# Check business rule: If order is cancelled, there should be no transaction
cancelled_orders <- orders_data$order_id[orders_data$order_status == 'Cancelled']
if (any(transactions_data$order_id %in% cancelled_orders)) {
  stop("There are transactions for cancelled orders.")
}


# Check primary key
if (any(duplicated(delivery_data$delivery_id))) {
  stop("Duplicate delivery_id detected.")
}

# Referential Integrity
if (!all(delivery_data$transaction_id %in% transactions_data$transaction_id)) {
  stop("Invalid transaction_id detected in delivery table.")
}
if (!all(delivery_data$customer_address_id %in% customer_addresses_data$customer_address_id)) {
  stop("Invalid customer_address_id detected in delivery table.")
}

# Check business rule: Only succeed transaction has delivery
succeed_transactions <- transactions_data$transaction_id[transactions_data$transaction_status == 'Succeed']

if (!all(delivery_data$transaction_id %in% succeed_transactions)) {
  stop("Invalid transaction_id detected in delivery table; delivery exists for non-succeed transactions.")
}

# Check delivery rule
# Check if the status is 'Not_Deliveried' then start and end dates must be NA
if (any(delivery_data$delivery_status == 'Not_Deliveried' & (!is.na(delivery_data$delivery_start_date) | !is.na(delivery_data$delivery_end_date)))) {
  stop("There are 'Not_Deliveried' deliveries with start or end dates.")
}

# If 'In_Delivery', start date must not be NA and end date must be NA
if (any(delivery_data$delivery_status == 'In_Delivery' & (is.na(delivery_data$delivery_start_date) | !is.na(delivery_data$delivery_end_date)))) {
  stop("Invalid 'In_Delivery' status dates.")
}

# If 'Completed', both start and end dates must not be NA
if (any(delivery_data$delivery_status == 'Completed' & (is.na(delivery_data$delivery_start_date) | is.na(delivery_data$delivery_end_date)))) {
  stop("'Completed' deliveries with missing start or end dates.")
}

# If 'Failed', start and end dates must not be NA and difference must be > 30 days
delivery_data$delivery_start_date <- as.Date(delivery_data$delivery_start_date)
delivery_data$delivery_end_date <- as.Date(delivery_data$delivery_end_date)

if (any(delivery_data$delivery_status == 'Failed' & (is.na(delivery_data$delivery_start_date) | is.na(delivery_data$delivery_end_date) | as.numeric(difftime(delivery_data$delivery_end_date, delivery_data$delivery_start_date, units = "days")) <= 30))) {
  stop("'Failed' deliveries have invalid dates or the duration is not more than 30 days.")
}

```

# Check the primary key
if (any(duplicated(category_data$category_id))) {
  stop("Duplicate category_id detected.")
}

# Referential Integrity
is_valid_parent <- category_data$parent_category_id %in% category_data$category_id | category_data$parent_category_id == 0

if (!all(is_valid_parent)) {
  stop("Invalid parent_category_id detected.")
}

# Validate non-null constraints
if (any(is.na(category_data$category_name))) {
  stop("Null values found in category_name.")
}

# Hierarchical rule check
if (any(category_data$category_id == category_data$parent_category_id)) {
  stop("A category cannot be its own parent.")
}

# Check the primary key
if (any(duplicated(product_data$product_id))) {
  stop("Duplicate product_id detected.")
}

# Referential Integrity
if (!all(product_data$category_id %in% category_data$category_id)) {
  stop("Invalid category_id detected in product table.")
}

# Validate non-null constraints
required_fields <- c("product_id", "category_id", "product_name", "product_price", "discount_percentage", "rate_value")
if (any(sapply(product_data[required_fields], is.na))) {
  stop("Null values found in required product fields.")
}

# Check discount_percentage
if (any(product_data$discount_percentage < 0 | product_data$discount_percentage > 1)) {
  stop("discount_percentage must be between 0 and 1.")
}

# Check rate_value
if (any(product_data$rate_value < 0 | product_data$rate_value > 5)) {
  stop("rate_value must be between 0 and 5.")
}

#Check the primary key
if (any(duplicated(supplier_data$supplier_id))) {
  stop("Duplicate supplier_id detected.")
}

# Check the unique 
if (any(duplicated(supplier_data$supplier_phone))) {
  stop("Duplicate supplier_phone detected.")
}
if (any(duplicated(supplier_data$supplier_email))) {
  stop("Duplicate supplier_email detected.")
}

# Validate non-null constraints
required_fields <- c("supplier_id", "supplier_phone", "supplier_name", "supplier_email", "supplier_zip_code", "supplier_country", "supplier_state", "supplier_city", "supplier_street")
if (any(sapply(supplier_data[required_fields], is.na))) {
  stop("Null values found in required supplier fields.")
}

# Check length
if (any(nchar(supplier_data$supplier_zip_code) > 10)) {
  print("zipcode exceeds 10 characters.")
}

if (any(nchar(supplier_data$supplier_country) > 20)) {
  print("country exceeds 20 characters.")
}

if (any(nchar(supplier_data$supplier_state) > 50)) {
  print("state exceeds 50 characters.")
}

if (any(nchar(supplier_data$supplier_city) > 50)) {
  print("city exceeds 50 characters.")
}

if (any(nchar(supplier_data$supplier_street) > 255)) {
  print("street exceeds 255 characters.")
}

# Check format
if (any(!grepl("^\\S+@\\S+\\.\\S+$", supplier_data$supplier_email))) {
  stop("Invalid supplier_email format detected.")
}
# A very basic phone number check (adjust regex as needed for specific formats)
if (any(!grepl("^\\+?\\d{10,20}$", supplier_data$supplier_phone))) {
  stop("Invalid supplier_phone format detected.")
}

```

# Check composite primary key
composite_keys <- paste(supply_data$supplier_id, supply_data$product_id)
if (any(duplicated(composite_keys))) {
  stop("Duplicate composite primary key (supplier_id, product_id) detected.")
}

# Referential Integrity
if (!all(supply_data$supplier_id %in% supplier_data$supplier_id)) {
  stop("Invalid supplier_id detected in supply table.")
}

if (!all(supply_data$product_id %in% product_data$product_id)) {
  stop("Invalid product_id detected in supply table.")
}

# Check the valid value of stock
if (any(supply_data$stock < 0)) {
  stop("Invalid stock values detected. Stock must be non-negative.")
}

# Check the primary key
if (any(duplicated(ads_data$ad_id))) {
  stop("Duplicate ad_id detected.")
}

# Referential Integrity
if (!all(ads_data$product_id %in% product_data$product_id)) {
  stop("Invalid product_id detected in ads table.")
}

# Validate non-null constraints
required_fields <- c("ad_id", "product_id", "ad_name", "ad_status", "ad_start_date", "ad_end_date")
if (any(sapply(ads_data[required_fields], is.na))) {
  stop("Null values found in required ad fields.")
}

# Check the ads status
ads_data$ad_start_date <- as.Date(ads_data$ad_start_date)
ads_data$ad_end_date <- as.Date(ads_data$ad_end_date)

today <- Sys.Date()

# Check for active ads
invalid_active_ads <- ads_data$ad_status == 'active' & ads_data$ad_end_date < today
if (any(invalid_active_ads)) {
  stop("There are active ads with an end date before today.")
}

# Check for ended ads
invalid_ended_ads <- ads_data$ad_status == 'ended' & ads_data$ad_end_date >= today
if (any(invalid_ended_ads)) {
  stop("There are ended ads with an end date today or in the future.")
}

# Disconnect
dbDisconnect(my_connection)
```
