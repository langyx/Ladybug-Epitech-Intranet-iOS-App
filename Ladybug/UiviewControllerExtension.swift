//
//  UiviewControllerExtension.swift
//  Ladybug
//
//  Created by Yannis Lang on 26/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import BTNavigationDropdownMenu
import Whisper

extension UIViewController {
    
    func addNavMenu(title : String) -> Void {
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: title, items: Constantes.menu.items as [AnyObject])
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            var viewControllersNew = self.navigationController?.viewControllers
            viewControllersNew?.removeAll()
            switch indexPath {
            case 0:
                let profileController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.PROFILE_VIEW) as! ProfileHomeController
                viewControllersNew?.append(profileController)
                break
            case 1:
                let ELearnController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.ELEARNING) as! ElearnMain
                viewControllersNew?.append(ELearnController)
            case 2:
                let trombyController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.TROMBI_HOME) as! TrombiHomeController
                viewControllersNew?.append(trombyController)
                break
            case 3:
                let LeaderBoardController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.LEADERBORD) as! LeaderBoard
                viewControllersNew?.append(LeaderBoardController)
                break
            case 4:
                let LoginController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.LOGIN_VIEW) as! LoginViwController
                LoginController.logOut = true
                viewControllersNew?.append(LoginController)
                break
            default:
                break
            }
            self.navigationController?.MakeAnimationTouch(force: 2)
            self.navigationController?.setViewControllers(viewControllersNew!, animated: true)
        }
        menuView.menuTitleColor = UIColor.white
        menuView.cellTextLabelColor = UIColor.white
        menuView.navigationBarTitleFont = UIFont(name: "Helvetica Neue Thin", size: 20)
        menuView.cellTextLabelFont = UIFont(name: "Helvetica Neue Thin", size: 20)
        menuView.cellSeparatorColor = UIColor.white
        self.navigationItem.titleView = menuView
    }
    
    func checkingAndGoingToReader(Ressource_Path : String, Ressource_title : String, Path_Extension : String) -> Void {
        switch Path_Extension {
        case "mp4", "html", "pdf", "mp3", "txt", "htm", "c", "ppt", "pptx", "aspx", "xls":
            self.navigationController?.pushToReader(url: Ressource_Path, titre: Ressource_title)
            break
        case "tar", "zip", "tgz":
          let message = Message(title: "Le format \(Path_Extension) n'est encore prise en charge", backgroundColor: UIColor.red)
            Whisper.show(whisper: message, to: (self.navigationController)!)
            break
        default:
            if Ressource_Path.verifyUrl() == true {
                self.navigationController?.pushToReader(url: Ressource_Path, titre: Ressource_title)
            }else{
                let message = Message(title: "Le format \(Path_Extension) est invalide", backgroundColor: UIColor.red)
                Whisper.show(whisper: message, to: (self.navigationController)!)
            }
            break
        }
    }
}
