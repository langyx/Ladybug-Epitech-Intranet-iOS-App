//
//  MediaFromIntra.swift
//  Ladybug
//
//  Created by Yannis on 23/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class MediaFromIntra {
    
    let url_profile_pic_160x190 = "https://cdn.local.epitech.eu/userprofil/profilview/"
    let image_format = ".jpg"
    
    var current_url_session_task : URLSessionDataTask? = nil
    
    func get_160190_profile_picture(login : String, sender : UIImageView) -> Void {
        var name = login
        if name.isValidEmail() {
            name.epureEmail()
            
            let full_url_image = "\(self.url_profile_pic_160x190)\(name)\(self.image_format)"
            let url_image = NSURL(string: full_url_image) as! URL
       
            
            getDataFromUrl(url: url_image) { (data, response, error)  in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() { () -> Void in
                    UIView.transition(with: sender,
                                      duration:1,
                                      options: UIViewAnimationOptions.transitionCrossDissolve,
                                      animations: {
                                        let reponse_url = response as! HTTPURLResponse
                                        if reponse_url.statusCode != 404 {
                                            sender.image = UIImage(data: data)
                                        }else{
                                            sender.image = #imageLiteral(resourceName: "profile")
                                        }
                                        sender.rounding_border(border_color: UIColor.black, border_size: nil)
                    },
                                      completion: nil)
                }
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        let session = URLSession.shared
        if current_url_session_task != nil {
            current_url_session_task?.cancel()
        }
        current_url_session_task = session.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }
        current_url_session_task?.resume()
    }
}
