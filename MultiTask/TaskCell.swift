//
//  PendingCell.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class TaskCell: UITableViewCell {

    // MARK: - API

    var pendingTask: Task? { didSet { updateCell() } }
    override var isEditing: Bool { didSet { animateCell() } }
    static let id = String(describing: TaskCell.self)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!

    private func animateCell() {
        if isEditing == true {
            UIView.animate(withDuration: 0.7, delay: 0, options: [.allowUserInteraction], animations: {
                self.containerView.backgroundColor = Color.red
                self.idLabel.textColor = Color.black
                self.taskLabel.textColor = Color.black
                self.dateLabel.textColor = Color.black
                self.separatorLabel.textColor = Color.black
                self.itemsCountLabel.textColor = Color.black
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                self.setupCell()
            }, completion: nil)
        }
    }

    private func updateCell() {
        if let pendingTask = self.pendingTask {
            idLabel.text = pendingTask.id
            taskLabel.text = pendingTask.name
            dateLabel.text = pendingTask.created_at.toRelativeDate()
            // fractional representation of item count
            itemsCountLabel.text = String(describing: calculateCountForCompletedItems(items: pendingTask.items)) + "/" + String(describing: pendingTask.items.count)
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

    private func setupCell() {
        self.backgroundColor = Color.clear
        self.contentView.backgroundColor = Color.clear
        self.containerView.backgroundColor = Color.midNightBlack
        self.containerView.layer.cornerRadius = 8.0
        self.idLabel.textColor = Color.lightGray
        self.idLabel.backgroundColor = Color.clear
        self.taskLabel.textColor = Color.white
        self.taskLabel.backgroundColor = Color.clear
        self.dateLabel.textColor = Color.lightGray
        self.dateLabel.backgroundColor = Color.clear
        self.itemsCountLabel.textColor = Color.lightGray
        self.itemsCountLabel.backgroundColor = Color.clear
        self.separatorLabel.textColor = Color.lightGray
        self.separatorLabel.backgroundColor = Color.clear
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.idLabel.text = nil
        self.taskLabel.text = nil
        self.dateLabel.text = nil
        self.separatorLabel.text = nil
        self.itemsCountLabel.text = nil
    }

}








