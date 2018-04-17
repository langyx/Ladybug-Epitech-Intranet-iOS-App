//
//  StringExtension.swift
//  Ladybug
//
//  Created by Yannis on 23/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    //Verification format d'une adresse mail
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@epitech.eu" //[A-Za-z0-9.-]+\\.[A-Za-z]{2,}
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    //Recupération du login sans l'arobase
    mutating func epureEmail() -> Void {
        if let dotRange = self.range(of: "@") {
            self.removeSubrange(dotRange.lowerBound..<self.endIndex)
        }
    }
    
    //insérer a un index
    mutating func insert(string:String,ind:Int) -> Void {
        self = String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
    
    //récupérer l'extension d'une url 
    func getExtension() -> String {
        var RessourceUrl_Ext = NSURL(string: self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)?.pathExtension
        if RessourceUrl_Ext == nil {
            RessourceUrl_Ext = "Extension inconnue"
        }
        return RessourceUrl_Ext!
    }
    
    func verifyUrl () -> Bool {
        if let url = NSURL(string: self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
}
