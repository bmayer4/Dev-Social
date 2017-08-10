//
//  PostCell.swift
//  Dev Social
//
//  Created by Brett Mayer on 7/31/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    var likesRef: DatabaseReference!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //must add tap gesture progrmatically because there are multiple objects with them in the feed
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true //IMPORTANT
        
    }
    
    
    //we want to cache images that we bring down from firebase
    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        self.likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        caption.text = self.post.caption
        likesLbl.text = String(self.post.likes)
        
        if img != nil {  //if it exists in the cache
            postImg.image = img
        } else {   //we need to download it
            let imageUrl = self.post.imageUrl
                let ref = Storage.storage().reference(forURL: imageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                if error != nil {
                    print("Unable to download image from firebase storage")
                } else {
                    print("Image downloaded from firebase storage")
                    if let imageData = data {
                        if let img = UIImage(data: imageData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: imageUrl as NSString)
                        }
                    }
                }
            }
        }
        
            likesRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            print("likesref snapshot: \(String(describing: snapshot.value))")
            if let _ = snapshot.value as? NSNull {  //if no likes then firebase will return NSNull, not nil
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")  //have we liked this particular cell before??? how
            }
        })
    }
    
    
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in

            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })

    }

}
