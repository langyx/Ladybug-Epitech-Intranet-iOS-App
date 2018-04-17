//
//  ProfileBinomesController.swift
//  Ladybug
//
//  Created by Yannis Lang on 30/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import Kingfisher
import Alamofire
import UIKit
import EZLoadingActivity

class ProfileBinomesController: UITableViewController {
    var profile_login = String()
    var header_data = [String : String]()

    var StudentBinome = [[String:AnyObject]]()
    
    var current_Activitie_All = -1
    
    @IBOutlet weak var mainTable : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Colaborations"
        self.mainTable.setBackground()
        EZLoadingActivity.show("Chargement...", disableUI: true)
        getBinome()
    }
    
    func getBinome() -> Void {
        var url_student_binome = Constantes.url.student_binome
        url_student_binome = url_student_binome.replacingOccurrences(of: "{user}", with: self.profile_login)
        
        Alamofire.request(url_student_binome, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [String:AnyObject]
                        let data_binomes = JSON["binomes"] as! [[String:AnyObject]]
                        
                        var new_data_binome = [[String:AnyObject]]()
                        
                        for person in data_binomes {
                            var new_person = [String:AnyObject]()
                            new_person["login"] = person["login"] as AnyObject
                            var activities_data = (person["activities"] as? String)?.components(separatedBy: ",")
                            activities_data?.sort(by : >)
                            new_person["activite"] = activities_data as AnyObject
                            new_person["nb"] = person["nb_activities"] as AnyObject
                            new_data_binome.append(new_person)
                        }
                        
                        new_data_binome.sort{ (item1, item2) -> Bool in
                            let note1 = Int(item1["nb"] as! String)!
                            let note2 = Int(item2["nb"] as! String)!
                            return note1 > note2
                        }
                        self.StudentBinome = new_data_binome
                        self.mainTable.reloadData()
                        EZLoadingActivity.hide()
                    }
                }
                break
                
            case .failure(_):
                print(response.result.error!)
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       let index = indexPath.row
        if tableView == self.mainTable {
            if index == 0 {
                return 113
            }
            return 143
        }
        return 27
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.mainTable {
            return self.StudentBinome.count
        }else{
            if current_Activitie_All != -1 {
                return (self.StudentBinome[current_Activitie_All]["activite"] as! [AnyObject]).count
            }
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell = UITableViewCell()
        let index = indexPath.row
        
        if tableView == self.mainTable { //Table des binomes
            if index == 0 { //header
                let cust_cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as! HeaderProfileCell
                
                let url_pic = URL(string: (header_data["etudiant_picture"])!)
                cust_cell.imageProfile.kf.setImage(with: url_pic)
                cust_cell.prenomLbl.text = (header_data["prenom"])!
                cust_cell.nomLbl.text = (header_data["nom"])!
                cust_cell.anneeLbl.text = (header_data["curr_annee"])!
                cust_cell.cityLbl.text = (header_data["etudiant_city"])!
                cust_cell.imageProfile.rounding_border(border_color: UIColor.black, border_size: nil)
                
                cell = cust_cell
            }else{
                let binome_data = self.StudentBinome[index - 1]
                
                let display_mode = binome_data["disp"] as? Int
                
                var login = binome_data["login"] as! String
                login.epureEmail()
                let nb_proj = binome_data["nb"] as! String
                let url_pic = NSURL(string: (Constantes.url.profile_pic).replacingOccurrences(of: "{user}", with: login)) as! URL
                let best = self.StudentBinome[0]["nb"] as! String
                let border_activiti = (CGFloat((nb_proj as NSString).floatValue) / CGFloat((best as NSString).floatValue) * 4) as CGFloat
                
                if display_mode == nil || display_mode == 0 {
                     let cust_cell = tableView.dequeueReusableCell(withIdentifier: "binomeResume", for: indexPath) as! BinomeCellResume
                    
                    let projet_word = Bool(Int(nb_proj)! - 1) ? "projets" : "projet"
                    let resume_txt = "\(nb_proj) \(projet_word) avec \((login.replacingOccurrences(of: ".", with: " ")).capitalized)"
                    cust_cell.labelActiv.text = resume_txt
                    
                    cust_cell.imageProfile.kf.setImage(with: url_pic, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cachetype, url) in
                        cust_cell.imageProfile.rounding_border(border_color: UIColor.black, border_size: border_activiti)
                        cust_cell.designView.applyCurvedShadow()
                    })
                    let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(goToProfile(sender:)))
                    cust_cell.designView.tag = index - 1
                    cust_cell.designView.isUserInteractionEnabled = true
                    cust_cell.designView.addGestureRecognizer(tapGestureRecognizer)
                    
                    cell = cust_cell
                }else{
                    let cust_cell = tableView.dequeueReusableCell(withIdentifier: "binomeActivities", for: indexPath) as! BinomeCellBinomeActivities
                    
                    cust_cell.nameLabel.text = (login.replacingOccurrences(of: ".", with: " ")).capitalized
                    cust_cell.profilePhoto.kf.setImage(with: url_pic, placeholder: #imageLiteral(resourceName: "profile"), options: nil, progressBlock: nil, completionHandler: { (image, error, cachetype, url) in
                        cust_cell.profilePhoto.rounding_border(border_color: UIColor.black, border_size: border_activiti)
                        cust_cell.designView.applyCurvedShadow()
                    })
                    let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(goToProfile(sender:)))
                    cust_cell.designView.tag = index - 1
                    cust_cell.designView.isUserInteractionEnabled = true
                    cust_cell.designView.addGestureRecognizer(tapGestureRecognizer)
                    
                    self.current_Activitie_All = index - 1
                    cust_cell.tableActivities.delegate = self
                    cust_cell.tableActivities.dataSource = self
                    cust_cell.tableActivities.backgroundColor = UIColor.clear
                    cust_cell.tableActivities.reloadData()
                    
                    cell = cust_cell
                }
            }
        }else{ //table des activités
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "SubActivieCell", for: indexPath) as! BinomeSubAllActivities
            let activities = self.StudentBinome[current_Activitie_All]["activite"] as! [String]
            
            cust_cell.name.text = activities[index]
            
            cell = cust_cell
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        self.navigationController?.MakeAnimationTouch(force: 0)
        if tableView == self.mainTable {
            if index > 0 {
                let dispMode = self.StudentBinome[index - 1]["disp"] as? Int
                if dispMode == nil || dispMode == 0 {
                    self.StudentBinome[index - 1]["disp"] = 1 as AnyObject
                }else{
                    self.StudentBinome[index - 1]["disp"] = 0 as AnyObject
                }
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }else{
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    func goToProfile(sender : UITapGestureRecognizer) -> Void {
        self.navigationController?.MakeAnimationTouch(force: 2)
        let index = (sender.view?.tag)!
        let login = self.StudentBinome[index]["login"] as! String
        
        var nav_views = (self.navigationController?.viewControllers)!
        for (index_ctrlr, viewController_in) in nav_views.enumerated() {
            if viewController_in is ProfileHomeController {
                let profile_controler = viewController_in as! ProfileHomeController
                if profile_controler.profile_login == login {
                    let range_del = index_ctrlr + 1 ..< nav_views.count
//                    print(range_del)
                    nav_views.removeSubrange(range_del)
//                    print("befor",(self.navigationController?.viewControllers)!)
                    self.navigationController?.setViewControllers(nav_views, animated: true)
                    break
                }
            }
        }
        
        let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.PROFILE_VIEW) as! ProfileHomeController
        profileViewController.profile_login = login
        profileViewController.peekMode = true
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
}
