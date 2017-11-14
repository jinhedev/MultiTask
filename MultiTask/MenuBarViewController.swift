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
    var indicatorBar: UIView!

    func setupIndicatorBar() {
        indicatorBar = UIView()
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

    func indicatorBar(scrollTo point: CGFloat) {
        indicatorBarLeftAnchor?.constant = point
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    // MARK: - UICollectionView

    @IBOutlet weak var collectionView: UICollectionView!

    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = Color.red
        self.collectionView.register(UINib(nibName: MenuCell.nibName, bundle: nil), forCellWithReuseIdentifier: MenuCell.cell_id)
        // initial selected state for the first cell
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.left)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupCollectionViewFlowLayout()
        self.setupIndicatorBar()
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let x = CGFloat(indexPath.item) * self.collectionView.frame.width / 2
        indicatorBarLeftAnchor?.constant = x
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
            self.mainTasksViewController?.tasksPageViewController?.scrollToPageIndex(pageIndex: indexPath.item)
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    private func setupCollectionViewFlowLayout() {
        self.collectionViewFlowLayout.minimumLineSpacing = 0
        self.collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.collectionView.frame.width / 2
        let cellHeight = self.collectionView.frame.height
        return CGSize(width: cellWidth, height: cellHeight)
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
            return BaseCollectionViewCell()
        }
    }

}









