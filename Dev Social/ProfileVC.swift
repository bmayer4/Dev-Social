//
//  ProfileVC.swift
//  Dev Social
//
//  Created by Brett Mayer on 8/11/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

//when this loads users profile image needs to pop up for editing purposes
class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var imageAdd: CircleView!
    
    var imagePicker: UIImagePickerController!
    var imageUrlToRemove: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        
        getProfileImage()
        getUsername()
    }
    
    @IBAction func submitProfile(_ sender: Any) {
        
        guard let username = usernameField.text, username != "" else {
            print("Enter username")
            return
        }
        
        guard let img = imageAdd.image else {
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
            
            DataService.ds.REF_PROFILE_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Unable to upload image to firebase storage")
                } else {
                    print("Successfully uploaded image to firebase storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString

                    let userData: Dictionary<String, Any> = ["username": username, "imageUrl": downloadUrl as Any]
                    DataService.ds.REF_USER_CURRENT.updateChildValues(userData)
                    print("Successfully created username and set profile image :)")

                    }
            }
            
        }
        
        if presentingViewController is SignInVC {
            performSegue(withIdentifier: "goToFeed", sender: nil)
            print("going into feed for first time")
        }
        else {
            print("going into feed from feed via dismiss")
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    
   
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageAdd.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        print(self.presentingViewController!)
        if self.presentingViewController is FeedVC {
            print("back to feed")
             dismiss(animated: true, completion: nil)
        }
         else if self.presentingViewController is SignInVC {
            print("presenting view controller is SignInVC")
            let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            print("Id removed from keychain: \(keychainResult)")
            
            do {
                try Auth.auth().signOut()
            } catch let err as NSError {
                print("Error signing out: \(err)")
            }
            
            performSegue(withIdentifier: "goToSignIn", sender: nil)
        }
    }
    
    func getProfileImage() {

        DataService.ds.REF_USER_CURRENT.child("imageUrl").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            if let _ = snapshot.value as? NSNull {
                print("no imageUrl")
            } else {
                let imageUrl = snapshot.value as! String
                self.imageUrlToRemove = imageUrl
                    if let img = FeedVC.imageCache.object(forKey: imageUrl as NSString) {
                    self.imageAdd.image = img
                    print("got image from cache!")
                } else {
                    let ref = Storage.storage().reference(forURL: imageUrl)
                    ref.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                        if error != nil {
                            print("Unable to download image from firebase storage")
                        } else {
                            print("Image downloaded from firebase storage")
                            if let imageData = data {
                                if let img = UIImage(data: imageData) {
                                    self.imageAdd.image = img
                                    FeedVC.imageCache.setObject(img, forKey: imageUrl as NSString)
                                }
                            }
                        }
                    }
                }
            }
        })

    
    }
    
    
    func getUsername() {
        DataService.ds.REF_USER_CURRENT.child("username").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            if let _ = snapshot.value as? NSNull {
                print("no  username")
            } else {
                self.usernameField.text = snapshot.value as? String
            }
        })
    }
    


}
