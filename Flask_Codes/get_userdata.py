import base64
import ftplib
from flask import Flask, jsonify,request,session
import secrets


from json import *
from flask_mysqldb import MySQL
# from _mysql_connector import *
import re
import pymysql
from flask_cors import CORS
import time
from mysql.connector import Error

import pymysql.cursors
import requests
from ftplib import FTP
from datetime import *
from datetime import datetime




class MySQLConnector:
    def __init__(self, host, user, password, database):
        self.host = host
        self.user = user
        self.password = password
        self.database = database

    def connect(self):
        return pymysql.connect(host=self.host, user=self.user, password=self.password, database=self.database)

class DataRetriever:
    def __init__(self, db_connector):
        self.db_connector = db_connector

    def get_data_from_db(self):
        connection = self.db_connector.connect()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        cursor.execute("SELECT * FROM reg")
        data = cursor.fetchall()
        connection.close()
        return data
  
DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''
DB_DATABASE = 'registration'
dict_class = pymysql.cursors.DictCursor
   
app = Flask(__name__)
CORS(app)
# secret_key = secrets.token_hex(16)  # Generates a 32-character hexadecimal string

app.secret_key = secrets.token_hex(16) 
print(secrets.token_hex(16) )
# MySQL database configuration


# Create an instance of MySQLConnector
db_connector = MySQLConnector(DB_HOST, DB_USER, DB_PASSWORD, DB_DATABASE)

# Create an instance of DataRetriever
data_retriever = DataRetriever(db_connector)



@app.route('/',methods=['GET', 'POST'])
def get_data():
    # Retrieve data from the database
    data = data_retriever.get_data_from_db()
    
    # Return data as JSON
    return jsonify({'data':data})



@app.route('/add', methods=['POST'])
def add_data_to_db():
    if request.method == 'POST':
        try:
            data = request.get_json()
            print("Received Data:", data)
            name = data['name'].title()
            phone = data['phone']
            password = data['password']
        except Exception as e:
            print(f"Error parsing JSON: {str(e)}")
            return jsonify({"error": f"Failed to parse JSON data: {str(e)}"}), 400

        try:
            connection = db_connector.connect()
            cursor = connection.cursor()
            print("Database connection established.")

            # Insert into reg table
            cursor.execute(
                "INSERT INTO reg (name, phone, password, created_date) VALUES (%s, %s, %s, %s)",
                (name, phone, password, datetime.now())
            )
            connection.commit()
            reg_id = cursor.lastrowid
            print(f"Inserted into reg table with reg_id: {reg_id}")

            # Insert into users table with a default cat_id
            default_cat_id = 56  # Replace with an actual valid cat_id
            cursor.execute(
                "INSERT INTO users (reg_id, name, phone, user_logged_date, cat_id) VALUES (%s, %s, %s, %s, %s)",
                (reg_id, name, phone, datetime.now(), default_cat_id)
            )
            connection.commit()
            print("Inserted into users table.")

            return jsonify({"reg_id": reg_id, "message": "Data added successfully"})

        except Exception as e:
            connection.rollback()
            print(f"Database operation failed: {str(e)}")
            return jsonify({"error": str(e)}), 500
        finally:
            cursor.close()
            connection.close()
            print("Database connection closed.")
        
    


@app.route('/login', methods=['POST'])
def login_user():
    if request.method == 'POST':
        try:
            data = request.get_json()
            print("Received Data:", data)  # Print the received data for debugging
            phone = data['phone']
            password = data['password']
        except Exception as e:
            return jsonify({"error": f"Failed to parse JSON data: {str(e)}"}), 400

        # Check if the user exists in the database
        connection = db_connector.connect()
        cursor = connection.cursor()
        try:
            cursor.execute("SELECT * FROM reg WHERE phone = %s AND password = %s", (phone, password))
            user = cursor.fetchone()
            print(user)
            if user:
                # User found, get the necessary details
                reg_id = user[0]  # Assuming reg_id is the first element in the tuple
                name = user[1]    # Assuming name is the second element in the tuple
                user_phone = user[2]  # Assuming phone is the third element in the tuple

                # Check if the user already exists in the users table
                cursor.execute("SELECT * FROM users WHERE phone = %s", (user_phone,))
                existing_user = cursor.fetchone()

                if existing_user:
                    print("User already exists in users table.")
                    # Update the user_logged_date to the current timestamp
                    try:
                        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                        cursor.execute(
                            "UPDATE users SET user_logged_date = %s WHERE phone = %s",
                            (current_time, user_phone)
                        )
                        connection.commit()
                        print("User login time updated.")
                        user_id = str(existing_user[0])  # Assuming user_id is the first element
                    except Exception as update_error:
                        return jsonify({"error": f"Failed to update login time: {str(update_error)}"}), 500
                else:
                    # User does not exist in users table, insert the data
                    try:
                        cursor.execute("INSERT INTO users (reg_id, name, phone) VALUES (%s, %s, %s)", (reg_id, name, user_phone))
                        connection.commit()  # Commit the transaction
                        print("User inserted into users table.")
                        user_id = str(cursor.lastrowid)  # Get the user_id of the newly inserted user
                    except Exception as insert_error:
                        return jsonify({"error": f"Failed to insert user into users table: {str(insert_error)}"}), 500

                return jsonify({
                    "message": "Login successful",
                    "user": {"reg_id": reg_id, "name": name, "phone": user_phone, "user_id": user_id}
                })
            else:
                # User not found, return error message
                return jsonify({"error": "Invalid phone number or password"}), 401
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            cursor.close()
            connection.close()



@app.route('/check_phone', methods=['POST'])
def check_phone():
    if request.method == 'POST':
        try:
            data = request.get_json()
            phone = data['phone']
            # You can ignore the password or set any necessary value
        except Exception as e:
            return jsonify({"error": f"Failed to parse JSON data: {str(e)}"}), 400

        connection = db_connector.connect()
        cursor = connection.cursor()
        try:
            cursor.execute("SELECT * FROM reg WHERE phone = %s", (phone,))
            user = cursor.fetchone()
            if user:
                return jsonify({"exists": True})
            else:
                return jsonify({"exists": False})
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            cursor.close()
            connection.close()


@app.route('/get_user_by_phone', methods=['GET'])
def get_user_by_phone():
    phone = request.args.get('phone')
    if not phone:
        return jsonify({"error": "Phone number is required"}), 400

    connection = None
    try:
        connection = db_connector.connect()
        cursor = connection.cursor()
        
        query = """
        SELECT users.user_id, users.name, users.cat_id, users.description, users.location, users.user_viewed, users.user_called, users.user_shared, cat.cat_name, users.photo 
        FROM users
        LEFT JOIN cat ON users.cat_id = cat.cat_id
        WHERE users.phone = %s
        """
        cursor.execute(query, (phone,))
        result = cursor.fetchone()
        print(result)

        if result:
            user_id = result[0]
            profile_pic = result[9]  # Assume the profile picture is in the last column

            profile_pic = profile_pic.split(',')[0]

            # Store user_id in the Flask session
            session['user_id'] = user_id

            # Fetch posts associated with the user_id
            post_query = """
            SELECT post.post_id, post.post_des, post.post_media, post.post_time,post.post_liked,post.post_viewed,post.post_shared
            FROM post
            WHERE post.user_id = %s
            ORDER BY post.post_time DESC
            """
            cursor.execute(post_query, (user_id,))
            posts = cursor.fetchall()

            # Format the post data as gallery items
            post_list = []
            for post in posts:
                post_media = post[2].split(',') if post[2] else []
                post_list.append({
                    "post_id": str(post[0]),
                    "post_description": post[1],
                    "post_media": post_media,
                    "post_time": post[3].strftime('%Y-%m-%d %H:%M:%S'),
                    'post_liked':post[4],
                    'post_viewed':post[5],
                    'post_shared':post[6],
                })

            return jsonify({
                'user_id':str(result[0]),
                "name": result[1],
                "cat_id": result[2],
                "description": result[3],
                "location": result[4],
                "user_viewed":result[5],
                "user_called":result[6],
                "user_shared":result[7],
                "cat_name": result[8],  # Correct index for category name
                "photo": profile_pic,  # Assuming profile_pic is a URL
                "posts": post_list  # Returning the posts as gallery items
            })
        else:
            return jsonify({"success": False, "message": "User not found"}), 404

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"success": False, "message": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"success": False, "message": str(e)}), 500
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

import traceback
FTP_HOST = '89.117.27.223'
FTP_USER = 'u790304855'
FTP_PASS = 'Abra!!@@12'
FTP_DIRECTORY = '/domains/aarambd.com/public_html/upload'
@app.route('/update_user_profile', methods=['POST'])
def update_user_profile():
    name = request.form.get('name')
    phone = request.form.get('phone')
    category = request.form.get('category')
    description = request.form.get('description')
    location = request.form.get('location')
    images = request.files.getlist('images')

    connection = db_connector.connect()
    if connection is None:
        return jsonify({"success": False, "message": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dict_class)
    try:
        # Fetch user data
        cursor.execute('''SELECT u.user_id, u.name, u.cat_id, u.description, u.location, u.photo, c.cat_name 
                          FROM users u
                          JOIN cat c ON u.cat_id = c.cat_id
                          WHERE u.phone = %s''', (phone,))
        user = cursor.fetchone()
        
        if not user:
            return jsonify({"success": False, "message": "User not found"}), 404

        # Accessing values as dictionary keys
        user_id = user['user_id']
        updated_name = name if name else user['name']
        category_id = category
        updated_category_name = category if category else user['cat_name']  # This is the category name we will use
        updated_description = description if description else user['description']
        updated_location = location if location else user['location']

        # Handle image URLs
        existing_image_urls = user['photo'].split(',') if user['photo'] else []
        new_image_urls = []

        # FTP connection
        try:
            ftp = FTP(FTP_HOST, FTP_USER, FTP_PASS)
            ftp.cwd(FTP_DIRECTORY)

            for image in images:
                image_filename = f"{phone}_{image.filename}"
                image_url = f"https://aarambd.com/upload/{image_filename}"

                # Upload image to FTP server
                with image.stream as file:
                    ftp.storbinary(f'STOR {image_filename}', file)

                new_image_urls.insert(0, image_url)

            updated_image_urls = new_image_urls + existing_image_urls
            updated_image_urls_str = ','.join(updated_image_urls)
        except Exception as ftp_err:
            logging.error(f"FTP Error: {str(ftp_err)}")
            return jsonify({"success": False, "message": "Failed to upload images to FTP"}), 500

        # Update user in the 'users' table
        query = """
        UPDATE users
        SET name = %s, cat_id = %s, description = %s, location = %s, photo = %s
        WHERE phone = %s
        """
        cursor.execute(query, (updated_name, category_id, updated_description, updated_location, updated_image_urls_str, phone))
        connection.commit()
        updated_category_name.lower()
        # Determine if the category name contains the word 'service'
        if 22 >= int(category_id) >=1:
            # Insert or update in 'service' table
            cursor.execute("SELECT shop_id FROM shop WHERE user_id = %s", (user_id,))
            if cursor.fetchone():
                # Delete user from 'shop' table
                cursor.execute("DELETE FROM shop WHERE user_id = %s", (user_id,))

            # Check if the user exists in 'service' table
            cursor.execute("SELECT COUNT(*) FROM service WHERE user_id = %s", (user_id,))
            result = cursor.fetchone()
            if result is None or result['COUNT(*)'] == 0:
                # Insert new record into 'service' table
                cursor.execute("""
                    INSERT INTO service (user_id, name, phone, cat_id, description, location, photo)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """, (user_id, updated_name, phone, category_id, updated_description, updated_location, updated_image_urls_str))
            else:
                # Update existing record in 'service' table
                cursor.execute("""
                    UPDATE service
                    SET name = %s, phone = %s, cat_id = %s, description = %s, location = %s, photo = %s
                    WHERE user_id = %s
                """, (updated_name, phone, category_id, updated_description, updated_location, updated_image_urls_str, user_id))
        else:
            # Insert or update in 'shop' table
            cursor.execute("SELECT service_id FROM service WHERE user_id = %s", (user_id,))
            if cursor.fetchone():
                # Delete user from 'service' table
                cursor.execute("DELETE FROM service WHERE user_id = %s", (user_id,))

            # Check if the user exists in 'shop' table
            cursor.execute("SELECT COUNT(*) FROM shop WHERE user_id = %s", (user_id,))
            result = cursor.fetchone()
            if result is None or result['COUNT(*)'] == 0:
                # Insert new record into 'shop' table
                cursor.execute("""
                    INSERT INTO shop (user_id, name, phone, cat_id, description, location, photo)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """, (user_id, updated_name, phone, category_id, updated_description, updated_location, updated_image_urls_str))
            else:
                # Update existing record in 'shop' table
                cursor.execute("""
                    UPDATE shop
                    SET name = %s, phone = %s, cat_id = %s, description = %s, location = %s, photo = %s
                    WHERE user_id = %s
                """, (updated_name, phone, category_id, updated_description, updated_location, updated_image_urls_str, user_id))

        # Commit changes
        connection.commit()

        return jsonify({"success": True, "image_urls": updated_image_urls_str})

    except Exception as e:
        connection.rollback()
        logging.error(f"Error: {str(e)}")
        logging.error(traceback.format_exc())
        return jsonify({"success": False, "message": str(e)}), 500

    finally:
        cursor.close()
        connection.close()
        



# Set up logging

import logging

# Set up logging
logging.basicConfig(level=logging.DEBUG)

@app.route('/post_data', methods=['POST'])
def post_data():
    try:
        logging.debug("Received request: %s", request.data)

        # Parse form data
        post_phone = request.form.get('post_phone')
        post_cat = request.form.get('post_cat')
        description = request.form.get('description')
        media_files = request.files.getlist('media')

        logging.debug("Parsed form data: post_phone=%s, post_cat=%s, description=%s, media_files=%s", post_phone, post_cat, description, media_files)

        if not post_phone or not post_cat or not description:
            return jsonify({"success": False, "message": "Missing required fields"}), 400

        media_urls = []
        post_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        # FTP upload
        try:
            ftp = FTP(FTP_HOST)
            ftp.login(FTP_USER, FTP_PASS)
            ftp.cwd(FTP_DIRECTORY)

            for media in media_files:
                filename = f"{post_phone}_{media.filename}"
                media_url = f"https://aarambd.com/upload/{filename}"

                with media.stream as file:
                    ftp.storbinary(f'STOR {filename}', file)

                media_urls.append(media_url)

            ftp.quit()
            logging.debug("FTP upload successful: media_urls=%s", media_urls)
        except Exception as e:
            logging.error("FTP error: %s", str(e))
            return jsonify({"success": False, "message": f"FTP error: {str(e)}"}), 500

        # Update user photo data
        try:
            # Fetch current user data
            connection = db_connector.connect()
            cursor = connection.cursor()

            cursor.execute("SELECT photo FROM users WHERE phone = %s", (post_phone,))
            user = cursor.fetchone()
            if not user:
                cursor.close()
                connection.close()
                return jsonify({"success": False, "message": "User not found"}), 404

            # Combine existing and new image URLs
            existing_photo_urls = user[0].split(',') if user[0] else []
            updated_photo_urls = existing_photo_urls + media_urls
            updated_photo_str = ','.join(updated_photo_urls)

            # Update user data in the database
            update_query = """
            UPDATE users
            SET photo = %s
            WHERE phone = %s
            """
            cursor.execute(update_query, (updated_photo_str, post_phone))
            connection.commit()

            cursor.close()
            connection.close()

            logging.debug("User photo update successful: phone=%s", post_phone)
        except Exception as e:
            logging.error("Database error: %s", str(e))
            return jsonify({"success": False, "message": f"Database error: {str(e)}"}), 500

        # Database insertion for post data
        try:
            connection = db_connector.connect()
            cursor = connection.cursor()

            insert_query = """
            INSERT INTO post (post_phone, post_cat, description, media, post_time)
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(insert_query, (post_phone, post_cat, description, ','.join(media_urls), post_time))
            connection.commit()

            post_id = cursor.lastrowid

            cursor.close()
            connection.close()

            logging.debug("Database insertion successful: post_id=%s", post_id)
            return jsonify({"success": True, "message": "Post created successfully", "post_id": post_id})
        except Exception as e:
            logging.error("Database error: %s", str(e))
            return jsonify({"success": False, "message": f"Database error: {str(e)}"}), 500

    except Exception as e:
        logging.error("Unexpected error: %s", str(e))
        return jsonify({"success": False, "message": f"Unexpected error: {str(e)}"}), 500






@app.route('/get_categories_name', methods=['GET'])
def get_categories_name():
    connection = db_connector.connect()
    if connection is None:
        return jsonify({"success": False, "message": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dict_class)
    try:
        category_type = request.args.get('type')  # Get the type from query parameter
        
        if category_type == 'service':
            cursor.execute("SELECT cat_id, cat_name FROM cat WHERE cat_id BETWEEN 1 AND 22 ORDER BY cat_name")
        elif category_type == 'shop':
            cursor.execute("SELECT cat_id, cat_name FROM cat WHERE cat_id BETWEEN 23 AND 55 ORDER BY cat_name")
        else:
            cursor.execute("SELECT cat_id, cat_name FROM cat WHERE cat_id BETWEEN 1 AND 55 ORDER BY cat_name")  # Default: get all categories

        categories = cursor.fetchall()

        if not categories:
            return jsonify({"success": False, "message": "No categories found"}), 404

        return jsonify({'categories': [{"cat_id": cat['cat_id'], "cat_name": cat['cat_name']} for cat in categories]})

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({"success": False, "message": str(e)}), 500
    finally:
        cursor.close()
        connection.close()



@app.route('/get_users_data', methods=['GET'])
def get_user_data():
    if request.method == 'GET':
        # Fetch user data from the users table
        connection = db_connector.connect()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        try:
            cursor.execute("SELECT * FROM service")
            users_data = cursor.fetchall()
            
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            cursor.close()
            connection.close()

        # Fetch data from the reg table based on the foreign key relationship
        users_with_phone_data = []
        for user in users_data:
            reg_id = user['service_id']
            connection = db_connector.connect()
            cursor = connection.cursor()
            try:
                cursor.execute("SELECT phone FROM reg WHERE reg_id = %s", (reg_id,))
                reg_data = cursor.fetchone()
                if reg_data:
                   phone = reg_data[0]  # Extract phone number from the tuple
                   user['phone'] = phone
                users_with_phone_data.append(user)
            except Exception as e:
                return jsonify({"error": str(e)}), 500
            finally:
                cursor.close()
                connection.close()

        return jsonify({"users_data": users_with_phone_data})



@app.route('/get_service_data', methods=['GET'])
def get_service_data():
    HTTP_BASE_URL = "http://aarambd.com/cat logo/" 
    if request.method == 'GET':
        connection = None
        try:
            connection = db_connector.connect()  # Ensure this function uses a robust method to handle connections
            with connection.cursor(pymysql.cursors.DictCursor) as cursor:
                # Fetch categories and their counts
                sql_query = '''SELECT c.cat_id,c.cat_name, c.cat_logo,s.cat_id, COUNT(s.service_id) AS count FROM service s
                JOIN cat c ON s.cat_id = c.cat_id GROUP BY c.cat_name, c.cat_logo'''
                cursor.execute(sql_query)
                categories_data = cursor.fetchall()

                # Fetch all service information
                cursor.execute('''SELECT s.service_id, c.cat_name,c.cat_logo, u.user_id,u.name,u.phone,u.location,u.photo
                FROM service s
                JOIN cat c ON s.cat_id = c.cat_id
                JOIN users u ON s.user_id = u.user_id''')
                all_users_data = cursor.fetchall()

                # Update photo path to include the full HTTP URL
                for user in all_users_data:
                    if 'photo' in user and user['photo']:
                        img= user['photo']
                        imgs = img.split(",")
                        user['photo'] = imgs[0]
                    else:
                        user['photo'] = f"{HTTP_BASE_URL}{user['cat_logo']}"

            # Prepare category count data
            sep_category_count = []
            for category in categories_data:
                category['cat_logo'] = f"{HTTP_BASE_URL}/{category['cat_logo']}" if category['cat_logo'] else None
                sep_category_count.append(
                    {"cat_id": str(category['cat_id']),"name": category['cat_name'], "count": category['count'],'photo':category['cat_logo']})

            return jsonify({'category_count': sep_category_count, 'service_information': all_users_data})

        except pymysql.MySQLError as e:
            print(f"Database error: {e}")
            return jsonify({"error": str(e)}), 500
        except Exception as e:
            print(f"General error: {e}")
            return jsonify({"error": str(e)}), 500
        finally:
            if connection:
                connection.close()  # 

"""Get Shop Data from DB"""
@app.route('/get_shops_data', methods=['GET'])

# Define your HTTP base URL
 # Adjust this to match the actual URL structu
def get_shop_data():
    HTTP_BASE_URL = "http://aarambd.com/cat logo/" 
    if request.method == 'GET':
        connection = None
        try:
            connection = db_connector.connect()  # Ensure this function uses a robust method to handle connections
            with connection.cursor(pymysql.cursors.DictCursor) as cursor:
                # Fetch categories and their counts
                sql_query = '''SELECT c.cat_id,c.cat_name, c.cat_logo, COUNT(s.shop_id) AS count 
                               FROM shop s
                               JOIN cat c ON s.cat_id = c.cat_id 
                               GROUP BY c.cat_name, c.cat_logo'''
                cursor.execute(sql_query)
                categories_data = cursor.fetchall()

                # Fetch all service information
                cursor.execute('''SELECT s.shop_id, c.cat_name, c.cat_logo, u.user_id, u.name, u.phone, u.location, u.photo
                                  FROM shop s
                                  JOIN cat c ON s.cat_id = c.cat_id
                                  JOIN users u ON s.user_id = u.user_id''')
                all_users_data = cursor.fetchall()

                # Update photo path to include the full HTTP URL
                for user in all_users_data:
                    if 'photo' in user and user['photo']:
                        img= user['photo']
                        imgs = img.split(",")
                        user['photo'] = imgs[0]
                    else:
                        user['photo'] = f"{HTTP_BASE_URL}{user['cat_logo']}"

            # Prepare category count data
            sep_category_count = []
            for category in categories_data:
                category['cat_logo'] = f"{HTTP_BASE_URL}/{category['cat_logo']}" if category['cat_logo'] else None
                sep_category_count.append(
                    {"cat_id": str(category['cat_id']),"name": category['cat_name'], "count": category['count'], 'photo': category['cat_logo']})

            return jsonify({'category_count': sep_category_count, 'shops_information': all_users_data})

        except pymysql.MySQLError as e:
            print(f"Database error: {e}")
            return jsonify({"error": str(e)}), 500
        except Exception as e:
            print(f"General error: {e}")
            return jsonify({"error": str(e)}), 500
        finally:
            if connection:
                connection.close()




@app.route('/get_category_and_counts_all_info', methods=['GET','POST'])
def get_category_and_counts_all_info():
    if request.method == 'GET' or request.method == 'POST':
        # Fetch unique categories and their counts from the users table
        connection = db_connector.connect()
        cursor = connection.cursor()
        try:
            cursor.execute('''SELECT c.cat_id,c.cat_name,COUNT(u.cat_id) AS count FROM users u
                JOIN cat c ON u.cat_id = c.cat_id GROUP BY c.cat_name''')
            category_counts = cursor.fetchall()
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            cursor.close()
            connection.close()

        # Separate category name and count
        separated_category_counts = []
        for cat_id, cat_name,count in category_counts:
            connection = db_connector.connect()
            cursor = connection.cursor()
            update_query = """
                UPDATE cat SET user_count = %s WHERE cat_id = %s
                """
            cursor.execute(update_query, (count, cat_id))
            connection.commit()


            separated_category_counts.append({"cat_id": cat_id, "cat_name": cat_name,"count":count})

        # Fetch all user information
        connection = db_connector.connect()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        try:
            cursor.execute("SELECT * FROM users")
            all_users_data = cursor.fetchall()
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            cursor.close()
            connection.close()

        return jsonify({"category_counts": separated_category_counts, "all_users_data": all_users_data})



@app.route('/update_cat_used', methods=['POST'])
def update_cat_used():
    cat_id = request.json.get('cat_id')

    if not cat_id:
        return jsonify({"error": "cat_id is required"}), 400

    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor() as cursor:
            # Increment the cat_used count
            update_query = """
            UPDATE cat 
            SET cat_used = cat_used + 1 
            WHERE cat_id = %s
            """
            cursor.execute(update_query, (cat_id,))
            connection.commit()

            return jsonify({"message": "Category usage updated successfully"}), 200

    except pymysql.MySQLError as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()




@app.route('/get_combined_data', methods=['GET'])
def get_combined_data():
    HTTP_BASE_URL = "http://aarambd.com/cat logo/" 
    if request.method == 'GET':
        connection = None
        try:
            connection = db_connector.connect()  # Ensure this function uses a robust method to handle connections
            with connection.cursor(pymysql.cursors.DictCursor) as cursor:
                # Fetch categories and their counts from service table
                sql_query_service = '''SELECT c.cat_id,c.cat_name, c.cat_logo,s.cat_id, COUNT(s.service_id) AS count FROM service s
                JOIN cat c ON s.cat_id = c.cat_id GROUP BY c.cat_name, c.cat_logo'''
                cursor.execute(sql_query_service)
                service_count = cursor.fetchall()
                
                for service in service_count:
                    service['cat_id'] =str(service['cat_id'])
                
               
                # Fetch all service information
                cursor.execute('''SELECT s.service_id, c.cat_name,c.cat_logo,u.user_id,u.name,u.phone,u.location,u.photo
                FROM service s
                JOIN cat c ON s.cat_id = c.cat_id
                JOIN users u ON s.user_id = u.user_id''')
                
                all_service_data = cursor.fetchall()

                for user in all_service_data:
                    if 'photo' in user and user['photo']:
                        img= user['photo']
                        imgs = img.split(",")
                        user['photo'] = imgs[0]
                    else:
                        user['photo'] = f"{HTTP_BASE_URL}{user['cat_logo']}"



                # Fetch categories and their counts from shop table
                sql_query_shop ='''SELECT c.cat_id,c.cat_name, c.cat_logo, COUNT(s.shop_id) AS count 
                               FROM shop s
                               JOIN cat c ON s.cat_id = c.cat_id 
                               GROUP BY c.cat_name, c.cat_logo'''
                cursor.execute(sql_query_shop)
                shop_count = cursor.fetchall()

                for shop in shop_count:
                    shop['cat_id'] =str(shop['cat_id'])
                
                
                # Fetch all shop information
                cursor.execute('''SELECT s.shop_id, c.cat_name, c.cat_logo, u.user_id, u.name, u.phone, u.location, u.photo
                                  FROM shop s
                                  JOIN cat c ON s.cat_id = c.cat_id
                                  JOIN users u ON s.user_id = u.user_id''')
                all_shop_data = cursor.fetchall()

                for user in all_shop_data:
                    if 'photo' in user and user['photo']:
                        # user['photo'] = user['photo']
                        img= user['photo']
                        imgs = img.split(",")
                        user['photo'] = imgs[0]
                    else:
                        user['photo'] = f"{HTTP_BASE_URL}{user['cat_logo']}"

                # Convert bytes to Base64 string if necessary
            # for user in all_service_data:
                    
            #         if 'photo' in user and user['photo']:
            #             user['photo'] = user['photo']
            
            # for user in all_shop_data:
            #         if 'photo' in user and user['photo']:
            #             user['photo'] = user['photo']

            # Interleave the service and shop data
            combined_data = []
            combined_category_count = []
            max_length = max(len(all_service_data), len(all_shop_data))
            max_cat_length = max(len(service_count),len(shop_count))

            for i in range(max_cat_length):
                if i < len(service_count):
                    combined_category_count.append(service_count[i])
                if i < len(shop_count):
                    combined_category_count.append(shop_count[i])
          
           
            for i in range(max_length):
                if i < len(all_service_data):
                    combined_data.append(all_service_data[i])
                if i < len(all_shop_data):
                    combined_data.append(all_shop_data[i])
                    
            
            # Prepare combined category count data
            # combined_category_count = service_categories_data + shop_categories_data


            return jsonify({'category_count': combined_category_count, 'combined_information': combined_data})

        except pymysql.MySQLError as e:
            print(f"Database error: {e}")
            return jsonify({"error": str(e)}), 500
        except Exception as e:
            print(f"General error: {e}")
            return jsonify({"error": str(e)}), 500
        finally:
            if connection:
                connection.close()


@app.route('/get_service_data_by_category', methods=['GET'])
def get_service_data_by_category():
    cat_id = request.args.get('cat_id', None)
    sort_by = request.args.get('sort_by', None)
    user_location = request.args.get('user_location', None)  # For 'nearby' sorting
    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            base_query = '''
            SELECT s.service_id, c.cat_name, c.cat_logo, u.*
            FROM service s
            JOIN cat c ON s.cat_id = c.cat_id
            JOIN users u ON s.user_id = u.user_id
            '''
            params = []

            # Filter by category if provided
            if cat_id:
                base_query += ' WHERE s.cat_id = %s'
                params.append(cat_id)

            # Sorting options
            if sort_by == 'most_viewed':
                base_query += ' ORDER BY u.user_viewed DESC'
            elif sort_by == 'most_called':
                base_query += ' ORDER BY u.user_called DESC'
            elif sort_by == 'recent':
                base_query += ' ORDER BY u.user_logged_date DESC'
            elif sort_by == 'nearby' and user_location:
                base_query += ' ORDER BY calculate_distance(u.location, %s)'
                params.append(user_location)

            # Execute query with the parameters list
            cursor.execute(base_query, params)
            all_data = cursor.fetchall()

            all_users_data = []

            for user in all_data:
                pp = user['photo'] or f"http://aarambd.com/cat logo/{user['cat_logo']}"
                pp = pp.split(",")[0]
                user['photo'] = pp

                # Calculate account age (days since creation)
                created_date = user['user_logged_date']
                days_since_creation = (datetime.now() - created_date).days if created_date else None

                # Handle data based on sort_by
                data = {
                    'user_id': user['user_id'],
                    'service_id': user['service_id'],
                    'name': user['name'],
                    'photo': user['photo'],
                    'phone': user['phone'],
                    'location': user['location'],
                    'days_since_creation': str(days_since_creation),
                    'cat_name': user['cat_name'],
                    'cat_id': str(user['cat_id'])
                }

                if sort_by == 'most_viewed':
                    data['user_viewed'] = str(user['user_viewed'])
                elif sort_by == 'most_called':
                    data['user_called'] = str(user['user_called'])
                elif sort_by == 'recent':
                    data['days_since_creation'] = str(days_since_creation)

                all_users_data.append(data)

            return jsonify({'service_information': all_users_data})

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()

@app.route('/get_shop_data_by_category', methods=['GET'])
def get_shop_data_by_category():
    cat_id = request.args.get('cat_id', None)
    sort_by = request.args.get('sort_by', None)
    user_location = request.args.get('user_location', None)
    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            base_query = '''
            SELECT s.shop_id, c.cat_name, c.cat_logo, u.*
            FROM shop s
            JOIN cat c ON s.cat_id = c.cat_id
            JOIN users u ON s.user_id = u.user_id
            '''
            params = []

            # Filter by category if provided
            if cat_id:
                base_query += ' WHERE s.cat_id = %s'
                params.append(cat_id)

            # Sorting options
            if sort_by == 'most_viewed':
                base_query += ' ORDER BY u.user_viewed DESC'
            elif sort_by == 'most_called':
                base_query += ' ORDER BY u.user_called DESC'
            elif sort_by == 'recent':
                base_query += ' ORDER BY u.user_logged_date DESC'
            elif sort_by == 'nearby' and user_location:
                base_query += ' ORDER BY calculate_distance(u.location, %s)'
                params.append(user_location)

            # Execute query with the parameters list
            cursor.execute(base_query, params)
            all_data = cursor.fetchall()

            all_users_data = []

            for user in all_data:
                pp = user['photo'] or f"http://aarambd.com/cat logo/{user['cat_logo']}"
                pp = pp.split(",")[0]
                user['photo'] = pp

                # Calculate account age (days since creation)
                created_date = user['user_logged_date']
                days_since_creation = (datetime.now() - created_date).days if created_date else None

                # Handle data based on sort_by
                data = {
                    'user_id': user['user_id'],
                    'shop_id': user['shop_id'],
                    'name': user['name'],
                    'photo': user['photo'],
                    'phone': user['phone'],
                    'location': user['location'],
                    'days_since_creation': str(days_since_creation),
                    'cat_name': user['cat_name'],
                    'cat_id': str(user['cat_id'])
                }

                if sort_by == 'most_viewed':
                    data['user_viewed'] = str(user['user_viewed'])
                elif sort_by == 'most_called':
                    data['user_called'] = str(user['user_called'])
                elif sort_by == 'recent':
                    data['days_since_creation'] = str(days_since_creation)

                all_users_data.append(data)

            return jsonify({'shop_information': all_users_data})

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()
    

@app.route('/get_data_by_category', methods=['GET'])
def get_data_by_category():
    # Get query parameters
    cat_id = request.args.get('cat_id', None)
    data_type = request.args.get('data_type', None)  # 'service' or 'shop'
    sort_by = request.args.get('sort_by', None)
    user_location = request.args.get('user_location', None)  # For 'nearby' sorting

    # Validate the data_type
    if not data_type or data_type not in ['service', 'shop']:
        return jsonify({"error": "Invalid or missing data_type parameter"}), 400

    connection = None
    try:
        # Database connection
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Base query for fetching service/shop data
            base_query = f'''
                SELECT s.{data_type}_id, c.cat_name, c.cat_logo, u.*, u.user_logged_date
                FROM {data_type} s
                JOIN cat c ON s.cat_id = c.cat_id
                JOIN users u ON s.user_id = u.user_id
            '''
            params = []

            # Filter by category if provided
            if cat_id:
                base_query += ' WHERE s.cat_id = %s'
                params.append(cat_id)

            # Sorting options
            if sort_by == 'most_viewed':
                base_query += ' ORDER BY u.user_viewed DESC'
            elif sort_by == 'most_called':
                base_query += ' ORDER BY u.user_called DESC'
            elif sort_by == 'recent':
                base_query += ' ORDER BY u.user_logged_date DESC'
            elif sort_by == 'nearby' and user_location:
                # Assuming a custom function 'calculate_distance' exists
                base_query += ' ORDER BY calculate_distance(u.location, %s)'
                params.append(user_location)

            # Execute query
            cursor.execute(base_query, params)
            all_data = cursor.fetchall()

            all_users_data = []

            # Process data and add additional info based on sort_by
            for user in all_data:
                # Handle missing profile photo
                pp = user['photo'] or f"http://aarambd.com/cat logo/{user['cat_logo']}"
                pp = pp.split(",")[0]  # Get the first photo URL
                user['photo'] = pp

                # Calculate account age (days since creation)
                created_date = user['user_logged_date']
                days_since_creation = (datetime.now() - created_date).days if created_date else None

                # Handle data based on sort_by
                if sort_by == 'most_viewed':
                    data = {
                        'user_id': user['user_id'],
                        f'{data_type}_id': user[f'{data_type}_id'],
                        'name': user['name'],
                        'photo': user['photo'],
                        'phone': user['phone'],
                        'view': str(user['user_viewed']),
                        'days_since_creation': ''
                    }
                elif sort_by == 'most_called':
                    data = {
                        'user_id': user['user_id'],
                        f'{data_type}_id': user[f'{data_type}_id'],
                        'name': user['name'],
                        'photo': user['photo'],
                        'phone': user['phone'],
                        'call': str(user['user_called']),
                        'days_since_creation': ''
                    }
                elif sort_by == 'recent':
                    data = {
                        'user_id': user['user_id'],
                        f'{data_type}_id': user[f'{data_type}_id'],
                        'name': user['name'],
                        'photo': user['photo'],
                        'phone': user['phone'],
                        #'time': user['user_logged_date'],
                        'days_since_creation': str(days_since_creation),
                        
                    }
                else:
                    # Default structure when no sort is applied
                    data = {
                        'user_id': user['user_id'],
                        f'{data_type}_id': user[f'{data_type}_id'],
                        'name': user['name'],
                        'photo': user['photo'],
                        'phone': user['phone'],
                        'location':user['location'],
                        'days_since_creation': str(days_since_creation),
                        'cat_name':user['cat_name'],
                        'cat_id':str(user['cat_id'])
                    }

                all_users_data.append(data)

            # Return sorted data or all data if no sorting is applied
            return jsonify({f'{data_type}_information': all_users_data})

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()



@app.route('/get_service_or_shop_data', methods=["GET","POST"])
def get_service_or_shop_data():
    service_id = request.args.get('service_id', None)
    shop_id = request.args.get('shop_id', None)
    login_user_id = request.json.get('login_user_id', None) 
    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            data = None
            user_id = None

            if service_id:
                # Fetch data for a service_id
                sql = '''SELECT s.service_id,c.cat_id, c.cat_name, c.cat_logo, u.user_id, u.name, u.phone, u.location, u.description, u.photo,u.user_viewed,u.user_shared,user_called
                         FROM service s
                         JOIN cat c ON s.cat_id = c.cat_id
                         JOIN users u ON s.user_id = u.user_id
                         WHERE service_id = %s'''
                cursor.execute(sql, (service_id,))
                data = cursor.fetchall()
                data_key = "service_data"
                user_id = data[0]['user_id'] if data else None

            elif shop_id:
                # Fetch data for a shop_id
                sql = '''SELECT s.shop_id,c.cat_id, c.cat_name, c.cat_logo, u.user_id, u.name, u.phone, u.location, u.description, u.photo,u.user_viewed,u.user_shared,user_called
                         FROM shop s
                         JOIN cat c ON s.cat_id = c.cat_id
                         JOIN users u ON s.user_id = u.user_id
                         WHERE shop_id = %s'''
                cursor.execute(sql, (shop_id,))
                data = cursor.fetchall()
                data_key = "shop_data"
                user_id = data[0]['user_id'] if data else None
            else:
                # Return error if no ID is provided
                return jsonify({"error": "Please provide either a service_id or a shop_id"}), 400
            
            #update the user_viewed count for the user
            login_id = login_user_id

            if user_id and str(user_id) != str(login_id):
                update_view_sql = '''UPDATE users SET user_viewed = user_viewed + 1 WHERE user_id = %s '''
                cursor.execute(update_view_sql,(user_id,))
                connection.commit()
            
             # Insert into view_list table
                if login_user_id and str(user_id) != str(login_id):
                    insert_view_sql = '''INSERT INTO view_list (view_time, view_user_id, user_id) 
                                         VALUES (NOW(), %s, %s)'''
                    cursor.execute(insert_view_sql, (login_user_id, user_id))
                    connection.commit()

            # Process the photos for both cases (service or shop)
            for user in data:
                pp = user['photo']
                if not pp:
                    pp = f"http://aarambd.com/cat logo/{user['cat_logo']}"
                pp = pp.split(",")
                user['photo'] = pp[0]

                # Fetch posts for the user based on user_id
                user_id = user['user_id']
                sql_posts = '''SELECT post_id, post_des, post_media, post_time,post_liked,post_viewed,post_shared
                               FROM post
                               WHERE user_id = %s
                               ORDER BY post_time DESC'''
                cursor.execute(sql_posts, (user_id,))
                posts = cursor.fetchall()

                # Process post_media if it has multiple media entries
                for post in posts:
                    media = post['post_media']
                    if media:
                        post['post_media'] = media.split(",")


                # Add posts to the user data
                user['posts'] = posts

            return jsonify({data_key: data})

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()


@app.route('/get_view_list', methods=["GET"])
def get_view_list():
    user_id = request.args.get('user_id', None)
    connection = None
    try:
        if not user_id:
            return jsonify({"error": "Please provide a user_id"}), 400

        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Query to retrieve view list for the specified user_id
            sql = '''
            SELECT v.view_id, v.view_time, v.view_user_id, v.user_id,
                       u.name AS view_user_name, u.photo AS view_user_photo
                FROM view_list v
                JOIN users u ON v.view_user_id = u.user_id
                WHERE v.user_id = %s
                ORDER BY v.view_time DESC'''
            cursor.execute(sql, (user_id,))
            view_list = cursor.fetchall()
            
            # For each call entry, determine if the user is in the service or shop table
            for view in view_list:
                view_user_id = view['view_user_id']
                
                # Check if the user is in the service table
                cursor.execute('SELECT service_id FROM service WHERE user_id = %s', (view_user_id,))
                service_data = cursor.fetchone()
                
                if service_data:
                    # User found in service table
                    view['is_service'] = True
                    view['service_id'] = service_data['service_id']
                    
                else:
                    # Check if the user is in the shop table
                    cursor.execute('SELECT shop_id FROM shop WHERE user_id = %s', (view_user_id,))
                    shop_data = cursor.fetchone()
                    
                    if shop_data:
                        # User found in shop table
                        view['is_service'] = False
                        view['shop_id'] = shop_data['shop_id']
                        
                    else:
                        # If user is not in either table, set fields as None
                        view['is_service'] = None
                        view['service_id'] = None
                        view['shop_id'] = None

            return jsonify({"view_list": view_list}), 200

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()


@app.route('/post_user_called', methods=["POST"])
def post_user_called():
    service_id = request.args.get('service_id', None)
    shop_id = request.args.get('shop_id', None)
    call_user_id = request.json.get('call_user_id')  # New parameter
    call_time = request.json.get('call_time')        # New parameter
    user_id = request.json.get('user_id')
    
    if not call_user_id or not call_time or not user_id:
        return jsonify({"error": "Missing required parameters"}), 400
    
    connection = None

    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            user_id = None

            if service_id:
                # Fetch user_id for a service_id
                sql = '''SELECT u.user_id 
                         FROM service s
                         JOIN users u ON s.user_id = u.user_id
                         WHERE s.service_id = %s'''
                cursor.execute(sql, (service_id,))
                result = cursor.fetchone()
                user_id = result['user_id'] if result else None

            elif shop_id:
                # Fetch user_id for a shop_id
                sql = '''SELECT u.user_id 
                         FROM shop s
                         JOIN users u ON s.user_id = u.user_id
                         WHERE s.shop_id = %s'''
                cursor.execute(sql, (shop_id,))
                result = cursor.fetchone()
                user_id = result['user_id'] if result else None

            else:
                return jsonify({"error": "Please provide either a service_id or a shop_id"}), 400

            # Update the user_called count for the user if user_id was found
            if user_id and str(user_id) != str(call_user_id):
                update_view_sql = '''UPDATE users SET user_called = user_called + 1 WHERE user_id = %s '''
                cursor.execute(update_view_sql, (user_id,))
                
                insert_call_sql = '''
                INSERT INTO call_list (call_user_id, call_time, user_id)                    
                VALUES (%s, %s, %s)'''
                cursor.execute(insert_call_sql, (call_user_id, call_time, user_id))
                
                connection.commit()

                return jsonify({"message": "user_called updated successfully", "user_id": user_id}), 200
            else:
                return jsonify({"error": "User not found for the provided service_id or shop_id"}), 404

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()


@app.route('/get_call_list', methods=["GET"])
def get_call_list():
    user_id = request.args.get('user_id', None)
    connection = None
    try:
        if not user_id:
            return jsonify({"error": "Please provide a user_id"}), 400

        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Query to retrieve incoming calls for the specified user_id
            sql_incoming = '''
            SELECT c.call_id, c.call_time, c.call_user_id, c.user_id,
                u.name AS call_user_name, u.photo AS call_user_photo
            FROM call_list c
            JOIN users u ON c.call_user_id = u.user_id
            WHERE c.user_id = %s
            ORDER BY c.call_time DESC'''
            cursor.execute(sql_incoming, (user_id,))
            incoming_calls = cursor.fetchall()
            

            # Process each incoming call to determine if it's a service or shop
            for call in incoming_calls:
                call['direction'] = 'incoming'
                call_user_id = call['call_user_id']
                cursor.execute('SELECT service_id FROM service WHERE user_id = %s', (call_user_id,))
                service_data = cursor.fetchone()

                if service_data:
                    call['is_service'] = True
                    call['service_id'] = service_data['service_id']
                else:
                    cursor.execute('SELECT shop_id FROM shop WHERE user_id = %s', (call_user_id,))
                    shop_data = cursor.fetchone()
                    call['is_service'] = False if shop_data else None
                    call['shop_id'] = shop_data['shop_id'] if shop_data else None

            # Query to retrieve outgoing calls where user_id is the caller
            sql_outgoing = '''
            SELECT c.call_id, c.call_time, c.user_id AS call_user_id, c.call_user_id AS receiver_id,
                u.name AS receiver_name, u.photo AS receiver_photo
            FROM call_list c
            JOIN users u ON c.user_id = u.user_id
            WHERE c.call_user_id = %s
            ORDER BY c.call_time DESC'''
            cursor.execute(sql_outgoing, (user_id,))
            outgoing_calls = cursor.fetchall()

            # Process each outgoing call to determine if the receiver is a service or shop
            for call in outgoing_calls:
                call['direction'] = 'outgoing'
                receiver_id = call['receiver_id']
                call_user_id = call['call_user_id']
                cursor.execute('SELECT service_id FROM service WHERE user_id = %s', (call_user_id,))
                service_data = cursor.fetchone()

                if service_data:
                    call['is_service'] = True
                    call['service_id'] = service_data['service_id']
                else:
                    cursor.execute('SELECT shop_id FROM shop WHERE user_id = %s', (call_user_id,))
                    shop_data = cursor.fetchone()
                    call['is_service'] = False if shop_data else None
                    call['shop_id'] = shop_data['shop_id'] if shop_data else None

        # Return both incoming and outgoing calls
        return jsonify({"incoming_calls": incoming_calls, "outgoing_calls": outgoing_calls}), 200


    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()


@app.route('/update_cat_data', methods=["GET","POST"])
def update_cat_data():
    service_id = request.args.get('service_id', None)
    shop_id = request.args.get('shop_id', None)
    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            if service_id:
                # Fetch data for a service_id
                sql = "SELECT * FROM service WHERE service_id = %s"
                cursor.execute(sql, (service_id,))
                data = cursor.fetchall()
                data_key = "service_data"
            elif shop_id:
                # Fetch data for a shop_id
                sql = "SELECT * FROM shop WHERE shop_id = %s"
                cursor.execute(sql, (shop_id,))
                data = cursor.fetchall()
                data_key = "shop_data"
            else:
                # Return error if no ID is provided
                return jsonify({"error": "Please provide either a service_id or a shop_id"}), 400

            # Process data (e.g., encode binary data as base64)
            # for record in data:
            #     for key, value in record.items():
            #         if isinstance(value, bytes):
            #             record[key] = base64.b64encode(value).decode()

            return jsonify({data_key: data})

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()


@app.route('/get_most_viewed_post', methods=['GET'])
def get_viewed_data():
    category = request.args.get('cat_id', None)
    data_type = request.args.get('data_type', None)
    if request.method == 'GET':
        # Fetch user data from the users table
        connection = db_connector.connect()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        try:
            cursor.execute("SELECT cat_id,post_viewed,post_liked FROM post GROUP BY post_viewed")
            view_data = cursor.fetchall()
            
            sorted_view_data = []
            for view in view_data:
                sorted_view_data.append(view['post_viewed'])
            
            sorted_view_data.sort()
            
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            cursor.close()
            connection.close()
        return jsonify({"viewed_data":view_data})

@app.route('/get_most_liked_post', methods=['GET'])
def get_liked_data():
    category = request.args.get('cat_id', None)
    data_type = request.args.get('data_type', None)
    if request.method == 'GET':
        # Fetch user data from the users table
        connection = db_connector.connect()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        try:
            cursor.execute("SELECT cat_id,post_viewed,post_liked,post_time FROM post GROUP BY post_liked desc")
            view_data = cursor.fetchall()
            
            sorted_view_data = []
            for view in view_data:
                sorted_view_data.append(view['post_viewed'])
            
            sorted_view_data.sort(reverse='True')
            
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            cursor.close()
            connection.close()
        return jsonify({"viewed_data":view_data})

@app.route('/get_most_updated_post', methods=['GET'])
def get_updated_data():
    category = request.args.get('cat_id', None)
    data_type = request.args.get('data_type', None)
    if request.method == 'GET':
        # Fetch user data from the users table
        connection = db_connector.connect()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        try:
            cursor.execute("SELECT post_time,cat_id,post_viewed,post_liked,post_id FROM post GROUP BY post_id desc")
            view_data = cursor.fetchall()
            
            # sorted_view_data = []
            # total_data =[]
            # for view in view_data:
            #         sorted_view_data.append(view['post_time'])
            
            # sorted_view_data.sort(reverse=True)

            # for j in sorted_view_data:
            #     for k in view_data:
            #         if j == k['post_time']:
            #             total_data.append({'post_id':k['post_id'],'post_viewed':k['post_viewed'],'post_liked':k['post_liked'],'post_time':j,'cat_id':k['cat_id']})
           

                
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            cursor.close()
            connection.close()
        return jsonify({"viewed_data":view_data})
    

@app.route('/get_total_post_on_users', methods=['GET','POST'])
def get_total_post_on_users():
    if request.method == 'GET' or request.method == 'POST':
        # Fetch unique categories and their counts from the users table
        connection = db_connector.connect()
        cursor = connection.cursor()
        
        try:
            cursor.execute('''SELECT p.user_id,COUNT(p.post_id) AS count FROM post p
                    JOIN users u ON u.user_id = p.user_id GROUP BY u.user_id''')
            
            post_counts = cursor.fetchall()
            seperated_post_counts = []
            for user_id,counts in post_counts:
                cursor = connection.cursor()
                sql = f"""UPDATE users set user_total_post = %s WHERE user_id = %s"""
                cursor.execute(sql, (counts,user_id))
                connection.commit()
                seperated_post_counts.append({'user_id':user_id,'post_counts':counts})

        
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
                cursor.close()
                connection.close()
        return jsonify({'post_counts':seperated_post_counts})



@app.route('/get_most_used_category', methods=['GET'])
def get_most_used_category():
    if request.method == 'GET':
        connection = db_connector.connect()
        cursor = connection.cursor()
        
        try:
            # Fetch category usage from users and join with cat_table to get category details
            cursor.execute("""
                SELECT * from cat
                GROUP BY cat_id
                ORDER BY cat_used DESC
            """)
            most_used_categories = cursor.fetchall()
            
            
            if most_used_categories:
                response = []
                for category in most_used_categories:
                    response.append({
                        'cat_id': category[0],
                        'cat_name': category[1],
                        'cat_logo': category[2],
                        'user_count': category[3],
                        'cat_used': category[4]
                    })
                return jsonify({"most_used_cat":response})
            else:
                return jsonify({"error": "No category usage data found"}), 404
        
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        
        finally:
            cursor.close()
            connection.close()

@app.route('/get_today_post', methods=['GET'])
def get_today_post():
    if request.method == 'GET':
        connection = db_connector.connect()
        cursor = connection.cursor()

        logged_in_user_id = session.get('user_id')
        
        try:
            # Fetch category usage from users and join with cat_table to get category details
            cursor.execute("""
                SELECT u.name,u.phone,c.cat_name,p.* 
                FROM post p 
                JOIN cat c ON c.cat_id = p.cat_id
                JOIN users u ON u.user_id = p.user_id
                GROUP BY p.post_id DESC
            """)
            update_post = cursor.fetchall()
            
            
            if update_post:
                response = []
                for category in update_post:
                    response.append({
                        'name': category[0],
                        'phone': category[1],
                        'category': category[2],
                        'post_id':category[3],
                        'description': category[6],
                        'photo':category[7],
                        'like':category[8],
                        'view':category[9],
                        'share':category[10],
                        'time':category[11],
                        'user_id': logged_in_user_id 

                    })
                return jsonify({"most_update_post":response})
            else:
                return jsonify({"error": "No category usage data found"}), 404
        
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        
        finally:
            cursor.close()
            connection.close()


#
@app.route('/get_fb_page', methods=['GET'])
def get_fb_page():
    if request.method == 'GET':
        connection = db_connector.connect()
        cursor = connection.cursor()
        
        try:
            # Fetch category usage from users and join with cat_table to get category details
            cursor.execute("""
                SELECT * FROM fb_page
            """)
            fb_page = cursor.fetchall()
            if fb_page:
                response = []
                for category in fb_page:
                    response.append({
                        'page_id': category[0],
                        'name': category[1],
                        'cat': category[2],
                        'phone':category[3],
                        'link': category[4],
                        'location':category[5],
                        'time':category[6]

                    })
                return jsonify({"fb_page":response})
            else:
                return jsonify({"error": "No  data found"}), 404
        
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        
        finally:
            cursor.close()
            connection.close()
                
@app.route('/submit_post', methods=['POST'])
def submit_post():
    phone = request.form.get('phone')
    post_description = request.form.get('post_description')
    post_media_files = request.files.getlist('post_media')  # Get multiple files

    if not phone or not post_description:
        return jsonify({"error": "Phone and post_description are required"}), 400

    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Fetch user_id and cat_id based on phone
            cursor.execute("SELECT user_id, cat_id FROM users WHERE phone = %s", (phone,))
            user_data = cursor.fetchone()
            if not user_data:
                return jsonify({"error": "User not found"}), 404
            
            user_id = user_data['user_id']
            cat_id = user_data['cat_id']

            # Handle multiple file uploads if media is provided
            media_urls = []
            if post_media_files:
                # Connect to the FTP server
                ftp = ftplib.FTP(FTP_HOST)
                ftp.login(FTP_USER, FTP_PASS)
                ftp.cwd(FTP_DIRECTORY)

                for media in post_media_files:
                    filename = f"{phone}_{media.filename}"
                    image_url = f"https://aarambd.com/upload/{filename}"

                    # Upload each file to the FTP server
                    with media.stream as file:
                        ftp.storbinary(f'STOR {filename}', file)

                    media_urls.append(image_url)

                ftp.quit()

            # Convert list of image URLs to a single string
            media_urls_str = ','.join(media_urls) if media_urls else ""

            # Insert post data into the post table
            cursor.execute(
                '''
                INSERT INTO post (cat_id, user_id, post_des, post_media, post_time)
                VALUES (%s, %s, %s, %s, NOW())
                ''',
                (cat_id, user_id, post_description, media_urls_str)
            )
            connection.commit()

            return jsonify({"message": "Post submitted successfully"}), 201

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()
            
            
            
import os

@app.route('/delete_post', methods=['DELETE'])
def delete_post():
    post_id = request.form.get('post_id')
    print('post_id', post_id)

    if not post_id:
        return jsonify({"error": "post_id is required"}), 400

    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Check if the post exists
            cursor.execute("SELECT post_media FROM post WHERE post_id = %s", (post_id,))
            post = cursor.fetchone()

            if not post:
                return jsonify({"error": "Post not found"}), 404

            # Handle post_media safely
            post_media = post.get('post_media')  # Use .get to avoid KeyError
            if post_media:  # Only proceed if media exists
                try:
                    ftp = ftplib.FTP(FTP_HOST)
                    ftp.login(FTP_USER, FTP_PASS)
                    ftp.cwd(FTP_DIRECTORY)

                    for media_url in post_media.split(','):
                        filename = os.path.basename(media_url)
                        try:
                            ftp.delete(filename)
                        except ftplib.error_perm as ftp_error:
                            print(f"FTP error while deleting {filename}: {ftp_error}")

                    ftp.quit()
                except Exception as ftp_exception:
                    print(f"FTP error: {ftp_exception}")
                    # Continue deleting the post even if FTP deletion fails

            # Delete the post from the database
            cursor.execute("DELETE FROM post WHERE post_id = %s", (post_id,))
            connection.commit()

            return jsonify({"message": "Post deleted successfully"}), 200

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()


# Route to update a post by post_id
@app.route('/update_post', methods=['PUT'])
def update_post():
    phone = request.form.get('phone')
    post_id = request.form.get('post_id')
    new_post_description = request.form.get('post_description')
    new_post_media_files = request.files.getlist('post_media')

    if not phone or not post_id:
        return jsonify({"error": "Phone and post_id are required"}), 400

    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Fetch user_id based on phone
            cursor.execute("SELECT user_id FROM users WHERE phone = %s", (phone,))
            user_data = cursor.fetchone()
            if not user_data:
                return jsonify({"error": "User not found"}), 404

            user_id = user_data['user_id']

            # Check if the post exists and belongs to the user
            cursor.execute("SELECT post_media FROM post WHERE post_id = %s AND user_id = %s", (post_id, user_id))
            post = cursor.fetchone()
            if not post:
                return jsonify({"error": "Post not found or unauthorized access"}), 404

            # Initialize media_urls_str with the existing media URLs
            media_urls_str = post['post_media']

            # Update media files if new ones are provided
            if new_post_media_files:
                # Delete old media files from FTP server
                if post['post_media']:
                    ftp = ftplib.FTP(FTP_HOST)
                    ftp.login(FTP_USER, FTP_PASS)
                    ftp.cwd(FTP_DIRECTORY)

                    for media_url in post['post_media'].split(','):
                        filename = os.path.basename(media_url)
                        ftp.delete(filename)

                # Upload new media files to FTP server
                media_urls = []
                for media in new_post_media_files:
                    filename = f"{phone}_{media.filename}"
                    image_url = f"https://aarambd.com/upload/{filename}"

                    with media.stream as file:
                        ftp.storbinary(f'STOR {filename}', file)

                    media_urls.append(image_url)

                ftp.quit()

                # Convert list of new media URLs to a single string
                media_urls_str = ','.join(media_urls)

            # Prepare the update query
            update_query = '''
                UPDATE post
                SET post_des = COALESCE(%s, post_des),
                    post_media = %s
                WHERE post_id = %s AND user_id = %s
            '''
            cursor.execute(update_query, (new_post_description, media_urls_str, post_id, user_id))
            connection.commit()

            return jsonify({"message": "Post updated successfully"}), 200

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()
1

@app.route('/submit_comment', methods=['POST'])
def submit_comment():
    data = request.json  # This should now accept JSON
    com_user_id = data.get('com_user_id')
    post_id = data.get('post_id')
    com_text = data.get('com_text')

    if  not post_id or not com_text:
        return jsonify({"error": "com_user_id, post_id, and com_text are required"}), 400

    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Insert comment data into the comment table
            cursor.execute(
                '''
                INSERT INTO comment (com_text, com_time, com_user_id, post_id, com_like, com_dislike)
                VALUES (%s, NOW(), %s, %s, 0, 0)
                ''',
                (com_text, com_user_id, post_id)
            )
            connection.commit()

            return jsonify({"message": "Comment submitted successfully"}), 201

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()




@app.route('/get_comments', methods=['GET'])
def get_comments():
    post_id = request.args.get('post_id')

    if not post_id:
        return jsonify({"error": "post_id is required"}), 400

    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Retrieve all comments for the specific post_id
            cursor.execute(
                '''
                SELECT c.com_id, c.com_text, c.com_like, c.com_dislike, c.com_time, u.photo,u.cat_id,u.name AS commenter_name,
                d.cat_name, d.cat_logo AS cat_photo
                FROM comment c
                JOIN users u ON c.com_user_id = u.user_id
                JOIN cat d ON u.cat_id = d.cat_id
                WHERE c.post_id = %s
                ORDER BY c.com_time DESC
                ''',
                (post_id,)
            )
            comments = cursor.fetchall()
            
            for comment in comments:
                # Handle missing user photo: assign category photo if user's photo is empty
                HTTP_BASE_URL = "http://aarambd.com/cat logo/" 
                cat_photo = "http://aarambd.com/cat logo/" + f"{comment['cat_photo']}"
                comment['cat_photo'] = cat_photo
                user_photo = comment['photo']
                if not user_photo:
                    comment['photo'] = cat_photo
                else:
                    # If the user has multiple photos, get only the first one
                    comment['photo'] = user_photo.split(',')[0]

            return jsonify({"comments": comments}), 200

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()


@app.route('/get_post', methods=['GET'])
def get_post():
    post_id = request.args.get('post_id')

    if not post_id:
        return jsonify({"error": "post_id is required"}), 400

    connection = None
    try:
        connection = db_connector.connect()
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Retrieve post data with user and category information
            cursor.execute(
                '''
                SELECT p.post_id, p.post_des, p.post_media, p.post_liked, p.post_viewed, 
                       p.post_shared, p.post_time, u.name AS user_name, u.photo AS user_photo,
                       c.cat_name, c.cat_logo AS cat_photo
                FROM post p
                JOIN users u ON p.user_id = u.user_id
                JOIN cat c ON p.cat_id = c.cat_id
                WHERE p.post_id = %s
                ''',
                (post_id,)
            )
            post_data = cursor.fetchone()

            if not post_data:
                return jsonify({"error": "Post not found"}), 404

            # Handle missing user photo: assign category photo if user's photo is empty
            HTTP_BASE_URL = "http://aarambd.com/cat logo/" 
            cat_photo = "http://aarambd.com/cat logo/" + f"{post_data['cat_photo']}"
            post_data['cat_photo'] = cat_photo
            user_photo = post_data['user_photo']
            if not user_photo:
                user_photo = cat_photo
            else:
                # If the user has multiple photos, get only the first one
                user_photo = user_photo.split(',')[0]

            # Update the photo in the response
            post_data['user_photo'] = user_photo

            return jsonify({"post": post_data}), 200

    except pymysql.MySQLError as e:
        print(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        print(f"General error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if connection:
            connection.close()


@app.route('/get_terms_policy', methods=['GET'])
def get_terms_policy():
    connection = db_connector.connect()
    if connection is None:
        return jsonify({"success": False, "message": "Failed to connect to the database"}), 500

    cursor = connection.cursor(pymysql.cursors.DictCursor)
    try:
        # Fetch description for term_id = 1
        cursor.execute("SELECT des FROM term_policy WHERE term_id = 1")
        term = cursor.fetchone()

        if not term:
            return jsonify({"success": False, "message": "Terms and policies not found"}), 404

        return jsonify({"success": True, "terms_policy": term['des']})

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({"success": False, "message": str(e)}), 500
    finally:
        cursor.close()
        connection.close()
            

if __name__ == '__main__':
    app.run(host= '0.0.0.0',port=5000,debug=True)