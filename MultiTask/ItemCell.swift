//
//  ItemCell.swift
//  MultiTask
//
//  Created by rightmeow on 8/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class ItemCell: BaseTableViewCell {

    // MARK: - API

    var item: Item? { didSet { configureCell(item: item) } }

    static let cell_id = String(describing: ItemCell.self)
    static let nibName = String(describing: ItemCell.self)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var delegateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func animateForDeletion(color: Color) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.containerView.backgroundColor = Color.red
        }, completion: nil)
    }

    /**
     Animate the background to indicate a cell's task is being marked as completed
     - parameter color: The backgroundColor of containerView animating into.
     - warning: There is a bug in the gesture control when the user swipe from delete back to its original position, the tableView somehow thinks is being swiped from the left to right. Subsequently, animateForCompletion is triggered. This glitch may cause confusion to the user.
     */
    func animateForCompletion(color: Color) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.containerView.backgroundColor = Color.seaweedGreen
        }, completion: nil)
    }

    func animateForDefault() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.containerView.backgroundColor = Color.midNightBlack
        }, completion: nil)
    }

    private func configureCell(item: Item?) {
        guard let item = item else { return }
        self.titleTextView.text = item.title
        self.subtitleLabel.text = item.id
        self.delegateLabel.text = item.delegate
        if item.completed_at != nil {
            self.titleTextView.textColor = Color.lightGray
            self.dateLabel.textColor = Color.seaweedGreen
            self.dateLabel.text = "Completed " + item.completed_at!.toRelativeDate()
        } else if item.updated_at != nil {
            self.titleTextView.textColor = Color.white
            self.dateLabel.textColor = Color.mandarinOrange
            self.dateLabel.text = "Updated " + item.updated_at!.toRelativeDate()
        } else {
            self.titleTextView.textColor = Color.white
            self.dateLabel.textColor = Color.lightGray
            self.dateLabel.text = "Created " + item.created_at.toRelativeDate()
        }
    }

    private func setupCell() {
        self.selectionStyle = .none
        self.contentView.backgroundColor = Color.inkBlack
        self.containerView.backgroundColor = Color.midNightBlack
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 8
        self.subtitleLabel.textColor = Color.lightGray
        self.subtitleLabel.backgroundColor = Color.clear
        self.titleTextView.textColor = Color.white
        self.titleTextView.tintColor = Color.miamiBlue
        self.titleTextView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.titleTextView.backgroundColor = Color.clear
        self.delegateLabel.backgroundColor = Color.clear
        self.delegateLabel.textColor = Color.lightGray
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
        titleTextView.text = nil
        delegateLabel.text = nil
        dateLabel.text = nil
    }

}




















