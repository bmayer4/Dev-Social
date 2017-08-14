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
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    print("DownloadUrl from FEEDVC: /(downloadUrl)")
                    
                    if let url = downloadUrl {
                        self.postToFirebase(imgUrl: url)
                    }
                    
                }
            }  //end REF_POST_IMAGES
        }
    }
    
    func postToFirebase(imgUrl: String) {
        
        let post: Dictionary<String, Any> = [
        "caption": captionField.text! as Any,
        "imageUrl": imgUrl as Any,
        "likes": 0 as Any,
        "userId": KeychainWrapper.standard.string(forKey: KEY_UID) as Any  //stores id of user who made post
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        print("firebase post: \(firebasePost.key)")  //Post Id, I could add this to the user table..
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
    

    @IBAction func menuTapped(_ sender: Any) {
        print("Menu tapped")
        
        let buttonPosition: CGPoint = (sender as! UIButton).convert(CGPoint.zero, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        let post = posts[indexPath!.row]
        
        let ac = UIAlertController(title: "Choose one", message: nil, preferredStyle: .alert)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
            
            //here is how to do it with code :)
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostInfoVC") as? PostInfoVC
            //self.present(vc!, animated: true, completion: nil)
            
            self.performSegue(withIdentifier: "goToPostInfoVC", sender: post)
            
            
        
            
        }
        ac.addAction(editAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) -> Void in
            
            post.deletePost()
        }
        ac.addAction(deleteAction)

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        ac.addAction(cancelAction)
        
        present(ac, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare worked")
        if segue.identifier == "goToPostInfoVC" {
            if let navController = segue.destination as? UINavigationController {
                let destination = navController.topViewController as! PostInfoVC
                if let post = sender as? Post {
                    destination.post = post
                }
            }
        }
    }

    
}
