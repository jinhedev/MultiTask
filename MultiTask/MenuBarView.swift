//
//  MenuBarView.swift
//  MultiTask
//
//  Created by rightmeow on 12/5/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class MenuBarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MainTasksViewControllerDelegate {

    // MARK: - API

    var isEditing: Bool = false {
        didSet {
            self.setEditing()
        }
    }

    weak var mainTasksViewController: MainTasksViewController? {
        didSet {
            self.setupMainTasksViewControllerDelegate()
        }
    }

    var menus = [Menu(title: "Pending"), Menu(title: "Completed")]
    static let nibName = String(describing: MenuBarView.self)

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollIndicatorView: UIView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var scrollIndicatorViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollIndicatorViewHeightConstraint: NSLayoutConstraint!

    private func setEditing() {
        // FIXME: when scrolling very fast in edit mode, some items may not be visible, and the collectionView is not fast enough to turn them into editing mode.
        self.collectionView.allowsSelection = !isEditing
        self.scrollIndicatorView.backgroundColor = isEditing ? Color.darkGray : Color.mandarinOrange
        self.collectionView.isScrollEnabled = !isEditing
    }

    @objc func enableEditingMode() {
        self.isEditing = true
    }

    // MARK: - MainTasksViewControllerDelegate

    private func setupMainTasksViewControllerDelegate() {
        self.mainTasksViewController?.delegateForMenuBarView = self
    }

    func mainTasksViewController(_ viewController: MainTasksViewController, didTapEdit button: UIBarButtonItem, isEditing: Bool) {
        self.isEditing = isEditing
    }

    func mainTasksViewController(_ viewController: MainTasksViewController, didTapTrash button: UIBarButtonItem) {
        self.isEditing = false
    }

    // MARK: - Notifications

    func observeNotificationForEditingMode() {
        NotificationCenter.default.addObserver(self, selector: #selector(enableEditingMode), name: NSNotification.Name(rawValue: NotificationKey.CollectionViewEditingMode), object: nil)
    }

    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: MenuBarView.nibName, bundle: nil).instantiate(withOwner: self, options: nil)
        self.setupView()
        self.setupCollectionView()
        self.setupCollectionViewFlowLayout()
        self.observeNotificationForEditingMode()
    }

    // MARK: - View

    private func setupView() {
        self.addSubview(view)
        self.view.frame = self.bounds
        self.containerView.backgroundColor = Color.inkBlack
        self.scrollIndicatorView.backgroundColor = Color.mandarinOrange
        self.scrollIndicatorView.layer.cornerRadius = self.scrollIndicatorViewHeightConstraint.constant / 2
    }

    // MARK: - CollectionVew

    private func setupCollectionView() {
        self.collectionView.backgroundColor = Color.clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = Color.red
        self.collectionView.register(UINib(nibName: MenuBarCell.nibName, bundle: nil), forCellWithReuseIdentifier: MenuBarCell.cell_id)
        // initial selected state for the first cell
        let initialSelectedIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.selectItem(at: initialSelectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.top)
    }

    // MARK: - CollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.mainTasksViewController?.scrollToIndex(menuIndex: indexPath.item)
    }

    // MARK: - CollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: MenuBarCell.cell_id, for: indexPath) as? MenuBarCell {
            cell.menu = menus[indexPath.item]
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // MARK: - CollectionViewDelegateFlowLayout

    private func setupCollectionViewFlowLayout() {
        self.collectionViewFlowLayout.scrollDirection = .horizontal
        self.collectionViewFlowLayout.minimumLineSpacing = 0
        self.collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.collectionView.frame.width / 2
        let cellHeight = self.collectionView.frame.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
