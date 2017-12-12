//
//  BranchesViewController.swift
//  MultiTask
//
//  Created by rightmeow on 12/5/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class StashViewController: BaseViewController, PersistentContainerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - API

    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "List"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleEdit(_:)))
        return button
    }()

    lazy var popButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Trash"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleTrash(_:)))
        return button
    }()

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
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: StashedTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: StashedTaskCell.cell_id)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return insets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.collectionView.frame.width
        let cellHeight: CGFloat = 8 + 16 + 22 + 8 + 15 + 16 + 8
        return CGSize(width: cellWidth, height: cellHeight)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        //
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        //
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: StashedTaskCell.cell_id, for: indexPath) as? StashedTaskCell {
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

}
