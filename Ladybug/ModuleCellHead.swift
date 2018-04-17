//
//  ModuleCellHead.swift
//  Ladybug
//
//  Created by Yannis Lang on 24/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

class ModuleCellHead: UITableViewCell {
    @IBOutlet weak var mainContent : UIView!
    @IBOutlet weak var projetButton : UIButton!
    @IBOutlet weak var codeModule : UILabel!
    @IBOutlet weak var grade : UILabel!
    @IBOutlet weak var credits : UILabel!
    @IBOutlet weak var dateFin : UILabel!
    @IBOutlet weak var dateDebut : UILabel!
    @IBOutlet weak var progressBar : UIProgressView!
}
