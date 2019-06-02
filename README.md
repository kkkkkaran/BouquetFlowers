# BouquetFlowers
Link to Saved Models for serving: https://drive.google.com/open?id=1knRnEFaTUX5Z1PGNKa0jRUF5ZS2pn80_
Link to Train and Test Datasets: https://drive.google.com/open?id=1dFKk7zcU6tDnoNp1OTVdfI8et11-irzs

GCP: Google Cloud Platform

TensorFlow YOLO:
- The system was deployed on a GCP Instance with 4vCPUs 16GB Memory and an Nvidia Tesla P4 GPU. Implementation guide is contained within the folder. 

Mobile App:
 - Selected Saved Models have been uploaded to GCP Storage Buckets, which are then deployed as models on Google ML Engine/AI    Platform Models. 
 - Firebase functions (/Mobile\ App/Cloud\ Functions) have been written in NodeJS to fetch images uploaded by the app, wrap the request and pass it to the Google CMLE (Cloud Machine Learning Engine). The results are fetched, based on which the bounding boxes and labels are drawn and then sent back to the Mobile App.
 - A native iOS App written in Swift, which uses Firebase iOS Libraries for API Calls. 
