//
//  BaseTableViewCell.swift
//  MultiTask
//
//  Created by rightmeow on 11/12/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    private func setupCell() {
        self.backgroundColor = Color.inkBlack
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
