//
//  QuestsViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/24/22.
//

import UIKit

class QuestsViewController: UIViewController, QuestModelDelegate {

    @IBOutlet weak var questsTableView: UITableView!
    
    var questsModel = QuestModel()
    var quests = [Quest]()
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        questsTableView.delegate = self
        questsTableView.dataSource = self
        
        questsModel.delegate = self
        questsModel.fetchQuests()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? QuestDetailViewController {
            if let selectedIndexPath = selectedIndexPath {
                detailVC.quest = quests[selectedIndexPath.row]
            }
        }
    }
    
    func receivedQuests(quests: [Quest]) {
        self.quests = quests
        questsTableView.reloadData()
    }
}

// MARK: - UITableView Methods
extension QuestsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Quest Cell") as! QuestTableViewCell
        cell.load(for: quests[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "segueToQuestDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
