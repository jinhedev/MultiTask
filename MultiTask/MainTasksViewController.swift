//
//  MainTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/10/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class MainTasksViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, UIViewControllerTransitioningDelegate, TaskEditorViewControllerDelegate {

    // MARK: - API

    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Plus"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleAdd(_:)))
        return button
    }()

    lazy var trashButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Trash"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleTrash(_:)))
        return button
    }()

    /// editButton can be toggled to become a cancel button when in edit mode
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "List"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleEdit(_:)))
        return button
    }()

    static let storyboard_id = String(describing: MainTasksViewController.self)
    let searchController = UISearchController(searchResultsController: nil)
    let popTransitionAnimator = PopTransitionAnimator()

    @IBOutlet weak var menuBarView: MenuBarView!
    @IBOutlet weak var mainCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mainCollectionView: UICollectionView!

    func scrollToIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        self.mainCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.mainCollectionView.allowsSelection = !editing
        self.addButton.isEnabled = !editing
        if editing {
            self.navigationItem.leftBarButtonItem = trashButton
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
        self.editButton.image = editing ? #imageLiteral(resourceName: "Delete") : #imageLiteral(resourceName: "List") // <<-- image literal
    }

    // MARK: - TaskEditorViewControllerDelegate

//    func taskEditorViewController(_ viewController: TaskEditorViewController, didAddTask task: Task, at indexPath: IndexPath?) {
//        viewController.dismiss(animated: true) {
//            // REMARK: When a new task is added pendingTasks in PendingTasksViewController, but if pendingTasks is still nil, PendingTasksViewController's realmNotification will not be able to track changes because pendingTasks == nil was never allocated on the RealmNotification's run loop. To fix this issue, do a manual fetch on the PendingTasksViewController to get everything kickstarted.
//            if self.tasksPageViewController?.pendingTasksViewController?.pendingTasks == nil {
//                self.tasksPageViewController?.pendingTasksViewController?.realmManager?.fetchTasks(predicate: Task.pendingPredicate, sortedBy: Task.createdAtKeyPath, ascending: false)
//            }
//        }
//    }

    func taskEditorViewController(_ viewController: TaskEditorViewController, didUpdateTask task: Task, at indexPath: IndexPath) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func taskEditorViewController(_ viewController: TaskEditorViewController, didCancelTask task: Task?, at indexPath: IndexPath?) {
        viewController.dismiss(animated: true, completion: nil)
    }

    // MARK: - NavigationBar

    private func setupNavigationBar() {
        self.isEditing = false
        // setup barButtons after the isEditting is set, otherwise setEditing get called.
        self.navigationItem.rightBarButtonItems = [addButton, editButton]
    }

    @objc func handleAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Segue.AddButtonToTaskEditorViewController, sender: self)
    }

    @objc func handleTrash(_ sender: UIBarButtonItem) {
        if self.isEditing == true {
            // if already in editMode, first commit trash and then exit editMode
            self.isEditing = false
            self.menuBarView?.isEditing = false
        }
    }

    @objc func handleEdit(_ sender: UIBarButtonItem) {
        if self.isEditing == true {
            // if already in editMode, exit editMode
            self.isEditing = false
            self.menuBarView?.isEditing = false
        } else {
            // if not in editMode, enter editMode
            self.isEditing = true
            self.menuBarView?.isEditing = true
            self.menuBarView?.isEditing = true
        }
    }

    // MARK: - SearchController & SearchResultsUpdating

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

    // MARK: - MenuBarView

    private func setupMenuBarView() {
        self.menuBarView.mainTasksViewController = self
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupCollectionView()
        self.setupMenuBarView()
        self.setupCollectionViewFlowLayout()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.AddButtonToTaskEditorViewController {
            if let taskEditorViewController = segue.destination as? TaskEditorViewController {
                taskEditorViewController.delegate = self
            }
        }
    }

    // MARK: - CollectionView

    private func setupCollectionView() {
        self.mainCollectionView.isPagingEnabled = true
        self.mainCollectionView.backgroundColor = Color.inkBlack
        self.mainCollectionView.dataSource = self
        self.mainCollectionView.delegate = self
        self.mainCollectionView.register(UINib(nibName: MainTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: MainTaskCell.cell_id)
    }

    // MARK: - ScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.menuBarView.scrollIndicatorViewHeightConstraint.constant = scrollView.contentOffset.x / 2
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let selectedIndexItem = targetContentOffset.pointee.x / self.mainCollectionView.frame.width
        let selectedIndexPath = IndexPath(item: Int(selectedIndexItem), section: 0)
        self.menuBarView.collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.left)
    }

    // MARK: - CollectionViewDelegate



    // MARK: - CollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let mainTaskCell = self.mainCollectionView.dequeueReusableCell(withReuseIdentifier: MainTaskCell.cell_id, for: indexPath) as? MainTaskCell else {
            return BaseCollectionViewCell()
        }
        return mainTaskCell
    }

    // MARK: - CollectionViewDelegateFlowLayout

    private func setupCollectionViewFlowLayout() {
        self.mainCollectionViewFlowLayout.scrollDirection = .horizontal
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: self.mainCollectionView.frame.width, height: self.mainCollectionView.frame.height)
        return cellSize
    }

    // MARK: - ViewControllerTransitioningDelegate

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
//            self.tasksContainerView.alpha = (size.width > size.height) ? 0.25 : 0.55
        }, completion: nil)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let addButtonView = self.addButton.value(forKey: "view") as? UIView {
            let barButtonFrame = addButtonView.frame
            popTransitionAnimator.originFrame = barButtonFrame
            popTransitionAnimator.isPresenting = true
            return popTransitionAnimator
        } else {
            return nil
        }
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // TODO: - implement this
        popTransitionAnimator.isPresenting = false
        return popTransitionAnimator
    }

}
