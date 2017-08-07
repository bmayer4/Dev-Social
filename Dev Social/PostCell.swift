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
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    //we want to cache images that we bring down from firebase
    func configureCell(post: Post, img: UIImage?) {
        self.post = post
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
    }

}
