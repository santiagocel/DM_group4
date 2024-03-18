#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 13 18:16:23 2024

@author: leijingyi
"""


from faker import Faker
from datetime import timedelta, datetime, date
import pandas as pd
import random
import os

fake = Faker()
Faker.seed(123)
random.seed(123)

# Function to generate a primary key based on the table name
def generate_primary_key(table_name):
    return table_name[:2].upper() + ''.join(random.choices('0123456789', k=4))

# Generate Customer Data
def generate_customer_data(num_records):
    customer_data = []
    for _ in range(num_records):
        customer_id = generate_primary_key('CU')
        customer_data.append({
            'customer_id': customer_id,
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'gender': random.choice(['male', 'female', 'other']),
            'date_of_birth': fake.date_of_birth(minimum_age=18, maximum_age=90).isoformat(),
            'email': fake.email(),
            'password_hash': fake.sha256(raw_output=False),
            'membership': random.choice(['yes', 'no'])
        })
    return pd.DataFrame(customer_data)

# Generate Customer Address Data
def generate_customer_address_data(customers_data):
    customer_address_data = []
    for _, customer in customers_data.iterrows():
        # Ensure at least one address per customer
        num_addresses = random.randint(1, 3)  # A customer can have 1 to 3 addresses
        for _ in range(num_addresses):
            customer_address_data.append({
                'customer_address_id': generate_primary_key('CA'),
                'customer_id': customer['customer_id'],
                'zip_code': fake.zipcode(),
                'country': fake.country(),
                'state': fake.state(),
                'city': fake.city(),
                'street': fake.street_address()
            })
    return pd.DataFrame(customer_address_data)

# Generate Orders Data
def generate_orders_data(num_records, customer_ids):
    orders_data = []
    for _ in range(num_records):
        order_id = generate_primary_key('OR')
        customer_id = random.choice(customer_ids)
        # Order date range from 2023-08-01 to 2024-03-01
        #order_date = fake.date_between(start_date="2023-08-01", end_date="2024-03-01")
        
        # Define date range
        start_date = datetime.strptime('2023-09-01', '%Y-%m-%d').date()
        end_date = datetime.strptime('2024-03-01', '%Y-%m-%d').date()
        
        order_date = fake.date_between(start_date=start_date, end_date=end_date)
        #order_date_str = order_date.strftime('%Y-%m-%d') if isinstance(order_date, datetime) else str(order_date)
        # Assuming order status directly influences transaction creation later
        order_status = random.choice(['Pending', 'Processing', 'Succeed', 'Cancelled'])
        
        orders_data.append({
            'order_id': order_id,
            'customer_id': customer_id,
            'order_date': order_date,
            'order_status': order_status
        })
    return pd.DataFrame(orders_data)

# Generate Order Details Data
# Function to check if a customer is a member
def is_customer_member(customer_id, customers_data):
    customer = customers_data.loc[customers_data['customer_id'] == customer_id].iloc[0]
    return customer['membership'] == 'yes'

# Function to fetch product price and discount price
def get_product_price(product_id, products_data):
    product = products_data.loc[products_data['product_id'] == product_id].iloc[0]
    return product['product_price'], product['discount_price']

# Function to generat eorder details data
def generate_order_details_data(orders_data, products_data, customers_data):
    order_details_data = []
    for _, order in orders_data.iterrows():
        # Assuming an order can have multiple products (1 to 10 for this example)
        num_products = random.randint(1, 10)
        selected_products = products_data.sample(n=num_products)  # Randomly select products
        
        for _, product in selected_products.iterrows():
        #    product_price, discount_price = get_product_price(product['product_id'], products_df)
         #   customer_member = is_customer_member(order['customer_id'], customers_df)
            
            # Determine unit price based on membership
           # unit_price = discount_price if customer_member else product_price
            
            order_details_data.append({
                'order_detail_id': generate_primary_key('OD'),
                'order_id': order['order_id'],
                'product_id': product['product_id'],
                'sub_quantity': random.randint(1, 10),  # Random quantity for each product
                #'unit_price': unit_price
            })
    return pd.DataFrame(order_details_data)

# Generate Transaction Data
# Generate random time
def generate_random_time():
    hours = random.randint(0, 23)
    minutes = random.randint(0, 59)
    seconds = random.randint(0, 59)
    return f"{hours:02d}:{minutes:02d}:{seconds:02d}"


def generate_transaction_data(orders_data):
    transaction_data = []
    # All possible statuses for transactions
    transaction_statuses = ['Pending', 'Processing', 'Succeed', 'Failed']
    # Set to keep track of used times to ensure uniqueness
    used_times = set()

    for _, order in orders_data.iterrows():
        # Transactions are only created for orders with the 'Succeed' status
        if order['order_status'] == 'Succeed':
            transaction_id = generate_primary_key('TR')
            # Ensure the order_date is a datetime.date object
            order_date = order['order_date']
            if isinstance(order_date, str):
                order_date = datetime.strptime(order_date, '%Y-%m-%d').date()

            # Generate a unique transaction time for the given order_date
            while True:
                random_time_str = generate_random_time()
                random_time = datetime.strptime(random_time_str, '%H:%M:%S').time()
                transaction_datetime = datetime.combine(order_date, random_time)
                if transaction_datetime not in used_times:
                    used_times.add(transaction_datetime)
                    break

            # Randomly choose a status for the transaction
            transaction_status = random.choice(transaction_statuses)

            transaction_data.append({
                'transaction_id': transaction_id,
                'order_id': order['order_id'],
                'customer_id': order['customer_id'],
                'transaction_time': transaction_datetime.strftime('%Y-%m-%d %H:%M:%S'),
                'payment_method': random.choice(['Credit Card', 'Debit Card', 'PayPal']),
                'transaction_status': transaction_status
            })

    return pd.DataFrame(transaction_data)


# Generate Delivery Data
def generate_delivery_data(transactions_data, orders_data, customer_addresses_data):
    delivery_data = []
    for _, transaction in transactions_data.iterrows():
        # Only create delivery for successful transactions
        if transaction['transaction_status'] == 'Succeed':
            order = orders_data.loc[orders_data['order_id'] == transaction['order_id']].iloc[0]
            customer_id = order['customer_id']
            customer_addresses = customer_addresses_data[customer_addresses_data['customer_id'] == customer_id]

            if customer_addresses.empty:
                continue

            customer_address_id = random.choice(customer_addresses['customer_address_id'].tolist())
            delivery_status = random.choice(['Not_Delivered', 'In_Delivery', 'Completed', 'Failed'])

            # Initialize start and end dates as empty
            delivery_start_date, delivery_end_date = '', ''
            
            transaction_datetime = datetime.strptime(transaction['transaction_time'], '%Y-%m-%d %H:%M:%S')
            if delivery_status != 'Not_Delivered':
                delivery_start_date = (transaction_datetime + timedelta(days=random.randint(1, 10))).strftime('%Y-%m-%d')

            if delivery_status == 'Completed':
                delivery_end_date = (datetime.strptime(delivery_start_date, '%Y-%m-%d') + timedelta(days=random.randint(1, 30))).strftime('%Y-%m-%d')
            elif delivery_status == 'Failed':
                # Set end date within 30 days of the start date
                start_date_obj = datetime.strptime(delivery_start_date, '%Y-%m-%d')
                delivery_end_date = (start_date_obj + timedelta(days=random.randint(1, 30))).strftime('%Y-%m-%d')

            delivery_data.append({
                'delivery_id': generate_primary_key('DE'),
                'transaction_id': transaction['transaction_id'],
                'customer_address_id': customer_address_id,
                'delivery_status': delivery_status,
                'delivery_start_date': delivery_start_date,
                'delivery_end_date': delivery_end_date
            })
    
    return pd.DataFrame(delivery_data)

# Generate Category Data
# Predefined parent categories and potential subcategory names for demonstration
category_templates = {
    'Clothing': ['Shirts', 'Pants', 'Dresses', 'Outerwear'],
    'Electronics': ['Smartphones', 'Laptops', 'Cameras', 'Accessories'],
    'Books': ['Fiction', 'Non-Fiction', 'Educational', 'Biographies'],
    'Home & Garden': ['Furniture', 'Gardening', 'Decor', 'Tools'],
    'Toys & Games': ['Board Games', 'Electronic Toys', 'Puzzles', 'Educational Toys']
}


# Function to generate category data with proper parent-child relationships
def generate_category_data(category_templates):
    category_data = []
    parent_category_counter = 1  # Start a simple counter for parent categories

    for parent_category, subcategories in category_templates.items():
        # Parent category ID (e.g., CT1001 for the first parent category)
        parent_category_id = f'CT{1000 + parent_category_counter}'
        category_data.append({
            'category_id': parent_category_id,
            'category_name': parent_category,
            'parent_category_id': None  # None indicates a parent category
        })

        # Generate subcategory IDs with reference to their parent category
        for subcategory in subcategories:
            subcategory_id = f'{parent_category_id}-{str(random.randint(1, 999)).zfill(3)}'
            category_data.append({
                'category_id': subcategory_id,
                'category_name': subcategory,
                'parent_category_id': parent_category_id
            })

        parent_category_counter += 1

    return pd.DataFrame(category_data)

category_data = generate_category_data(category_templates)
subcategory_ids = category_data[category_data['parent_category_id'] != category_data['category_id']]['category_id'].tolist()

# Generate Product Data
# Define a dictionary for sample product names for each subcategory
product_names_by_category = {
    'Shirts': ['Casual Shirt', 'Formal Shirt', 'Polo Shirt', 'Flannel Shirt'],
    'Pants': ['Jeans', 'Chinos', 'Cargo Pants', 'Sweatpants'],
    'Dresses': ['Evening Gown', 'Summer Dress', 'Cocktail Dress', 'Wrap Dress'],
    'Outerwear': ['Leather Jacket', 'Trench Coat', 'Windbreaker', 'Puffer Jacket'],
    'Smartphones': ['Touchscreen Phone', 'Camera Phone', 'Smart Mobile', 'Android Handset'],
    'Laptops': ['Gaming Laptop', 'Ultrabook', 'Business Laptop', 'Convertible Laptop'],
    'Cameras': ['DSLR Camera', 'Mirrorless Camera', 'Action Camera', 'Point and Shoot'],
    'Accessories': ['Headphones', 'Portable Charger', 'Phone Case', 'Camera Lens'],
    'Fiction': ['Science Fiction Novel', 'Fantasy Book', 'Mystery Novel', 'Historical Fiction'],
    'Non-Fiction': ['Self-Help Book', 'Biography', 'Cookbook', 'Travel Guide'],
    'Educational': ['Mathematics Textbook', 'Science Textbook', 'Language Workbook', 'History Textbook'],
    'Biographies': ['Celebrity Biography', 'Political Memoir', 'Sports Star Biography', 'Historical Biography'],
    'Furniture': ['Sofa', 'Coffee Table', 'Bookshelf', 'Dining Set'],
    'Gardening': ['Pruning Shears', 'Gardening Gloves', 'Plant Pots', 'Watering Can'],
    'Decor': ['Area Rug', 'Wall Art', 'Vase', 'Picture Frame'],
    'Tools': ['Cordless Drill', 'Screwdriver Set', 'Hammer', 'Handsaw'],
    'Board Games': ['Strategy Board Game', 'Classic Board Game', 'Family Game', 'Trivia Game'],
    'Electronic Toys': ['Remote Control Car', 'Handheld Game Console', 'Learning Tablet', 'Robot Toy'],
    'Puzzles': ['Jigsaw Puzzle', 'Crossword Puzzle Book', '3D Puzzle', 'Brain Teaser'],
    'Educational Toys': ['Building Blocks', 'Science Kit', 'Math Game', 'Language Learning Toy']
}

def find_category_id_by_name(subcategory_name, category_data):
    # Find the row in category_data where the category_name matches the subcategory_name
    category_row = category_data[category_data['category_name'] == subcategory_name]
    
    # If a match is found, return the category_id, otherwise return None
    if not category_row.empty:
        return category_row.iloc[0]['category_id']
    else:
        return None

# Function to generate product data
def generate_product_data(num_records, category_data, product_names_by_category):
    product_data = []
    # Flatten the subcategories and their respective parent categories
    subcategories = [(subcat, parent) for parent, subcats in category_templates.items() for subcat in subcats]
    
    for _ in range(num_records):
        product_id = generate_primary_key('PR')
        subcategory_name, parent_category = random.choice(subcategories)  # Randomly select a subcategory and its parent
        product_name_options = product_names_by_category.get(subcategory_name)
        if not product_name_options:
            continue  # If there are no predefined product names for this subcategory, skip this iteration
        product_name = random.choice(product_name_options)  # Randomly select a product name
        product_price = round(random.uniform(20, 5000), 2)
        #discount_percentage = round(random.uniform(0, 0.99), 2),
        rate_value = round(random.uniform(1, 5), 1)
        
        # Assuming you have a function to find the category_id by name
        category_id = find_category_id_by_name(subcategory_name, category_data)

        product_data.append({
            'product_id': product_id,
            'category_id': category_id,
            'product_name': product_name,
            'product_price': product_price,
            'discount_percentage': round(random.uniform(0, 0.99), 2),
            'rate_value': rate_value
        })

    return pd.DataFrame(product_data)


# Generate Supplier Data
def generate_phone_number():
    # Generate a phone number with country code optionally prefixed by '+'
    # and followed by 10 to 20 digits
    number_of_digits = random.randint(10, 20)
    phone_number = "+" + ''.join([str(random.randint(0, 9)) for _ in range(number_of_digits)])
    return phone_number

def generate_supplier_data(num_suppliers):
    supplier_data = []
    for _ in range(num_suppliers):
        supplier_id = generate_primary_key('SU')
        supplier_data.append({
            'supplier_id': supplier_id,
            'supplier_name': fake.company(),
            'supplier_phone': generate_phone_number(),
            'supplier_email': fake.email(),
            'supplier_zip_code': fake.zipcode(),
            'supplier_country': fake.country(),
            'supplier_state': fake.state(),
            'supplier_city': fake.city(),
            'supplier_street': fake.street_address()
        })
    return pd.DataFrame(supplier_data)


# Generate Supply Data
def generate_supply_data(suppliers_data, products_data, num_records):
    supply_data = []
    for _ in range(num_records):
        supplier_id = random.choice(suppliers_data['supplier_id'].tolist())
        product_id = random.choice(products_data['product_id'].tolist())
        stock = random.randint(0, 1000)  # Random stock level

        # Create a supply record
        supply_data.append({
            'supply_id': generate_primary_key('SP'),
            'supplier_id': supplier_id,
            'product_id': product_id,
            'stock': stock
        })
        
    # Remove potential duplicates that might occur from random selection
    supply_data = pd.DataFrame(supply_data).drop_duplicates(subset=['supplier_id', 'product_id'])
    return supply_data


# Generate Ads Data
def generate_ads_data(num_ads, product_ids):
    ads_data = []
    for _ in range(num_ads):
        ad_id = generate_primary_key('AD')
        product_id = random.choice(product_ids)  # Each ad is linked to a product
        start_date = fake.date_between(start_date='-2y', end_date='today')
        ad_status = random.choice(['active', 'ended'])
        
        # Set a range for the end date based on the status of the ad
        if ad_status == 'active':
            # Active ads end sometime in the future
            end_date = fake.date_between(start_date='+1d', end_date='+2y')
        else:
            # Ended ads end on or before today
            end_date = fake.date_between(start_date=start_date, end_date='today')
        
        ads_data.append({
            'ad_id': ad_id,
            'product_id': product_id,
            'ad_name': fake.catch_phrase(),
            'ad_status': ad_status,
            'ad_start_date': start_date.strftime('%Y-%m-%d'),
            'ad_end_date': end_date.strftime('%Y-%m-%d')
        })

    return pd.DataFrame(ads_data)


# Generate data
# data size
num_customers = 100
num_customer_address = 150
num_supplier = 80
num_product = 150
num_order = 200
num_order_details = 200
num_ads = 100
num_transaction = 200
num_supply = 100
num_delivery = 200
num_category = 100



customers_data = generate_customer_data(num_customers)
customer_addresses_data = generate_customer_address_data(customers_data)
supplier_data = generate_supplier_data(num_supplier)
category_data = generate_category_data(category_templates)
product_data = generate_product_data(500, category_data, product_names_by_category)
ads_data = generate_ads_data(num_ads, product_data['product_id'].tolist())
orders_data = generate_orders_data(num_order, customers_data['customer_id'].tolist())
order_details_data = generate_order_details_data(orders_data, product_data, customers_data)
supply_data = generate_supply_data(supplier_data, product_data, num_supply)
transactions_data = generate_transaction_data(orders_data)
delivery_data = generate_delivery_data(transactions_data, orders_data, customer_addresses_data)


# store data
# Create the dataframe
dataframes = {
    'customers_data': customers_data,
    'product_data': product_data,
    'orders_data': orders_data,
    'transactions_data': transactions_data,
    'delivery_data': delivery_data,
    'supply_data': supply_data,
    'supplier_data': supplier_data,
    'category_data': category_data,
    'ads_data': ads_data,
    'customer_addresses_data': customer_addresses_data,
    'order_details_data': order_details_data
}

directory = 'e-commerce_data'

# Create the directory if it does not exist
if not os.path.exists(directory):
    os.makedirs(directory)

# Save each DataFrame to its own CSV file
for name, df in dataframes.items():
    path = os.path.join(directory, f'{name}.csv')
    df.to_csv(path, index=False)
















