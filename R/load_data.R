library(readr)
library(RSQLite)

e.commerce_data <- readr::read_csv("/cloud/project/ecommerce_data/ads_data.csv")
my_connection <-RSQLite::dbConnect(RSQLite::SQLite(),"/cloud/project/database/database.db")
RSQLite::dbWriteTable(my_connection,"ads_data",e.commerce_data)




