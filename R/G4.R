library(RSQLite)
library(readr)

# Connect to the database
my_connection <- dbConnect(SQLite(), "database/database.db")

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

missing_values <- apply(is.na(customer_data), 2, sum)

# Check primary key
if (length(unique(customer_data$Customer_ID)) != nrow(customer_data)) {
  print("Customer ID is not unique.")
}


# Close the database connection
dbDisconnect(my_connection)
