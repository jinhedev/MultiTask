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

    var item: Item? {
        didSet {
            self.configureCell(item: item)
        }
    }

    var selectedIndexPath: IndexPath?
    static let cell_id = String(describing: ItemCell.self)
    static let nibName = String(describing: ItemCell.self)
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var delegateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    
    /**
     Animate the background to indicate a cell is highlighted
     - parameter color: The backgroundColor of containerView animating into.
     - warning: Do NOT use this animation for cell editing action. There is a bug in the gesture control when the user swipe from delete back to its original position, the tableView somehow thinks is being swiped from the left to right. Subsequently, as animateForCompletion is triggered. This glitch may cause confusion to the user.
     */
    func animateForHighlight(isHighlighted: Bool) {
        if isHighlighted == true {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                self.containerView.backgroundColor = Color.mandarinOrange
                self.dateLabel.textColor = Color.lightGray
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                self.containerView.backgroundColor = Color.midNightBlack
                self.configureCell(item: self.item)
            }, completion: nil)
        }
    }

    private func configureCell(item: Item?) {
        guard let item = item else { return }
        self.titleTextView.text = item.title
        self.delegateLabel.text = item.delegate
        if item.is_completed == true {
            self.titleTextView.textColor = Color.lightGray
            self.dateLabel.textColor = Color.seaweedGreen
            self.dateLabel.text = "Completed " + item.updated_at!.toRelativeDate()
        } else if item.updated_at != nil {
            self.titleTextView.textColor = Color.white
            self.dateLabel.textColor = Color.mandarinOrange
            self.dateLabel.text = "Updated " + item.updated_at!.toRelativeDate()
        } else {
            // this includes the case of when is_completed == false
            self.titleTextView.textColor = Color.white
            self.dateLabel.textColor = Color.lightGray
            self.dateLabel.text = "Created " + item.created_at.toRelativeDate()
        }
    }

    private func setupCell() {
        self.selectionStyle = .none
        self.backgroundColor = Color.inkBlack
        self.contentView.backgroundColor = Color.inkBlack
        self.containerView.backgroundColor = Color.midNightBlack
        self.titleTextView.textColor = Color.white
        self.titleTextView.tintColor = Color.miamiBlue
        self.titleTextView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.titleTextView.backgroundColor = Color.clear
        self.delegateLabel.backgroundColor = Color.clear
        self.delegateLabel.textColor = Color.lightGray
        self.dateLabel.backgroundColor = Color.clear
        self.dateLabel.textColor = Color.lightGray
        self.dividerView.backgroundColor = Color.darkGray
    }

    private func resetDataForReuse() {
        self.titleTextView.text?.removeAll()
        self.delegateLabel.text?.removeAll()
        self.dateLabel.text?.removeAll()
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetDataForReuse()
    }

}




















