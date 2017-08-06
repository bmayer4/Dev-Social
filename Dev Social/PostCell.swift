//
//  PostCell.swift
//  Dev Social
//
//  Created by Brett Mayer on 7/31/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit

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
    func configureCell(post: Post) {
        self.post = post
        caption.text = self.post.caption
        likesLbl.text = String(self.post.likes)
    }

}
