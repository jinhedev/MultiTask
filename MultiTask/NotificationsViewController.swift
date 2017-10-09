//
//  SettingsViewController.swift
//  MultiTask
//
//  Created by rightmeow on 10/1/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    // MARK: - API

    @IBOutlet weak var collectionView: UICollectionView!

    private func setupView() {
        self.view.backgroundColor = Color.inkBlack
    }

    private func setupCollectionView() {
        self.collectionView.backgroundColor = Color.inkBlack
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
    }

}
