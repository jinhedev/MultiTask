//
//  DynamicTabBarController.swift
//  MultiTask
//
//  Created by rightmeow on 10/1/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import AVFoundation

class BaseTabBarController: UITabBarController {

    // MARK: - API

    private func setupTabBar() {
        self.tabBar.barTintColor = Color.inkBlack
        self.tabBar.tintColor = Color.mandarinOrange
        self.tabBar.isTranslucent = false
    }
    
    private func removeTabBarItemsText() {
        // FIXME: it doesn't work?!?
        if let items = tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBar()
        self.removeTabBarItemsText()
    }

    // MARK: - UITabBarControllerDelegate

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        SoundEffectManager.shared.play(soundEffect: SoundEffect.Click)
    }

}
