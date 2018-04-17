//
//  TableViewExtension.swift
//  Ladybug
//
//  Created by Yannis Lang on 29/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func scrollToTop(animated : Bool) -> Void {
        let index_zero = NSIndexPath(row: 0, section: 0)
        self.scrollToRow(at: index_zero as IndexPath, at: UITableViewScrollPosition.top, animated: animated)
    }
    
    func setBackground() -> Void {
        let imageViewBg = UIImageView(image: #imageLiteral(resourceName: "background_img"))
        imageViewBg.contentMode = .scaleAspectFill
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.75
        blurView.frame = imageViewBg.bounds
        imageViewBg.addSubview(blurView)
        self.backgroundColor = UIColor.clear
        self.backgroundView = imageViewBg
    }
}
