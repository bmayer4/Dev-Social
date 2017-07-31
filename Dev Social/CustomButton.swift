//
//  CustomButton.swift
//  Dev Social
//
//  Created by Brett Mayer on 7/30/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset  = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 2
    }

}
