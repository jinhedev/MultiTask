//
//  FirstViewController.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, PersistentContainerDelegate, UISearchResultsUpdating, EditViewDelegate {

    // MARK: - API

    let PAGE_SIZE: Int = 20
    let preloadMargin: Int = 5
    var lastLoadedPage: Int = 0

    var tasks: [Results<Task>]?
    var notificationToken: NotificationToken?
    static let storyboard_id = String(describing: TasksViewController.self)

    // MARK: - UISearchController & UISearchResultsUpdating

    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.searchBar.tintColor = Color.white
        controller.dimsBackgroundDuringPresentation = true
        controller.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        controller.searchBar.placeholder = "Search"
        return controller
    }()

    private func setupSearchBar() {
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // TODO: Fallback on earlier versions
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            // TODO: implement this
            print(text)
        }
    }
    
    // MARK: - PersistentContainerDelegate

    var realmManager: RealmManager? {
        didSet {
            realmManager?.fetchTasks(predicate: Task.pendingPredicate)
        }
    }

    private func setupNotifications() {
        notificationToken = realm.addNotificationBlock { [unowned self] notification, realm in
            print(notification)
            // TODO: retrieve data from the database
        }
    }

    private func setupRealmManager() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func createTask(taskName: String) {
        let task = Task()
        task.id = NSUUID().uuidString
        task.name = taskName
        realmManager?.createObjects(objects: [task])
    }

    func container(_ manager: RealmManager, didErr error: Error) {
        playAlertSound(type: AlertSoundType.error)
        //        scheduleNavigationPrompt(with: error.localizedDescription, duration: 4)
        print(trace(file: #file, function: #function, line: #line))
    }

    func containerDidFetch(_ manager: RealmManager, tasks: Results<Task>) {
        if self.tasks == nil {
            self.tasks = [Results<Task>]()
            self.tasks!.append(tasks)
        } else {
            self.tasks!.append(tasks)
        }
        self.reloadTableView()
    }

    func containerDidCreateTasks(_ manager: RealmManager) {
        manager.fetchTasks(predicate: Task.pendingPredicate)
        reloadTableView()
    }

    func containerDidUpdateTasks() {
        realmManager?.fetchTasks(predicate: Task.pendingPredicate)
        reloadTableView()
    }

    // MARK: - UINavigationBar
    
    @IBOutlet weak var addButton: UIBarButtonItem!

    @IBAction func handleAdd(_ sender: UIBarButtonItem) {
        guard let editViewController = storyboard?.instantiateViewController(withIdentifier: EditViewController.storyboard_id) as? EditViewController else { return }
        editViewController.transitioningDelegate = self
        editViewController.delegate = self
        self.present(editViewController, animated: true, completion: nil)

//        let alertController = UIAlertController(title: "New Task", message: "Add a new task", preferredStyle: UIAlertControllerStyle.alert)
//        var alertTextField: UITextField!
//        alertController.addTextField { textField in
//            alertTextField = textField
//            textField.keyboardAppearance = UIKeyboardAppearance.dark
//            textField.placeholder = "Task Name"
//            textField.autocapitalizationType = .sentences
//        }
//        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
//            guard let taskName = alertTextField.text , !taskName.isEmpty else { return }
//            // add thing items to realm
//            self.createTask(taskName: taskName)
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
//        alertController.addAction(cancelAction)
//        alertController.addAction(addAction)
//        present(alertController, animated: true, completion: nil)
    }

    // MARK: - EditViewDelegate

    private func setupEditViewDelegate() {
        // TODO: implement this
    }

    func editView(_ controller: EditViewController, didSave input: String) {
        // TODO: implement this
        print(input)
    }

    // MARK: - UITableView

    @IBOutlet weak var tableView: UITableView!

    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private func setupTableView() {
        self.tableView.backgroundColor = Color.inkBlack
        self.tableView.register(UINib(nibName: TaskHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: TaskHeaderView.header_id)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupRealmManager()
        setupNotifications()
        realmManager?.fetchTasks(predicate: Task.pendingPredicate)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let itemsViewController = segue.destination as? ItemsViewController {
            guard let selectedIndexPath = tableView.indexPathForSelectedRow, let selectedTask = tasks?[selectedIndexPath.section][selectedIndexPath.row] else {
                print(trace(file: #file, function: #function, line: #line))
                return
            }
            itemsViewController.navigationItem.title = selectedTask.name
            itemsViewController.selectedTask = selectedTask
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.tableView.alpha = (size.width > size.height) ? 0.25 : 0.55
        }, completion: nil)
    }

    // MARK: - UIViewControllerTransitioningDelegate

    let popTransition = PopAnimator()

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let barButtonView = self.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView {
            let barButtonFrame = barButtonView.frame
            popTransition.originFrame = barButtonFrame
            popTransition.isPresenting = true
            return popTransition
        } else {
            return nil
        }
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // MARK: - implement this
        popTransition.isPresenting = false
        return popTransition
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segue.TaskCellToItemsViewController, sender: self)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tasks?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?[section].count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.cell_id, for: indexPath) as? TaskCell else {
            // Warning: verbose
            print(trace(file: #file, function: #function, line: #line))
            return UITableViewCell()
        }
        let task = tasks?[indexPath.section][indexPath.row]
        cell.pendingTask = task
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TaskCell {
            cell.isDeleting = false
        }
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let cell = tableView.cellForRow(at: indexPath) as? TaskCell {
            cell.isDeleting = true
        }
        let deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Delete") { (action, view, is_success) in
            is_success(true)
        }
        deleteAction.image = #imageLiteral(resourceName: "Delete")
        deleteAction.backgroundColor = Color.inkBlack
        let swipeActionConfigurations = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActionConfigurations.performsFirstActionWithFullSwipe = false
        return swipeActionConfigurations
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TaskHeaderView.header_id) as? TaskHeaderView
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    // MARK: - UIViewControllerPreviewingDelegate
    // experiment with pop and peek to activate the edit mode
    
}












