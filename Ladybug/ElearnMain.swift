//
//  ElearnMain.swift
//  Ladybug
//
//  Created by Yannis Lang on 06/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Whisper
import EZLoadingActivity

class ElearnMain: UITableViewController {
    
    var EData = [[String:AnyObject]]()
    
    var SelectedModuleData = [String : AnyObject]()
    var SelectedModuleCourseData = [[String : AnyObject]]()
    var SelectedModuleCourseRessourcesData = [[String : AnyObject]]()
    
    var SelectedSemestre = -1
    var SelectedModule = -1
    var SelectedCours = -1
    var Step = 0 //0 : Semestre ; 1 : Module ; 2 : Cours ; 3 : Ressource
    
    var backButton = UIBarButtonItem()
    
    @IBOutlet weak var mainTable : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.navigationBar.barTintColor = UIColor.black
//        self.navigationController?.navigationBar.isTranslucent = true
        
        self.mainTable.tableFooterView = UIView()
        
        self.title = "Elearning"
        self.addNavMenu(title: "ELearning")
        
        self.navigationItem.hidesBackButton = true
        backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(gestNavigationViaButton))
        self.navigationItem.leftBarButtonItem = backButton
        backButton.isEnabled = false
        
        getEData()
    }
    
    func gestNavigationViaButton() -> Void {
        self.navigationController?.MakeAnimationTouch(force: 0)
        switch self.Step {
        case 1:
            self.Step = 0
            self.backButton.title = ""
            self.backButton.isEnabled = false
            break
        case 2:
            self.Step = 1
            self.backButton.title = "< Semestres"
            self.backButton.isEnabled = true
            break
        case 3:
            self.Step = 2
            self.backButton.title = "< Modules"
            self.backButton.isEnabled = true
            break
        case 4:
            self.Step = 3
            self.backButton.title = "< Cours"
            self.backButton.isEnabled = true
        default:
            break
        }
        self.mainTable.reloadData()
    }
    
    func getEData() -> Void {
        
        EZLoadingActivity.show("Chargement...", disableUI: true)
        
        let urlE = Constantes.elearning.url.main
        
        Alamofire.request(urlE, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [[String : AnyObject]]
                        self.EData = JSON
                        print(self.EData)
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
        return 96
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.Step {
        case 0:
            return self.EData.count
        case 1:
            return self.SelectedModuleData.count
        case 2:
            return self.SelectedModuleCourseData.count
        case 3:
            return self.SelectedModuleCourseRessourcesData.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        let index = indexPath.row
        
        switch self.Step {
        case 0:
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "classicCell", for: indexPath) as! ElearnClassicCell
            let semestre_title = String(self.EData[index]["semester"] as! Int)
            cust_cell.title.text = "Semestre \(semestre_title)"
            cust_cell.subTitle.isHidden = true
            cell = cust_cell
           break
        case 1:
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "classicCell", for: indexPath) as! ElearnClassicCell
            let module_title = Array(self.SelectedModuleData.values)[index]["title"] as! String
            cust_cell.title.text = module_title
            cust_cell.subTitle.isHidden = true
            cell = cust_cell
            break
        case 2:
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "classicCell", for: indexPath) as! ElearnClassicCell
            let Course_data = self.SelectedModuleCourseData[indexPath.row]
            cust_cell.title.text = Course_data["title"] as? String ?? "Aucun Titre"
            cust_cell.subTitle.isHidden = true
            cell = cust_cell
            break
        case 3:
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "classicCell", for: indexPath) as! ElearnClassicCell
            let Ressources_data = self.SelectedModuleCourseRessourcesData[indexPath.row]
            let Ressources_Step_data = Ressources_data["step"] as! [String:AnyObject]
            cust_cell.title.text = Ressources_data["title"] as? String ?? "Aucun Titre"
            cust_cell.subTitle.isHidden = false
            let Ressources_Full_Path = Ressources_Step_data["fullpath"] as? String ?? "Aucun Path"
            var extensionStr = Ressources_Full_Path.getExtension()
            if extensionStr == "" {
                if Ressources_Full_Path.verifyUrl() == true {
                    extensionStr = "Site Internet"
                }
            }
            cust_cell.subTitle.text = extensionStr
             cell = cust_cell
            break
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.MakeAnimationTouch(force: 1)
        
        switch self.Step {
        case 0:
            self.SelectedSemestre = indexPath.row
            self.SelectedModuleData = self.EData[self.SelectedSemestre]["modules"] as! [String:AnyObject]
            self.Step = 1
            self.backButton.title = "< Semestres"
            self.backButton.isEnabled = true
            self.mainTable.reloadData()
            return
        case 1:
            self.SelectedModule = indexPath.row
            self.SelectedModuleCourseData = Array(self.SelectedModuleData.values)[self.SelectedModule]["classes"] as! [[String:AnyObject]]
            self.Step = 2
            self.backButton.title = "< Modules"
            self.backButton.isEnabled = true
            self.mainTable.reloadData()
            return
        case 2:
            self.SelectedCours = indexPath.row
            self.SelectedModuleCourseRessourcesData =  self.SelectedModuleCourseData[self.SelectedCours]["steps"] as! [[String:AnyObject]]
            self.Step = 3
            self.backButton.title = "< Cours"
            self.backButton.isEnabled = true
            self.mainTable.reloadData()
            return
        case 3:
            let Ressources_data = self.SelectedModuleCourseRessourcesData[indexPath.row]
            let Ressource_title = Ressources_data["title"] as? String ?? "Aucune Titre"
            let Ressources_Step_data = Ressources_data["step"] as! [String:AnyObject]
            let Ressource_Path = Ressources_Step_data["fullpath"] as? String ?? "Aucun fichier valide"
            let Path_Extension = Ressource_Path.getExtension()
            self.checkingAndGoingToReader(Ressource_Path: Ressource_Path, Ressource_title: Ressource_title, Path_Extension: Path_Extension)
            return
        default:
            return
        }

    }
}
