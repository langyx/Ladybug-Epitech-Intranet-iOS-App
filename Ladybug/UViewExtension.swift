//
//  TextFieldExtension.swift
//  Ladybug
//
//  Created by Yannis on 24/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func bordering_field(width : Float, color : UIColor?, radius : Float?) -> Void {
        let apply_color : UIColor
        if color == nil {
            apply_color = UIColor.clear
        }else{
            apply_color = color!
        }
        self.layer.borderColor = apply_color.cgColor
        self.layer.borderWidth = CGFloat(width)
        if radius != nil {
            self.layer.cornerRadius = CGFloat(radius!)
        }
        self.applyPlainShadow()
    }
    
    func applyPlainShadow() { //ombre dans le prolongement
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5
    }
    
    func applyCurvedShadow() { //ombre incurvé
        let size = bounds.size
        let width = size.width
        let height = size.height
        let depth = CGFloat(11.0)
        let lessDepth = 0.8 * depth
        let curvyness = CGFloat(5)
        let radius = CGFloat(1)
        
        let path = UIBezierPath()
        
        // top left
        path.move(to: CGPoint(x: radius, y: height))
        
        // top right
        path.addLine(to: CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLine(to: CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurve(to: CGPoint(x: radius, y: height + depth),
                             controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
                             controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: -3)
    }
    
    
    func applyHoverShadow() { // ombre arrondie en dessous
        let size = bounds.size
        let width = size.width
        let height = size.height
        
        let ovalRect = CGRect(x: 5, y: height + 5, width: width - 10, height: 15)
        let path = UIBezierPath(roundedRect: ovalRect, cornerRadius: 10)

        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func addBlurEffect() { //effet de flou
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    
    func setBackgroundView() -> Void {
        let imageViewBg = UIImageView(image: #imageLiteral(resourceName: "background_img"))
        imageViewBg.contentMode = .scaleAspectFill
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.75
        blurView.frame = imageViewBg.bounds
        imageViewBg.addSubview(blurView)
        self.backgroundColor = UIColor.clear
        self.insertSubview(imageViewBg, at: 0)
    }
}
