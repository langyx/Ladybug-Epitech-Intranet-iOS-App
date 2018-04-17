//
//  Leaderboard.swift
//  Ladybug
//
//  Created by Yannis Lang on 08/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Kingfisher
import EZLoadingActivity

class LeaderBoard: UITableViewController {
    
    var LeaderNoteData = [[String:AnyObject]]()
    var LeaderProjetData = [[String:AnyObject]]()
    var LeaderModuleData = [[String:AnyObject]]()
    var LeaderActiviteData = [[String:AnyObject]]()
    var LeaderNewsData = [[String:AnyObject]]()
    
    var LeaderMode = 0 // 0 : Projet ; 1 : Note ; 2: Module ; 3: News ; 4: Activité
    
    //Arrived from antoher Controller
    var LeaderProfileData : [String:AnyObject]?
    var ArrivedFromIndexPath : IndexPath?
    
    @IBOutlet weak var mainTable : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EZLoadingActivity.show("Chargement...", disableUI: true)
        self.getLeaderData()
        
        self.title = "Leaderboard"
        self.addNavMenu(title: "Leaderboard")
        self.mainTable.setBackground()
    }
    
   @IBAction func MenuChange(sender : UISegmentedControl) -> Void {
        self.LeaderMode = sender.selectedSegmentIndex
        self.mainTable.reloadData()
        self.navigationController?.MakeAnimationTouch(force: 2)
    }

    func getLeaderData() -> Void {
        
        if self.LeaderProfileData != nil {
            let board = self.LeaderProfileData!["board"] as! [String:AnyObject]
            self.LeaderNoteData = board["notes"] as! [[String:AnyObject]]
            self.LeaderModuleData = board["modules"] as! [[String:AnyObject]]
            self.LeaderProjetData = board["projets"] as! [[String:AnyObject]]
            self.LeaderActiviteData = board["activites"] as! [[String:AnyObject]]
            self.LeaderNewsData = self.LeaderProfileData!["history"] as! [[String:AnyObject]]
            self.mainTable.reloadData()
            self.mainTable.scrollToRow(at: self.ArrivedFromIndexPath!, at: UITableViewScrollPosition.top, animated: true)
            EZLoadingActivity.hide()
        }else{
            let url_Leader = Constantes.url.url_connexion_home
            
            Alamofire.request(url_Leader, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let result = response.result.value {
                            let JSON = result as! [String : AnyObject]
                            let board = JSON["board"] as! [String:AnyObject]
                            
                            self.LeaderNoteData = board["notes"] as! [[String:AnyObject]]
                            self.LeaderModuleData = board["modules"] as! [[String:AnyObject]]
                            self.LeaderProjetData = board["projets"] as! [[String:AnyObject]]
                            self.LeaderActiviteData = board["activites"] as! [[String:AnyObject]]
                            self.LeaderNewsData = JSON["history"] as! [[String:AnyObject]]
                            self.mainTable.reloadData()
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
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.LeaderMode {
        case 0:
            return self.LeaderProjetData.count
        case 1:
            return self.LeaderNoteData.count
        case 2:
            return self.LeaderModuleData.count
        case 3:
            return self.LeaderNewsData.count
        case 4:
            return self.LeaderActiviteData.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.LeaderMode {
        case 1:
            return 102
        default:
            return 118
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let index = indexPath.row
        
        switch self.LeaderMode {
        case 0, 2, 4: // Projet // Module
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "ClassicProgressCell", for: indexPath) as! LeaderClassicProgressCell
            var ProjetData = [String:AnyObject]()
            if self.LeaderMode == 0 {
                ProjetData = self.LeaderProjetData[index]
            }else if self.LeaderMode == 2{
                ProjetData = self.LeaderModuleData[index]
            }else{
                ProjetData = self.LeaderActiviteData[index]
            }
            
            if self.LeaderMode == 4 {
                 cust_cell.titreLabel.text = "\(ProjetData["title"] as? String ?? "Aucun Titre") (\(ProjetData["salle"] as? String ?? "Aucune salle"))"
            }else{
                cust_cell.titreLabel.text = ProjetData["title"] as? String ?? "Aucun Titre"
            }
            cust_cell.dateDebut.text = ProjetData["timeline_start"] as? String
            cust_cell.dateFin.text = ProjetData["timeline_end"] as? String
            let InscriptionMax =  ProjetData["date_inscription"] as? String ?? ""
            if InscriptionMax == "" {
                cust_cell.dateInscription.isHidden = true
            }else{
                cust_cell.dateInscription.text = "Inscription jusqu'au \(InscriptionMax)"
                cust_cell.dateInscription.isHidden = false
            }
            
            let progressString = ProjetData["timeline_barre"] as? String ?? "100"
            cust_cell.progressView.progress = Float(progressString)! / 100
            cust_cell.mainContent.applyPlainShadow()
            
            cell = cust_cell
            break
        case 1: //Note
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "ClassicNoteCell", for: indexPath) as! LeaderClassicNoteCell
            let NoteData = self.LeaderNoteData[index]
            let NoteCorrecteur = NoteData["noteur"] as? String ?? ""
            let NoteCorrectionTxt = "Par \(NoteCorrecteur)"
            
            cust_cell.correcteur.text = NoteCorrectionTxt
            cust_cell.note.text = NoteData["note"] as? String ?? "Nd."
            cust_cell.titreLabel.text = NoteData["title"] as? String ?? "Aucun Titre"
            
            cell = cust_cell
            break
        case 3:
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "ClassicNewsCell", for: indexPath) as! LeaderClassicNewsCell
            let NewData = self.LeaderNewsData[index]
            let NewUserData = NewData["user"] as! [String:AnyObject]
            
            let NewTitle = NewData["title"] as? String ?? "Aucun Titre"
            let NewContent = NewData["content"] as? String ?? "Pas de Contenu"
            let NewDate = NewData["date"] as? String ?? "Date inconnue"
            let NewHtml = "<body style=\"background-color: transparent;\"> \(NewTitle)<br><br>\(NewContent)<br><br>Le \(NewDate)"
            cust_cell.webView.scrollView.bounces = false
            cust_cell.webView.layer.masksToBounds = false
            cust_cell.webView.applyPlainShadow()
            cust_cell.webView.loadHTMLString(NewHtml, baseURL: nil)
            
            let NewUserImage = NewUserData["picture"] as? String
            if NewUserImage != nil {
                let UserImageUrl = NSURL(string: NewUserImage!) as! URL
                cust_cell.picture.kf.setImage(with: UserImageUrl)
            }
            cust_cell.picture.rounding_border(border_color: UIColor.black, border_size: 1)
            
            let NewUserTitle = NewUserData["title"] as? String
            cust_cell.titreLabel.text = NewUserTitle
            
            cell = cust_cell
            break
        default:
            break
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        self.navigationController?.MakeAnimationTouch(force: 0)
        tableView.deselectRow(at: indexPath, animated: true)
        switch self.LeaderMode {
        case 0:
            let projetSelected = self.LeaderProjetData[index]
            let projetLink = projetSelected["title_link"] as! String
            let projetFullLink = "\(Constantes.url.base)\(projetLink)project/?format=json"
            let projetFileFullLink = "\(Constantes.url.base)\(projetLink)project/file/?format=json"
            let progressString = projetSelected["timeline_barre"] as? String ?? "100"
            
            let ProjectControllerView = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.PROJECT_VIEW) as! ProjectController
            ProjectControllerView.projectLink = projetFullLink
            ProjectControllerView.projectProgressLine = Float(progressString)! / 100
            ProjectControllerView.projectFileLink = projetFileFullLink
            self.navigationController?.pushViewController(ProjectControllerView, animated: true)
            break
        case 1:
            let noteSelected = self.LeaderNoteData[index]
            let noteSelectedAllLink = noteSelected["title_link"] as! String
            
            let noteSelectedController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.PROJECT_FULLNOTE_VIEW) as! ProjetFullNoteMain
            noteSelectedController.urlActivite = "\(Constantes.url.base)\(noteSelectedAllLink)"
            self.navigationController?.pushViewController(noteSelectedController, animated: true)
            break
        case 2:
            let moduleSelected = self.LeaderModuleData[index]
            let moduleLink = moduleSelected["title_link"] as? String ?? ""
            if moduleLink != "" {
                let moduleFullLink = "\(Constantes.url.base)\(moduleLink)?format=json"
                let moduleProgress = moduleSelected["timeline_barre"] as? String ?? "0"
                
                let moduleController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.MODULE_VIEW) as! ModuleMain
                moduleController.ModuleUrl = moduleFullLink
                moduleController.ModuleProgress = Float(moduleProgress)! / 100
                self.navigationController?.pushViewController(moduleController, animated: true)
            }
            break
        case 4:
            let activitieSelected = self.LeaderActiviteData[index]
            let activitieBaseLink = activitieSelected["title_link"] as! String
            let activtieFullLink = "\(Constantes.url.base)\(activitieBaseLink)?format=json"
            
            let activitieController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.ACTIVITIE_VIEW) as! ActivitieMain
            activitieController.ActivitieUrl = activtieFullLink
            activitieController.ActivitieMainTimelidePercent = Float(activitieSelected["timeline_barre"] as? String ?? "100")! / 100
            self.navigationController?.pushViewController(activitieController, animated: true)
            break
        default:
            break
        }
    }
    
}
