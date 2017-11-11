//
//  TaskHeaderView.swift
//  MultiTask
//
//  Created by rightmeow on 10/8/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class TaskHeaderView: UITableViewHeaderFooterView {

    // AMRK: - API

    static let nibName = String(describing: TaskHeaderView.self)
    static let header_id = String(describing: TaskHeaderView.self)
    @IBOutlet weak var segmentedControl: UISegmentedControl! { didSet { updateView() } }

    private func updateView() {
        // TODO: implement this
    }

    private func setupView() {
        self.contentView.backgroundColor = Color.inkBlack
        self.segmentedControl.backgroundColor = Color.clear
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

}
