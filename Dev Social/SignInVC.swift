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
    
    @IBOutlet weak var emailField: CustomField!
    @IBOutlet weak var passwordField: CustomField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        //makes more sense to try to and sign user in first
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    print("Email user authenticated with Firebase")
                    print("Password email: \(user?.email)")
                } else {
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        if let err  = error as? NSError {
                            print("Unable to authenticate with Firebase using email")
                            if let errorCode = AuthErrorCode(rawValue: err.code) {
                                switch errorCode {
                                case .invalidEmail:
                                    //handle invalid email
                                    print("email invalid format")
                                    self.emailField.text = "email invalid format"  //could make an error outlet instead
                                    //but better to do this, or do the validation yourself with the text put in?
                                case .wrongPassword:
                                    //handle wrong password
                                    print("wrong pw")
                                case .emailAlreadyInUse:
                                    //handle email already in use
                                    print("email in use")
                                case .weakPassword:
                                    //handle weakpassword
                                    print("need longer pw")
                                default:
                                    print(err)
                                }
                            }
                        } else {
                            print("Successfully authenticated email with Firebase")
                        }
                    }
                }
            }

        }
    
    }

}

