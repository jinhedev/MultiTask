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

class PendingMasterViewController: UITableViewController, PersistentContainerDelegate, UISearchBarDelegate, Loggable {

    // MARK: - API

    var tasks: Results<Task>?

    // MARK: - UISearchBar & UISearchBarDelegate

    @IBOutlet weak var searchBar: UISearchBar!

    private func setupSearchBar() {
        searchBar.keyboardAppearance = UIKeyboardAppearance.dark
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            let namePredicate = NSPredicate(format: "name contains[c] %@", searchText)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, Task.pendingPredicate])
            let pendingTasks = realmManager?.getOrderedTasks(predicate: compoundPredicate)
            self.tasks = pendingTasks
        } else {
            searchBar.endEditing(true)
            fetchPendingTasks()
        }
    }

    // MARK:- Loggable

    var remoteLogManager: RemoteLogManager?

    private func setupRemoteLogManager() {
        remoteLogManager = RemoteLogManager()
        remoteLogManager!.delegate = self
    }

    func didLogged() {
        // ignore, for now.
    }
    
    // MARK: - PersistentContainerDelegate

    var realmManager: RealmManager? {
        didSet {
            fetchPendingTasks()
        }
    }

    func fetchPendingTasks() {
        let pendingTasks = realmManager?.getOrderedTasks(predicate: Task.pendingPredicate)
        self.tasks = pendingTasks
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

    func containerDidErr(error: Error) {
        playAlertSound(type: AlertSoundType.error)
        scheduleNavigationPrompt(with: error.localizedDescription, duration: 4)
        remoteLogManager?.logCustomEvent(type: String(describing: PendingMasterViewController.self), key: #function, value: error.localizedDescription)
        print(trace(file: #file, function: #function, line: #line))
    }

    func containerDidFetchTasks() {
        reloadTableView()
        updateNavigationTitle()
    }

    func containerDidCreateTasks() {
        fetchPendingTasks()
        reloadTableView()
        updateNavigationTitle()
    }

    func containerDidUpdateTasks() {
        fetchPendingTasks()
        reloadTableView()
        updateNavigationTitle()
    }

    func containerDidDeleteTasks() {
        fetchPendingTasks()
        reloadTableView()
        updateNavigationTitle()
    }

    // MARK: - UINavigationController

    @IBAction func handleAdd(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task", message: "Add a new task", preferredStyle: UIAlertControllerStyle.alert)
        var alertTextField: UITextField!
        alertController.addTextField { textField in
            alertTextField = textField
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.placeholder = "Task Name"
        }
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            guard let taskName = alertTextField.text , !taskName.isEmpty else { return }
            // add thing items to realm
            self.createTask(taskName: taskName)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        present(alertController, animated: true, completion: nil)
    }

    var timer: Timer?

    func scheduleNavigationPrompt(with message: String, duration: TimeInterval) {
        DispatchQueue.main.async {
            self.navigationItem.prompt = message
            self.timer = Timer.scheduledTimer(timeInterval: duration,
                                              target: self,
                                              selector: #selector(self.removePrompt),
                                              userInfo: nil,
                                              repeats: false)
            self.timer?.tolerance = 5
        }
    }

    @objc private func removePrompt() {
        if navigationItem.prompt != nil {
            DispatchQueue.main.async {
                self.navigationItem.prompt = nil
            }
        }
    }

    private func updateNavigationTitle() {
        guard let count = tasks?.count else { return }
        DispatchQueue.main.async {
            self.navigationItem.title = String(describing: count) + " Pending Tasks"
        }
    }

    private func setupNavigationController() {
        navigationController?.navigationBar.barTintColor = Color.midNightBlack
    }

    // MARK: - UITabBarController

    private func setupTabBarController() {
        tabBarController?.tabBar.barTintColor = Color.midNightBlack
    }

    // MARK: - UITableView

    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private func setupTableView() {
        self.tableView.backgroundColor = Color.inkBlack
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationController()
        setupRealmManager()
        setupSearchBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchPendingTasks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBarController()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? DetailViewController {
            guard let selectedIndexPath = tableView.indexPathForSelectedRow, let selectedTask = tasks?[selectedIndexPath.row] else {
                print(trace(file: #file, function: #function, line: #line))
                remoteLogManager?.logCustomEvent(type: String(describing: PendingMasterViewController.self), key: #function, value: String(describing: tasks))
                return
            }
            detailViewController.navigationItem.title = selectedTask.name
            detailViewController.selectedTask = selectedTask
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: DetailViewController.destinationSegueID, sender: self)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PendingCell.id, for: indexPath) as? PendingCell else {
            // Warning: extremely verbose
            print(trace(file: #file, function: #function, line: #line))
            remoteLogManager?.logCustomEvent(type: String(describing: PendingMasterViewController.self), key: #function, value: "Failed to dequeue: \(String(describing: PendingCell.self))")
            return UITableViewCell()
        }
        let task = tasks?[indexPath.row]
        cell.pendingTask = task
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) in
            if let taskToBeDeleted = self.tasks?[indexPath.row] {
                self.realmManager?.deleteObjects(objects: [taskToBeDeleted])
            } else {
                print(trace(file: #file, function: #function, line: #line))
            }
        }
        return [deleteAction]
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
}

