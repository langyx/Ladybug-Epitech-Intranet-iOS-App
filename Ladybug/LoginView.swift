//
//  LoginViwController
//  Ladybug
//
//  Created by Yannis on 23/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import UIKit
import Alamofire
import EZLoadingActivity

class LoginViwController : UIViewController, UITextFieldDelegate {

    //Intervare graphique
    @IBOutlet weak var image_profile : UIImageView!
    @IBOutlet weak var login_txt : UITextField!
    @IBOutlet weak var pass_txt : UITextField!
    @IBOutlet weak var connexion_button : UIButton!
    @IBOutlet weak var officeSwitch : UISwitch!
    @IBOutlet weak var officeLbl : UILabel!
    
    //DEFINE
    let MediaFromIntraImg = MediaFromIntra()
    let Suffix_email = "@epitech.eu"
    let userDef = UserDefaults.standard
    var logOut = false
    var help_user_login = true
    var connected_status = false
    var connexion_request : Alamofire.Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.setBackgroundView()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.login_txt.delegate = self
        self.pass_txt.delegate = self
        
        self.connexion_button.bordering_field(width: 2, color: nil, radius: 3)
        self.image_profile.rounding_border(border_color: UIColor.black, border_size: nil)
        
        if self.logOut {
            EZLoadingActivity.show("Déconnexion", disableUI: true)
            self.DisconnectionProcess()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func DisconnectionProcess() -> Void {
        self.login_txt.isHidden = true
        self.pass_txt.isHidden = true
        self.image_profile.isHidden = true
        self.connexion_button.isHidden = true
        
        userDef.removeObject(forKey: Constantes.key_userdef.LOGIN_KEY)
        userDef.removeObject(forKey: Constantes.key_userdef.PASS_KEY)
        userDef.removeObject(forKey: Constantes.key_userdef.CONNECTED_KEY)
        userDef.removeObject(forKey: Constantes.key_userdef.CONNEXION_MODE)
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        let cookieJar = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
        
        Alamofire.request(Constantes.url.logout, method : .post).response { response in
//            debugPrint(response)
            self.login_txt.isHidden = false
            self.pass_txt.isHidden = false
            self.image_profile.isHidden = false
            self.connexion_button.isHidden = false
            EZLoadingActivity.hide()
        }
    }

    //MARK: TextFielDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.login_txt.bordering_field(width: 0, color: nil, radius: nil)
        self.pass_txt.bordering_field(width: 0, color: nil, radius: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.login_txt {
            MediaFromIntraImg.get_160190_profile_picture(login: self.login_txt.text!, sender : image_profile)
        }else if textField == self.pass_txt {
            if self.login_txt.layer.borderColor != UIColor.red.cgColor && self.pass_txt.layer.borderColor != UIColor.red.cgColor && !(self.connected_status) && (self.login_txt.text?.characters.count)! > 3 {
                if !self.officeSwitch.isOn {
                    attempt_connexion(enter: false)
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //textfield login
        if textField == self.login_txt {
            var current_text = (self.login_txt.text)!
            let prohib_zone_start = current_text.characters.count - self.Suffix_email.characters.count
            if !(help_user_login) && range.location >= prohib_zone_start {
                if !(range.location == prohib_zone_start && string != "") {
                    return false
                }
            }
            current_text.insert(string: string, ind: range.location)
            if (current_text.isValidEmail()) {
                MediaFromIntraImg.get_160190_profile_picture(login: current_text, sender : image_profile)
            }else{
                if help_user_login {
                    self.login_txt.text = self.login_txt.text! + self.Suffix_email
                    if let newPosition = textField.position(from: self.login_txt.endOfDocument, offset: self.Suffix_email.characters.count * -1) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                    help_user_login = false
                }
            }
        }else if textField == self.pass_txt{ //TEXTFIELD PASSWORD
            var current_text = self.pass_txt.text
            current_text?.insert(string: string, ind: range.location)
            if self.login_txt.layer.borderColor != UIColor.red.cgColor && string != ""
                && !(self.connected_status) && (current_text?.characters.count)! > 5 {
                self.pass_txt.text = current_text
                if !self.officeSwitch.isOn {
                    attempt_connexion(enter: false)
                }
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: UI Interaction
    @IBAction func push_connection(){
        self.navigationController?.MakeAnimationTouch(force: 2)
        if self.officeSwitch.isOn {
            let ConnexionRoutine = self.storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.CONNEXION_ROUTINE) as! ConnexionRoutine
            ConnexionRoutine.officeConnexionMode = true
            ConnexionRoutine.officeLogin = self.login_txt.text!.replacingOccurrences(of: "@", with: "%40")
            ConnexionRoutine.OfficePasswd = self.pass_txt.text!
            self.navigationController?.pushViewController(ConnexionRoutine, animated: true)
        }else{
            if connected_status {
                self.performSegue(withIdentifier: Constantes.segues.ENTER_FROM_LOGIN, sender: nil)
            }else{
                EZLoadingActivity.show("Connexion", disableUI: true)
                attempt_connexion(enter: true)
            }
        }
    }
    
    //Core Process
    func attempt_connexion(enter : Bool) -> Void {
        if connexion_request != nil {
            connexion_request?.cancel()
        }
        
        MediaFromIntraImg.get_160190_profile_picture(login: self.login_txt.text!, sender : image_profile)
        
        let url_connex = Constantes.url.url_connexion_home
        
        let post_data = ["login" : self.login_txt.text! as AnyObject ,
                         "password" : self.pass_txt.text! as AnyObject,
                         "remember_me" : "on" as AnyObject]
 
       // print("requet on : ", url_connex, "\nwith param : ", post_data)
        self.connexion_request =  Alamofire.request(url_connex, method: .post, parameters: post_data, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [String:AnyObject]
                        self.connexionStatusCore(info: JSON, enter: enter)
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
    
    //MARK: Status connexion
    func connexionStatusCore(info : [String:AnyObject], enter : Bool) -> Void {
        print("info == " , info)
        if info["infos"] != nil {
            EZLoadingActivity.hide()
            self.userDef.set(self.login_txt.text, forKey: Constantes.key_userdef.LOGIN_KEY)
            self.userDef.set(self.pass_txt.text, forKey: Constantes.key_userdef.PASS_KEY)
            self.userDef.set(true, forKey: Constantes.key_userdef.CONNECTED_KEY)
            setStatusConnected()
            if enter {
                self.performSegue(withIdentifier: Constantes.segues.ENTER_FROM_LOGIN, sender: nil)
            }
        }else{
            EZLoadingActivity.Settings.FailText = "Erreur"
            EZLoadingActivity.Settings.FailIcon = "✕"
            EZLoadingActivity.hide(false, animated: true)
            setStatusError(info: info)
        }
    }
    
    func setStatusConnected() -> Void {
        self.officeSwitch.isEnabled = false
        self.officeSwitch.isHidden = true
        self.officeLbl.isHidden = true
        self.image_profile.rounding_border(border_color: UIColor.green, border_size: nil)
        self.connected_status = true
        self.pass_txt.bordering_field(width: 0, color: nil, radius: nil)
        self.login_txt.bordering_field(width: 0, color: nil, radius: nil)
    }
    
    func setStatusError(info : [String: AnyObject]) -> Void {
        let message_error = info["message"] as? String
        if message_error != nil && (message_error == "Login or password does not match." || message_error == "Le login et/ou le mot de passe sont invalides."){
            self.pass_txt.bordering_field(width: 1, color: UIColor.red, radius: nil)
        }else{
            self.login_txt.bordering_field(width: 1, color: UIColor.red, radius: nil)
        }
    }
}

