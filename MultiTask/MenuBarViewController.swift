//
//  MenuBarViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

protocol MenuBarViewControllerDelegate {
    func numberOfMenus(in menuBarViewController: MenuBarViewController) -> Int
}

extension MenuBarViewControllerDelegate {
    func numberOfMenus(in menuBarViewController: MenuBarViewController) -> Int { return 0 }
}

class MenuBarViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    // MARK: - API

    static let storyboard_id = String(describing: MenuBarViewController.self)
    var menus = [Menu(title: "Pending"), Menu(title: "Completed")]
    var mainTasksViewController: MainTasksViewController?

    // MARK: - Horizontal indicator bar

    var indicatorBarLeftAnchor: NSLayoutConstraint?

    func setupIndicatorBar() {
        let indicatorBar = UIView()
        indicatorBar.backgroundColor = Color.mandarinOrange
        indicatorBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicatorBar)
        // constraints
        indicatorBarLeftAnchor = indicatorBar.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        indicatorBarLeftAnchor?.isActive = true
        indicatorBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        indicatorBar.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/2).isActive = true
        indicatorBar.heightAnchor.constraint(equalToConstant: 3).isActive = true
    }

    // MARK: - UICollectionView

    @IBOutlet weak var collectionView: UICollectionView!

    private func setupCollectionView() {
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: MenuCell.nibName, bundle: nil), forCellWithReuseIdentifier: MenuCell.cell_id)
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.left)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupIndicatorBar()
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mainTasksViewController?.scrollToMenuIndex(menuIndex: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = self.collectionView.frame.width
        let collectionViewHeight = self.collectionView.frame.height
        return CGSize(width: collectionViewWidth / 2, height: collectionViewHeight)
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: MenuCell.cell_id, for: indexPath) as? MenuCell {
            cell.menu = menus[indexPath.item]
            return cell
        } else {
            return UICollectionViewCell()
        }
    }

}









