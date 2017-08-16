//
//  PostInfoVC.swift
//  Dev Social
//
//  Created by Brett Mayer on 8/12/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import Firebase

class PostInfoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    
    var post: Post!
    var imagePicker: UIImagePickerController!
    
    var imageUrlToRemove: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        captionField.text = post.caption
        
        getImageFromFirebase()

    }
    
    
    func getImageFromFirebase() {
        
        let imageUrl = self.post.imageUrl
        imageUrlToRemove = imageUrl
        if let img = FeedVC.imageCache.object(forKey: imageUrl as NSString) {
            addImage.image = img
            print("Image retrieved from cache")
        } else {
            let ref = Storage.storage().reference(forURL: imageUrl)
            ref.getData(maxSize: 1024 * 1024 * 2) { (data, error) in
            if error != nil {
                print("Unable to download image from firebase storage")
            } else {
                print("Image downloaded from firebase storage")
                if let imageData = data {
                    if let img = UIImage(data: imageData) {
                        self.addImage.image = img
                        FeedVC.imageCache.setObject(img, forKey: imageUrl as NSString)
                    }
            }
          }
        }
    }
}
    
    @IBAction func imageTapped(_ sender: Any) {
        print("image tapped")
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        guard let caption = captionField.text, caption != "" else {
            print("caption must not be empty")
            return
        }
        
        guard let img = addImage.image else {
            print("An image must be selected")
            return
        }
        
        //remove original image!
        let ref = Storage.storage().reference(forURL: imageUrlToRemove!)
        ref.delete() { (error) in
            if error != nil {
                print("Could not remove image from storage")
            } else {
                print("Removed image \(self.imageUrlToRemove!) from storage")
                FeedVC.imageCache.removeObject(forKey: self.imageUrlToRemove! as NSString)
                
            }
        }

        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Unable to upload image to firebase storage")
                } else {
                    print("Successfully uploaded image to firebase storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    
                    let userData: Dictionary<String, Any> = ["caption": caption, "imageUrl": downloadUrl as Any]
                    print("post key about to be deleted: \(self.post.postKey)")
                    DataService.ds.REF_POSTS.child(self.post.postKey).updateChildValues(userData)
                    print("Successfully edited post")
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
            }

            
        }

        
}





