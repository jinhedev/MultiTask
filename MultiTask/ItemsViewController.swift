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

    var selectedTask: Task? // only use this object's id for query for items
    var items: [Results<Item>]?
    lazy var apiClient: APIClientProtocol = APIClient()

    static let storyboard_id = String(describing: ItemsViewController.self)

    // MARK: - ItemEditorContainerView && ItemEditorViewControllerDelegate

    var itemEditorViewController: ItemEditorViewController?

    func itemEditorViewController(_ viewController: ItemEditorViewController, didTapCancel button: UIButton?) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func itemEditorViewController(_ viewController: ItemEditorViewController, didAddItem item: Item) {
        viewController.dismiss(animated: true) {
            self.insertRowsAtTableViewTopIndexPath()
        }
    }

    func itemEditorViewController(_ viewController: ItemEditorViewController, didTapSave button: UIButton?, toSave item: Item) {
        viewController.dismiss(animated: true) {
            self.reloadTableView()
            self.postNotificationForTaskUpdate(task: self.selectedTask!)
        }
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
                    realmManager?.fetchItems(parentTaskId: taskId)
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
        itemEditorViewController?.selectedItem = items?[indexPath.section][indexPath.row]
        // setting the peeking cell's animation
        if let selectedCell = self.tableView.cellForRow(at: indexPath) as? ItemCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return itemEditorViewController
    }

    // MARK: - PersistentContainerDelegate

    var realmManager: RealmManager?

    func checkParentTaskForCompletion() -> Bool {
        let completionPredicate = NSPredicate(format: "is_completed == %@", NSNumber(booleanLiteral: true))
        let completionCountInItems = self.items?.first?.filter(completionPredicate).count
        if self.items?.first?.count == completionCountInItems {
            return true
        } else {
            return false
        }
    }

    private func setupRealmManager() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didFetchItems items: Results<Item>?) {
        guard let unwrappedItems = items else { return }
        if self.items == nil {
            // for initial fetch only
            self.items = [Results<Item>]()
            self.items!.append(unwrappedItems)
        } else {
            // called when updating protocol is triggered by search
            self.items!.removeAll()
            self.items!.append(unwrappedItems)
        }
        self.reloadTableView()
    }

    func persistentContainer(_ manager: RealmManager, didUpdate object: Object) {
        if checkParentTaskForCompletion() == true {
            self.postNotificationForTaskCompletion(task: selectedTask!)
        }
    }

    func persistentContainer(_ manager: RealmManager, didAdd objects: [Object]) {
        self.insertRowsAtTableViewTopIndexPath()
        if selectedTask?.items.count != items?.count {
            // a new task has been added to **items**
            self.postNotificationForTaskUpdate(task: selectedTask!)
        }
    }

    func persistentContainer(_ manager: RealmManager, didDelete objects: [Object]) {
        if self.checkParentTaskForCompletion() == true {
            self.postNotificationForTaskCompletion(task: selectedTask!)
        }
    }

    // MARK: - Notification

    func postNotificationForTaskCompletion(task: Task) {
        let notification = Notification(name: Notification.Name.init(NotificationKey.TaskCompletion), object: nil, userInfo: [NotificationKey.TaskCompletion : task])
        NotificationCenter.default.post(notification)
    }

    func postNotificationForTaskUpdate(task: Task) {
        let notification = Notification(name: Notification.Name.init(NotificationKey.TaskUpdate), object: nil, userInfo: [NotificationKey.TaskUpdate : task])
        NotificationCenter.default.post(notification)
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

    /**
     Reload the whole tableView on a main thread.
     - warning: Reloading the whole tableView is expensive. Only use this method for the initial reload at the first time tableView is set at viewDidLoad.
     */
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func deleteRowAtTableView(indexPath: IndexPath) {
        self.tableView.performBatchUpdates({
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }, completion: nil)
    }

    func updateRowAtTableView(indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? ItemCell {
            cell.item = items?[indexPath.section][indexPath.row]
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }, completion: nil)
        }
    }

    func insertRowsAtTableViewTopIndexPath() {
        let topIndexPath = IndexPath(row: 0, section: 0)
        self.tableView.performBatchUpdates({
            self.tableView.insertRows(at: [topIndexPath], with: UITableViewRowAnimation.automatic)
        }, completion: nil)
    }

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
        self.setupRealmManager()
        self.setupViewControllerPreviewingDelegate()
        if let task = selectedTask {
            realmManager?.fetchItems(parentTaskId: task.id)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.ItemsViewControllerToItemEditorViewController {
            itemEditorViewController = segue.destination as? ItemEditorViewController
            itemEditorViewController?.delegate = self
            itemEditorViewController?.parentTask = self.selectedTask
        }
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? ItemCell else { return }
        cell.animateForDefault()
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: UIContextualAction.Style.normal, title: nil) { (action, view, is_success) in
            // perform complete action
            if let itemToBeCompleted = self.items?[indexPath.section][indexPath.row] {
                self.realmManager?.updateObject(object: itemToBeCompleted, keyedValues: [Item.isCompletedKeyPath : true, Item.completedAtKeyPath : NSDate(), Item.updatedAtKeyPath : NSDate()])
                self.updateRowAtTableView(indexPath: indexPath)
            } else {
                print(trace(file: #file, function: #function, line: #line))
            }
            is_success(true)
        }
        doneAction.image = #imageLiteral(resourceName: "Tick") // <<-- watch out for image literal
        doneAction.backgroundColor = Color.seaweedGreen // <<-- hacky
        let swipeActionConfigurations = UISwipeActionsConfiguration(actions: [doneAction])
        swipeActionConfigurations.performsFirstActionWithFullSwipe = true
        return swipeActionConfigurations
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: nil) { (action, view, is_success) in
            // perform delete action
            if let itemToBeDeleted = self.selectedTask?.items[indexPath.row] {
                self.realmManager?.deleteObjects(objects: [itemToBeDeleted])
                self.deleteRowAtTableView(indexPath: indexPath)
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






