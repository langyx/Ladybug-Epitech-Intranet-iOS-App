//
//  ProjetFullNoteMain.swift
//  Ladybug
//
//  Created by Yannis Lang on 14/12/2016.
//  Copyright © 2016 Yannis. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Kingfisher
import EZLoadingActivity

class ProjetFullNoteMain: UITableViewController {
    
    var urlActivite : String!
    var noteData = [[String:AnyObject]]()
    
    @IBOutlet weak var mainTableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.urlActivite.append("note/?format=json")
        EZLoadingActivity.show("Chargement...", disableUI: true)
        self.getAllNote()
        self.mainTableView.setBackground()
    }

    func getAllNote() -> Void {
        Alamofire.request(self.urlActivite, method: .get, parameters: nil, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    if let result = response.result.value {
                        let JSON = result as! [[String : AnyObject]]
                        self.noteData = JSON
                        self.title = self.noteData[0]["title"] as? String ?? "Sans Titre"
                        self.noteData.sort(by: { (item1, item2) -> Bool in
                            //                print("#item", item1, item2)
                            let gpa1 = (item1["note"] as! Double)
                            let gpa2 = (item2["note"] as! Double)
                            return gpa1 > gpa2
                        })
                        self.mainTableView.reloadData()
                    }
                }
                EZLoadingActivity.hide()
                break
                
            case .failure(_):
                EZLoadingActivity.hide()
                print(response.result.error!)
                break
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.noteData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! ProjetFullNoteAllInfoCell
        
        let thisNote = self.noteData[indexPath.row]
        let thisNotePic = NSURL(string: thisNote["picture"] as? String ?? "") as? URL
        if (thisNotePic != nil) {
            cell.Picture.kf.setImage(with: thisNotePic)
        }
        cell.Picture.rounding_border(border_color: UIColor.black, border_size: 1)
        
        cell.Eleve.text = thisNote["user_title"] as? String ?? ""
        cell.Note.text = String(thisNote["note"] as? Int ?? 0)
        
        var thisNoteCommentTxt = String()
        let thisNoteNoteur = "Noté par : \(thisNote["grader"] as? String ?? "inconnu")"
        let thisNoteComment = thisNote["comment"] as? String ?? "Aucun commentaire"
        thisNoteCommentTxt = "\(thisNoteComment)\n\(thisNoteNoteur)"
        cell.Comment.text = thisNoteCommentTxt
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
}
