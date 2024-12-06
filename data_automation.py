import pandas as pd
import os
import mysql.connector

# Load data from Excel file

# excel_path = open("O:/Test_Flutter/aarambd/Assorted.xlsx","r")
# path = os.path.dirname(excel_path)
df = pd.read_excel('Assorted .xlsx', sheet_name='Service')
print(df.columns)


# MySQL database connection
mydb = mysql.connector.connect(
    host='localhost',
    user="root",
    password="",
    database="registration"
)

cursor = mydb.cursor()

# SQL query to insert data
sql = """
INSERT INTO service (category, business_name, address, phone, photo) 
VALUES (%s, %s, %s, %s, %s)
"""

# Loop through the data and insert into the database
for index, row in df.iterrows():
    try:
        # Prepare data, checking for NaN and replacing with defaults or skipping
        if pd.isna(row['category']) or pd.isna(row['business Name']) or pd.isna(row['phone ']):
            print(f"Skipping row {index} due to missing essential data.")
            continue  # Skip rows with missing essential data
         # Clean and convert phone number to integer
        phone = int(''.join(filter(str.isdigit, str(row['phone ']))))
         # Resolve full path to image file
        photo_path = row['photo files']
        if pd.notna(photo_path):
            photo_path = os.path.abspath(photo_path)  # Convert to absolute path if needed

        # Ensuring no missing essential data
        data_tuple = (
            row['category'],
            row['business Name'].strip() if pd.notna(row['business Name']) else "Unknown",
            row['address'].strip() if pd.notna(row['address']) else "No Address",
            phone,
            row['photo files'] if pd.notna(row['photo files']) else "No Photo"
        )

        # Check data_tuple to ensure it has exactly 5 elements
        if len(data_tuple) != 5:
            print(f"Data tuple for row {index} does not match SQL placeholders: {data_tuple}")
            continue

        cursor.execute(sql, data_tuple)
        mydb.commit()  # Commit each insert to ensure data integrity

    except KeyError as e:
        print(f"Error with column names: {e}")
    except mysql.connector.Error as e:
        print("Error inserting data:", e)
        mydb.rollback()  # Rollback the transaction on error

cursor.close()
mydb.close()

print("Data successfully inserted into the database.")

