//
//  QuestTableViewCell.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import UIKit

class QuestTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressButton: UIButton!
    
    var quest: String?
    
    func load(for quest: String) {
        nameLabel.text = nil
        progressButton.setTitle(nil, for: .normal)
        
        self.quest = quest
        nameLabel.text = quest
        progressButton.setTitle("0 / 10", for: .normal)
    }

}
