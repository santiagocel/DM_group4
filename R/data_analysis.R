
library(ggplot2)

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

