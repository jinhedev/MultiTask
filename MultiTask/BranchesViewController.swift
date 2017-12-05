//
//  BranchesViewController.swift
//  MultiTask
//
//  Created by rightmeow on 12/5/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class BranchesViewController: BaseViewController {

    // MARK: - API

    @IBOutlet weak var collectionView: UICollectionView!

    lazy var avatarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Starfish"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleAvatar))
        return barButtonItem
    }()

    // MARK: - NavigationBar

    @objc func handleAvatar() {
        // TODO: implement this
    }

    private func setupNavigationBar() {
        self.navigationItem.rightBarButtonItems = [avatarButton]
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupCollectionView()
    }

    // MARK: - CollectionView

    private func setupCollectionView() {
        self.collectionView.backgroundColor = Color.inkBlack
    }

}
