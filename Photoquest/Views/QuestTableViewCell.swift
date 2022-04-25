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
    
    var quest: Quest?
    
    func load(for quest: Quest) {
        nameLabel.text = nil
        progressButton.setTitle(nil, for: .normal)
        progressButton.layer.cornerRadius = 10
        
        self.quest = quest
        nameLabel.text = quest.name
        progressButton.setTitle("\(quest.capturedPhotos.count) / \(quest.photos.count)", for: .normal)
    }
}
