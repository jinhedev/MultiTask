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
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBar()
    }

}
