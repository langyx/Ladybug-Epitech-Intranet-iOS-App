//
//  ProfileNoteViewController.swift
//  Ladybug
//
//  Created by Yannis Lang on 27/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Whisper
import EZLoadingActivity

class ProfileNoteViewController: UITableViewController {
    
    var profile_login = String()
    var profile_login_epured = String()
    
    var header_data = [String : String]()
    
    var notes_data = [[String:AnyObject]]()
    var resume_data = [String:AnyObject]()
    
    var note_of_module = [[String : AnyObject]]()
    var all_note_of_note = [[[String : AnyObject]]]()
    var current_all_note_index = -1
    
    var module_mode = true
    
    @IBOutlet weak var mainTableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notes"
        self.mainTableView.setBackground()
        
        profile_login_epured = profile_login
        profile_login_epured.epureEmail()
        
        EZLoadingActivity.show("Chargement...", disableUI: true)
        getModuleData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //hiddingBarManager?.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //hiddingBarManager?.viewWillDisappear(animated)
    }
    
    func getModuleData() -> Void {
        let url = (Constantes.url.notes as NSString).replacingOccurrences(of: Constantes.url_key.urername, with: profile_login)
        
        Alamofire.request(url, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [String:AnyObject]
                        self.assigningDataCore(data: JSON)
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
    
    func assigningDataCore(data : [String : AnyObject]) -> Void {
        var modules_data = [[String:AnyObject]]()
        var notes_data = [[String:AnyObject]]()
        
        var acqui_Count = 0
        var a_Count = 0
        var b_Count = 0
        var c_Count = 0
        var d_Count = 0
        var e_Count = 0
        
        var total_note = 0
        
        modules_data = data["modules"] as! [[String:AnyObject]]
        notes_data = data["notes"] as! [[String:AnyObject]]
        
        for one_module in modules_data {
            var new_module = [String : AnyObject]()
            let module_code = one_module["codemodule"] as! String
            
            var new_module_note = [[String : AnyObject]]()
            total_note = 0
            for one_note in notes_data {
                let note_module_code = one_note["codemodule"] as! String
                if note_module_code == module_code {
                    total_note += 1
                    new_module_note.append(one_note)
                }
            }
            new_module["notes"] = new_module_note as AnyObject
            
            let new_module_grade = one_module["grade"] as! String
            
            switch new_module_grade {
            case "Acquis":
                acqui_Count += 1
                break
            case "A":
                a_Count += 1
                break
            case "B":
                b_Count += 1
                break
            case "C":
                c_Count += 1
                break
            case "D":
                d_Count += 1
                break
            case "Echec":
                e_Count += 1
                break
            default:
                break
            }
            
            new_module["annee"] = one_module["scolaryear"] as AnyObject
            new_module["code"] = one_module["codemodule"] as AnyObject
            new_module["titre"] = one_module["title"] as AnyObject
            new_module["grade"] = new_module_grade as AnyObject
            new_module["credits"] = one_module["credits"] as AnyObject
            new_module["totale_note"] = total_note as AnyObject
            
            var date_inscr = one_module["date_ins"] as! String
            date_inscr = date_inscr.replacingOccurrences(of: ":", with: "")
            date_inscr = date_inscr.replacingOccurrences(of: " ", with: "")
            date_inscr = date_inscr.replacingOccurrences(of: "-", with: "")
            new_module["date"] = date_inscr as AnyObject
            
            self.notes_data.append(new_module)
        }
        
        resume_data["acquis"] = acqui_Count as AnyObject
        resume_data["A"] = a_Count as AnyObject
        resume_data["B"] = b_Count as AnyObject
        resume_data["C"] = c_Count as AnyObject
        resume_data["D"] = d_Count as AnyObject
        resume_data["E"] = e_Count as AnyObject
        let totale_grade = a_Count + b_Count + c_Count + d_Count
            + e_Count + acqui_Count
        resume_data["totale"] = totale_grade as AnyObject
        resume_data["mode"] = 0 as AnyObject
        resume_data["acquisp"] = Int(CGFloat(acqui_Count) / CGFloat(totale_grade) * 100) as AnyObject
        resume_data["Ap"] = Int(CGFloat(a_Count) / CGFloat(totale_grade) * 100) as AnyObject
        resume_data["Bp"] = Int(CGFloat(b_Count) / CGFloat(totale_grade) * 100) as AnyObject
        resume_data["Cp"] = Int(CGFloat(c_Count) / CGFloat(totale_grade) * 100) as AnyObject
        resume_data["Dp"] = Int(CGFloat(d_Count) / CGFloat(totale_grade) * 100) as AnyObject
        resume_data["Ep"] = Int(CGFloat(e_Count) / CGFloat(totale_grade) * 100) as AnyObject
        
        self.notes_data.sort { (item1, item2) -> Bool in
            let date1 = Int(item1["date"] as! String)!
            let date2 = Int(item2["date"] as! String)!
            return date1 > date2
        }
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.mainTableView {
            if indexPath.row == 0 {
                return 113
            }else{
                if self.module_mode {
                    return 144
                }else{
                    if let note_disp = self.note_of_module[indexPath.row - 1]["disp"] as? Int {
                        if note_disp == 1 || note_disp == 2{
                            return 228
                        }
                    }
                    return 95
                }
            }
        }else{
            if let note_disp = self.all_note_of_note[self.current_all_note_index][indexPath.row]["disp"] as? Int {
                if note_disp == 1 {
                    return 228
                }
            }
            return 44
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.mainTableView {
            if self.module_mode {
                if self.resume_data.isEmpty {
                    return self.notes_data.count + 1
                }else{
                    return self.notes_data.count + 2
                }
            }else{
                return self.note_of_module.count + 1
            }
        }else{
            if self.current_all_note_index ==  -1 {
                return 0
            }
            return self.all_note_of_note[self.current_all_note_index].count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        let index = indexPath.row
        
        if tableView == self.mainTableView { //Table view module et note principales
            if index == 0 {
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
                if self.module_mode {
                    if index == 1 {
                        let cust_cell = tableView.dequeueReusableCell(withIdentifier: "resumeCell", for: indexPath) as! NoteResumeCell
                        //                    print("resume =", resume_data)
                        cust_cell.mainContent.bordering_field(width: 1, color: UIColor.black, radius: 2)
                        
                        let mode_resume = resume_data["mode"] as? Int
                        if mode_resume == 0 { //mode chiffre
                            cust_cell.gradeAcquis.text = String(resume_data["acquis"] as! Int)
                            cust_cell.gradeA.text = String(resume_data["A"] as! Int)
                            cust_cell.gradeB.text = String(resume_data["B"] as! Int)
                            cust_cell.gradeC.text = String(resume_data["C"] as! Int)
                            cust_cell.gradeD.text = String(resume_data["D"] as! Int)
                            cust_cell.gradeE.text = String(resume_data["E"] as! Int)
                        }else{ //mode pourcentage
                            cust_cell.gradeAcquis.text = "\(String(resume_data["acquisp"] as! Int))%"
                            cust_cell.gradeA.text = "\(String(resume_data["Ap"] as! Int))%"
                            cust_cell.gradeB.text = "\(String(resume_data["Bp"] as! Int))%"
                            cust_cell.gradeC.text = "\(String(resume_data["Cp"] as! Int))%"
                            cust_cell.gradeD.text = "\(String(resume_data["Dp"] as! Int))%"
                            cust_cell.gradeE.text = "\(String(resume_data["Ep"] as! Int))%"
                        }
                        
                        cell = cust_cell
                    }else{ //module
                        let cust_cell = tableView.dequeueReusableCell(withIdentifier: "moduleCell", for: indexPath) as! NoteModuleCell
                        let module_data = self.notes_data[index - 2]
                        //                    print("module data = ", module_data)
                        
                        cust_cell.mainContent.bordering_field(width: 1, color: UIColor.black, radius: 2)
                        cust_cell.annee.text = String(module_data["annee"] as! Int)
                        cust_cell.total_note.text = String(module_data["totale_note"] as! Int)
                        cust_cell.code_module.text = (module_data["code"] as! String)
                        cust_cell.credits.text = String(module_data["credits"] as! Int)
                        
                        let grade_data = module_data["grade"] as? String ?? "En cours"
                        cust_cell.grade.text = grade_data
                        cust_cell.grade.ApplyGradeColor()
                        cust_cell.grade.badgeIt(bg_color: UIColor.black)
                        
                        cust_cell.moduleName.text = (module_data["titre"] as! String)
                        cell = cust_cell
                    }
                }else{ // MODE NOTE
                    let this_note = self.note_of_module[index - 1]
                    let display_note = this_note["disp"] as? Int
                    
                    if  display_note == nil || display_note == 0 { // Mode chiffre
                        let cust_cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteNoteCell
                        cust_cell.note.text = String(this_note["final_note"] as! Int)
                        cust_cell.noteName.text = this_note["title"] as? String
                        cust_cell.mainContent.applyPlainShadow()
                        cell = cust_cell
                    }else if display_note == 1 { // Mode détail - commentaire
                        let cust_cell = tableView.dequeueReusableCell(withIdentifier: "noteDetailCell", for: indexPath) as! NoteDetailCell
                        
                        cust_cell.noteName.text = this_note["title"] as? String
                        var correcteur = this_note["correcteur"] as? String
                        if (correcteur?.isValidEmail())! {
                            correcteur?.epureEmail()
                        }
                        cust_cell.correcteur.text = correcteur
                        
                        cust_cell.commentaire.text = this_note["comment"] as? String
                        
                        cell = cust_cell
                    }else{ // Mode toutes les notes
                        let cust_cell = tableView.dequeueReusableCell(withIdentifier: "noteEleveCell", for: indexPath) as! NoteElveCell
                        cust_cell.noteName.text = this_note["title"] as? String
                        cust_cell.tableNote.delegate = self
                        cust_cell.tableNote.dataSource = self
                        
                        let annee = String(this_note["scolaryear"] as! Int)
                        let module = this_note["codemodule"] as? String
                        let ville = this_note["codeinstance"] as? String
                        let acti = this_note["codeacti"] as? String
                        
                        var url_all_notes = Constantes.url.student_note_acti
                        url_all_notes = (url_all_notes as NSString).replacingOccurrences(of: "{annee}", with: annee)
                        url_all_notes = (url_all_notes as NSString).replacingOccurrences(of: "{module}", with: module!)
                        url_all_notes = (url_all_notes as NSString).replacingOccurrences(of: "{ville}", with: ville!)
                        url_all_notes = (url_all_notes as NSString).replacingOccurrences(of: "{acti}", with: acti!)
                        
                        self.current_all_note_index = index - 1
                        
                        if !(self.all_note_of_note[self.current_all_note_index].isEmpty) {
                            cust_cell.tableNote.reloadData()
                        }else{
                            Alamofire.request(url_all_notes, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
                                
                                switch(response.result) {
                                case .success(_):
                                    if response.result.value != nil{
                                        if let result = response.result.value {
                                            var JSON = result as! [[String:AnyObject]]
                                            
                                            JSON.sort{ (item1, item2) -> Bool in
                                                let note1 = item1["note"] as! Int
                                                let note2 = item2["note"] as! Int
                                                return note1 > note2
                                            }
                                            
                                            self.all_note_of_note.insert(JSON, at: index - 1)
                                            cust_cell.tableNote.reloadData()
                                        }
                                    }
                                    break
                                    
                                case .failure(_):
                                    print(response.result.error!)
                                    break
                                }
                            }
                        }
                        
                        cell = cust_cell
                    }
                }
            }
        }else{ //Table view toutes les notes d'une note
            let one_note = self.all_note_of_note[self.current_all_note_index][index]
            let display_note = one_note["disp"] as? Int
            
            if  display_note == nil || display_note == 0 { // Mode chiffre
               let cust_cell = tableView.dequeueReusableCell(withIdentifier: "subNoteCell", for: indexPath) as! NoteSubEleveNote
                var login = one_note["login"] as! String
                login.epureEmail()
                
                cust_cell.login.text = login
                cust_cell.note.text = String(one_note["note"] as! Int)
                
//                if login == self.profile_login_epured {
//                    cust_cell.backgroundColor = UIColor.blue
//                }
                
                cell = cust_cell
            }else{ // Mode commentaire
                let cust_cell = tableView.dequeueReusableCell(withIdentifier: "noteDetailCell", for: indexPath) as! NoteDetailCell
                
                var correcteur = one_note["grader"] as? String
                if (correcteur?.isValidEmail())! {
                    correcteur?.epureEmail()
                }
                var login = one_note["login"] as! String
                login.epureEmail()
                
                cust_cell.noteName.text = login
                cust_cell.correcteur.text = correcteur
               
                let commentaire = one_note["comment"] as? String
                let commentaire_final = "Note Finale : \(String(one_note["note"] as! Int))\n\(commentaire!)"
                cust_cell.commentaire.text = commentaire_final
                
                cell = cust_cell
            }
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.MakeAnimationTouch(force: 0)
        if tableView == self.mainTableView {
            if self.module_mode {
                if indexPath.row > 0 {
                    if indexPath.row == 1 {
                        if resume_data["mode"] as? Int == 0 {
                            resume_data["mode"] = 1 as AnyObject?
                        }else{
                            resume_data["mode"] = 0 as AnyObject?
                        }
                        let resumeCell = NSIndexPath(row: 1, section: 0)
                        self.tableView.reloadRows(at: [resumeCell as IndexPath], with: UITableViewRowAnimation.top)
                    }else{
                        let selected_module = self.notes_data[indexPath.row - 2]
                        if selected_module["totale_note"] as! Int > 0 {
                            self.note_of_module = selected_module["notes"] as! [[String:AnyObject]]
                            for _ in self.note_of_module {
                                self.all_note_of_note.append([[String:AnyObject]]())
                            }
                            self.module_mode = false
                            self.title = selected_module["titre"] as? String
                            self.tableView.reloadData()
                            self.tableView.scrollToTop(animated: true)
                            self.navigationItem.hidesBackButton = true
                            let newBackButton = UIBarButtonItem(title: "< Modules", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backFromNotesToModules))
                            self.navigationItem.leftBarButtonItem = newBackButton
                        }else{
                            let message = Message(title: "Aucune note", backgroundColor: UIColor.red)
                            Whisper.show(whisper: message, to: (self.navigationController)!)
                        }
                    }
                }
            }else{
                let index = indexPath.row - 1
                
                if index + 1 > 0 {
                    let current_disp = self.note_of_module[index]["disp"] as? Int
                    if current_disp == nil || current_disp == 0 {
                        self.note_of_module[index]["disp"] = 1 as AnyObject?
                    }else if current_disp == 1{
                        self.note_of_module[index]["disp"] = 2 as AnyObject?
                    }else{
                        self.note_of_module[index]["disp"] = 0 as AnyObject?
                    }
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.top)
                }
            }
        }else{
            let index = indexPath.row
            
            let upcell = ((tableView.superview!).superview!).superview! as! NoteElveCell
            self.current_all_note_index = (findCurrentNoteInAllNote(title: upcell.noteName.text!))

            let current_disp = self.all_note_of_note[self.current_all_note_index][index]["disp"] as? Int
            if current_disp == nil || current_disp == 0 {
                self.all_note_of_note[self.current_all_note_index][index]["disp"] = 1 as AnyObject?
            }else{
                self.all_note_of_note[self.current_all_note_index][index]["disp"] = 0 as AnyObject?
            }
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.top)
        }
    }
    
    func findCurrentNoteInAllNote(title : String) -> Int {
        var index_resch = 0
//        print(title)
        for all_note in self.all_note_of_note {
            //print(all_note)
            if !(all_note.isEmpty) && all_note[0]["title"] as! String == title {
                return index_resch
            }
            index_resch += 1
        }
        return 0
    }
    
    func backFromNotesToModules() -> Void {
        self.navigationController?.MakeAnimationTouch(force: 0)
        self.module_mode = true
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = false
        self.tableView.reloadData()
        self.tableView.scrollToTop(animated: true)
        self.title = ""
    }
    
    
}
