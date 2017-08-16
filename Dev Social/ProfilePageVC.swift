//
//  ProfilePageVC.swift
//  Dev Social
//
//  Created by Brett Mayer on 8/14/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import Firebase

class ProfilePageVC: UIViewController {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var providerLbl: UILabel!
    @IBOutlet weak var likesCountLbl: UILabel!
    
    var userId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("userId from profile page: \(userId)")
        
        greetUser()

    }

    @IBAction func backPressed(_ sender: UIButton) {
       dismiss(animated: true, completion: nil)
    }
  
    func greetUser() {
        
        DataService.ds.REF_USERS.child(self.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                print("User Id Invalid")
            } else {
                if let snap = snapshot.value as? Dictionary<String, Any> {
                    let username = snap["username"] as? String
                    let provider = snap["provider"] as? String
                    let likes = snap["likes"] as? Dictionary<String, Any>
                    
                    self.nameLbl.text = "Hello, \(String(describing: username!))"
                    self.providerLbl.text = provider!
                    self.likesCountLbl.text = "You have \(String(describing: likes?.count)) likes!"  //nil for oscar
                }
            }

        })
        }
    

}
