//
//  PendingCell.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class PendingCell: UITableViewCell {

    var pendingTask: Task? {
        didSet {
            updateCell()
        }
    }

    static let id = String(describing: PendingCell.self)

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!

    private func updateCell() {
        // STEP 1: reset any existing UI info/outlets, otherwise info could become misplaced
        taskLabel?.text = nil
        dateLabel?.text = nil
        // STEP 2: load new info from user (if any)
        if let pendingTask = self.pendingTask {
            taskLabel.text = pendingTask.name
            dateLabel.text = pendingTask.created_at.toRelativeDate()
            // fraction representation of item count
            itemCountLabel.text = String(describing: calculateCountForCompletedItems(items: pendingTask.items)) + "/" + String(describing: pendingTask.items.count)
        }
    }

    private func calculateCountForCompletedItems(items: List<Item>) -> Int {
        var completedTasksCount: Int = 0
        for item in items {
            if item.is_completed == true {
                completedTasksCount += 1
            }
        }
        return completedTasksCount
    }

    private func setupViews() {
        self.backgroundColor = Color.midNightBlack
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted == true {
            self.backgroundColor = Color.darkGray
        } else {
            self.backgroundColor = Color.midNightBlack
        }
    }

}
