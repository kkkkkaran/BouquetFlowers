//
//  ViewController.swift
//  BouquetDetection
//
//  Created by MinXue on 24/4/19.
//  Completed by Karan Katnani. Current Version 4/6/19.
//  Copyright © 2019 Karan Katnani. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate  {

    var storage: Storage!
    var firestore: Firestore!
    var modelChoice:String?
    var pickedImgInfo:[UIImagePickerController.InfoKey: Any]?
    let cameraPicker = UIImagePickerController()
    
    @IBOutlet weak var modelSelect: UIButton!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var ResultList: UILabel!
    @IBOutlet weak var flowerListView: UITextView!
    
    //Function called as soon as view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Reachability.isConnectedToNetwork(){
            let alert=UIAlertController.init(title: "Alert", message: "No Internet Connection Detected! The App may not work as intended", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        self.modelSelect.isEnabled = false
        self.flowerListView.isEditable = false
        self.flowerListView.text=("How to Use: \n 1. Select or Click an Image \n 2. Select a Model")
        storage = Storage.storage()
        firestore = Firestore.firestore()
        cameraPicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
    }
    
    //inherited from parent function to free memory resources. NEEDS TO BE DEVELOPED
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function to click photo from within the app
    @IBAction func TakePhoto(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        present(cameraPicker, animated: true)
    }
    
    //function to open user photo library, allowing user to select picture
    @IBAction func PhotoLibrary(_ sender: Any) {
        cameraPicker.sourceType = .photoLibrary
        present(cameraPicker, animated: true)
    }

    //function to dismiss photo library, if users cancels action
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //function to take action after user selects an image for detection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            ImageView.image = userPickedImage
            self.modelSelect.isEnabled = true
            self.flowerListView.text=("How to Use: \n 2. Select a Model")
            if self.cameraPicker.sourceType == .camera{
                UIImageWriteToSavedPhotosAlbum(userPickedImage, self, #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            
            pickedImgInfo = info
        
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    //function to save image clicked within the app, to photo gallery
    @objc func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Please re-select the image from photo library to start detection.", preferredStyle: .alert)
            self.flowerListView.text=("How to Use: \n 1. Please re-select the image from photo library  \n 2. Select a Model")
            self.modelSelect.isEnabled = false
            
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    //function to provide options of models to user
    @IBAction func ModelSearch(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "SSD Depth Quantized", style: .default , handler:{ (UIAlertAction)in
            self.modelChoice = "model1"
            self.upload(remoteDatabase: "predicted_images")
            print("User chooses SSD model")
            self.flowerListView.text=("Uploading!")
        }))
        
        alert.addAction(UIAlertAction(title: "SSD FPN MobileNet", style: .default , handler:{ (UIAlertAction)in
            self.modelChoice = "model2"
            self.upload(remoteDatabase: "predicted_images2")
            print("User chooses YOLO model")
            self.flowerListView.text=("Uploading!")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        present(alert,animated: true)
    }
    
    
    //function to upload image to firebase, and add an async listener for results
    func upload(remoteDatabase: String){
        let imageURL = pickedImgInfo?[UIImagePickerController.InfoKey.imageURL] as! URL
        let imageName = imageURL.lastPathComponent
        let storageRef = storage.reference().child("images").child(imageName)
        guard let image = pickedImgInfo?[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        storageRef.putFile(from: imageURL, metadata: nil) { metadata, error in
            if let error = error {
                self.flowerListView.text=("Uploaded Failed! \n Please try again.")
                print(error)
            }
            else {
                print("upload success!")
                self.flowerListView.text=("Uploaded successfully \n Waiting for results")
                self.firestore.collection(remoteDatabase).document(imageName)
                    .addSnapshotListener { documentSnapshot, error in
                        if let error = error {
                            print("error occurred\(error)")
                        } else {
                            print("maybe im okay?")
                            if (documentSnapshot?.exists)! {
                                let imageData = (documentSnapshot?.data())
                                self.visualizePrediction(imgData: imageData)
                            } else {
                                print("waiting for prediction data...")
                            }
                        }
                }
            }
        }
    }
    
    //function to display detection results
    func visualizePrediction(imgData: [String: Any]?) {
        print(imgData!)
        if (imgData!["image_path"] as! String).isEmpty {
            self.flowerListView.text="No Flower Found"
        }
        else{
            let confidence = (imgData!["confidence"] as! String).components(separatedBy:",")
            let label_id = (imgData!["label_name"] as! String).components(separatedBy:",")
            print(confidence)
            print(label_id)
            var output = ""
            var i=0
            for data in confidence{
                if i==0{
                    i=1
                    continue
                }
                output +=  String(i) + ":" + " " + label_id[i] + " " + data + "\n"
                i+=1
            }
            print(output)
            self.flowerListView.text=output
            let predictedImgRef = storage.reference(withPath: imgData!["image_path"] as! String)
            predictedImgRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                }
                else {
                    let image = UIImage(data: data!)
                    self.ImageView.image = image
                }
            }
        
        }
    }

}
