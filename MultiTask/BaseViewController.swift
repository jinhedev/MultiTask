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

    func initPlaceholderBackgroundView(type: PlaceholderType) -> PlaceholderBackgroundView? {
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

    private func animateView(didAppear: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: { [weak self] in
            self?.view.alpha = didAppear ? 1.0 : 0.5
        }, completion: nil)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateView(didAppear: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.animateView(didAppear: false)
    }

}
