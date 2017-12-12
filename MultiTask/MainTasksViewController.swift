//
//  MainTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/10/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

protocol MainTasksViewControllerDelegate: NSObjectProtocol {
    func mainTasksViewController(_ viewController: MainTasksViewController, didTapEdit button: UIBarButtonItem, isEditing: Bool)
    func mainTasksViewController(_ viewController: MainTasksViewController, didTapTrash button: UIBarButtonItem)
}

class MainTasksViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, TaskEditorViewControllerDelegate, UITabBarControllerDelegate {

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

    var mainPendingTasksCell: MainPendingTasksCell?
    var mainCompletedTasksCell: MainCompletedTasksCell?
    weak var delegateForMenuBarView: MainTasksViewControllerDelegate? // set in MenuBarView
    weak var delegateForPendingTasksCell: MainTasksViewControllerDelegate? // set in MainPendingTasksCell
    weak var delegateForCompletedTasksCell: MainTasksViewControllerDelegate? // set in MainCompletedTasksCell

    static let storyboard_id = String(describing: MainTasksViewController.self)
    let searchController = UISearchController(searchResultsController: nil)
    let popTransitionAnimator = PopTransitionAnimator()
    let navigationItemTitles = ["Pending, Completed"]

    @IBOutlet weak var menuBarView: MenuBarView!
    @IBOutlet weak var mainCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mainCollectionView: UICollectionView!

    func scrollToIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        self.mainCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.mainCollectionView.isScrollEnabled = !editing
        self.addButton.isEnabled = !editing
        self.navigationItem.leftBarButtonItem = editing ? trashButton : nil
        self.editButton.image = editing ? #imageLiteral(resourceName: "Delete") : #imageLiteral(resourceName: "List") // <<-- image literal
    }

    @objc func enableEditingMode() {
        self.isEditing = true
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
            self.delegateForMenuBarView?.mainTasksViewController(self, didTapTrash: sender)
            self.delegateForCompletedTasksCell?.mainTasksViewController(self, didTapTrash: sender)
            self.delegateForPendingTasksCell?.mainTasksViewController(self, didTapTrash: sender)
            self.isEditing = false
        } else {
            print(trace(file: #file, function: #function, line: #line))
        }
    }

    @objc func handleEdit(_ sender: UIBarButtonItem) {
        // toggling edit mode
        if self.isEditing == true {
            // if already in editMode, exit editMode
            self.isEditing = false
            self.delegateForMenuBarView?.mainTasksViewController(self, didTapEdit: sender, isEditing: false)
            self.delegateForPendingTasksCell?.mainTasksViewController(self, didTapEdit: sender, isEditing: false)
            self.delegateForCompletedTasksCell?.mainTasksViewController(self, didTapEdit: sender, isEditing: false)
        } else {
            // if not in editMode, enter editMode
            self.isEditing = true
            self.delegateForMenuBarView?.mainTasksViewController(self, didTapEdit: sender, isEditing: true)
            self.delegateForPendingTasksCell?.mainTasksViewController(self, didTapEdit: sender, isEditing: true)
            self.delegateForCompletedTasksCell?.mainTasksViewController(self, didTapEdit: sender, isEditing: true)
        }
    }

    // MARK: - MenuBarView

    private func setupMenuBarView() {
        self.menuBarView.mainTasksViewController = self
    }

    // MARK: - TaskEditorViewControllerDelegate

    func taskEditorViewController(_ viewController: TaskEditorViewController, didAddTask task: Task) {
        if let navigationController = viewController.navigationController {
            navigationController.popViewController(animated: true)
            // REMARK: When a new task is added pendingTasks in PendingTasksViewController, but if pendingTasks is still nil, PendingTasksViewController's realmNotification will not be able to track changes because pendingTasks == nil was never allocated on the RealmNotification's run loop. To fix this issue, do a manual fetch on the PendingTasksViewController to get everything kickstarted.
            if self.mainPendingTasksCell?.pendingTasks == nil {
                self.mainPendingTasksCell?.realmManager?.fetchTasks(predicate: Task.pendingPredicate, sortedBy: Task.createdAtKeyPath, ascending: false)
            }
        }
    }

    func taskEditorViewController(_ viewController: TaskEditorViewController, didUpdateTask task: Task) {
        if let navigationController = viewController.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    // MARK: - Notifications

    func observeNotificationForEditingMode() {
        NotificationCenter.default.addObserver(self, selector: #selector(enableEditingMode), name: NSNotification.Name(rawValue: NotificationKey.PendingTaskCellEditingMode), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enableEditingMode), name: NSNotification.Name(rawValue: NotificationKey.CompletedTaskCellEditingMode), object: nil)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupUITabBarControllerDelegate()
        self.setupCollectionView()
        self.setupMenuBarView()
        self.setupCollectionViewFlowLayout()
        self.observeNotificationForEditingMode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITabBarControllerDelegate

    private func setupUITabBarControllerDelegate() {
        if let baseTabBarController = self.tabBarController as? BaseTabBarController {
            baseTabBarController.delegate = self
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let selectedIndex = tabBarController.viewControllers?.index(of: viewController) {
            if selectedIndex == 0 {
                let topIndexPath = IndexPath(item: 0, section: 0)
                if self.menuBarView.selectedIndexPath?.item == 0 {
                    // you are looking at the mainPendingCell
                    guard let tasks = self.mainPendingTasksCell?.pendingTasks else { return }
                    if !tasks.isEmpty {
                        self.mainPendingTasksCell?.collectionView.scrollToItem(at: topIndexPath, at: UICollectionViewScrollPosition.top, animated: true)
                    }
                } else {
                    // looking at the mainCompletedCell
                    guard let tasks = self.mainCompletedTasksCell?.completedTasks else { return }
                    if !tasks.isEmpty {
                        self.mainCompletedTasksCell?.collectionView.scrollToItem(at: topIndexPath, at: UICollectionViewScrollPosition.top, animated: true)
                    }
                }
            }
        }
    }

    // MARK: - CollectionView

    private func setupCollectionView() {
        self.mainCollectionView.isPagingEnabled = true
        self.mainCollectionView.backgroundColor = Color.inkBlack
        self.mainCollectionView.dataSource = self
        self.mainCollectionView.delegate = self
        self.mainCollectionView.register(UINib(nibName: MainPendingTasksCell.nibName, bundle: nil), forCellWithReuseIdentifier: MainPendingTasksCell.cell_id)
        self.mainCollectionView.register(UINib(nibName: MainCompletedTasksCell.nibName, bundle: nil), forCellWithReuseIdentifier: MainCompletedTasksCell.cell_id)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Segue.AddButtonToTaskEditorViewController {
            if let taskEditorViewController = segue.destination as? TaskEditorViewController {
                taskEditorViewController.delegate = self
            }
        }
    }

    // MARK: - ScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // synchronising the scrolling position between menuBarView and the mainTasksCollectionView
        self.menuBarView.scrollIndicatorViewLeadingConstraint.constant = scrollView.contentOffset.x / 2
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // select a collectionView item in menuBarView when scroll ends dragging
        let selectedIndexItem = targetContentOffset.pointee.x / self.mainCollectionView.frame.width
        let selectedIndexPath = IndexPath(item: Int(selectedIndexItem), section: 0)
        self.menuBarView.collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.left)
        self.menuBarView.selectedIndexPath = selectedIndexPath
    }

    // MARK: - CollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // ignore
    }

    // MARK: - CollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let mainPendingTasksCell = self.mainCollectionView.dequeueReusableCell(withReuseIdentifier: MainPendingTasksCell.cell_id, for: indexPath) as? MainPendingTasksCell else {
                return BaseCollectionViewCell()
            }
            self.mainPendingTasksCell = mainPendingTasksCell
            mainPendingTasksCell.mainTasksViewController = self
            return mainPendingTasksCell
        } else if indexPath.item == 1 {
            guard let mainCompletedTasksCell = self.mainCollectionView.dequeueReusableCell(withReuseIdentifier: MainCompletedTasksCell.cell_id, for: indexPath) as? MainCompletedTasksCell else {
                return BaseCollectionViewCell()
            }
            self.mainCompletedTasksCell = mainCompletedTasksCell
            mainCompletedTasksCell.mainTasksViewController = self
            return mainCompletedTasksCell
        } else {
            return BaseCollectionViewCell()
        }
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
            self.mainCollectionView.alpha = (size.width > size.height) ? 0.25 : 0.55
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
