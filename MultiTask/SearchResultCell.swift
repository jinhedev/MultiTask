//
//  SearchResultCell.swift
//  MultiTask
//
//  Created by rightmeow on 11/20/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class SearchResultCell: BaseTableViewCell {

    // MARK: - API

    var item: Item? {
        didSet {
            self.configureCell(item: item)
        }
    }

    static let cell_id = String(describing: SearchResultCell.self)
    static let nibName = String(describing: SearchResultCell.self)

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    private func configureCell(item: Item?) {
        if let item = item {
            self.titleLabel.text = item.title
            self.titleLabel.textColor = item.is_completed ? Color.seaweedGreen : Color.white
        }
    }

    private func setupCell() {
        self.selectionStyle = .none
        self.backgroundColor = Color.clear
        self.contentView.backgroundColor = Color.clear
        self.containerView.backgroundColor = Color.midNightBlack
        self.containerView.layer.cornerRadius = 8
        self.containerView.clipsToBounds = true
        self.titleLabel.backgroundColor = Color.clear
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
    }

}
