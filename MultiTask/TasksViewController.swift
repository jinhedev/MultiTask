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

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PersistentContainerDelegate, UISearchResultsUpdating {

    // MARK: - API

    var tasks: Results<Task>?

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
        if !tasks.isEmpty {
            self.tasks = tasks
            reloadTableView()
        }
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

    @IBAction func handleAdd(_ sender: UIBarButtonItem) {
        

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRealmManager()
        realmManager?.fetchTasks(predicate: Task.pendingPredicate)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let itemsViewController = segue.destination as? ItemsViewController {
            guard let selectedIndexPath = tableView.indexPathForSelectedRow, let selectedTask = tasks?[selectedIndexPath.row] else {
                print(trace(file: #file, function: #function, line: #line))
                return
            }
            itemsViewController.navigationItem.title = selectedTask.name
            itemsViewController.selectedTask = selectedTask
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segue.TaskCellToItemsViewController, sender: self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.cell_id, for: indexPath) as? TaskCell else {
            // Warning: verbose
            print(trace(file: #file, function: #function, line: #line))
            return UITableViewCell()
        }
        let task = tasks?[indexPath.row]
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
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TaskHeaderView.header_id) as? TaskHeaderView {
            return headerView
        } else {
            return nil
        }
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












