//
//  DynamicTabBarController.swift
//  MultiTask
//
//  Created by rightmeow on 10/1/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    // MARK: - API

    private func setupTabBar() {
        self.tabBar.barTintColor = Color.inkBlack
        self.tabBar.tintColor = Color.mandarinOrange
        self.tabBar.isTranslucent = false
        self.tabBar.layer.shadowOpacity = 0.5
        self.tabBar.layer.shadowRadius = 3.0
        self.tabBar.layer.shadowColor = Color.black.cgColor
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBar()
    }

}
