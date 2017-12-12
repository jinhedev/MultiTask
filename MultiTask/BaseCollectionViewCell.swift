//
//  BaseCell.swift
//  MultiTask
//
//  Created by rightmeow on 11/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {

    private func setupCell() {
        self.backgroundColor = Color.inkBlack
        self.contentView.backgroundColor = Color.clear
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
