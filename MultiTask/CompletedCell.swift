//
//  CompletedCell.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class CompletedCell: UITableViewCell {

    var completedTask: Task? {
        didSet {
            updateCell()
        }
    }

    static let id = String(describing: CompletedCell.self)

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!

    private func updateCell() {
        // STEP 1: reset any existing UI info/outlets, otherwise info could become misplaced
        taskLabel.text = nil
        dateLabel.text = nil
        // STEP 2: load new info from user (if any)
        if let completedTask = self.completedTask {
            taskLabel.text = completedTask.name
            dateLabel.text = String(describing: completedTask.updated_at)
            itemCountLabel.text = String(describing: completedTask.items.count)
        }
    }

    private func setupViews() {
        self.backgroundColor = Color.midNightBlack
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted == true {
            self.backgroundColor = Color.darkGray
        } else {
            self.backgroundColor = Color.midNightBlack
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
}
