//
//  BoolExtension.swift
//  Ladybug
//
//  Created by Yannis Lang on 27/11/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

extension Bool {
    init<T : Integer>(_ integer: T){
        self.init(integer != 0)
    }
}
