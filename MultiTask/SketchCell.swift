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

    var sketch: Sketch? {
        didSet {
            self.updateCell()
        }
    }

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

    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sketchImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    private func setHighlighted() {
        self.containerView.backgroundColor = self.isHighlighted ? Color.mediumBlueGray : Color.midNightBlack
    }

    private func setEditing() {
        // FIXME: There is a UI bug when a cell is finished editing, its content is still remained squeezed due to the change of cell's size during animation.
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction], animations: {
            self.checkmarkImageView.isHidden = self.isEditing ? false : true
            self.containerView.transform = self.isEditing ? CGAffineTransform.init(scaleX: 0.94, y: 0.94) : CGAffineTransform.identity
        }, completion: nil)
    }

    private func setSelected() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction], animations: {
            self.containerView.transform = self.isSelected ? CGAffineTransform.init(scaleX: 0.97, y: 0.97) : CGAffineTransform.init(scaleX: 0.94, y: 0.94)
            self.containerView.layer.borderColor = self.isSelected ? Color.roseScarlet.cgColor : Color.midNightBlack.cgColor
            self.checkmarkImageView.backgroundColor = self.isSelected ? Color.roseScarlet : Color.inkBlack
        }, completion: nil)
    }

    private func updateCell() {
        guard let unwrappedSketch = sketch else { return }
        self.sketchImageView.image = UIImage(data: unwrappedSketch.imageData! as Data)
        self.titleLabel.text = unwrappedSketch.title
    }

    private func setupCell() {
        self.checkmarkImageView.layer.cornerRadius = 11
        self.checkmarkImageView.clipsToBounds = true
        self.checkmarkImageView.layer.borderColor = Color.white.cgColor
        self.checkmarkImageView.layer.borderWidth = 1
        self.checkmarkImageView.backgroundColor = Color.inkBlack
        self.checkmarkImageView.isHidden = true
        self.frameView.backgroundColor = Color.inkBlack
        self.frameView.clipsToBounds = true
        self.containerView.backgroundColor = Color.midNightBlack
        self.containerView.layer.cornerRadius = 8
        self.containerView.clipsToBounds = true
        self.containerView.layer.borderColor = Color.midNightBlack.cgColor
        self.containerView.layer.borderWidth = 1
        self.sketchImageView.enableParallaxMotion(magnitude: 14)
        self.sketchImageView.contentMode = .scaleAspectFill
        self.sketchImageView.backgroundColor = Color.inkBlack
        self.titleLabel.backgroundColor = Color.clear
        self.titleLabel.textColor = Color.white
    }

    private func resetDataForReuse() {
        self.sketchImageView.image = nil
        self.titleLabel.text?.removeAll()
    }

    // MARK: - Notifications

    private func setupLongPressGestureRecognizer() {
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(postNotificationForSketchEditing(gestureRecognizer:)))
        self.longPressGestureRecognizer!.allowableMovement = 22
        self.longPressGestureRecognizer!.minimumPressDuration = 1.3
        self.containerView.addGestureRecognizer(self.longPressGestureRecognizer!)
    }

    @objc func postNotificationForSketchEditing(gestureRecognizer: UILongPressGestureRecognizer) {
        if self.isEditing == false && gestureRecognizer.minimumPressDuration >= 1.3 {
            let notification = Notification(name: Notification.Name(rawValue: NotificationKey.SketchCellEditingMode), object: nil, userInfo: [NotificationKey.SketchCellEditingMode : true])
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
