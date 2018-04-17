//
//  ModuleMain.swift
//  Ladybug
//
//  Created by Yannis Lang on 24/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import EZLoadingActivity

class ModuleMain: UITableViewController {
    
    @IBOutlet weak var mainTable : UITableView!
    var ModuleUrl = String()
    var ModuleProgress = Float()
    var ModuleData = [String:AnyObject]()
    var ModuleActivities = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTable.setBackground()
        self.mainTable.estimatedRowHeight = 120
        self.mainTable.rowHeight = UITableViewAutomaticDimension
        EZLoadingActivity.show("Chargement...", disableUI: true)
        self.getModuleData()
        
        
    }
    
    func getModuleData() -> Void {
        Alamofire.request(self.ModuleUrl, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [String : AnyObject]
                        self.ModuleData = JSON
                        self.ModuleActivities = JSON["activites"] as! [[String:AnyObject]]
                        self.title = self.ModuleData["title"] as? String ?? "Module"
                        self.ModuleData.removeValue(forKey: "activites")
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + self.ModuleActivities.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.row {
        case 0:
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "headCell", for: indexPath) as! ModuleCellHead
            
            cust_cell.progressBar.progress = self.ModuleProgress
            cust_cell.dateFin.text = self.ModuleData["end"] as? String ?? "Nd."
            cust_cell.dateDebut.text = self.ModuleData["begin"] as? String ?? "Nd."
            cust_cell.credits.text = String("\(self.ModuleData["credits"] as? Int ?? 0) crédits")
            cust_cell.codeModule.text = "(\(self.ModuleData["codemodule"] as? String ?? "Code Nd."))"
            cust_cell.grade.text = self.ModuleData["student_grade"] as? String ?? "En cours"
            cust_cell.grade.ApplyGradeColor()
            cust_cell.grade.badgeIt(bg_color: UIColor.black)
            cust_cell.projetButton.bordering_field(width: 1, color: nil, radius: 4)
            cust_cell.projetButton.addTarget(self, action: #selector(self.goToAllRegistered), for: .touchUpInside)
            
            cell = cust_cell
            break
        case 1:
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "descrCell", for: indexPath) as! ActivitieCellDescr
            cust_cell.textDescr.text = self.ModuleData["description"] as? String ?? "Aucune description"
            cell = cust_cell
            break
        default:
            let indexEvent = indexPath.row - 2
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "activCell", for: indexPath) as! ModuleCellActivitie
            let ActivitieData = self.ModuleActivities[indexEvent]
            let BeginActi = ActivitieData["begin"] as? String ?? ""
            let BeginDataTrimmed = BeginActi.range(of: " ")?.lowerBound
            
            
            cust_cell.titre.text = ActivitieData["title"] as? String ?? "Sans titre"
            cust_cell.sousTitre.text = "\(ActivitieData["type_title"] as? String ?? "Nd.") (\(BeginActi.substring(to: BeginDataTrimmed!)))"
            
            let dateFormat = "yyyy-MM-dd HH:mm:ss"
            var beginDateStr = Date()
            beginDateStr.getStringDate(dateStr: BeginActi, dateFormat: dateFormat)
            var endDateStr = Date()
            endDateStr.getStringDate(dateStr: (ActivitieData["end"] as? String ?? ""), dateFormat: dateFormat)
            let todayDateStr = Date()
            print(beginDateStr, endDateStr, todayDateStr, "avancement == ", todayDateStr.getAvancement(start: beginDateStr, end: endDateStr))
            let EventAvancement = todayDateStr.getAvancement(start: beginDateStr, end: endDateStr)
            self.ModuleActivities[indexEvent]["myavancement"] = EventAvancement as AnyObject
            cust_cell.progressBar.progress = EventAvancement
            
            cell = cust_cell
            break
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row > 1 {
            let indexActivitie = indexPath.row - 2
            var ActivitieData = self.ModuleActivities[indexActivitie]
            let ActivitieEvents = ActivitieData["events"] as! [[String:AnyObject]]
            ActivitieData.removeValue(forKey: "events")
            
            var urlActi = Constantes.url.activitie
            urlActi = urlActi.replacingOccurrences(of: "{year}", with: self.ModuleData["scolaryear"] as? String ?? "")
            urlActi = urlActi.replacingOccurrences(of: "{module}", with: self.ModuleData["codemodule"] as? String ?? "")
            urlActi = urlActi.replacingOccurrences(of: "{city}", with: self.ModuleData["codeinstance"] as? String ?? "")
            urlActi = urlActi.replacingOccurrences(of: "{acti}", with: ActivitieData["codeacti"] as? String ?? "")
            
            
            let activitieController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.ACTIVITIE_VIEW) as! ActivitieMain
            activitieController.ActivitieData = ActivitieData
            activitieController.ActivitieUrl = urlActi
//            print(urlActi)
            activitieController.ActivitieEventData = ActivitieEvents
            activitieController.ActivitieMainTimelidePercent = (ActivitieData["myavancement"] as! Float) / 100
            self.navigationController?.pushViewController(activitieController, animated: true)
        }
    }
    
    func goToAllRegistered() -> Void {
        self.navigationController?.MakeAnimationTouch(force: 2)
        let SessionController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.ACTIVITIE_SESSION) as! ActivitieSessionRegistered
        var AllRegUrl = self.ModuleUrl
        AllRegUrl = AllRegUrl.replacingOccurrences(of: "?format=json", with: "registered?format=json")
        SessionController.ActivitieSessionUrl = AllRegUrl
        SessionController.title = "Inscrits"
        self.navigationController?.pushViewController(SessionController, animated: true)
    }
}
