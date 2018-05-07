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

    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "FloppyDisk"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleSave(_:)))
        button.isEnabled = false
        return button
    }()

    var currentUser: User?
    var avatars: [Avatar]?
    var realmManager: RealmManager?
    static let storyboard_id = String(describing: AvatarsViewController.self)

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    @objc func handleSave(_ sender: UIBarButtonItem) {
        guard let user = currentUser, let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else { return }
        if let selectedAvatarName = avatars?[selectedIndexPath.item].name {
            self.realmManager?.updateObject(object: user, keyedValues: ["avatar" : selectedAvatarName])
        }
    }

    private func fetchAvatarsFromPropertyList(for resource: String, of type: String) {
        var items = [Avatar]()
        guard let path = Bundle.main.path(forResource: resource, ofType: type) else {
            print("AvatarsViewController: - Undefined property list")
            return
        }
        let inputArray = NSArray(contentsOfFile: path)
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

    func persistentContainer(_ manager: RealmManager, didUpdateObject object: Object) {
        if let baseNavController = self.navigationController as? BaseNavigationController {
            baseNavController.popViewController(animated: true)
        }
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    // MARK: - UINavigationBar

    private func setupUINavigationBar() {
        navigationItem.rightBarButtonItem = saveButton
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUINavigationBar()
        self.setupCollectionView()
        self.setupUICollectionViewDelegateFlowLayout()
        self.setupPersistentContainerDelegate()
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
        let cellWidth = (self.collectionView.frame.width / 3) - 16 - 8
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
        if let selectedItemsCount = self.collectionView.indexPathsForSelectedItems?.count {
            self.saveButton.isEnabled = selectedItemsCount > 0 ? true : false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? AvatarCell {
            cell.isSelected = false
        }
        if let selectedItemsCount = self.collectionView.indexPathsForSelectedItems?.count {
            self.saveButton.isEnabled = selectedItemsCount > 0 ? true : false
        }
    }

}
