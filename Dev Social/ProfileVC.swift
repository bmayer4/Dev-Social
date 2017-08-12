//
//  ProfileVC.swift
//  Dev Social
//
//  Created by Brett Mayer on 8/11/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func submitProfile(_ sender: Any) {
        
        guard let username = usernameField.text, username != "" else {
            print("Enter username")
            return
        }
            let userData = ["username": "\(username)"]
            DataService.ds.REF_USER_CURRENT.updateChildValues(userData)
            print("Successfully created username")
        
        performSegue(withIdentifier: "goToFeed", sender: nil)
        
    }
}
