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
    var isCompleting: Bool = false { didSet { animateCell() } }
    var isDeleting: Bool = false { didSet { animateCell() } }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var itemTextView: UITextView!
    @IBOutlet weak var delegateLabel: UILabel!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    private func animateCell() {
        if isDeleting == true {
            UIView.animate(withDuration: 0.7, delay: 0, options: [.allowUserInteraction], animations: {
                self.containerView.backgroundColor = Color.red
            }, completion: nil)
        } else if isCompleting == true {
            UIView.animate(withDuration: 0.7, delay: 0, options: [.allowUserInteraction], animations: {
                self.containerView.backgroundColor = Color.seaweedGreen
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                self.setupCell()
            }, completion: nil)
        }
    }

    private func updateCell() {
        guard let item = self.item else { return }
        self.itemTextView.text = item.title
        self.idLabel.text = item.id
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
        self.selectionStyle = .none
        self.backgroundColor = Color.midNightBlack
        self.contentView.backgroundColor = Color.clear
        self.containerView.backgroundColor = Color.midNightBlack
        self.idLabel.textColor = Color.lightGray
        self.idLabel.backgroundColor = Color.clear
        self.separatorView.backgroundColor = Color.darkGray
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




















