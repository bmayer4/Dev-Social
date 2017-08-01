//
//  CustomView.swift
//  Dev Social
//
//  Created by Brett Mayer on 7/30/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit

class CustomView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0  //how far shadow blurs out
        layer.shadowOffset  = CGSize(width: 0.0, height: 0.0)  //width is where it starts from left of view, height is down
        layer.cornerRadius = 2.0
    }
    
}
