
# -*- coding: utf-8 -*-

from time import sleep
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Your Facebook account user and password
print "enter page email address"
usr = raw_input()
print "enter page password: "
pwd = raw_input()
message = "test_post_2"
attach_image = True
image_path = "/home/tom/test.png"
group_links = [
# Your Facebook Groups links.
# IMPORTANT: You must be a member of the group, being ADMIN nor required.
"https://www.facebook.com/groups/872035709926787/", # A group of Mark Zuckerberg
]

chrome_options = webdriver.ChromeOptions()
chrome_options.add_experimental_option("detach", True)
chrome_options.add_argument("--disable-infobars")
chrome_options.add_experimental_option("prefs", { \
"profile.default_content_setting_values.notifications": 2 # 1:allow, 2:block 
})

driver = webdriver.Chrome(options=chrome_options)
driver.implicitly_wait(15) # seconds

# Go to facebook.com
driver.get("http://www.facebook.com")

# Enter user email
elem = driver.find_element_by_id("email")
elem.send_keys(usr)
# Enter user password
elem = driver.find_element_by_id("pass")
elem.send_keys(pwd)
# Login
elem.send_keys(Keys.RETURN)
group = group_links[0]
#for group in group_links:
sleep(2)

# Go to the Facebook Group
driver.get(group)
sleep(2)

# Click the post box
post_box=driver.find_element_by_xpath("//*[@name='xhpc_message_text']")
#sleep(2)
# Enter the text we want to post to Facebook
post_box.send_keys(message)


# Click on the add media button
addMediaButton = driver.find_elements_by_xpath("//*[contains(text(), 'Photo/Video')]")[0]
addMediaButton.click()
sleep(5)

# Click the 'Upload Photo/Video' button
uploadPhotoButton = driver.find_element_by_name("composer_photo")

uploadPhotoButton.send_keys(image_path)

# Wait for the image to upload
sleep(5)


buttons = driver.find_elements_by_xpath("//button")
for button in buttons:
	if "Post" == button.text:
		post_button = button

post_button.click()
sleep(5)

driver.close()

if __name__ == '__main__':
	main()
