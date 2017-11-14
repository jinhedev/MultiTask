//
//  DynamicNavigationController.swift
//  MultiTask
//
//  Created by rightmeow on 10/1/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    // MARK: - API

    private func setupNavigationBar() {
        self.navigationBar.barTintColor = Color.midNightBlack
        self.navigationBar.tintColor = Color.orange
        self.navigationBar.isTranslucent = false
        self.navigationBar.layer.shadowColor = Color.black.cgColor
        self.navigationBar.layer.shadowRadius = 3.0
        self.navigationBar.layer.shadowOpacity = 0.5
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

}

















