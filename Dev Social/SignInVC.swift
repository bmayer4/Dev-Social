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
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: CustomField!
    @IBOutlet weak var passwordField: CustomField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //viewDidLoad can not perform segues, too early
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("Id found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }

    }
    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let fbLogin = FBSDKLoginManager()
        fbLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error  != nil {
                print("Unable to authenticate with Facebook. Error \(String(describing: error))");
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
            print("Unable to authenticate with firebase. \(String(describing: error))")
            } else {
            print("Successfully authenticated with Firebase")
            if let user = user {
                let userData = ["provider": credential.provider]
            self.completeSignIn(id: user.uid, userData: userData)
            }
           
        }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        //makes more sense to try to and sign user in first
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    print("Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }

                } else {
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        if let err  = error as NSError? {
                            print("Unable to authenticate with Firebase using email")
                            if let errorCode = AuthErrorCode(rawValue: err.code) {
                                switch errorCode {
                                case .invalidEmail:
                                    //handle invalid email
                                    print("email invalid format")
                                    self.emailField.text = "email invalid format"  //could make an error outlet instead
                                case .wrongPassword:
                                    //handle wrong password
                                    print("wrong pw")
                                case .weakPassword:
                                    //handle weakpassword
                                    print("need longer pw")
                                default:
                                    print(err)
                                }
                            }
                        } else {
                            print("Successfully authenticated email with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }

                        }
                    }
                }
            }

        }
    
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        print("ID is \(id)")  //this id is in firebase under user id in database
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Data saved to keychain: \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }

}

