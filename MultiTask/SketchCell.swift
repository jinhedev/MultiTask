//
//  StashedTaskCell.swift
//  MultiTask
//
//  Created by rightmeow on 12/12/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class SketchCell: BaseCollectionViewCell {

    // MARK: - API

    override var isHighlighted: Bool {
        didSet {
            self.setHighlighted()
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
    static let cell_id = String(describing: SketchCell.self)
    static let nibName = String(describing: SketchCell.self)

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sketchImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    private func setHighlighted() {
        self.containerView.backgroundColor = self.isHighlighted ? Color.mediumBlueGray : Color.midNightBlack
    }

    private func setEditing() {

    }

    private func setSelected() {

    }

    private func setupCell() {
        self.containerView.backgroundColor = Color.midNightBlack
        self.containerView.layer.cornerRadius = 8
        self.titleLabel.backgroundColor = Color.clear
        self.titleLabel.textColor = Color.white
    }

    private func resetDataForReuse() {
        self.titleLabel.text?.removeAll()
    }

    // MARK: - Notifications

    private func setupLongPressGestureRecognizer() {
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(postNotificationForTaskEditing(gestureRecognizer:)))
        self.longPressGestureRecognizer!.allowableMovement = 22
        self.longPressGestureRecognizer!.minimumPressDuration = 1.3
        self.containerView.addGestureRecognizer(self.longPressGestureRecognizer!)
    }

    @objc func postNotificationForTaskEditing(gestureRecognizer: UILongPressGestureRecognizer) {
        if self.isEditing == false && gestureRecognizer.minimumPressDuration >= 1.3 {
            let notification = Notification(name: Notification.Name(rawValue: NotificationKey.StashedTaskCellEditingMode), object: nil, userInfo: [NotificationKey.StashedTaskCellEditingMode : true])
            NotificationCenter.default.post(notification)
        }
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
