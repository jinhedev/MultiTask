//
//  PendingCell.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

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
            dateLabel.text = String(describing: pendingTask.created_at)
            itemCountLabel.text = String(describing: pendingTask.items.count)
        }
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
