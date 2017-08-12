//
//  ItemCell.swift
//  MultiTask
//
//  Created by rightmeow on 8/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    var item: Item? {
        didSet {
            updateCell()
        }
    }

    static let id = String(describing: ItemCell.self)

    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completionSwitch: UISwitch!

    private func updateCell() {
        // STEP 1: reset any existing UI info/outlets, otherwise info could become misplaced
        noteLabel?.text = nil
        // STEP 2: load new info from user (if any)
        if let item = self.item {
            if item.is_completed == false {
                noteLabel.textColor = Color.white
            } else {
                noteLabel.textColor = Color.lightGray
            }
            noteLabel.text = item.note
            completionSwitch.isOn = item.is_completed
        }
    }

    @IBAction func toggleCompletion(_ sender: UISwitch) {
        postNotification(is_completed: sender.isOn)
    }

    private func postNotification(is_completed: Bool) {
        let notificationName = NSNotification.Name(rawValue: CompletionSiwtchNotifications.notification)
        let userInfo: [String : Bool] = ["is_completed" : is_completed]
        let notification = Notification(name: notificationName, object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }

    private func setupViews() {
        completionSwitch.isOn = false
        self.noteLabel.textColor = Color.white
        self.backgroundColor = Color.midNightBlack
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

}

struct CompletionSiwtchNotifications {
    static let key: String = "CompletionSwitch"
    static let notification: String = "CompletionSwitchValueDidChange"
}




















