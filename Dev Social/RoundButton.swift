//
//  RoundButton.swift
//  Dev Social
//
//  Created by Brett Mayer on 7/30/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit

class RoundButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //this shadow will go around button
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset  = CGSize(width: 1.0, height: 1.0)
        imageView?.contentMode = .scaleAspectFit  //could do this in IB
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //this needs to go here because at this point, the frame size has been calculated
        layer.cornerRadius = self.frame.width / 2
    }

}
