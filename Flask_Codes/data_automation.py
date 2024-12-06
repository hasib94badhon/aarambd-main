import mysql.connector


my_string = "Where's Waldo?"
print(type(my_string.find("Waldo")))

# MySQL connection
connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="registration"
)

# Fetch data from the reg table where phone does not start with '0'
select_query = """
SELECT user_id FROM users
"""
cursor = connection.cursor(dictionary=True)  # Use dictionary=True for easier row access
cursor.execute(select_query)
phones = cursor.fetchall()

# SQL query to update the phone number (prepend '0' if not present)
phone = 0
update_query = f"""
UPDATE users 
SET user_shared = {phone} , user_viewed = {phone},user_called = {phone}
WHERE user_id = %s
"""

# Iterate through the fetched data and update phone numbers
for row in phones:
    user_id = row['user_id']
    cursor.execute(update_query, (user_id,))

# Commit the transaction
connection.commit()

# Close the cursor and connection
cursor.close()
connection.close()

print("Phone numbers updated successfully!")









#  import os
# import mysql.connector
# import pandas as pd
# from pymysql import Error
# import numpy as np



# # MySQL database connection configuration
# connection = mysql.connector.connect(
#     host="localhost",
#     user="root",
#     password="",
#     database="registration"
# )

# excel_file = "C:/Users/user/Desktop/assorted.xlsx"
# df = pd.read_excel(excel_file,"business")
# df = df[['name', 'category', 'phone', 'link', 'location']]
# # Replace NaN values with empty strings
# df = df.replace(np.nan, '')
# print(df.to_string())
# cursor = connection.cursor()

# # SQL query to insert data
# insert_query = """
# INSERT INTO fb_page (name, cat, phone, link, location,time)
# VALUES (%s, %s, %s, %s, %s,NOW())
# """

# # Insert each row from the dataframe
# for index, row in df.iterrows():
#     cursor.execute(insert_query, (row['name'], row['category'], f"0{row['phone']}", row['link'], row['location']))

# Commit the transaction

# def fetch_cat_id_phone():
#     try:
#         cursor = connection.cursor()
#         cursor.execute("SELECT cat_id,phone FROM shops")
#         service_info = cursor.fetchall()
#         # print(f"Fetched details: {service_info}")
#         return service_info
#     except Error as error:
#         print(f"Error fetching phone numbers: {error}")
#         return []

# fetched_details = fetch_cat_id_phone()

# for cat_id,number in fetched_details:
#     cursor = connection.cursor()
#     sql = "UPDATE users SET cat_id = %s WHERE phone = %s"
#     cursor.execute(sql, (cat_id, number))
#     print(f"Uploaded {cat_id} on the phone number {number}.")
#     connection.commit()
    



# from random import *

# def fetch_cat_id_phone():
#     try:
#         cursor = connection.cursor()

#         cursor.execute("SELECT post_id FROM post")

#         cursor.execute("SELECT post_id FROM users")

#         service_info = cursor.fetchall()
#         # print(f"Fetched details: {service_info}")
#         return service_info
#     except Error as error:
#         print(f"Error fetching phone numbers: {error}")
#         return []

# fetched_details = fetch_cat_id_phone()




# for post_id in fetched_details:
#     cursor = connection.cursor()
#     called = rand
#     sql = f"""
#             UPDATE post set user_called={str(called)} WHERE user_id = %s
#     """
#     cursor.execute(sql, (post_id))
    
#     print(f"Upldate user_shared {called} on the user_id {post_id}.")

# des = 5
# called = 10 
# share = 1
# liked = 0
# for post_id in fetched_details:
#     cursor = connection.cursor()
#     liked += 2 
#     share += 1
#     called += 10

#     sql = f"""
#             UPDATE users set user_shared ={str(liked)},user_called={str(called)} WHERE user_id = %s
#     """
#     cursor.execute(sql, (post_id))
    
#     print(f"Upldate user_shared {liked} on the user_id {post_id}.")

#     connection.commit()
    




# d = [{"name":'abid',"dept":"cse"},{"name":'abid',"dept":"cse"},{"name":'abid',"dept":"cse"},{"name":'abid',"dept":"cse"},{"name":'abid',"dept":"cse"}]
# for i in d:
#     print(i['dept'])










# def insert_into_regcursor, phone:
#     try:
#         sql_insert_query = """INSERT INTO reg phone, password VALUES %s, %s"""
#         cursor.executesql_insert_query, phone, '12345'
#         printf"Inserted phone number {phone} into reg"
#     except Error as error:
#         printf"Error inserting phone number {phone} into reg: {error}"






# # List of categories and corresponding image URLs assuming cat_name matches the image name
# # 
# categories = [
#     "Gift shops", "Restaurant", "Flower shops", "Furniture shops", "ISP provider",
#     "Hardware store", "Gas cylinders shops", "Sanitary Store", "Sweet Shops",
#     "Money-Exchange", "Sporting store", "Clothing shops", "Tiles store", "Cosmetics store",
#     "parlour", "Tree/Plant garden", "Saloon", "Exercise equipment store", "Pharmacy",
#     "Interior Decorator", "Grocery store", "Glass & mirror shops", "Electronics store",
#     "Appliance store", "Bedding store", "Bike & Car", "Books shops", "Kacha-bazar",
#     "kids stuff", "land and property", "Pet & Birds store",'AC repair service','Ambulance service','Appliance repair','Bike service',
#     'Car wash','Cleaning service','Clock and watch maker','Computer service','Courier Service','Driving school','Event management','House Shifting','Key/lock mechanic',
#     'Laundry','Mobile Repair','Pest control','Refrigerator repair service','Rent a car','Sound system','Transportation','Trips and travels',
#     'Water/Waste tank cleaning service'
# ]

# # Directory where the images are stored on your domain

# image_directory = "https://aarambd.com/cat_logo"

# # Function to upload images to the database
# def upload_images_to_database(connection, categories):
#     cursor = connection.cursor()
#     try:
#         for category in categories:
#             # Construct the full image URL
#             image_url = f"{category}.jpg"# Adjust file extension as necessary

#             # SQL query to update the cat_logo column for each category
#             sql = "UPDATE cat SET cat_logo = %s WHERE cat_name = %s"
#             cursor.execute(sql, (image_url, category))
#             connection.commit()
#             print(f"Uploaded {category} image to database.")
    
#     except Exception as e:
#         print(f"Error uploading images to database: {str(e)}")
    
#     finally:
#         cursor.close()

# # Call the function to upload images
# upload_images_to_database(connection, categories)
# # Close the database connection
# connection.close()


































# import pandas as pd
# import os
# import mysql.connector
# import openpyxl
# from datetime import datetime
# import re

# from openpyxl_image_loader import SheetImageLoader
# from pymysql import Error
# # path = os.path.dirnameexcel_path
# # df = pd.read_excel'Assorted.xlsx', sheet_name='shops'

# # MySQL database connection


   
# def fetch_phone_numberscursor:
#     try:
#         cursor.execute"SELECT phone FROM shops"
#         phone_numbers = cursor.fetchall
#         printf"Fetched phone numbers: {phone_numbers}"
#         return phone_numbers
#     except Error as error:
#         printf"Error fetching phone numbers: {error}"
#         return []

# def insert_into_regcursor, phone:
#     try:
#         sql_insert_query = """INSERT INTO reg phone, password VALUES %s, %s"""
#         cursor.executesql_insert_query, phone, '12345'
#         printf"Inserted phone number {phone} into reg"
#     except Error as error:
#         printf"Error inserting phone number {phone} into reg: {error}"


# def fetch_unique_service_categoriescursor:
#     try:
#         cursor.execute"SELECT DISTINCT category FROM service"
#         return cursor.fetchall
#     except Error as error:
#         printf"Error fetching categories: {error}"
#         return []

# def fetch_unique_shops_categoriescursor:
#     try:
#         cursor.execute"SELECT DISTINCT category FROM shops"
#         return cursor.fetchall
#     except Error as error:
#         printf"Error fetching categories: {error}"
#         return []

# def insert_into_catcursor, category:
#     try:
#         sql_insert_query = """INSERT INTO cat cat_name VALUES %s"""
#         cursor.executesql_insert_query, category,
#         printcursor
#     except Error as error:
#         printf"Error inserting category {category} into cat: {error}"

# def main:
#     try:
#         connection = mysql.connector.connect
#             host="localhost",
#             user="root",
#             password="",
#             database="registration"
#         
#         if connection.is_connected:
#             cursor = connection.cursor
#             shop_categories = fetch_unique_shops_categoriescursor
#             service_categories = fetch_unique_service_categoriescursor

#             for category in shop_categories:
#                 insert_into_catcursor, category[0].lower
            
#             for category in service_categories:
#                 insert_into_catcursor, category[0].lower

#             connection.commit # Commit all insertions
#             print"Categories inserted successfully."

#     except Error as error:
#         printf"Database connection error: {error}"
#     finally:
#         if connection.is_connected:
#             cursor.close
#             connection.close














    #         phone_numbers = fetch_phone_numberscursor

    #         for phone in phone_numbers:
    #             phone_number = phone[0]
    #             phone_number = strphone_number
    #             if lenphone_number == 10:
    #                 formatted_phone = f"0{phone_number}"
    #                 insert_into_regcursor, formatted_phone

    #         connection.commit # Commit all insertions
    #         print"Phone numbers inserted successfully."

    # except Error as error:
    #     printf"Database connection error: {error}"
    # finally:
    #     if connection.is_connected:
    #         cursor.close
    #         connection.close


      












# def update_image_pathscursor, connection:
#     try:
#         # Fetch all shop IDs from the shops table
#         cursor.execute"SELECT service_id FROM service"
#         rows = cursor.fetchall

#         # Update each shop with a unique photo path
#         for index, row in enumeraterows:
#             service_id = row[0]
#             image_file_name = f'photo-{index + 1}.png'
#             sql_update_query = """UPDATE service SET photo = %s WHERE service_id = %s"""
#             update_tuple = image_file_name, service_id
#             cursor.executesql_update_query, update_tuple
#             printf"Image path {image_file_name} for shop ID {service_id} updated successfully"

#         # Commit the updates to the database
#         connection.commit

#     except Error as error:
#         printf"Failed to update data in MySQL table {error}"

# connection,cursor = mydb

# if connection and cursor:
#     update_image_pathscursor,connection
#     cursor.close
#     connection.close



# cursor = mydb.cursor
# for filename in os.listdir'downloaded_images':
#         if filename.endswith".png":  # Check if the file is a JPEG image
#             user_id = filename.split'_'[1].split'.'[0]  # Extract user_id from filename e.g., '1' from 'image_1.jpg'
#             filepath = os.path.join'downloaded_images', filename
            
#             if intuser_id < 11:
#                 with openfilepath, 'rb' as file:
#                     binary_data = file.read
            
#             # SQL Query to update the image data in the service table where user_id matches
#             query = "UPDATE service SET photo = %s WHERE service_id = %s"
            
#             # Execute the query
#             cursor.executequery, binary_data, user_id
#             printf"Image {filename} updated in the database for user_id {user_id}."
#         else:
#              break

       
            # Open the image file and read it into a binary variable
            



# SQL query to insert data
# SQL query to insert data, excluding shop_id auto-increment and using NOW for the current timestamp
# sql = "INSERT INTO shops category, business_name, address, phone, date_time VALUES  %s, %s, %s, %s, NOW"
# DEFAULT_PHONE = "0000000000"  # Replace with an appropriate default value

# # Loop through the data and insert into the database
# for index, row in df.iterrows:
#     try:
#         # Check and clean the phone number
#         phone = strrow['phone'] if pd.notnarow['phone'] else DEFAULT_PHONE
#         phone = re.subr'[^0-9]', '   ', phone  # Remove all non-numeric characters
        
#         if not phone.isdigit or phone == "":
#             phone = DEFAULT_PHONE  # Set phone to default if non-numeric or empty

#         # Insert data into the database
#         cursor.executesql, 
#             row['category'] if pd.notnarow['category'] else None,
#             row['business_name'] if pd.notnarow['business_name'] else None,
#             row['address'] if pd.notnarow['address'] else None,
#             phone,
           
#         
#     except Exception as e:
#         printf"Error inserting row {index}: {e}"

# # Commit changes and close connection
# mydb.commit
# cursor.close
# mydb.close

# print"Data successfully inserted into the database."

# path = "C:\\Users\\user\\Downloads\\photo\\die"
# counter = 1
# for filename in os.listdirpath:
#     if filename.endswith'png' or filename.endswith'jpg' or filename.endswith'jpeg':
#         old_file_path = os.path.joinpath,filename
#         new_name = f'photo-{counter}.png'
#         new_file_path = os.path.joinpath,new_name
#         os.renameold_file_path,new_file_path
#         counter += 1
#         printf"{new_name} file name rename" 

# update 
# import mysql.connector
# from mysql.connector import Error
# from ftplib import FTP

# def update_image_pathcursor, shop_id, image_file_name:
#     try:
#         # Update shop details with image file path in the database
#         sql_update_query = """UPDATE shops SET photo = %s WHERE shop_id = %s"""
#         update_tuple = image_file_name, shop_id
#         cursor.executesql_update_query, update_tuple
#         printf"Image path {image_file_name} for shop ID {shop_id} updated successfully"
#     except Error as error:
#         printf"Failed to update data in MySQL table {error}"

# def list_ftp_imagesftp, directory:
#     ftp.cwddirectory
#     files = ftp.nlst
#     return [f for f in files if f.endswith'.jpg', '.jpeg', '.png']

# def process_imagesftp_host, ftp_user, ftp_password, ftp_directory:
#     try:
#         # Connect to FTP server
#         ftp = FTPftp_host
#         ftp.loginftp_user, ftp_password
#         cursor = mydb.cursor
        
#         image_files = list_ftp_imagesftp, ftp_directory
        
#         for image_file in image_files:
#             try:
#                 # Extract shop ID from filename
#                 shop_id = intimage_file.split'-'[1].split'.'[0]
#                 update_image_pathcursor, shop_id, image_file
#             except ValueError:
#                 printf"Skipping file {image_file}, unable to extract shop ID"
        
#         mydb.commit
#         cursor.close
#         mydb.close
#         ftp.quit
#         print"All updates completed and connections closed successfully"
#     except Exception as e:
#         printf"Error processing images: {e}"

# # Example usage
# ftp_host = '89.117.27.223'
# ftp_user = 'u790304855'
# ftp_password = 'Badhon12345'
# ftp_directory = '/domains/aarambd.com/public_html/photo'  # Update this to your directory

# process_imagesftp_host, ftp_user, ftp_password, ftp_directory
