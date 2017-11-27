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
    func collectionViewEditMode(_ viewController: MainTasksViewController, didTapEdit button: UIBarButtonItem, editMode isEnabled: Bool)
    func collectionViewEditMode(_ viewController: MainTasksViewController, didTapTrash button: UIBarButtonItem)
}

class MainTasksViewController: BaseViewController, UISearchResultsUpdating, UIViewControllerTransitioningDelegate, TaskEditorViewControllerDelegate {

    // MARK: - API

    static let storyboard_id = String(describing: MainTasksViewController.self)
    weak var menuBarDelegate: MainTasksViewControllerDelegate?
    weak var tasksPageDelegate: MainTasksViewControllerDelegate?
    weak var pendingTasksDelegate: MainTasksViewControllerDelegate?
    weak var completedTasksDelegate: MainTasksViewControllerDelegate?
    var menuBarViewController: MenuBarViewController?
    var tasksPageViewController: TasksPageViewController? // tasksPageViewController contains PendingTasksViewController and CompletedTasksViewController
    let searchController = UISearchController(searchResultsController: nil)
    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Delete"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleCancel(_:)))
        return button
    }()
    let popTransitionAnimator = PopTransitionAnimator()
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var menuBarContainerView: UIView!
    @IBOutlet weak var tasksContainerView: UIView! // tasksContainerView contains tasksPageViewController
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.addButton.isEnabled = !editing
        self.navigationItem.leftBarButtonItem = editing ? self.cancelButton : nil
        self.editButton.image = editing ? #imageLiteral(resourceName: "Trash") : #imageLiteral(resourceName: "List") // <<-- image literal
    }

    // MARK: - TaskEditorViewControllerDelegate

    func taskEditorViewController(_ viewController: TaskEditorViewController, didAddTask task: Task, at indexPath: IndexPath?) {
        viewController.dismiss(animated: true) {
            // REMARK: When a new task is added pendingTasks in PendingTasksViewController, but if pendingTasks is still nil, PendingTasksViewController's realmNotification will not be able to track changes because pendingTasks == nil was never allocated on the RealmNotification's run loop. To fix this issue, do a manual fetch on the PendingTasksViewController to get everything kickstarted.
            if self.tasksPageViewController?.pendingTasksViewController?.pendingTasks == nil {
                self.tasksPageViewController?.pendingTasksViewController?.realmManager?.fetchTasks(predicate: Task.pendingPredicate, sortedBy: Task.createdAtKeyPath, ascending: false)
            }
        }
    }

    func taskEditorViewController(_ viewController: TaskEditorViewController, didUpdateTask task: Task, at indexPath: IndexPath) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func taskEditorViewController(_ viewController: TaskEditorViewController, didCancelTask task: Task?, at indexPath: IndexPath?) {
        viewController.dismiss(animated: true, completion: nil)
    }

    // MARK: - MenuBarContainerView

    private func setupMenuBarContainerView() {
        self.menuBarContainerView.backgroundColor = Color.clear
    }

    // MARK: - TasksContainerView

    private func setupTasksContainerView() {
        self.tasksContainerView.backgroundColor = Color.clear
    }

    // MARK: - UINavigationBar

    private func setupNavigationBar() {
        self.isEditing = false
    }

    @IBAction func handleAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Segue.AddButtonToTaskEditorViewController, sender: self)
    }

    @IBAction func handleEdit(_ sender: UIBarButtonItem) {
        if self.isEditing == true {
            // if already in editMode, first commit trash and then exit editMode
            self.isEditing = false
            self.menuBarDelegate?.collectionViewEditMode(self, didTapTrash: sender)
            self.tasksPageDelegate?.collectionViewEditMode(self, didTapTrash: sender)
            self.pendingTasksDelegate?.collectionViewEditMode(self, didTapTrash: sender)
            self.completedTasksDelegate?.collectionViewEditMode(self, didTapTrash: sender)
        } else {
            // if not in editMode, enter editMode
            self.isEditing = true
            self.menuBarDelegate?.collectionViewEditMode(self, didTapEdit: sender, editMode: true)
            self.tasksPageDelegate?.collectionViewEditMode(self, didTapEdit: sender, editMode: true)
            self.pendingTasksDelegate?.collectionViewEditMode(self, didTapEdit: sender, editMode: true)
            self.completedTasksDelegate?.collectionViewEditMode(self, didTapEdit: sender, editMode: true)
        }
    }

    @objc func handleCancel(_ sender: UIBarButtonItem) {
        // exit editing mode
        self.isEditing = false
        self.menuBarDelegate?.collectionViewEditMode(self, didTapEdit: sender, editMode: false)
        self.tasksPageDelegate?.collectionViewEditMode(self, didTapEdit: sender, editMode: false)
        self.pendingTasksDelegate?.collectionViewEditMode(self, didTapEdit: sender, editMode: false)
        self.completedTasksDelegate?.collectionViewEditMode(self, didTapEdit: sender, editMode: false)
    }

    // MARK: - UISearchController & UISearchResultsUpdating

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

    private func setupRefreshControl() {
        refreshControl.tintColor = Color.lightGray
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTasksContainerView()
        self.setupMenuBarContainerView()
        self.setupNavigationBar()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.MenuBarContainerViewToMenuBarViewController {
            menuBarViewController = segue.destination as? MenuBarViewController
            menuBarViewController?.mainTasksViewController = self
        } else if segue.identifier == Segue.AddButtonToTaskEditorViewController {
            if let taskEditorViewController = segue.destination as? TaskEditorViewController {
                taskEditorViewController.delegate = self
            }
        } else if segue.identifier == Segue.TasksContainerViewToPageViewController {
            tasksPageViewController = segue.destination as? TasksPageViewController
            tasksPageViewController?.mainTasksViewController = self
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.tasksContainerView.alpha = (size.width > size.height) ? 0.25 : 0.55
        }, completion: nil)
    }

    // MARK: - UIViewControllerTransitioningDelegate

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








