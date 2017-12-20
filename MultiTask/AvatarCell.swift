//
//  AvatarCell.swift
//  MultiTask
//
//  Created by rightmeow on 12/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class AvatarCell: BaseCollectionViewCell {

    // MARK: - API

    var avatar: Avatar? {
        didSet {
            self.updateCell()
        }
    }

    override var isSelected: Bool {
        didSet {
            self.setSelected()
        }
    }

    static let cell_id = String(describing: AvatarCell.self)
    static let nibName = String(describing: AvatarCell.self)

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!

    private func setSelected() {
        self.containerView.layer.borderColor = isSelected ? Color.mandarinOrange.cgColor : Color.darkGray.cgColor
    }

    private func updateCell() {
        if let unwrappedAvatar = self.avatar, let image = UIImage(named: unwrappedAvatar.name) {
            avatarImageView.image = image
        }
    }

    private func setupCell() {
        self.backgroundColor = Color.midNightBlack
        self.containerView.backgroundColor = Color.midNightBlack
        self.containerView.layer.cornerRadius = 8
        self.containerView.clipsToBounds = true
        self.containerView.layer.borderColor = Color.darkGray.cgColor
        self.containerView.layer.borderWidth = 3
        self.avatarImageView.backgroundColor = Color.clear
        self.avatarImageView.contentMode = .scaleAspectFill
    }

    private func resetDataForReuse() {
        self.avatarImageView.image = nil
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
