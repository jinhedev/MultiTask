//
//  BranchesViewController.swift
//  MultiTask
//
//  Created by rightmeow on 12/5/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class StashViewController: BaseViewController, PersistentContainerDelegate {

    // MARK: - API

    var realmManager: RealmManager?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    lazy var avatarButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(#imageLiteral(resourceName: "DeadEmoji"), for: UIControlState.normal)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.layer.borderColor = Color.lightGray.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleAvatar), for: UIControlEvents.touchUpInside)
        return button
    }()

    static let storyboard_id = String(describing: StashViewController.self)

    // MARK: - NavigationBar

    @objc func handleAvatar() {
        self.performSegue(withIdentifier: Segue.AvatarButtonToSettingsViewController, sender: self)
    }

    private func setupNavigationBar() {
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: avatarButton)]
    }

    // MARK: - PersistentContainerDelegate

    private func setupPersistentContainerDelegate() {
        self.realmManager = RealmManager()
        self.realmManager!.delegate = self
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didFetchUsers users: Results<User>?) {
        guard let fetchedUsers = users else { return }
        if !fetchedUsers.isEmpty {
            self.avatarButton.setImage(#imageLiteral(resourceName: "RubberDuck"), for: UIControlState.normal)
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupCollectionView()
        self.setupPersistentContainerDelegate()
        self.realmManager?.fetchExistingUsers()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Segue.AvatarButtonToSettingsViewController {
            guard let stashViewController = self.storyboard?.instantiateViewController(withIdentifier: StashViewController.storyboard_id) as? StashViewController else { return }
            stashViewController.hidesBottomBarWhenPushed = false
        }
    }

    // MARK: - CollectionView

    private func setupCollectionView() {
        self.collectionView.backgroundColor = Color.inkBlack
    }

}
