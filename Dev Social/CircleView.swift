//
//  CircleView.swift
//  Dev Social
//
//  Created by Brett Mayer on 7/31/17.
//  Copyright © 2017 Devslopes. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true  //this made image stay rounded when we used imagepicker
    }
}
