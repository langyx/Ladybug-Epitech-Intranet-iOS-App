//
//  UiLabelExtension.swift
//  Ladybug
//
//  Created by Yannis Lang on 24/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func ApplyGradeColor() -> Void {
        if self.text != nil {
            switch self.text! {
            case "Acquis":
                self.textColor = UIColor.green
                break
            case "A":
                self.textColor = UIColor.green
                break
            case "B":
                self.textColor = UIColor.yellow
                break
            case "C":
                self.textColor = UIColor.orange
                break
            case "D":
                self.textColor = UIColor.red
                break
            case "E":
                self.textColor = UIColor.red
                break
            case "-":
                self.textColor = UIColor.white
                self.text = "En cours"
            default:
                self.textColor = UIColor.white
                break
            }
        }
    }
    
    func badgeIt(bg_color : UIColor) -> Void {
        self.sizeToFit()
        self.backgroundColor = bg_color
        self.clipsToBounds = true
        self.layer.cornerRadius = 3
    }
}
