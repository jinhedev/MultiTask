//
//  ItemCell.swift
//  MultiTask
//
//  Created by rightmeow on 8/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class PendingItemCell: UITableViewCell {

    var item: Item? {
        didSet {
            updateCell()
        }
    }

    static let id = String(describing: PendingItemCell.self)

    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var completionSwitch: UISwitch!

    private func updateCell() {
        // STEP 1: reset any existing UI info/outlets, otherwise info could become misplaced
        noteTextView?.text = nil
        // STEP 2: load new info from user (if any)
        if let item = self.item {
            noteTextView.text = item.note
            completionSwitch.isOn = item.is_completed
        }
    }

    private func setupViews() {
        completionSwitch.isOn = false
        self.noteTextView.textColor = Color.lightGray
        self.backgroundColor = Color.midNightBlack
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

}
