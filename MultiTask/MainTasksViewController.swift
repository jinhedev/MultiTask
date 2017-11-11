//
//  MainTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/10/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class MainTasksViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {

    // MARK: - API

    static let storyboard_id = String(describing: MainTasksViewController.self)

    // MARK: - MenuBarContainerView

    @IBOutlet weak var menuBarContainerView: UIView!
    var menuBarViewController: MenuBarViewController?

    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: [], animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBarViewController?.indicatorBarLeftAnchor?.constant = scrollView.contentOffset.x / 2 // because the collectionView is 2X as width as one menuBarViewController's cell
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / self.view.frame.width
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBarViewController?.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }

    // MARK: - UISearchController & UISearchResultsUpdating

    let searchController = UISearchController(searchResultsController: nil)

    private func setupSearchController() {
        // FIXME: problem with searchController being overlaid by MenuBarViewController
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = Color.white
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        searchController.searchBar.placeholder = "Search"
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
    }

    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text {
            // TODO: implement this
            print(searchString)
        }
    }

    // MARK: - UIRefreshControl

    let refreshControl = UIRefreshControl()

    private func setupRefreshControl() {
        refreshControl.tintColor = Color.lightGray
    }

    // MARK: - UICollectionView

    @IBOutlet weak var collectionView: UICollectionView!

    private func setupCollectionView() {
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: MainTasksCell.nibName, bundle: nil), forCellWithReuseIdentifier: MainTasksCell.cell_id)
        self.collectionView.isPagingEnabled = true
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.MenuBarContainerViewToMenuBarViewController {
            menuBarViewController = segue.destination as? MenuBarViewController
            menuBarViewController?.mainTasksViewController = self
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = self.collectionView.frame.width
        let collectionViewHeight = self.collectionView.frame.height
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: MainTasksCell.cell_id, for: indexPath) as? MainTasksCell {
            return cell
        } else {
            return UICollectionViewCell()
        }
    }

}



















