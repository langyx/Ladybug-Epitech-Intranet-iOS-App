//
//  ActiviteMain.swift
//  Ladybug
//
//  Created by Yannis Lang on 16/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import EZLoadingActivity

class ActivitieMain: UITableViewController {
    
    @IBOutlet weak var mainTable : UITableView!
    
    var ActivitieUrl = String()
    var ActivitePreRowNumber = 0
    var ActivitieData = [String:AnyObject]()
    var ActivitieEventData = [[String:AnyObject]]()
    var ActivitieMainTimelidePercent : Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTable.setBackground()
        self.mainTable.estimatedRowHeight = 120
        self.mainTable.rowHeight = UITableViewAutomaticDimension
        if !(self.ActivitieData.isEmpty) {
            self.ActivitePreRowNumber = 2
            self.title = self.ActivitieData["title"] as? String ?? "Sans titre"
        }else{
            EZLoadingActivity.show("Chargement...", disableUI: true)
            self.getActivitieData()
        }
    }
    
    func getActivitieData() -> Void {
        Alamofire.request(self.ActivitieUrl, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [String : AnyObject]
                        self.ActivitieData = JSON
                        self.ActivitieData.removeValue(forKey: "events")
                        self.ActivitieEventData = JSON["events"] as! [[String:AnyObject]]
//                        print(self.ActivitieEventData, self.ActivitieData)
                        self.title = self.ActivitieData["title"] as? String ?? "Sans titre"
                        self.ActivitePreRowNumber = 2
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
        return self.ActivitePreRowNumber + self.ActivitieEventData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.row {
        case 0:
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "headCell", for: indexPath) as! ActivitieCellHead
            let projetMode = self.ActivitieData["project_title"] as? String ?? ""

            cust_cell.progressBar.progress = self.ActivitieMainTimelidePercent
            cust_cell.dateDebut.text = self.ActivitieData["begin"] as? String ?? "Pas de date"
            cust_cell.dateFin.text = self.ActivitieData["end"] as? String ?? ""
            cust_cell.projetButton.bordering_field(width: 1, color: nil, radius: 4)
            if projetMode != "" {
                cust_cell.projetButton.isEnabled = true
                cust_cell.projetButton.addTarget(self, action: #selector(self.goToProject), for: .touchUpInside)
            }else{
                cust_cell.projetButton.alpha = 0.5
            }
            
            cell = cust_cell
            break
        case 1:
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "descrCell", for: indexPath) as! ActivitieCellDescr
            var description = self.ActivitieData["description"] as? String ?? "Aucune description..."
            if description == "" {
               description = "Aucune description..."
            }
            cust_cell.textDescr.text = description
            
            cell = cust_cell
            break
        default:
            let indexEvent = indexPath.row - 2
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! ActivitieCellEvents
            let eventData = self.ActivitieEventData[indexEvent]
            let sessionNumb = eventData["num_event"] as? String ?? "1"
            let sessionSeat = eventData["seats"] as? String ?? "Nd."
            
            cust_cell.titreSession.text = "Session \(sessionNumb)"
            cust_cell.dateFin.text = eventData["end"] as? String ?? "Nd."
            cust_cell.dateDebut.text = eventData["begin"] as? String ?? "Nd."
            cust_cell.participantInscrit.text = eventData["nb_inscrits"] as? String ?? "Nd."
            cust_cell.participantPotentiel.text = "\(sessionSeat) inscrits"
            cust_cell.nomSalle.text = eventData["location"] as? String ?? "Nd."
            
            cell = cust_cell
            break
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func goToProject() -> Void {
        let activitieProjectUrl = self.ActivitieUrl.replacingOccurrences(of: "/?format=json", with: "/project/?format=json")
        let activitieProjectUrlFile = self.ActivitieUrl.replacingOccurrences(of: "/?format=json", with: "/project/file/?format=json")
        print(activitieProjectUrl, activitieProjectUrlFile)
        
        self.navigationController?.MakeAnimationTouch(force: 2)
        let ProjectControllerView = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.PROJECT_VIEW) as! ProjectController
        ProjectControllerView.projectLink = activitieProjectUrl
        ProjectControllerView.projectProgressLine = self.ActivitieMainTimelidePercent
        ProjectControllerView.projectFileLink = activitieProjectUrlFile
        self.navigationController?.pushViewController(ProjectControllerView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.navigationController?.MakeAnimationTouch(force: 0)
        if indexPath.row > 1 {
            let sessionData = self.ActivitieEventData[indexPath.row - 2]
            let sessionCode = sessionData["code"] as? String ?? ""
            if sessionCode != "" {
                var sessionUrl  = self.ActivitieUrl
                sessionUrl = sessionUrl.replacingOccurrences(of: "?format=json", with: "\(sessionCode)/registered/?format=json")
                let SessionController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.ACTIVITIE_SESSION) as! ActivitieSessionRegistered
                SessionController.ActivitieSessionUrl = sessionUrl
                SessionController.title = "Session \(indexPath.row - 1)"
                self.navigationController?.pushViewController(SessionController, animated: true)
            }
        }
    }
}
