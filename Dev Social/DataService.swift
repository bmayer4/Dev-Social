//
//  DataService.swift
//  Dev Social
//
//  Created by Brett Mayer on 8/3/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

//contains url of the root of our database
let DB_BASE = Database.database().reference()
let STORAGE_BASE  = Storage.storage().reference()

class DataService {
    
    static let ds = DataService() //singleton
    private init() {}
    
    //these will all be global since it is singletion class
    //DB references
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    //storage references
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    private var _REF_PROFILE_IMAGES = STORAGE_BASE.child("profile-pics")

    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        print("uid for current user is: \(String(describing: uid))")
        
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_POST_IMAGES: StorageReference {
        return _REF_POST_IMAGES
    }
    
    var REF_PROFILE_IMAGES: StorageReference {
        return _REF_PROFILE_IMAGES
    }
    
    
    //use this function when signing in
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        //firebase will create the uid
        REF_USERS.child(uid).updateChildValues(userData)   //I could use .setValue but this will overwrite data
    }
    
}
