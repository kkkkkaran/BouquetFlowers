// Copyright 2017 Google LLC

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     https://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

'use strict';

const functions = require('firebase-functions');
const gcs = require('@google-cloud/storage');
const admin = require('firebase-admin');
const exec = require('child_process').exec;
const path = require('path');
const fs = require('fs');
const google = require('googleapis');
const sizeOf = require('image-size');

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

function classLabel(classId){
    if (classId == 1)
        return 'Rose'
    else if(classId == 2)
        return 'Carnation'
    else if(classId == 3)
        return 'Daffodil'
    else if(classId == 4)
        return 'Sunflower'
    else if(classId == 5)
        return 'Tulip'
    else if(classId == 6)
        return 'Orchid'
    else if(classId == 7)    
        return 'Lavender'
    else if(classId == 8)    
        return 'Lily'
    else if(classId == 9)    
        return 'Iris'    
    else
        return 'NA'
}
  
function cmlePredict(b64img) {
    return new Promise((resolve, reject) => {
        google.auth.getApplicationDefault(function (err, authClient) {
            if (err) {
                reject(err);
            }
            if (authClient.createScopedRequired && authClient.createScopedRequired()) {
                authClient = authClient.createScoped([
                    'https://www.googleapis.com/auth/cloud-platform'
                ]);
            }

            var ml = google.ml({
                version: 'v1'
            });

            const params = {
                auth: authClient,
                name: 'projects/bouquetdetectionproject/models/bouquetDetection',  
                resource: {
                    instances: [
                    {
                        "inputs": {
                        "b64": b64img
                        }
                    }
                    ]
                }
            };

            ml.projects.predict(params, (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(result);
                }
            });
        });
    });
}

function resizeImg(filepath) {
    return new Promise((resolve, reject) => {
        exec(`convert ${filepath} -resize 600x ${filepath}`, (err) => {
          if (err) {
            console.error('Failed to resize image', err);
            reject(err);
          } else {
            console.log('resized image successfully');
            resolve(filepath);
          }
        });
      });
}

exports.runPrediction1 = functions.storage.object().onFinalize((object, context) => {

    fs.rmdir('./tmp/', (err) => {
        if (err) {
            console.log('error deleting tmp/ dir');
        }
    });

//     const object = event.data;
    const fileBucket = object.bucket;
    const filePath = object.name;
    const bucket = gcs().bucket(fileBucket);
    const fileName = path.basename(filePath);
    const file = bucket.file(filePath);

    if (filePath.startsWith('images/')) {  
        const destination = '/tmp/' + fileName;
        console.log('got a new image', filePath);
        return file.download({
            destination: destination
        }).then(() => {
            if(sizeOf(destination).width > 600) {
                console.log('scaling image down...');
                return resizeImg(destination);
            } else {
                return destination;
            }
        }).then(() => {
            console.log('base64 encoding image...');
            let bitmap = fs.readFileSync(destination);
            return new Buffer(bitmap).toString('base64');
        }).then((b64string) => {
            console.log('sending image to CMLE...');
            return cmlePredict(b64string);
        }).then((result) => {
            var aout;
            let boxes = result.predictions[0].detection_boxes;
            let scores0 = result.predictions[0].detection_scores;
            let labels = result.predictions[0].detection_classes;
            console.log(result)
            console.log('got prediction with confidence: ',scores0[0]);
            // Only output predictions with confidence > 50%
            var i;
          	var countAnno=0;
          	console.log('scores length:',scores0.length);
          	var flag=true;
            for(i=0;i<scores0.length;i++){
            
            if (scores0[i] >= 0.50) {
              	countAnno = countAnno + 1;
              	console.log("score is greater");
                let dimensions = sizeOf(destination);
                let box = boxes[i];
                let x0 = box[1] * dimensions.width;
                let y0 = box[0] * dimensions.height;
                let x1 = box[3] * dimensions.width;
                let y1 = box[2] * dimensions.height;    
    			let classL = labels[i];
              	let flowerLabel = classLabel(classL);
                // Draw a box on the image around the predicted bounding box
                 aout = new Promise((resolve, reject) => {
                    console.log(destination);
                    exec(`convert ${destination} -stroke "#39ff14" -strokewidth 5 -fill none -draw "rectangle ${x0},${y0},${x1},${y1} "\ -stroke white -strokewidth 2 -draw "text ${x0+10},${y0+10} '${countAnno}'" ${destination}`, (err) => {
                      if (err) {
                        console.error('Failed to draw rect.', err);
                        flag=false;
                        reject(err);
                      } else {
                        console.log('drew the rect at',x0,y0,x1,y1," for ",box, "class = ",classL," class name = ", flowerLabel );
                   
                        resolve(result.predictions[0]);
                      }
                    });
                  });
            } else {
              	flag=false;
                aout = result.predictions[0];
            }}
          	if(flag==true){
              bucket.upload(destination, {destination: 'test2.jpg'})
            }
          	return aout;
        })
        .then((results) => {
            let scores = results.detection_scores;
            let labels = results.detection_classes;
            let outlinedImgPath = '';
            let imageRef = db.collection('predicted_images').doc(filePath.slice(7));
          	var uploadFlag = false;
          	var j;
          	var confidenceString = ""
            var labelString = ""
          	for(j=0;j<scores.length;j++){
              if (scores[j] >= 0.50){
                let flowerName = classLabel(labels[j]); 
                uploadFlag = true
                confidenceString = confidenceString+","+scores[j].toString();
                labelString = labelString+","+flowerName
              }
            
            }
          
          	
          	
          	
            if (uploadFlag == true) {
                outlinedImgPath = `outlined_img1/${filePath.slice(7)}`;
                imageRef.set({
                    image_path: outlinedImgPath,
                    confidence: confidenceString,
                    label_name: labelString //reurne info in imagedata
                });
                return bucket.upload(destination, {destination: outlinedImgPath});
            } else {
                imageRef.set({
                    image_path: outlinedImgPath,
                    confidence: scores[0],
                    label_name: labels[0]
                });
                console.log('No flower found');
                return confidence;
            }
        })
        .catch(err => {
            console.log('Error occurred: ',err);
        });
    } else {
        return 'not a new image';
    }
});