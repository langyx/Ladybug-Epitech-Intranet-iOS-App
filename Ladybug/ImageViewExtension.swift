//
//  ImageViewExtension.swift
//  Ladybug
//
//  Created by Yannis on 23/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func rounding_border(border_color : UIColor,  border_size : CGFloat?) {
        if border_size != nil {
            self.layer.borderWidth = border_size!
        }else{
            self.layer.borderWidth = 1
        }
        self.layer.masksToBounds = false
        self.layer.borderColor = border_color.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }

}
