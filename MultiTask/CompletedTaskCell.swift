//
//  CompletedTaskCell.swift
//  MultiTask
//
//  Created by rightmeow on 11/24/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class CompletedTaskCell: BaseCollectionViewCell {

    // MARK: - API

    var completedTask: Task? {
        didSet {
            self.configureCell(task: completedTask)
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
    static let cell_id = String(describing: CompletedTaskCell.self)
    static let nibName = String(describing: CompletedTaskCell.self)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!

    private func setHightlighted() {
        self.containerView.backgroundColor = self.isHighlighted ? Color.mediumBlueGray : Color.midNightBlack
    }

    func setEditing() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction], animations: {
            self.checkmarkImageView.isHidden = self.isEditing ? false : true
            self.containerView.transform = self.isEditing ? CGAffineTransform.init(scaleX: 0.94, y: 0.94) : CGAffineTransform.identity
        }, completion: nil)
    }

    func setSelected() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction], animations: {
            self.containerView.transform = self.isSelected ? CGAffineTransform.init(scaleX: 0.97, y: 0.97) : CGAffineTransform.init(scaleX: 0.94, y: 0.94)
            self.containerView.layer.borderColor = self.isSelected ? Color.roseScarlet.cgColor : Color.clear.cgColor
            self.containerView.layer.borderWidth = self.isSelected ? 1 : 0
            self.checkmarkImageView.backgroundColor = self.isSelected ? Color.roseScarlet : Color.inkBlack
        }, completion: nil)
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
                self.dateLabel.textColor = Color.seaweedGreen
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

    private func setupCell() {
        self.checkmarkImageView.layer.cornerRadius = 11
        self.checkmarkImageView.clipsToBounds = true
        self.checkmarkImageView.layer.borderColor = Color.white.cgColor
        self.checkmarkImageView.layer.borderWidth = 1
        self.checkmarkImageView.backgroundColor = Color.inkBlack
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
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(postNotificationToEnableEditMode(gestureRecognizer:)))
        self.longPressGestureRecognizer!.allowableMovement = 22
        self.longPressGestureRecognizer!.minimumPressDuration = 1.3
        self.containerView.addGestureRecognizer(self.longPressGestureRecognizer!)
    }

    @objc func postNotificationToEnableEditMode(gestureRecognizer: UILongPressGestureRecognizer) {
        if self.isEditing == false && gestureRecognizer.minimumPressDuration >= 1.3 {
            let notification = Notification(name: Notification.Name.EditMode, object: nil, userInfo: ["isEditing" : true])
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
