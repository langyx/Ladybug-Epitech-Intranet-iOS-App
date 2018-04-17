//
//  FileReaderMain.swift
//  Ladybug
//
//  Created by Yannis Lang on 07/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import EZLoadingActivity

class FileReaderMain: UIViewController, UIWebViewDelegate {
    
    var FilePath = String()
    var TitleFile = String()
    
    @IBOutlet weak var toolbarBottom : UIToolbar!
    @IBOutlet weak var webView : UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.TitleFile
        
        self.webView.delegate = self
        
        //inject webview
        let FileUrl = NSURL(string: FilePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) as! URL
        webView.loadRequest(URLRequest(url: FileUrl))
        
    }
    
    //MARK: WebView Delegate
    
    @IBAction func refreshWebView() -> Void {
        self.navigationController?.MakeAnimationTouch(force: 2)
        self.webView.reload()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("LOAD")
        self.webView.isHidden = true
        EZLoadingActivity.show("Chargement...", disableUI: true)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("END")
        self.webView.isHidden = false
        EZLoadingActivity.hide()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("FAIL")
        self.webView.isHidden = false
        EZLoadingActivity.hide()
    }
}
