//
//  PendingDetailViewController.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class ItemsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIViewControllerPreviewingDelegate, PersistentContainerDelegate, ItemEditorViewControllerDelegate {

    // MARK: - API

    var selectedTask: Task?
    var items: [Results<Item>]?
    var notificationToken: NotificationToken?
    lazy var apiClient: APIClientProtocol = APIClient()
    static let storyboard_id = String(describing: ItemsViewController.self)

    // MARK: - ItemEditorContainerView && ItemEditorViewControllerDelegate

    var itemEditorViewController: ItemEditorViewController?

    func itemEditorViewController(_ viewController: ItemEditorViewController, didCancelItem item: Item?, at indexPath: IndexPath?) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func itemEditorViewController(_ viewController: ItemEditorViewController, didAddItem item: Item, at indexPath: IndexPath?) {
        viewController.dismiss(animated: true) {
            // update the parent task's updated_at
            guard let task = self.selectedTask else { return }
            self.realmManager?.updateObject(object: task, keyedValues: [Task.updatedAtKeyPath : NSDate()])
        }
    }

    func itemEditorViewController(_ viewController: ItemEditorViewController, didUpdateItem item: Item, at indexPath: IndexPath) {
        viewController.dismiss(animated: true, completion: nil)
    }

    // MARK: - UISearchController & UISearchResultsUpdating

    let searchController = UISearchController(searchResultsController: nil)

    private func setupSearchController() {
        self.searchController.searchBar.barStyle = .black
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.tintColor = Color.mandarinOrange
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text {
            if !searchString.isEmpty {
                if let taskId = self.selectedTask?.id {
                    realmManager?.fetchItems(parentTaskId: taskId, predicate: Item.getTitlePredicate(value: searchString))
                }
            } else {
                if let taskId = self.selectedTask?.id {
                    realmManager?.fetchItems(parentTaskId: taskId, sortedBy: Item.createdAtKeyPath, ascending: false)
                }
            }
        }
    }

    // MARK: - UIViewControllerPreviewingDelegate

    private func setupViewControllerPreviewingDelegate() {
        self.registerForPreviewing(with: self, sourceView: self.tableView)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return nil }
        let itemEditorViewController = storyboard?.instantiateViewController(withIdentifier: ItemEditorViewController.storyboard_id) as? ItemEditorViewController
        itemEditorViewController?.delegate = self
        itemEditorViewController?.parentTask = self.selectedTask
        itemEditorViewController?.selectedIndexPath = indexPath
        itemEditorViewController?.selectedItem = items?[indexPath.section][indexPath.row]
        // setting the peeking cell's animation
        if let selectedCell = self.tableView.cellForRow(at: indexPath) as? ItemCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return itemEditorViewController
    }

    // MARK: - PersistentContainerDelegate

    var realmManager: RealmManager?

    private func setupPersistentContainerDelegate() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    private func setupItemsForTableViewWithParentTask() {
        guard let unwrappedItems = self.selectedTask?.items.sorted(byKeyPath: Item.createdAtKeyPath, ascending: false) else { return }
        self.items = [Results<Item>]()
        self.items!.append(unwrappedItems)
        self.setupRealmNotificationsForTableView()
    }

    private func setupRealmNotificationsForTableView() {
        notificationToken = self.items!.first?.observe({ [weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                tableView.applyChanges(deletions: deletions, insertions: insertions, updates: modifications)
            case .error(let err):
                print(trace(file: #file, function: #function, line: #line))
                print(err.localizedDescription)
            }
        })
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didDelete objects: [Object]?) {
        // delete an item from items may cause the parentTask to toggle its completion state to either completed or pending
        // check to see if the parent task has all items completed, if so, mark parent task completed and set the updated_at and completed_at to today's date
        guard let parentTask = self.selectedTask else { return }
        if parentTask.shouldComplete() == true {
            self.realmManager?.updateObject(object: parentTask, keyedValues: [Task.isCompletedKeyPath : true, Task.completedAtKeyPath : NSDate(), Task.updatedAtKeyPath : NSDate()])
        } else if parentTask.shouldComplete() == false {
            self.realmManager?.updateObject(object: parentTask, keyedValues: [Task.isCompletedKeyPath : false, Task.completedAtKeyPath : NSNull(), Task.updatedAtKeyPath : NSDate()])
        }
    }

    func persistentContainer(_ manager: RealmManager, didUpdate object: Object) {
        // update an item from items may cause the parentTask to toggle its completion state to either completed or pending
        // check to see if the parent task has all items completed, if so, mark parent task completed and set the updated_at and completed_at to today's date
        guard let parentTask = self.selectedTask else { return }
        if parentTask.shouldComplete() == true {
            self.realmManager?.updateObject(object: parentTask, keyedValues: [Task.isCompletedKeyPath : true, Task.completedAtKeyPath : NSDate(), Task.updatedAtKeyPath : NSDate()])
        } else if parentTask.shouldComplete() == false {
            self.realmManager?.updateObject(object: parentTask, keyedValues: [Task.isCompletedKeyPath : false, Task.completedAtKeyPath : NSNull(), Task.updatedAtKeyPath : NSDate()])
        } else {
            // parentTask's completion state is now in sync with its items now. Safe to ignore.
        }
    }

    // MARK: - UINavigationBar

    private func setupNavigationBar() {
        self.navigationItem.title?.removeAll()
    }

    @IBAction func handleAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Segue.ItemsViewControllerToItemEditorViewController, sender: self)
    }

    // MARK: - UITableView

    @IBOutlet weak var tableView: UITableView!

    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: ItemCell.nibName, bundle: nil), forCellReuseIdentifier: ItemCell.cell_id)
        self.tableView.backgroundColor = Color.inkBlack
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupTableView()
        self.setupSearchController()
        self.setupViewControllerPreviewingDelegate()
        self.setupPersistentContainerDelegate()
        self.setupItemsForTableViewWithParentTask()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.ItemsViewControllerToItemEditorViewController {
            itemEditorViewController = segue.destination as? ItemEditorViewController
            itemEditorViewController?.delegate = self
            itemEditorViewController?.parentTask = self.selectedTask
        }
    }

    // MARK: - UITableViewDelegate

    func isItemCompleted(at indexPath: IndexPath) -> Bool? {
        if let is_completed = items?[indexPath.section][indexPath.row].is_completed {
            return is_completed
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? ItemCell else { return }
        cell.animateForDefault()
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // user marks item for pending
        let pendingAction = UIContextualAction(style: UIContextualAction.Style.normal, title: nil) { (action, view, is_success) in
            // perform pending action
            if let itemToBePending = self.items?[indexPath.section][indexPath.row] {
                self.realmManager?.updateObject(object: itemToBePending, keyedValues: [Item.isCompletedKeyPath : false, Item.completedAtKeyPath : NSNull(), Item.updatedAtKeyPath : NSDate()])
                self.realmManager?.updateObject(object: self.selectedTask!, keyedValues: [Task.completedAtKeyPath : NSNull(), Task.updatedAtKeyPath : NSDate()])
            } else {
                print(trace(file: #file, function: #function, line: #line))
            }
            is_success(true)
        }
        pendingAction.image = #imageLiteral(resourceName: "Spinner") // <<-- watch out for image literal
        pendingAction.backgroundColor = Color.mandarinOrange
        // user marks item for completion
        let doneAction = UIContextualAction(style: UIContextualAction.Style.normal, title: nil) { (action, view, is_success) in
            // perform complete action
            if let itemToBeCompleted = self.items?[indexPath.section][indexPath.row] {
                self.realmManager?.updateObject(object: itemToBeCompleted, keyedValues: [Item.isCompletedKeyPath : true, Item.completedAtKeyPath : NSDate(), Item.updatedAtKeyPath : NSDate()])
                self.realmManager?.updateObject(object: self.selectedTask!, keyedValues: [Task.completedAtKeyPath : NSNull(), Task.updatedAtKeyPath : NSDate()]) // NSNull() doesn't seem to work
            } else {
                print(trace(file: #file, function: #function, line: #line))
            }
            is_success(true)
        }
        doneAction.image = #imageLiteral(resourceName: "Tick") // <<-- watch out for image literal
        doneAction.backgroundColor = Color.seaweedGreen
        // if this cell has been completed, show pendingAction, if not, show doneAction
        if let is_completed = self.isItemCompleted(at: indexPath) {
            if is_completed {
                let swipeActionConfigurations = UISwipeActionsConfiguration(actions: [pendingAction])
                swipeActionConfigurations.performsFirstActionWithFullSwipe = true
                return swipeActionConfigurations
            } else {
                let swipeActionConfigurations = UISwipeActionsConfiguration(actions: [doneAction])
                swipeActionConfigurations.performsFirstActionWithFullSwipe = true
                return swipeActionConfigurations
            }
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: nil) { (action, view, is_success) in
            // perform delete action
            if let itemToBeDeleted = self.selectedTask?.items[indexPath.row] {
                self.realmManager?.deleteObjects(objects: [itemToBeDeleted])
            } else {
                print(trace(file: #file, function: #function, line: #line))
            }
            is_success(true)
        }
        deleteAction.image = #imageLiteral(resourceName: "Delete") // <<-- watch out for image literal
        deleteAction.backgroundColor = Color.roseScarlet // <<-- hacky
        let swipeActionConfigurations = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActionConfigurations.performsFirstActionWithFullSwipe = false
        return swipeActionConfigurations
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let itemCell = self.tableView.dequeueReusableCell(withIdentifier: ItemCell.cell_id, for: indexPath) as? ItemCell else {
            return BaseTableViewCell()
        }
        let item = items?[indexPath.section][indexPath.row]
        itemCell.item = item
        return itemCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?[section].count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}
