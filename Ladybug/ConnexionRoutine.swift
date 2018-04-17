//
//  ConnexionRoutine.swift
//  Ladybug
//
//  Created by Yannis Lang on 26/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import EZLoadingActivity

class ConnexionRoutine: UIViewController, UIWebViewDelegate {
    
    let userDef = UserDefaults.standard
    var connected_BYPASS : Bool? = nil
    var officeConnexionMode : Bool? = nil
    var officeLogin = String()
    var OfficePasswd = String()
    var webViewPassing = 0
    
    @IBOutlet weak var webViewConnect : UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.setBackgroundView()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if self.officeConnexionMode != nil && self.officeConnexionMode! {
            self.title = "Office"
            self.officeConnexion(login: self.officeLogin, passwd: self.OfficePasswd)
        }else{
            print("user connu")
            connected_BYPASS = userDef.bool(forKey: Constantes.key_userdef.CONNECTED_KEY)
            userDef.removeObject(forKey: Constantes.key_userdef.CONNECTED_KEY)
            if (connected_BYPASS != nil && connected_BYPASS!) {
                print("BYPASS")
                goToProfile()
            }else{
                let login = userDef.string(forKey: Constantes.key_userdef.LOGIN_KEY)
                if login == nil || login == "" {
                    let LOGIN_VIEW = storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.LOGIN_VIEW) as! LoginViwController
                    self.navigationController?.replace_by(controller: LOGIN_VIEW)
                }else{
                    logIN()
                }
            }
        }
    }
    
    func officeConnexion(login : String, passwd : String) -> Void {
        var urlOfficeString = Constantes.url.office_login
        urlOfficeString = urlOfficeString.replacingOccurrences(of: "{user}", with: login)
        self.OfficePasswd = passwd
        self.officeLogin = login
        let reqConnect = NSURLRequest(url: URL(string: urlOfficeString)!)
        EZLoadingActivity.show("Chargement...", disableUI: true)
        self.webViewConnect.loadRequest(reqConnect as URLRequest)
    }
    
    func goToProfile() -> Void {
        let profile_Home = storyboard?.instantiateViewController(withIdentifier: Constantes.storyboard_id.PROFILE_VIEW) as! ProfileHomeController
//        self.navigationController?.replace_by(controller: profile_Home)
            self.navigationController?.empty_Push(ctrlr: profile_Home)
    }
    
    func logIN() -> Void {
        
        let login = userDef.string(forKey: Constantes.key_userdef.LOGIN_KEY)
        let pass = userDef.string(forKey: Constantes.key_userdef.PASS_KEY)
        let mode = userDef.string(forKey: Constantes.key_userdef.CONNEXION_MODE)
        
        if mode == nil || mode != "office" {
            print("classic autoco")
            let url_connex = Constantes.url.url_connexion_home
            let post_data = ["login" : login as AnyObject ,
                             "password" : pass as AnyObject,
                             "remember_me" : "on" as AnyObject]
            
            Alamofire.request(url_connex, method: .post, parameters: post_data, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let result = response.result.value {
                            let JSON = result as! [String:AnyObject]
                            if JSON["infos"] == nil {
                                //user_def.set(false, forKey: Constantes.key_userdef.CONNECTED_KEY)
                            }else{
                                // user_def.set(true, forKey: Constantes.key_userdef.CONNECTED_KEY)
                                self.goToProfile()
                            }
                        }
                    }
                    break
                    
                case .failure(_):
                    self.userDef.set(false, forKey: Constantes.key_userdef.CONNECTED_KEY)
                    print(response.result.error!)
                    break
                }
                
            }
        }else{
            print("office auto connexion")
            self.officeConnexionMode = true
            self.officeConnexion(login: login!, passwd: pass!)
        }
    }
    
    //MARK: WEBVIEW DELEGATE
    func webViewDidStartLoad(_ webView: UIWebView) {
        EZLoadingActivity.show("Chargement...", disableUI: true)
        self.webViewConnect.isHidden = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if webView.request?.url?.absoluteString == "https://intra.epitech.eu/" {
            self.webViewConnect.stopLoading()
            self.userDef.set(self.officeLogin, forKey: Constantes.key_userdef.LOGIN_KEY)
            self.userDef.set(self.OfficePasswd, forKey: Constantes.key_userdef.PASS_KEY)
//            self.userDef.set(true, forKey: Constantes.key_userdef.CONNECTED_KEY)
            self.userDef.set("office", forKey: Constantes.key_userdef.CONNEXION_MODE)
            EZLoadingActivity.hide()
            goToProfile()
        }else{
            self.webViewPassing += 1
            print("passing ==", self.webViewPassing)
            if self.officeConnexionMode! && (webView.request?.url?.absoluteString.contains("//sts.epitech.eu/adfs/ls/?client-request-id=f93caf87-23f7-4a27-8138-c5bc075b5dbb"))! {
                let savedPassword = self.OfficePasswd
                let fillForm = String(format: "document.getElementById('passwordInput').value = '\(savedPassword)';")
                webView.stringByEvaluatingJavaScript(from: fillForm)
                webView.stringByEvaluatingJavaScript(from: "document.forms[\"loginForm\"].submit();")
                self.officeConnexionMode = false
                EZLoadingActivity.hide()
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if !self.webViewConnect.isLoading
                    {
                        EZLoadingActivity.Settings.FailText = "Erreur connexion"
                        EZLoadingActivity.hide(false, animated: true)
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
            }
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        EZLoadingActivity.hide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.webViewPassing = 0
    }
}
