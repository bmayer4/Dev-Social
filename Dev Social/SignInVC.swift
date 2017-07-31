//
//  SignInVC.swift
//  Dev Social
//
//  Created by Brett Mayer on 7/27/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SignInVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let fbLogin = FBSDKLoginManager()
        fbLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error  != nil {
                print("Unable to authenticate with Facebook. Error \(error)");
            } else if result?.isCancelled == true {
                print("Login cancelled");
            } else {
                print("Successfully authenticated with Facebook");
                
                //FacebookAuthProvider is firebase method, working with facebook current token
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    func firebaseAuth(_ credential: AuthCredential) {
    Auth.auth().signIn(with: credential) { (user, error) in
        if error != nil {
            print("Unable to authenticate with firebase. \(error)")
        } else {
            print("Successfully authenticated with Firebase")
        }
        }
    }

}

