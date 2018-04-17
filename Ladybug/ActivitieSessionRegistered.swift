//
//  ActivitieSessionRegistered.swift
//  Ladybug
//
//  Created by Yannis Lang on 19/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Kingfisher
import EZLoadingActivity

class ActivitieSessionRegistered: UITableViewController {
    
    var ActivitieSessionUrl : String!
    var ActivitieSessionData = [[String:AnyObject]]()
    
    let userDefaut = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setBackground()
       
        EZLoadingActivity.show("Chargement...", disableUI: true)
        self.getSessionData()
    }
    
    func getSessionData() -> Void {
        Alamofire.request(self.ActivitieSessionUrl, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as? [[String : AnyObject]] ?? [["title" : "Aucun Inscrit" as AnyObject]]
                        self.ActivitieSessionData = JSON
                        self.tableView.reloadData()
                        EZLoadingActivity.hide()
                    }
                }
                break
                
            case .failure(_):
                print(response.result.error!)
                EZLoadingActivity.hide()
                break
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ActivitieSessionData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! ActivitieSessionRegisteredCellStudent
        let index = indexPath.row
        let StudentData = self.ActivitieSessionData[index]
        let StudentImage = NSURL(string: StudentData["picture"] as? String ?? "")
        let StudentPresent = StudentData["present"] as? String ?? ""
        
        cell.designView.applyCurvedShadow()
        cell.profileImage.kf.setImage(with: StudentImage as! URL, placeholder: #imageLiteral(resourceName: "profile"), options: nil, progressBlock: nil, completionHandler: nil)
        if StudentPresent == "" {
            cell.profileImage.rounding_border(border_color: UIColor.red, border_size: 1)
        }else{
            cell.profileImage.rounding_border(border_color: UIColor.green, border_size: 1)
        }
        cell.name.text = (StudentData["title"] as! String? ?? "Inconnu").capitalized
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.MakeAnimationTouch(force: 0)
        let profileController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.PROFILE_VIEW) as! ProfileHomeController
        let StudentTouched = self.ActivitieSessionData[indexPath.row]
        let StudentTouchedLogin = StudentTouched["login"] as? String ?? ""
        
        if StudentTouchedLogin != "" {
            let login_Self = userDefaut.string(forKey: Constantes.key_userdef.LOGIN_KEY)
            if login_Self == StudentTouchedLogin {
                profileController.profile_self_mode = true
            }else{
                profileController.profile_login = StudentTouchedLogin
            }
            profileController.peekMode = true
            self.navigationController?.pushViewController(profileController, animated: true)
        }
    }
}
