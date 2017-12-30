//
//  DynamicTabBarController.swift
//  MultiTask
//
//  Created by rightmeow on 10/1/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import AVFoundation

class BaseTabBarController: UITabBarController, SoundEffectDelegate {

    // MARK: - API

    var soundEffectManager: SoundEffectManager?

    private func setupTabBar() {
        self.tabBar.barTintColor = Color.inkBlack
        self.tabBar.tintColor = Color.mandarinOrange
        self.tabBar.isTranslucent = false
    }

    // MARK: - SoundEffectDelegate

    private func setupSoundEffectDelegate() {
        self.soundEffectManager = SoundEffectManager()
        self.soundEffectManager!.delegate = self
    }

    func soundEffect(_ manager: SoundEffectManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func soundEffect(_ manager: SoundEffectManager, didPlaySoundEffect soundEffect: SoundEffect, player: AVAudioPlayer) {
        // implement this if needed
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBar()
        self.setupSoundEffectDelegate()
    }

    // MARK: - UITabBarControllerDelegate

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.soundEffectManager?.play(soundEffect: SoundEffect.Click)
    }

}
