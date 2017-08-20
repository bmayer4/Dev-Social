//
//  Post.swift
//  Dev Social
//
//  Created by Brett Mayer on 8/5/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import Foundation
import Firebase

class Post {

    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!  //could have called this id
    private var _postRef: DatabaseReference!
    private var _userId: String!
    private var _postedDate: String!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var userId: String {
        return _userId
    }
    
    var postedDate: String {
        return _postedDate
    }
    
    init(caption: String, imageUrl: String, likes: Int) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
    }
    
    init(postKey: String, postData: Dictionary<String, Any>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let userId = postData["userId"] as? String {
            self._userId = userId
        }
        
        if let postedDate = postData["postedDate"] as? String {
            self._postedDate = postedDate
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else if _likes > 0 {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }
    
    func deletePost() {
        DataService.ds.REF_POSTS.child(self.postKey).removeValue()
        print("post with key of \(self.postKey) deleted")
        
        Storage.storage().reference(forURL: self._imageUrl).delete { (error) in
            print("deleted image reference from storage")
        }
        
        FeedVC.imageCache.removeObject(forKey: self.imageUrl as NSString)

    }
}
