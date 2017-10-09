//
//  TaskHeaderView.swift
//  MultiTask
//
//  Created by rightmeow on 10/8/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class TaskHeaderView: UIView {

    // AMRK: - API

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    private func setupView() {
        self.backgroundColor = Color.inkBlack
        self.segmentedControl.backgroundColor = Color.clear
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

}
