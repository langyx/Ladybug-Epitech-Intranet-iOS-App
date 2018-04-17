//
//  IntExtension.swift
//  Ladybug
//
//  Created by Yannis Lang on 31/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    mutating func getCurrentYear() -> Void {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        
        let year =  components.year
        self = year!
    }
}
