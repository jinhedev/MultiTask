//
//  StatsCell.swift
//  MultiTask
//
//  Created by rightmeow on 11/22/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class StatsCell: BaseTableViewCell {

    // MARK: - API

    private func setupCell() {
        // TODO: implement this
    }

    private func resetDataForReuse() {
        // TODO: implement this
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
