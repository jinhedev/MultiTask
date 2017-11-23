//
//  InformationCell.swift
//  MultiTask
//
//  Created by rightmeow on 10/24/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class TaskCell: BaseCollectionViewCell {

    // MARK: - Public API

    var task: Task? {
        didSet {
            self.configureCell(task: task)
        }
    }

    static let cell_id = String(describing: TaskCell.self)
    static let nibName = String(describing: TaskCell.self)

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var containerViewLeadingMargin: NSLayoutConstraint! // increase its constant when in editing mode to give space for checkmarImageView

    var editing: Bool = false {
        didSet {
            self.containerViewLeadingMargin.constant = 22 + 16 // width of checkmarkImageView + some space
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.checkmarkImageView.isHidden = !self.editing
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }

    func animateForEditing(isEditing: Bool) {
        if isEditing {
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
                self.containerView.backgroundColor = Color.mandarinOrange
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.transform = CGAffineTransform.identity
                self.containerView.backgroundColor = Color.midNightBlack
            })
        }
    }

    func animateForSelect(isSelected: Bool) {
        if isSelected {
            UIView.animate(withDuration: 0.3, animations: {
                self.dateLabel.textColor = Color.lightGray
                self.containerView.backgroundColor = Color.mandarinOrange
                self.containerView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.configureCell(task: self.task)
                self.containerView.backgroundColor = Color.midNightBlack
                self.containerView.transform = CGAffineTransform.identity
            })
        }

    }

    func animateForHighlight(isHighlighted: Bool) {
        if isHighlighted == true {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                self.containerView.backgroundColor = Color.mandarinOrange
                self.dateLabel.textColor = Color.lightGray
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                self.containerView.backgroundColor = Color.midNightBlack
                self.configureCell(task: self.task)
            }, completion: nil)
        }
    }

    override var isSelected: Bool {
        didSet {
            if editing {
                self.checkmarkImageView.backgroundColor = isSelected ? Color.mandarinOrange : Color.clear
            }
        }
    }

    // MARK: - Private API

    private func configureCell(task: Task?) {
        if let task = task {
            self.titleLabel.text = task.title
            if task.items.isEmpty {
                self.subtitleLabel.text = "No items found"
            } else {
                self.subtitleLabel.text = task.items.last!.title
            }
            self.statsLabel.text = String(describing: self.calculateCountForCompletedItems(items: task.items)) + "/" + String(describing: task.items.count)
            if task.is_completed == true {
                self.dateLabel.text = "Completed " + task.updated_at!.toRelativeDate()
                self.dateLabel.textColor = Color.metallicGold
            } else if task.updated_at != nil {
                self.dateLabel.text = "Updated " + task.updated_at!.toRelativeDate()
                self.dateLabel.textColor = Color.mandarinOrange
            } else {
                // this includes the case of when is_completed == false
                self.dateLabel.text = "Created " + task.created_at.toRelativeDate()
                self.dateLabel.textColor = Color.lightGray
            }
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
        self.checkmarkImageView.layer.cornerRadius = 11
        self.checkmarkImageView.clipsToBounds = true
        self.checkmarkImageView.layer.borderColor = Color.lightGray.cgColor
        self.checkmarkImageView.layer.borderWidth = 2
        self.checkmarkImageView.backgroundColor = Color.clear
        self.checkmarkImageView.isHidden = true
        self.containerView.backgroundColor = Color.midNightBlack
        self.containerView.layer.cornerRadius = 8
        self.containerView.layer.borderColor = Color.clear.cgColor
        self.containerView.layer.borderWidth = 1
        self.containerView.clipsToBounds = true
        self.containerView.layer.masksToBounds = true
        self.titleLabel.text?.removeAll()
        self.titleLabel.backgroundColor = Color.clear
        self.titleLabel.textColor = Color.white
        self.subtitleLabel.text?.removeAll()
        self.subtitleLabel.backgroundColor = Color.clear
        self.subtitleLabel.textColor = Color.lightGray
        self.dateLabel.text?.removeAll()
        self.dateLabel.backgroundColor = Color.clear
        self.dateLabel.textColor = Color.lightGray
        self.statsLabel.text?.removeAll()
        self.statsLabel.backgroundColor = Color.clear
        self.statsLabel.textColor = Color.lightGray
    }

    private func resetDataForReuse() {
        self.titleLabel.text?.removeAll()
        self.subtitleLabel.text?.removeAll()
        self.dateLabel.text?.removeAll()
        self.statsLabel.text?.removeAll()
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetDataForReuse()
    }
    
}












