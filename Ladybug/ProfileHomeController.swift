//
//  ProfileHomeController.swift
//  Ladybug
//
//  Created by Yannis on 24/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Kingfisher
import MessageUI
import Whisper
import EZLoadingActivity

class ProfileHomeController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    let userDef = UserDefaults.standard
    
    var profile_self_mode = false
    var profile_login = String() //DEFINE THISE TO USER
    var profile_info_data = [String : AnyObject]()
    var profile_info_mine = [String : AnyObject]()
    
    var ui_construction_data = [String: AnyObject]()
    var ui_disposition = [String]()
    
    var subTableData = [[String : String]]()
    
    var peekMode = false
    var staffMode = false
    
    @IBOutlet weak var mainTable : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainTable.setBackground()
        self.title = "Profile"
        if !peekMode {
            self.addNavMenu(title: "Profile")
        }
        
        if profile_login == "" {
            self.profile_self_mode = true
            profile_login = userDef.string(forKey: Constantes.key_userdef.LOGIN_KEY)!
        }
        EZLoadingActivity.show("Chargement...", disableUI: true)
        getProfileData()
    }

    override func viewDidAppear(_ animated: Bool) {
        if (self.navigationController?.viewControllers.count)! < 2 {
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(false, animated: false)
    }
    
    func getProfileData() -> Void {
        let profile_url = (Constantes.url.profile as NSString).replacingOccurrences(of: Constantes.url_key.urername, with: profile_login)
        
        Alamofire.request(profile_url, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [String:AnyObject]
                        self.profile_info_data = JSON
                        if self.profile_self_mode {
                            self.getProfileMineData()
                        }else{
                            self.constructingEnv()
                        }
                    }
                }
                break
                
            case .failure(_):
                EZLoadingActivity.hide()
                print(response.result.error!)
                break
            }
        }
    }
    
    func getProfileMineData() -> Void {
        let profile_url = Constantes.url.url_connexion_home
        
        Alamofire.request(profile_url, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [String:AnyObject]
                        self.profile_info_mine = JSON
                        self.constructingEnv()
                    }
                }
                break
                
            case .failure(_):
                EZLoadingActivity.hide()
                print(response.result.error!)
                break
            }
        }
    }
    
    func constructingEnv() -> Void {
//        print("\n\n\n\n\n\n\n\n" , profile_info_data, "\n\n\n\n\n\n\n\n", profile_info_mine)
        
        /**** HEADER DATA CONSTRUCTION ***/
        let prenom = self.profile_info_data["firstname"] as! String
        let nom = self.profile_info_data["lastname"] as! String
       
        let dateClass = DateMainFunc()
        
        let etudiant_annee = self.profile_info_data["studentyear"] as? Int ?? dateClass.getCurrentYear()
        var etudiant_annee_txt_prefix : String
        var etudiant_annee_txt : String = ""
        if etudiant_annee > 10 {
            etudiant_annee_txt_prefix = "Année " + String(etudiant_annee)
            etudiant_annee_txt = etudiant_annee_txt_prefix
        }else{
            etudiant_annee_txt_prefix = Bool(etudiant_annee - 1) ? "ème" : "ére"
            etudiant_annee_txt = "\(etudiant_annee)\(etudiant_annee_txt_prefix) année"
        }
        
        var etudiant_groups = self.profile_info_data["groups"] as? [[String:AnyObject]]
        if etudiant_groups == nil || (etudiant_groups?.isEmpty)! {
            etudiant_groups = [["name" : "Staff" as AnyObject]]
        }
        let etudiant_city = etudiant_groups![0]["name"] as! String
        
        let etudian_picture = self.profile_info_data["picture"] as? String ?? ""
        
        let header_data = ["prenom" : prenom, "nom" : nom, "curr_annee" : etudiant_annee_txt, "etudiant_city" : etudiant_city, "etudiant_picture" : etudian_picture]
        self.ui_construction_data["header"] = header_data as AnyObject?
        /*********************************/
        
        /**** CLASSIC 3 CONSTRUCTION ***/
        let etudiant_credits = String(self.profile_info_data["credits"] as? Int ?? -42)
        
        let etudiant_gpa_table = self.profile_info_data["gpa"] as? [[String:AnyObject]]
        var etudiant_gpa = String()
        if etudiant_gpa_table != nil {
            etudiant_gpa = etudiant_gpa_table?[0]["gpa"] as? String ?? "Nd."
        }
        

        let etudiant_epice_table = self.profile_info_data["spice"] as? [String:AnyObject]
        var etudiant_epice = String()
        if etudiant_epice_table != nil {
            etudiant_epice = etudiant_epice_table?["available_spice"] as? String ?? "0"
        }else{
            etudiant_epice =  "0"
        }
        
        if etudiant_credits != "-42" {
            let classic_3_data = [etudiant_gpa, etudiant_credits, etudiant_epice]
            self.ui_construction_data["classic_3"] = classic_3_data as AnyObject?
        }else{
            self.staffMode = true
        }
        /*********************************/
        
        /**** CLASSIC 4 CONSTRUCTION ***/
        if !self.staffMode {
            let etudiant_semester = "Semestre #\(String(self.profile_info_data["semester"] as? Int ?? 0))"
            let etudiant_semester_code = self.profile_info_data["semester_code"] as? String ?? "Staff"
            
            let etudiant_parcours = self.profile_info_data["course_code"] as? String ?? "Nd."
            
            //        print(self.profile_info_data)
            let etudiant_log_table = self.profile_info_data["nsstat"] as? [String:AnyObject]
            var etudiant_log = "0 heure"
            if etudiant_log_table != nil && !((etudiant_log_table?.isEmpty)!) {
                etudiant_log = "\(String((etudiant_log_table?["active"])! as! Int)) heures"
            }
            
            let classic_4_data = [etudiant_parcours,  etudiant_semester_code , etudiant_log, etudiant_semester]
            self.ui_construction_data["classic_4"] = classic_4_data as AnyObject?
        }
        /*********************************/
        
        /**** SUB TABLE PROJET CONSTRUCTION ***/
        if self.profile_self_mode && !self.staffMode {
            let board_selfProfile = self.profile_info_mine["board"] as! [String : AnyObject]
            let board_projet_table = board_selfProfile["projets"] as! [[String:AnyObject]]
            var subTable_projet_data = [[String:String]]()
            for item in board_projet_table {
                var one_proj = [String:String]()
                one_proj["title"] = item["title"] as? String
                one_proj["avancement"] = item["timeline_barre"] as? String
                subTable_projet_data.append(one_proj)
            }
            self.ui_construction_data["tableCell_p"] = subTable_projet_data as AnyObject?
        }
        /*************************************/
        
        if self.staffMode {
            self.ui_disposition = ["header" , "action_cell"]
        }else{
            if self.profile_self_mode { //DEFINITION DU MENU
                self.ui_disposition = ["header" , "classic_3",  "tableCell_p" ,"classic_4", "action_cell"]
            }else{
                self.ui_disposition = ["header" , "classic_3" ,"classic_4", "action_cell"]
            }
        }
        self.profile_info_data = [String:AnyObject]()
        self.tableView.reloadData()
        EZLoadingActivity.hide()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.mainTable {
            switch self.ui_disposition[indexPath.row] {
            case "tableCell_p" , "tableCell_n" :
                return 173
            default:
                return 113
            }
        }else{
            return 44
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.mainTable {
            return self.ui_disposition.count
        }else{
            return self.subTableData.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let index = indexPath.row
        var cell : UITableViewCell!

        
        if tableView == self.mainTable {
            let module = self.ui_disposition[index]
            
            switch module {
            case "header":
                let header_data = self.ui_construction_data["header"] as? [String : String]
                
                let cust_cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as! HeaderProfileCell
                
                if self.ui_construction_data["header"] != nil {
                    let url_pic = URL(string: (header_data?["etudiant_picture"])!)
                    cust_cell.imageProfile.kf.setImage(with: url_pic, placeholder: #imageLiteral(resourceName: "profile"), options: nil, progressBlock: nil, completionHandler: nil)
                    cust_cell.prenomLbl.text = (header_data?["prenom"])!
                    cust_cell.nomLbl.text = (header_data?["nom"])!
                    cust_cell.anneeLbl.text = (header_data?["curr_annee"])!
                    cust_cell.cityLbl.text = (header_data?["etudiant_city"])!
                    cust_cell.imageProfile.rounding_border(border_color: UIColor.black, border_size: nil)
                }
                cell = cust_cell
                break
            case "classic_3" , "classic_4" :
                let cust_cell = tableView.dequeueReusableCell(withIdentifier: module, for: indexPath) as! ClassicProfileCell_3
                if self.ui_construction_data[module] != nil {
                    let classic_3_data = self.ui_construction_data[module] as? [String]
                    cust_cell.mainContent.bordering_field(width: 1, color: UIColor.black, radius: 2)
                    cust_cell.stat1.text = classic_3_data![0]
                    cust_cell.stat2.text = classic_3_data![1]
                    cust_cell.stat3.text = classic_3_data![2]
                    if module == "classic_4" {
                        cust_cell.stat22.text = classic_3_data![3]
                    }
                }
                
                cell = cust_cell
                break
            case "action_cell" :
                let cust_cell = tableView.dequeueReusableCell(withIdentifier: module, for: indexPath) as! PlusActionsCell
                cust_cell.mainContent.bordering_field(width: 1, color: UIColor.black, radius: 2)
                cust_cell.buttonLeft.bordering_field(width: 1, color: nil, radius: 4)
                cust_cell.buttonMid.bordering_field(width: 1, color: nil, radius: 4)
                cust_cell.buttonRight.bordering_field(width: 1, color: nil, radius: 4)
                cust_cell.buttonRight.addTarget(self, action: #selector(sendEmailTo(sender:)), for: .touchUpInside)
                if !self.staffMode {
                    cust_cell.buttonMid.addTarget(self, action: #selector(goToBinome(sender:)), for: .touchUpInside)
                    cust_cell.buttonLeft.addTarget(self, action: #selector(goToNotes(sender:)), for: .touchUpInside)
                }else{
                    cust_cell.buttonMid.isEnabled = false
                    cust_cell.buttonLeft.isEnabled = false
                    cust_cell.buttonLeft.alpha = 0.5
                    cust_cell.buttonMid.alpha = 0.5
                }
                cell = cust_cell
                cell.backgroundColor = UIColor.clear
                break
            case "tableCell_p", "tableCell_n" :
                let cust_cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableCell
                let sub_table_data = self.ui_construction_data[module] as? [[String : String]]
                self.subTableData = sub_table_data!
                if module == "tableCell_p" {
                    cust_cell.titleLbl.text = "Projets"
                }else{
                    cust_cell.titleLbl.text = "Notes"
                }
                cust_cell.mainContent.bordering_field(width: 1, color: UIColor.black, radius: 2)
                cust_cell.tableProj.delegate = self
                cust_cell.tableProj.dataSource = self
                cust_cell.tableProj.reloadData()
                cell = cust_cell
                break
            default:
                break
            }
            cell.backgroundColor = UIColor.clear
        }else{
           let cust_cell = tableView.dequeueReusableCell(withIdentifier: "projetCell", for: indexPath) as! ProjetSubCell
            
            let data_cell = self.subTableData[indexPath.row]
            let title_txt = data_cell["title"]
            
            if data_cell["avancement"] != nil {
                var pourcentage = CGFloat((data_cell["avancement"]! as NSString).doubleValue)
                pourcentage = pourcentage / 100
                cust_cell.progressBar.progress = Float(pourcentage)
                
            }else{
                cust_cell.progressBar.isHidden = true
            }
            cust_cell.titleLbl.text = title_txt
            
            cell = cust_cell
            
        }
        
        return cell
    }
    
    func goToNotes(sender : UIButton) {
        self.navigationController?.MakeAnimationTouch(force: 2)
        self.performSegue(withIdentifier: Constantes.segues.PROFILE_TO_NOTES, sender: nil)
    }
    
    func goToBinome(sender : UIButton) {
        self.navigationController?.MakeAnimationTouch(force: 2)
        self.performSegue(withIdentifier: Constantes.segues.PROFILE_TO_BINOME, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.MakeAnimationTouch(force: 0)
        if tableView != self.mainTable {
            var viewControllersNew = self.navigationController?.viewControllers
            viewControllersNew?.removeAll()
            let LeaderBoardController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.LEADERBORD) as! LeaderBoard
            LeaderBoardController.LeaderProfileData = self.profile_info_mine
            LeaderBoardController.ArrivedFromIndexPath = indexPath
            viewControllersNew?.append(LeaderBoardController)
            self.navigationController?.setViewControllers(viewControllersNew!, animated: true)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segue_id = segue.identifier

        let profile_note = Constantes.segues.PROFILE_TO_NOTES
        let profile_binome = Constantes.segues.PROFILE_TO_BINOME
        
        switch segue_id {
        case profile_note? :
            let ProfileNotesView = segue.destination as! ProfileNoteViewController
            ProfileNotesView.header_data = self.ui_construction_data["header"] as! [String : String]
            ProfileNotesView.profile_login = self.profile_login
            break
        case profile_binome? :
            let ProfileBinomeView = segue.destination as! ProfileBinomesController
            ProfileBinomeView.header_data = self.ui_construction_data["header"] as! [String : String]
            ProfileBinomeView.profile_login = self.profile_login
            break
        default:
            break
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    //MARK: Mail Delegate
    
    func sendEmailTo(sender : UIButton) -> Void {
        self.navigationController?.MakeAnimationTouch(force: 2)
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([self.profile_login])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let message = Message(title: "Configurer les mails !", backgroundColor: UIColor.red)
        Whisper.show(whisper: message, to: (self.navigationController)!)
    }
  
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
       
}
