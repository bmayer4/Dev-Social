//
//  CustomField.swift
//  Dev Social
//
//  Created by Brett Mayer on 7/30/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit

class CustomField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.2).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 2
    }
    
    //this will affect placeholder text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)  //dx is offset from left and dy is adjusting text box height
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }

}
