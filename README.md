# Flower Detection and Classification using Machine Learning: Mobile App


Source for University of Melbourne COMP90019/COMP90055 projects

Karan Katnani (kkkkkaran) - kkatnani@student.unimelb.edu.au - 920130 

Andi Hartarto Wardana Samijono (andi23) - asamijono@student.unimelb.edu.au - 979056  

Min Xue - mxue2@student.unimelb.edu.au (mxue2) - mxue2@student.unimelb.edu.au - 897082





Link to Saved Models for serving: https://drive.google.com/open?id=1knRnEFaTUX5Z1PGNKa0jRUF5ZS2pn80_
Link to Train and Test Datasets: https://drive.google.com/open?id=1dFKk7zcU6tDnoNp1OTVdfI8et11-irzs

GCP: Google Cloud Platform

TensorFlow YOLO:
- The model was trained and tested on a GCP Instance with 4vCPUs 16GB Memory and an Nvidia Tesla P4 GPU. Implementation guide is contained within the folder. 

GCP TPU Training for Object Detection
- Instructions on training pre-trained models for transfer learning using Google's TPU and solutions to road blocks due to Tensorflow changes.
- Added jupyter notebook which includes further configuration such as confidence values, objects returned and fixed bugs in the code.

Mobile App:
 - Selected Saved Models have been uploaded to GCP Storage Buckets, which are then deployed as models on Google ML Engine/AI    Platform Models. 
 - Firebase functions (/Mobile\ App/Cloud\ Functions) have been written in NodeJS to fetch images uploaded by the app, wrap the request and pass it to the Google CMLE (Cloud Machine Learning Engine). The results are fetched, based on which the bounding boxes and labels are drawn and then sent back to the Mobile App.
 - A native iOS App written in Swift, which uses Firebase iOS Libraries for API Calls. 

