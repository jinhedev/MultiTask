//
//  ItemCell.swift
//  MultiTask
//
//  Created by rightmeow on 8/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class ItemCell: UITableViewCell {

    // MARK: - API

    var item: Item? { didSet { updateCell() } }
    static let cell_id = String(describing: ItemCell.self)
    @IBOutlet weak var itemTextView: UITextView!
    @IBOutlet weak var delegateLabel: UILabel!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    private func updateCell() {
        guard let item = self.item else { return }
        self.itemTextView.text = item.note
        if item.is_completed == true {
            self.backgroundColor = Color.inkBlack
            self.itemTextView.textColor = Color.lightGray
            self.dateLabel.textColor = Color.seaweedGreen
        } else {
            self.backgroundColor = Color.midNightBlack
            self.itemTextView.textColor = Color.white
            self.dateLabel.textColor = Color.lightGray
        }
    }

//    private func postNotification(is_completed: Bool) {
//        guard let item = self.item else { return }
//        let notificationName = NSNotification.Name(rawValue: CompletionSiwtchNotifications.notificationName)
//        let userInfo: [String : Object] = [CompletionSiwtchNotifications.key : item]
//        let notification = Notification(name: notificationName, object: self, userInfo: userInfo)
//        NotificationCenter.default.post(notification)
//    }

    private func setupCell() {
        self.backgroundColor = Color.midNightBlack
        self.contentView.backgroundColor = Color.clear
        self.itemTextView.textColor = Color.white
        self.itemTextView.tintColor = Color.orange
        self.itemTextView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.itemTextView.backgroundColor = Color.clear
        self.delegateLabel.backgroundColor = Color.clear
        self.delegateLabel.textColor = Color.lightGray
        self.separatorLabel.backgroundColor = Color.clear
        self.separatorLabel.textColor = Color.lightGray
        self.dateLabel.backgroundColor = Color.clear
        self.dateLabel.textColor = Color.lightGray
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        itemTextView.text = nil
        delegateLabel.text = nil
        separatorLabel.text = nil
        dateLabel.text = nil
    }

}




















