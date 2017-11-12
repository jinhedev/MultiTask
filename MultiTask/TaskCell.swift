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

    var task: Task? { didSet { self.configureCell(task: task) } }

    static let cell_id = String(describing: TaskCell.self)
    static let nibName = String(describing: TaskCell.self)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!

    func animateCell(isEditing: Bool) {
        if isEditing {
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
                self.containerView.backgroundColor = Color.red
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.transform = CGAffineTransform.identity
                self.containerView.backgroundColor = Color.midNightBlack
            })
        }
    }

    func animateBorderColor(_ view: UIView, duration: TimeInterval, color: Color) {
        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            view.layer.borderColor = color.cgColor
        }, completion: nil)
    }

    // MARK: - Private API

    private func configureCell(task: Task?) {
        if let task = task {
            UIView.animate(withDuration: 0.3, animations: {
                self.titleLabel.text = task.title
                self.subtitleLabel.text = task.id
                self.dateLabel.text = task.created_at.toRelativeDate()
                self.statsLabel.text = String(describing: self.calculateCountForCompletedItems(items: task.items)) + "/" + String(describing: task.items.count)
                if task.is_completed {
                    self.dateLabel.textColor = Color.seaweedGreen
                } else {
                    self.dateLabel.textColor = Color.mandarinOrange
                }
            })
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
        self.dateLabel.textColor = Color.mandarinOrange
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












