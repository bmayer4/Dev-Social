//
//  FeedVC.swift
//  Dev Social
//
//  Created by Brett Mayer on 7/31/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: CustomField!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    
    static var imageCache = NSCache<NSString, UIImage>()
    
    var imageSelected = false //so if you post a caption with no image, it doesn't upload camera image

    override func viewDidLoad() {
        super.viewDidLoad()
        
       tableView.delegate = self
       tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            print("SNAP \(String(describing: snapshot.value))")
            
            self.posts = []  //so no duplcate posts
     
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let postDic = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        print("SNAP KEY: \(snap.key)") //COOL, this is the post id from firebase database
                        let post = Post(postKey: key, postData: postDic)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let p = posts[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
            
            //check for cache image
            if let img = FeedVC.imageCache.object(forKey: p.imageUrl as NSString) {
                cell.configureCell(post: p, img: img)
            } else {
                cell.configureCell(post: p, img: nil)
            }
             return cell
        } else {
            return UITableViewCell()
        }
    }
    

    
    //make sure user interraction enabled is checked in storyboard for image this is linked to, with tap gesture rec
    @IBAction func signOutTapped(_ sender: Any) {
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Id removed from keychain: \(keychainResult)")
        
        do {
            try Auth.auth().signOut()
        } catch let err as NSError {
            print("Error signing out: \(err)")
        }
    
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
    
    
    @IBAction func addImageTapped(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
   
    @IBAction func postBtnTapped(_ sender: Any) {
        guard let caption = captionField.text, caption != "" else {
                print("Caption must be entered")
                return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            print("An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metadata) {
            (metadata, error) in
                if error != nil {
                    print("Unable to upload image to firebase storage")
                } else {
                    print("Successfully uploaded image to firebase storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString  //we will need this in nex video
                    print("DownloadUrl: /(downloadUrl)")
                    
                    if let url = downloadUrl {
                        self.postToFirebase(imgUrl: url)
                    }
                    
                }
            }  //end RED_POST_IMAGES
        }
    }
    
    func postToFirebase(imgUrl: String) {
        
        let post: Dictionary<String, Any> = [
        "caption": captionField.text! as Any,
        "imageUrl": imgUrl as Any,
        "likes": 0 as Any
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)  //brand new post, ok to use setValue
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        tableView.reloadData()
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        }
        dismiss(animated: true, completion: nil)
    }



}
