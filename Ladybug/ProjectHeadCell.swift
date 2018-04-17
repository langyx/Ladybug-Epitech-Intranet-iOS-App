//
//  ProjectHeadCell.swift
//  Ladybug
//
//  Created by Yannis Lang on 11/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit

class ProjectHeadCell: UITableViewCell {
    @IBOutlet weak var mainContent : UIView!
    @IBOutlet weak var titreLabel : UILabel!
    @IBOutlet weak var dateDebut : UILabel!
    @IBOutlet weak var dateFin : UILabel!
    @IBOutlet weak var dateInscription : UILabel!
    @IBOutlet weak var progressView : UIProgressView!
    @IBOutlet weak var endCount : UILabel!
    @IBOutlet weak var numbStudent : UILabel!
}
