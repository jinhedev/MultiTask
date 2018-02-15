//
//  InformationCell.swift
//  MultiTask
//
//  Created by rightmeow on 10/24/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class PendingTaskCell: BaseCollectionViewCell {

    // MARK: - API

    var task: Task? {
        didSet {
            self.configureCell(task: task)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.setHightlighted()
        }
    }

    var isEditing: Bool = false {
        didSet {
            self.setEditing()
        }
    }

    override var isSelected: Bool {
        didSet {
            if isEditing == true {
                self.setSelected()
            }
        }
    }

    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    static let cell_id = String(describing: PendingTaskCell.self)
    static let nibName = String(describing: PendingTaskCell.self)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var containerViewLeadingMargin: NSLayoutConstraint! // increase its constant when in editing mode to give space for checkmarImageView
    
    private func setHightlighted() {
        self.containerView.backgroundColor = self.isHighlighted ? Color.mediumBlueGray : Color.midNightBlack
    }

    private func setEditing() {
        // FIXME: There is a UI bug when a cell is finished editing, its content is still remained squeezed due to the change of cell's size during animation.
        if self.isEditing == true {
            self.containerViewLeadingMargin.constant = self.isEditing ? (16 + 22 + 16) : 16
            UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction], animations: {
                self.layoutIfNeeded()
            }) { (completed) in
                self.checkmarkImageView.isHidden = self.isEditing ? false : true
            }
        } else {
            self.checkmarkImageView.isHidden = self.isEditing ? false : true
            self.containerViewLeadingMargin.constant = self.isEditing ? (16 + 22 + 16) : 16
            UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }

    private func setSelected() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction], animations: {
            self.containerView.transform = self.isSelected ? CGAffineTransform.init(scaleX: 1.03, y: 1.03) : CGAffineTransform.identity
            self.containerView.layer.borderColor = self.isSelected ? Color.roseScarlet.cgColor : Color.clear.cgColor
            self.containerView.layer.borderWidth = self.isSelected ? 1 : 0
            self.checkmarkImageView.backgroundColor = self.isSelected ? Color.roseScarlet : Color.clear
        }, completion: nil)
    }

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
        self.checkmarkImageView.layer.borderColor = Color.white.cgColor
        self.checkmarkImageView.layer.borderWidth = 1
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

    // MARK: - UILongPressGesture

    private func setupLongPressGestureRecognizer() {
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(postNotificationForEditMode(gestureRecognizer:)))
        self.longPressGestureRecognizer!.allowableMovement = 22
        self.longPressGestureRecognizer!.minimumPressDuration = 1.3
        self.containerView.addGestureRecognizer(self.longPressGestureRecognizer!)
    }

    @objc func postNotificationForEditMode(gestureRecognizer: UILongPressGestureRecognizer) {
        if self.isEditing == false && gestureRecognizer.minimumPressDuration >= 1.3 {
            let notification = Notification(name: Notification.Name.PendingTaskCellEditingMode, object: nil, userInfo: ["isEditing" : true])
            NotificationCenter.default.post(notification)
        }
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
        self.setupLongPressGestureRecognizer()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetDataForReuse()
    }

}
