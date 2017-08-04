//
//  FeedVC.swift
//  Dev Social
//
//  Created by Brett Mayer on 7/31/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
       tableView.delegate = self
       tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell //temp
    }
    

    
    //make sure user interraction enabled is checked in storyboard for image this is linked to, with tap gesture rec
    @IBAction func signOutTapped(_ sender: Any) {
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("Id removed from keychain: \(keychainResult)")
        
        do {
            try Auth.auth().signOut()
        } catch let err as NSError {
            print("Error signing out: \(err)")
        }
    
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }


}
