library(DBI)
library(dplyr)
library(RSQLite)
library(readr)
library(ggplot2)

# 1.Connect to the database
my_connection <- dbConnect(SQLite(),"database/an_e_commerce.db")

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

ads = ads_data
category = category_data
customer_address = customer_addresses_data
customer = customers_data
delivery = delivery_data
orders_details = order_details_data
orders = orders_data
product = product_data
supplier = supplier_data
supply = supply_data
transaction = transactions_data


# 1 Product Popularity 

# Count the frequency of each product_id in the orders_details table
product_popularity <- orders_details %>%
  group_by(product_id) %>%
  summarise(Frequency = sum(sub_quantity))

# Sort the product_popularity dataframe by frequency in descending order and select the top 10
top_10_popular_products <- product_popularity %>%
  arrange(desc(Frequency)) %>%
  top_n(10)

# Plot the bar chart of the top 10 popular products with product names on the x-axis
ggplot(top_10_popular_products, aes(x = reorder(product_id, -Frequency), y = Frequency)) +
  geom_bar(stat = "identity", fill = "#6495ED") +
  geom_text(aes(label = Frequency), vjust = -0.5, size = 3, color = "black") +  # Add numeric labels on top of bars
  labs(title = "Top 10 Popular Products",
       x = "Product ID",
       y = "Amount") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# 2 Age Visualization
# Get current date
current_date <- Sys.Date()

# Calculate customers' age
customer <- customer %>%
  mutate(age1 = floor(as.numeric(difftime(current_date, date_of_birth, units = "days") / 365.25)))

# Plot the distribution of Age
ggplot(customer, aes(x = age1)) +
  geom_histogram(aes(y = after_stat(density)), fill = "#6495ED", binwidth = 5) +
  geom_density(color = "red") +
  labs(title = "Histogram and Density Plot of Age", x = "Age", y = "Density") +
  scale_x_continuous(breaks = seq(0, max(customer$age1), by = 10)) +
  theme_minimal()

# Disconnect
dbDisconnect(my_connection)
