//
//  NSDateExtension.swift
//  Ladybug
//
//  Created by Yannis Lang on 24/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    func secondsBetween(endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.second], from: self, to: endDate)
        return components.second!
    }
    
    func getAvancement(start : Date,  end : Date) -> Float {
        let totalSeconds = Float(start.secondsBetween(endDate: end))
        let resteSeconds = Float(self.secondsBetween(endDate: end))
        
        print(Float(resteSeconds / totalSeconds))
        if resteSeconds < 0 {
            return Float(1.0)
        }
        return Float((resteSeconds / totalSeconds) / 100)
    }
    
    mutating func getStringDate(dateStr : String, dateFormat: String) -> Void {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
         /* date_format_you_want_in_string from
         *  http://userguide.icu-project.org/formatparse/datetime
         */
        let date = dateFormatter.date(from: dateStr)
        self = date!
    }
}
