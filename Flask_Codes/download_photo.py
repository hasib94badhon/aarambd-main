import requests
from bs4 import BeautifulSoup
import os

import mysql.connector
import os

def convert_to_binary(filename):
    """Read an image file and convert it to binary data."""
    with open(filename, 'rb') as file:
        binary_data = file.read()
    return binary_data



# Database connection parameters
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'registration'
}

# Connect to the database
db = mysql.connector.connect(**db_config)
cursor = db.cursor()

# Directory where images are stored
image_directory = 'downloaded_images'
image_files = os.listdir(image_directory)

for image_file in image_files:
    # Assuming file names are service_ids or you have some mapping logic
    service_id = int(image_file.split('.')[0])  # Extract ID from filename, adjust as necessary
    image_path = os.path.join(image_directory, image_file)
    binary_data = convert_to_binary(image_path)

    # SQL query to update the photo in the service table
    query = "UPDATE service SET photo = %s WHERE service_id = %s"
    cursor.execute(query, (binary_data, service_id))

# Commit changes and close the connection
db.commit()
cursor.close()
db.close()

print("Images have been successfully uploaded to the database.")





# def download_images_from_anchor(url, folder_name, anchor_text):
#     # Create a directory to save images
#     if not os.path.exists(folder_name):
#         os.makedirs(folder_name)
    
#     # Get the HTML content from the URL
#     response = requests.get(url)
#     soup = BeautifulSoup(response.text, 'html.parser')
    
#     # Find the anchor tag by its text
#     anchor = soup.find('a', string=anchor_text)
#     if anchor and anchor.has_attr('href'):
#         section_id = anchor['href'].strip('#')
#         section = soup.find(id=section_id)
#         if section is None:
#             print(f"No section found with id {section_id}")
#             return
        
#         # Find all image tags within the section
#         images = section.find_all('img')
#         for i, image in enumerate(images):
#             img_url = image['src']
#             img_data = requests.get(img_url).content
            
#             # Write the image data to a file
#             with open(f'{folder_name}/image_{i+1}.jpg', 'wb') as handler:
#                 handler.write(img_data)
            
#             print(f"Downloaded image {i+1} from section {section_id}")
#     else:
#         print("Anchor text not found or has no href attribute")

# # Replace 'your_published_link' with your actual URL
# url = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSPVUlUKCqFTqZG7VpNfXTDfAsjIkiL5PYCGBjbL4K90AFt-8iL-CqMtMZjVh16deGUXEN-DoUTx1xQ/pubhtml#'
# anchor_text = 'Service'  # Replace with the actual text of the anchor
# download_images_from_anchor(url, 'downloaded_images', anchor_text)
