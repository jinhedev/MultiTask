//
//  AvatarsViewController.swift
//  MultiTask
//
//  Created by rightmeow on 12/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class AvatarsViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PersistentContainerDelegate {

    // MAKR: - API

    var avatars: [Avatar]?
    var realmManager: RealmManager?
    static let storyboard_id = String(describing: AvatarsViewController.self)

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    private func fetchAvatarsFromPropertyList(for resource: String, of type: String) {
        var items = [Avatar]()
        guard let inputFile = Bundle.main.path(forResource: resource, ofType: type) else {
            print("AvatarsViewController: - Undefined property list")
            return
        }
        let inputArray = NSArray(contentsOfFile: inputFile)
        for inputItem in inputArray as! [Dictionary<String, String>] {
            let imageNameItem = Avatar(nameDictionary: inputItem)
            items.append(imageNameItem)
        }
        self.avatars = items
    }

    // MARK: - PersistentContainerDelegate

    private func setupPersistentContainerDelegate() {
        self.realmManager = RealmManager()
        self.realmManager!.delegate = self
    }

    func persistentContainer(_ manager: RealmManager, didFetchUsers users: Results<User>?) {
        guard let fetchedUsers = users else { return }
        if !fetchedUsers.isEmpty {

        }
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupUICollectionViewDelegateFlowLayout()
        self.setupPersistentContainerDelegate()
        self.realmManager?.fetchExistingUsers()
        self.fetchAvatarsFromPropertyList(for: "Avatars", of: "plist")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

    // MARK: - UICollectionView

    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: AvatarCell.nibName, bundle: nil), forCellWithReuseIdentifier: AvatarCell.cell_id)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    private func setupUICollectionViewDelegateFlowLayout() {
        self.collectionViewFlowLayout.minimumLineSpacing = 16
        self.collectionViewFlowLayout.minimumInteritemSpacing = 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return insets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.collectionView.frame.width / 2) - 16 - 8
        let cellHeight: CGFloat = cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCell.cell_id, for: indexPath) as? AvatarCell {
            cell.avatar = avatars?[indexPath.item]
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.avatars?.count ?? 0
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? AvatarCell {
            cell.isSelected = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? AvatarCell {
            cell.isSelected = false
        }
    }

}
