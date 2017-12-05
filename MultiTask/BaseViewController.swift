//
//  BaseViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import AVFoundation

class BaseViewController: UIViewController {

    // MARK: - API

    func initPlaceholderBackgroundView(type: PlaceholderType) -> UIView? {
        if let view = UINib(nibName: PlaceholderBackgroundView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? PlaceholderBackgroundView {
            view.type = type
            view.isHidden = true
            return view
        } else {
            return nil
        }
    }

    private func setupView() {
        self.view.backgroundColor = Color.inkBlack
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

}


















