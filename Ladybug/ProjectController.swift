//
//  ProjectController.swift
//  Ladybug
//
//  Created by Yannis Lang on 11/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import EZLoadingActivity

class ProjectController: UITableViewController {
    
    var projectLink : String!
    var projectFileLink : String!
    var projectProgressLine : Float!
    
    var projetData = [String:AnyObject]()
    var projetGroupData = [[String:AnyObject]]()
    var projectFileData = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 140
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setBackground()
        
        EZLoadingActivity.show("Chargement...", disableUI: true)
        self.getProjectData()
    }
    
    func getProjectData() -> Void {
        Alamofire.request(self.projectLink, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [String : AnyObject]
                        self.projetData = JSON
                        self.projetGroupData = self.projetData["registered"] as! [[String:AnyObject]]
                        self.projetData.removeValue(forKey: "registered")
                        self.projetData.removeValue(forKey: "notregistered")
                        self.getProjetFileData()
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
    
    func getProjetFileData() -> Void {
        Alamofire.request(self.projectFileLink, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as? [[String : AnyObject]]
                        if JSON != nil {
                            self.projectFileData = JSON!
                        }
                        self.title = self.projetData["project_title"] as? String ?? "Aucun titre"
                        self.tableView.reloadData()
//                        print("info == ", self.projetData, "file == ", self.projectFileData, "group ==", self.projetGroupData)
                    }
                }
                EZLoadingActivity.hide()
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
        return 2 + self.projectFileData.count + self.projetGroupData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if case indexPath.row = 0 {
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "HeadCell", for: indexPath) as! ProjectHeadCell
            
            let inscrMax = self.projetData["end_register"] as? String ?? ""
            let inscrTxt = "Inscription jusqu'au \(inscrMax)"
            
            let overDay = self.projetData["over"] as? Int ?? 0
            var overDayText = String()
            if overDay < 0 {
                overDayText = "Terminé depuis \(String(-overDay)) jours !"
            }else{
                overDayText = "Se termine dans \(String(overDay)) jours !"
            }
            
            let studentMin = self.projetData["nb_min"] as? Int ?? 1
            let studentMax = self.projetData["nb_max"] as? Int ?? 1
            var studentCountTxt = String()
            if studentMax == 1 {
                studentCountTxt = "Projet individuel"
            }else{
                studentCountTxt = "Groupe de \(studentMin) à \(studentMax) étudiants"
            }
            
            cust_cell.numbStudent.text = studentCountTxt
            cust_cell.endCount.text = overDayText
            cust_cell.dateInscription.text = inscrTxt
            cust_cell.titreLabel.text = self.projetData["module_title"] as? String ?? "Module Inconnu"
            cust_cell.dateDebut.text = self.projetData["begin"] as? String ?? ""
            cust_cell.dateFin.text = self.projetData["end"] as? String ?? ""
            cust_cell.progressView.progress = self.projectProgressLine
            cust_cell.mainContent.applyPlainShadow()
            
            cell = cust_cell
        }else if case indexPath.row = 1 {
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "descrCell", for: indexPath) as! ActivitieCellDescr
            
            cust_cell.textDescr.text = self.projetData["description"] as? String ?? "Aucune description"
            if cust_cell.textDescr.text == "" {
                cust_cell.textDescr.text = "Aucune description"
            }
            
            cell = cust_cell
        }else if self.projectFileData.count > 0, case 2 ... self.projectFileData.count + 1 = indexPath.row {
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! ProjectFileCell
            
            let file_index = indexPath.row - 2
            let fileData = self.projectFileData[file_index]
            let fileFullPath = fileData["fullpath"] as? String ?? "Fichier invalide"
            let fileExtension = fileFullPath.getExtension().capitalized
            //fileFullPath = "\(Constantes.url.base)\(fileFullPath)"
            let fileUpdate = fileData["mtime"] as? String ?? "Nd."
            
            cust_cell.fileName.text = fileData["title"] as? String ?? "Aucun Titre"
            
            cust_cell.fileExt.text = fileExtension
            cust_cell.fileExt.textColor = UIColor.white
            cust_cell.fileExt.sizeToFit()
            cust_cell.fileExt.backgroundColor = UIColor.black
            cust_cell.fileExt.clipsToBounds = true
            cust_cell.fileExt.layer.cornerRadius = 3
            
            cust_cell.fileUp.text = "Màj : \(fileUpdate)"
            cust_cell.mainContent.applyPlainShadow()
            
            cell = cust_cell
        }else{
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! ProjectStudentCell
            
            let student_index = indexPath.row - 2 - self.projectFileData.count
            let studentData = self.projetGroupData[student_index]
            let studentMasterData = studentData["master"] as! [String:AnyObject]
            let studentGroupData = studentData["members"] as! [[String:AnyObject]]
            
            let studentPicture = studentMasterData["picture"] as? String
            let studentStatus = studentMasterData["status"] as? String
            
            var studentFullGroup = studentMasterData["title"] as? String
            for student in studentGroupData {
                let studentTitle = student["title"] as? String ?? ""
                studentFullGroup?.append(", \(studentTitle)")
            }
            
            cust_cell.titleGroup.text = studentData["title"] as? String ?? "Aucun Titre"
            cust_cell.studentList.text  = studentFullGroup
            cust_cell.picture.kf.setImage(with: (NSURL(string: studentPicture!) as! URL))
            if studentStatus == "confirmed" {
                cust_cell.picture.rounding_border(border_color: UIColor.green, border_size: 1)
            }else{
                cust_cell.picture.rounding_border(border_color: UIColor.red, border_size: 1)
            }
            cell = cust_cell
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.projectFileData.count > 0, case 2 ... self.projectFileData.count + 1 = indexPath.row {
            let file_index = indexPath.row - 2
            let fileData = self.projectFileData[file_index]
            var fileFullPath = fileData["fullpath"] as? String ?? ""
            let fileTitle = fileData["title"] as? String ?? "Aucun Titre"
            let fileExtension = fileFullPath.getExtension()
            fileFullPath = "\(Constantes.url.base)\(fileFullPath)"
            self.checkingAndGoingToReader(Ressource_Path: fileFullPath, Ressource_title: fileTitle, Path_Extension: fileExtension)
        }
    }
    
}
