//
//  NavigationControllerExtension.swift
//  Ladybug
//
//  Created by Yannis Lang on 27/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension UINavigationController {
    
    func empty_Push(ctrlr : UIViewController) -> Void{
        var stack = self.viewControllers
        stack.removeAll()
        stack.append(ctrlr)
        self.setViewControllers(stack, animated: true)
    }
    
    func replace_by(controller : UIViewController) -> Void {
        var stack = self.viewControllers
        stack.remove(at: stack.count - 1)
        stack.insert(controller, at: stack.count)
        self.setViewControllers(stack, animated: false)
    }
    
    func pushToReader(url : String, titre : String) -> Void {
        let FileReaderController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.FILEREADER) as! FileReaderMain
        FileReaderController.FilePath = url
        FileReaderController.TitleFile = titre.capitalized
        self.pushViewController(FileReaderController, animated: true)
    }
    
    func MakeAnimationTouch(force : Int) -> Void {
        var power : UIImpactFeedbackStyle
        
        switch force {
        case 0:
            power = .light
            break
        case 1:
            power = .medium
            break
        case 2:
            power = .heavy
            break
        default:
            power = .medium
            break
        }
        let generator = UIImpactFeedbackGenerator(style: power)
        generator.impactOccurred()
    }
}
