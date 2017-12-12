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

    var timer: Timer?

    func scheduleNavigationPrompt(with message: String, duration: TimeInterval) {
        UIView.animate(withDuration: 0.3) {
            self.navigationItem.prompt = message
        }
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: duration,
                                              target: self,
                                              selector: #selector(self.removePrompt),
                                              userInfo: nil,
                                              repeats: false)
            self.timer?.tolerance = 5
        }
    }

    @objc private func removePrompt() {
        if self.navigationItem.prompt  != nil {
            DispatchQueue.main.async {
                self.navigationItem.prompt = nil
                self.timer?.invalidate()
            }
        }
    }

    private func setupNavigationBar() {
//        self.navigationBar.barStyle = .black
        self.navigationBar.barTintColor = Color.midNightBlack
        self.navigationBar.tintColor = Color.mandarinOrange
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
