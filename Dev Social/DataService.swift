//
//  DataService.swift
//  Dev Social
//
//  Created by Brett Mayer on 8/3/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import Foundation
import Firebase

//contains url of the root of our database
let DB_BASE = Database.database().reference()

class DataService {
    
    static let ds = DataService() //singleton
    
    //these will all be global since it is singletion class
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    
    //use this function when signing in
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        //firebase will create the uid
        REF_USERS.child(uid).updateChildValues(userData)   //I could use .setValue but this will overwrite data
    }
    
    
}
