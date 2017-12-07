//
//  MenuCell.swift
//  MultiTask
//
//  Created by rightmeow on 11/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class MenuBarCell: BaseCollectionViewCell {

    // MARK: - API

    override var isHighlighted: Bool {
        didSet {
            self.titleLabel.textColor = isHighlighted ? UIColor.white : Color.lightGray
        }
    }

    override var isSelected: Bool {
        didSet {
            self.titleLabel.textColor = isSelected ? UIColor.white : Color.lightGray
        }
    }

    var menu: Menu? { didSet { self.configureCell(menu: menu) } }
    static let cell_id = String(describing: MenuBarCell.self)
    static let nibName = String(describing: MenuBarCell.self)

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    private func resetDataForReuse() {
        self.titleLabel.text?.removeAll()
    }

    private func configureCell(menu: Menu?) {
        if let menu = menu {
            self.titleLabel.text = menu.title
        }
    }

    private func setupCell() {
        self.containerView.backgroundColor = Color.inkBlack
        self.titleLabel.backgroundColor = Color.clear
        self.titleLabel.textColor = Color.lightGray
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




















