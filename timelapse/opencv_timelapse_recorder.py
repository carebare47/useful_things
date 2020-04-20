#!/bin/python
import cv2
import time
import numpy as np
import glob


## Settings ###############################
camera_id = 0
print_time_hours = 5
print_time_minutes = 30
desired_length_seconds = 60
desired_fps = 25
###########################################


print_time_seconds = ((print_time_hours * 60) + print_time_minutes) * 60
desired_frames = desired_fps * desired_length_seconds
seconds_per_frame = print_time_seconds / desired_frames
print "desired_frames: ", desired_frames
print "seconds_per_frame: ", seconds_per_frame
print "storage_size: ", (desired_frames * 0.4), "MB", " @ 400kB each"

cap = cv2.VideoCapture(camera_id) 

# clear buffer
for i in range(20):
    ret, img = cap.read()

# window_name = 'preview'

for i in range(desired_frames):
    ret, img = cap.read()
    #cv2.imshow(window_name, img)
    cv2.imwrite('./img_'+str(i).zfill(4)+'.png', img)
    print "recording frame ", i, " out of ", desired_frames, ". ", (seconds_per_frame * i ), "s out of ", (desired_frames * seconds_per_frame), "."
    time.sleep(seconds_per_frame)

cap.release()


img_array = []
image_filenames = sorted(glob.glob('/home/tom/useful_things/timelapse/*png'))
for filename in image_filenames:
    frame = cv2.imread(filename)
    height, width, layers = frame.shape
    size = (width, height)
    img_array.append(frame)

print "processing frames..."
out = cv2.VideoWriter('output.avi',cv2.VideoWriter_fourcc(*'DIVX'), desired_fps, size)
for i in range(len(img_array)):
    out.write(img_array[i])

out.release()

