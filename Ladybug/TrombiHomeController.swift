//
//  TrombiHomeController.swift
//  Ladybug
//
//  Created by Yannis Lang on 03/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import EZLoadingActivity
import AVFoundation

class TrombiHomeController: UITableViewController, UISearchBarDelegate, UIViewControllerPreviewingDelegate {
    
    let userDefaut = UserDefaults.standard
    
    var searchData = [[String:AnyObject]]()
    var searchRequest : Alamofire.Request?
    var SchoolsList = [[String:AnyObject]]()
    var StudentList = [[String:AnyObject]]()
    var MaxStudents = -1
    
    var SchoolSelected = -1
    var SchoolSelected_Title = String()
    var year = String()
    var PromoSelected = String()
    
    var newBackButton : UIBarButtonItem!
    var ClassementButton : UIBarButtonItem!
    
    var Step = 0 //0 : School 1 : promo 2 : Student 3 : recherche
    var Step_save = -1
    
    @IBOutlet weak var mainTable : UITableView!
    @IBOutlet weak var seachBar : UISearchBar!
 
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if self.Step != 2 && self.Step != 3 {
            return nil
        }
        
        guard let indexPath = self.mainTable.indexPathForRow(at: location) else { return nil }
        guard let cell = self.mainTable.cellForRow(at: indexPath) else { return nil }
        guard let profileVC = storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.PROFILE_VIEW) as? ProfileHomeController else { return nil }
        
        var student_data = [String:AnyObject]()
        if self.Step == 2 {
            student_data = self.StudentList[indexPath.row]

        }else{
            student_data = self.searchData[indexPath.row]
        }
        let login_Touched = student_data["login"] as! String
        let login_Self = userDefaut.string(forKey: Constantes.key_userdef.LOGIN_KEY)
        if login_Self == login_Touched {
            profileVC.profile_self_mode = true
        }else{
            profileVC.profile_login = login_Touched
        }
        profileVC.peekMode = true
        profileVC.preferredContentSize = CGSize(width: 0.0, height: 300.0)
        previewingContext.sourceRect = cell.frame
        
        return profileVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: self.mainTable)
        }
        
        self.mainTable.setBackground()
        self.title = "Etudiants"
        self.addNavMenu(title: "Etudiants")
       
        EZLoadingActivity.show("Chargement...", disableUI: true)
        self.getSchools()
        
        self.seachBar.delegate = self
        self.seachBar.setValue("Annuler", forKey: "_cancelButtonText")
        
        
        self.navigationItem.hidesBackButton = true
        newBackButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(gestionRetourViaButton))
        self.navigationItem.leftBarButtonItem = newBackButton
        newBackButton.isEnabled = false
        
        ClassementButton = UIBarButtonItem(title: "Classement", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goClassement))
        self.navigationItem.rightBarButtonItem = ClassementButton
        ClassementButton.isEnabled = false
        self.ClassementButton.tintColor = UIColor.clear
    }
    
    func goClassement() -> Void {
        self.navigationController?.MakeAnimationTouch(force: 0)
        if self.ClassementButton.title == "Classement" {
            //check du cache
            let cacheKey = "\(self.SchoolSelected)_\(self.PromoSelected)_\(self.year)"
            let studentClassedCachedObj = userDefaut.value(forKey: cacheKey)
//            print("export==", studentClassedCachedObj)
            if studentClassedCachedObj == nil {
                self.classementByUpdate()
            }else{
                let studentClassedCacheData = NSKeyedUnarchiver.unarchiveObject(with: studentClassedCachedObj as! Data)
                let cachedList = studentClassedCacheData as! [[String:AnyObject]]
                self.StudentList = cachedList
                self.mainTable.reloadData()
                self.ClassementButton.title = "Rafraichir"
            }
        }else{
            self.ClassementButton.title = "Classement"
            self.ClassementButton.isEnabled = false
            self.ClassementButton.tintColor = UIColor.clear
            self.classementByUpdate()
        }
    }
    
    func classementByUpdate() -> Void {
        let table_Rect = self.mainTable.frame
        let waitingView = UIView(frame: CGRect(x: 0, y: 0, width: table_Rect.width, height: table_Rect.height + self.seachBar.frame.height))
        waitingView.setBackgroundView()
        self.view.addSubview(waitingView)
        let labelWaiting = UILabel(frame: CGRect(x: 0, y: (waitingView.frame.size.height / 2) - 15, width: waitingView.frame.size.width, height: 30))
        labelWaiting.textAlignment = .center
        labelWaiting.font = UIFont(name: "Helvetica Neue", size: 17.0)
        labelWaiting.textColor = UIColor.white
        waitingView.addSubview(labelWaiting)
        
        self.mainTable.isScrollEnabled = false
        self.mainTable.scrollToTop(animated: true)
        self.ClassementButton.isEnabled = false
        self.ClassementButton.tintColor = UIColor.clear
        self.newBackButton.isEnabled = false
        self.newBackButton.tintColor = UIColor.clear
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
//        print(self.MaxStudents)
        
        if self.MaxStudents > self.mainTable.numberOfRows(inSection: 0) {
            labelWaiting.text = "Téléchargement des profiles manquants"
            DownloadAllStudentLoop(offset: self.mainTable.numberOfRows(inSection: 0)) {_ in
                self.getAllGpa(waitingView : waitingView, labelWaiting: labelWaiting)
            }
        }else{
            self.getAllGpa(waitingView : waitingView, labelWaiting: labelWaiting)
        }
    }
    
    func getAllGpa(waitingView : UIView, labelWaiting : UILabel) -> Void {
        let myGroup = DispatchGroup()
        
        labelWaiting.text = "Téléchargement des gpa"
        let progressBar = UIProgressView(frame: CGRect(x: 20, y: labelWaiting.frame.maxY + 10, width: labelWaiting.frame.width - 40, height: 30))
        waitingView.addSubview(progressBar)
        
        
        for (index, studen) in self.StudentList.enumerated() {
            myGroup.enter()
            let studend_login = studen["login"] as! String
            
            var url_profile = Constantes.url.profile
            url_profile = url_profile.replacingOccurrences(of: "{user}", with: studend_login)
            var request = URLRequest(url: NSURL.init(string: url_profile)! as URL)
            request.httpMethod = "GET"
            request.timeoutInterval = 250 // Set your timeout interval here.
            
            Alamofire.request(request).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let result = response.result.value {
                            let JSON = result as! [String : AnyObject]
                            let gpa_table = JSON["gpa"] as! [[String:AnyObject]]
                            let student_gpa = gpa_table[0]["gpa"] as! String
//                            print("#", index, student_gpa, self.StudentList[index]["title"] as! String)
                            progressBar.progress = Float(CGFloat(index) / CGFloat(self.MaxStudents))
                            print("#", Float(CGFloat(index) / CGFloat(self.MaxStudents)))
                            self.StudentList[index]["gpa"] = student_gpa as AnyObject
                            myGroup.leave()
                        }
                    }
                    break
                    
                case .failure(_):
                    print(response.result.error!)
                    myGroup.leave()
                    break
                }
            }
            
//            print("task #", index)
        }
        myGroup.notify(queue: DispatchQueue.main, execute: {
//            print("END")
//            print(self.StudentList)
            labelWaiting.text = "Tri des étudiants"
            self.StudentList.sort(by: { (item1, item2) -> Bool in
//                print("#item", item1, item2)
                let gpa1 = (item1["gpa"] as! NSString).doubleValue
                let gpa2 = (item2["gpa"] as! NSString).doubleValue
                return gpa1 > gpa2
            })
            
            //mise en cache
            let cacheKey = "\(self.SchoolSelected)_\(self.PromoSelected)_\(self.year)"
            let archiveData = NSKeyedArchiver.archivedData(withRootObject: self.StudentList)
            print("archive data ==", archiveData)
            self.userDefaut.set(archiveData, forKey: cacheKey)
            
            self.mainTable.reloadData()
            self.mainTable.isScrollEnabled = true
            self.newBackButton.isEnabled = true
            self.newBackButton.tintColor = UIColor.white
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            progressBar.removeFromSuperview()
            labelWaiting.removeFromSuperview()
            waitingView.removeFromSuperview()
        })
    }
    
    func DownloadAllStudentLoop(offset : Int, completionHandler : @escaping (Int) -> ()) -> Void {
        self.DownloadSutdent(at: offset) { data, error in
            if error == nil {
                self.StudentList.append(contentsOf: data as! [[String:AnyObject]])
                if self.StudentList.count < self.MaxStudents {
                    self.DownloadAllStudentLoop(offset: self.StudentList.count){_ in
                        completionHandler(1)
                    }
//                    print("encore")
                }else{
//                    print("le compte est bon")
//                    self.mainTable.reloadData()
                    completionHandler(1)
                }
            }
        }
    }
    
    func DownloadSutdent(at offset: Int, completionHandler: @escaping (AnyObject?, String?) -> ()) -> Void {
        var url_student = Constantes.tromby.url.student_list
        url_student = url_student.replacingOccurrences(of: "{city}", with: self.SchoolSelected_Title)
        url_student = url_student.replacingOccurrences(of: "{year}", with: self.year)
        url_student = url_student.replacingOccurrences(of: "{promo}", with: self.PromoSelected)
        url_student = url_student.replacingOccurrences(of: "{offset}", with: String(offset))
        
        print(url_student)
        
        self.AlamofireNeedToBeFucked(url: url_student, completionHandler: completionHandler)
    }
    
    func AlamofireNeedToBeFucked(url : String, completionHandler: @escaping (AnyObject?, String?) -> ()) -> Void {
        Alamofire.request(url, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [String : AnyObject]
                        let student_data = JSON["items"] as! [[String:AnyObject]]
                        
                        completionHandler(student_data as AnyObject, nil)
                    }
                }
                break
                
            case .failure(_):
                print(response.result.error!)
                completionHandler(nil, "Error")
                break
            }
        }
    }

    func gestionRetourViaButton() -> Void {
        if self.Step == 1 {
            self.Step = 0
            self.SchoolSelected = -1
            self.SchoolSelected_Title = ""
            
            self.newBackButton.title = ""
            self.newBackButton.isEnabled = false
            
            self.ClassementButton.isEnabled = false
            
            self.tableView.reloadData()
        }else if self.Step == 2 {
            self.Step = 1
            self.PromoSelected = ""
            
            newBackButton.isEnabled = true
            newBackButton.title = "< Villes"
            self.ClassementButton.isEnabled = false
            
            self.StudentList = [[String:AnyObject]]()
            
            self.tableView.reloadData()
        }else{
            self.seachBar.endEditing(true)
            self.seachBar.text = ""
            self.Step = self.Step_save
            self.Step_save = -1
            self.ClassementButton.isEnabled = true
            switch self.Step {
            case 0:
                self.newBackButton.isEnabled = false
                self.newBackButton.title = ""
                break
            case 1 :
                self.newBackButton.isEnabled = true
                self.newBackButton.title = "< Villes"
            case 2 :
                self.newBackButton.isEnabled = true
                self.newBackButton.title = "< Promos"
            default:
                break
            }
            self.mainTable.reloadData()
        }
        self.navigationController?.MakeAnimationTouch(force: 0)
    }

    func getSchools() -> Void {
        let url_schools = Constantes.tromby.url.schools
        
        Alamofire.request(url_schools, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        var JSON = result as! [[String:String]]
                        
                        JSON.sort{ (item1, item2) -> Bool in
                            let note1 = item1["title"]
                            let note2 = item2["title"]
                            return note1! < note2!
                        }
                        self.SchoolsList = JSON as [[String : AnyObject]]
                        self.getSchoolYear()
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
    
    func getSchoolYear() -> Void {
        var url_year = Constantes.tromby.url.years
        let first_school_code = self.SchoolsList[0]["code"]!
        url_year = url_year.replacingOccurrences(of: "{city}", with: first_school_code as! String)
//        print(url_year)
        Alamofire.request(url_year, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        var JSON = result as! [[String:String]]
                        
                        let first = JSON[JSON.count - 1]
                        self.year = first["scolaryear"]!
                        self.getAllPromo()
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
    
    func getAllPromo() -> Void {
        
        //let last_index = self.SchoolsList.count - 1
        for (index, school) in self.SchoolsList.enumerated() {
            var url_promo = Constantes.tromby.url.promos
            url_promo = url_promo.replacingOccurrences(of: "{city}", with: school["code"] as! String)
            url_promo = url_promo.replacingOccurrences(of: "{anne}", with: self.year)
            
//            print("url", url_promo)
            Alamofire.request(url_promo, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let result = response.result.value {
                            let JSON = result as! [[String:String]]
                            self.SchoolsList[index]["promos"] = JSON as AnyObject
//                            print("aie", self.SchoolsList)
                            EZLoadingActivity.hide()
                            self.tableView.reloadData()
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
        if self.Step == 0 {
            return self.SchoolsList.count
        }else if self.Step == 1{
            let current_promo = self.SchoolsList[SchoolSelected]["promos"] as! [[String:String]]
            return current_promo.count
        }else if self.Step == 3 {
            return self.searchData.count
        }else{
            return self.StudentList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.Step == 2 || self.Step == 3 {
            return 90
        }
        return 79
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if self.Step == 0 {
            let school_Data = self.SchoolsList[indexPath.row]
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! TrombiCellCity
            cust_cell.name.text = school_Data["title"] as? String
            cust_cell.mainContent.bordering_field(width: 0.5, color: UIColor.black, radius: 2)
            cust_cell.mainContent.applyPlainShadow()
            cust_cell.mainContent.bordering_field(width: 0.5, color: UIColor.white, radius: 0.5)
            cell = cust_cell
        }else if self.Step == 1{
            let promos_Data = self.SchoolsList[self.SchoolSelected]["promos"] as! [[String:String]]
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! TrombiCellCity
            cust_cell.name.text = promos_Data[indexPath.row]["promo"]?.capitalized
            cust_cell.mainContent.bordering_field(width: 0.5, color: UIColor.black, radius: 2)
            cust_cell.mainContent.applyPlainShadow()
            cust_cell.mainContent.bordering_field(width: 0.5, color: UIColor.white, radius: 0.5)
            cell = cust_cell
        }else if self.Step == 2 || self.Step == 3{
            var studen_data = [String : AnyObject]()
            if self.Step == 2 {
                studen_data = self.StudentList[indexPath.row]
            }else{
                studen_data = self.searchData[indexPath.row]
            }
            
            let cust_cell = tableView.dequeueReusableCell(withIdentifier: "studCell", for: indexPath) as! TrombiCellStuden
            
            var login = studen_data["login"] as! String
            
            var gpa : String?
            if self.Step == 2{
                gpa = studen_data["gpa"] as? String
                if gpa != nil {
                    cust_cell.gpa.text = gpa
                    cust_cell.gpa.isHidden = false
                }else{
                    cust_cell.gpa.isHidden = true
                }
            }else{
                cust_cell.gpa.isHidden = true
            }
            
            cust_cell.name.text = studen_data["title"] as! String?
            cust_cell.designView.applyCurvedShadow()
            if login != "aucun" {
                login.epureEmail()
                let url_pic = NSURL(string: (Constantes.url.profile_pic).replacingOccurrences(of: "{user}", with: login)) as! URL
                cust_cell.picture.kf.setImage(with: url_pic, placeholder: #imageLiteral(resourceName: "profile"), options: nil, progressBlock: nil, completionHandler: nil)
            }else{
                cust_cell.picture.image = #imageLiteral(resourceName: "larme_large")
            }
            
            cust_cell.picture.rounding_border(border_color: UIColor.black, border_size: 2)
            cell = cust_cell
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.MakeAnimationTouch(force: 0)
     
        if self.Step == 0 {
            self.Step = 1
            self.SchoolSelected = indexPath.row
            self.SchoolSelected_Title = (self.SchoolsList[indexPath.row]["code"] as? String)!
            
            newBackButton.isEnabled = true
            newBackButton.title = "< Villes"
            
            self.tableView.reloadData()
        }else if self.Step == 1 {
            self.Step = 2
            let promos_Data = self.SchoolsList[self.SchoolSelected]["promos"] as! [[String:String]]
            self.PromoSelected = promos_Data[indexPath.row]["promo"]!
            
            self.ClassementButton.title = "Classement"
            self.ClassementButton.isEnabled = true
            self.ClassementButton.tintColor = UIColor.white
            
            var url_student = Constantes.tromby.url.student_list
            url_student = url_student.replacingOccurrences(of: "{city}", with: self.SchoolSelected_Title)
            url_student = url_student.replacingOccurrences(of: "{year}", with: self.year)
            url_student = url_student.replacingOccurrences(of: "{promo}", with: self.PromoSelected)
            url_student = url_student.replacingOccurrences(of: "{offset}", with: "0")
            
            print(url_student)
            
            Alamofire.request(url_student, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let result = response.result.value {
                            let JSON = result as! [String : AnyObject]
                           
                            let student_data = JSON["items"] as! [[String:AnyObject]]
                            let Max_Student = JSON["total"] as! Int
                            self.MaxStudents = Max_Student
                            self.StudentList = student_data
                            self.ClassementButton.isEnabled = true
                            self.tableView.reloadData()
                            self.mainTable.scrollToTop(animated: true)
                        }
                    }
                    break
                    
                case .failure(_):
                    print(response.result.error!)
                    break
                }
            }
            newBackButton.isEnabled = true
            newBackButton.title = "< Promos"
        }else if self.Step == 2 || self.Step == 3 {
            let profileController = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.PROFILE_VIEW) as! ProfileHomeController
            var StudentData = [String:AnyObject]()
            if self.Step == 2 {
                StudentData = self.StudentList[indexPath.row]
            }else{
                StudentData = self.searchData[indexPath.row]
            }
            let login_Touched = StudentData["login"] as! String
            let login_Self = userDefaut.string(forKey: Constantes.key_userdef.LOGIN_KEY)
            if login_Self == login_Touched {
                profileController.profile_self_mode = true
            }else{
                profileController.profile_login = login_Touched
            }
            print(profileController.profile_login)
            profileController.peekMode = true
            self.navigationController?.pushViewController(profileController, animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = tableView.numberOfRows(inSection: 0) - 1
//        print("last", lastElement)
        if indexPath.row == lastElement {
            if self.Step == 2 && lastElement + 1 < self.MaxStudents{
                let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                pagingSpinner.startAnimating()
                pagingSpinner.color = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
                pagingSpinner.hidesWhenStopped = true
                tableView.tableFooterView = pagingSpinner
                
                var url_student = Constantes.tromby.url.student_list
                url_student = url_student.replacingOccurrences(of: "{city}", with: self.SchoolSelected_Title)
                url_student = url_student.replacingOccurrences(of: "{year}", with: self.year)
                url_student = url_student.replacingOccurrences(of: "{promo}", with: self.PromoSelected)
                url_student = url_student.replacingOccurrences(of: "{offset}", with: String(lastElement + 1))
                
                print(url_student)
                
                Alamofire.request(url_student, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
                    
                    switch(response.result) {
                    case .success(_):
                        if response.result.value != nil{
                            if let result = response.result.value {
                                let JSON = result as! [String : AnyObject]
                                
                                let student_data = JSON["items"] as! [[String:AnyObject]]
                                self.StudentList.append(contentsOf: student_data)
                                pagingSpinner.stopAnimating()
                                self.tableView.reloadData()
                            }
                        }
                        break
                        
                    case .failure(_):
                        print(response.result.error!)
                        break
                    }
                }
            }
        }
    }
    
    func searchStudents() -> Void {
        if self.searchRequest != nil {
            self.searchRequest?.cancel()
        }
        if self.seachBar.text != "" {
            self.Step = 3
            self.newBackButton.title = "< Retour"
            self.newBackButton.isEnabled = true
            self.ClassementButton.isEnabled = false
            var url_search = Constantes.tromby.url.student_search
            url_search = url_search.replacingOccurrences(of: "{user}", with: self.seachBar.text!)
            url_search = url_search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            print(url_search)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.searchRequest = Alamofire.request(url_search, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let result = response.result.value {
                            if let JSON = result as? [[String : AnyObject]] {
                                self.searchData = JSON
                            }else{
                                self.searchData = [["title" : "Aucun résultat" as AnyObject, "login" : "aucun" as AnyObject]]
                            }
                            self.mainTable.reloadData()
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    }
                    break
                    
                case .failure(_):
                    print(response.result.error!)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    break
                }
            }
        }
    }
    
    
    //MARK: SearchBar 
   
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchStudents()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.seachBar.showsCancelButton = true
        for ob: UIView in ((seachBar.subviews[0] )).subviews {
            
            if let z = ob as? UIButton {
                let btn: UIButton = z
                btn.setTitleColor(UIColor.white, for: .normal)
            }
        }
        if self.Step != 3 {
            self.Step_save = self.Step
        }
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchStudents()
        self.seachBar.showsCancelButton = false
        self.seachBar.endEditing(true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("hay le teesh", searchData.count)
        if self.searchData.count == 0 {
            self.gestionRetourViaButton()
        }
        self.seachBar.text = ""
        self.seachBar.showsCancelButton = false
        self.seachBar.endEditing(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.seachBar.showsCancelButton = false
        /*self.Step = 0
        self.searchData = [[String:AnyObject]]()
        self.searchRequest = nil
        self.mainTable.reloadData()*/
    }
}
