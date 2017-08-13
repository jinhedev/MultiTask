//
//  SecondViewController.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class CompletedMasterViewController: UITableViewController, PersistentContainerDelegate, Loggable {

    // MARK: - API

    var tasks: Results<Task>?

    // MARK: - Loggable

    var remoteLogManager: RemoteLogManager?

    private func setupRemoteLogManager() {
        remoteLogManager = RemoteLogManager()
        remoteLogManager!.delegate = self
    }

    func didLogged() {
        // ignore, for now
    }

    // MARK: - PersistentContainerDelegate

    var realmManager: RealmManager? {
        didSet {
            fetchCompletedTasks()
        }
    }

    func fetchCompletedTasks() {
        let completedTasks = realmManager?.getOrderedTasks(predicate: Task.completedPredicate)
        self.tasks = completedTasks
    }

    private func setupRealmManager() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func containerDidErr(error: Error) {
        playAlertSound(type: AlertSoundType.error)
        scheduleNavigationPrompt(with: error.localizedDescription, duration: 4)
        remoteLogManager?.logCustomEvent(type: String(describing: CompletedMasterViewController.self), key: #function, value: error.localizedDescription)
        print(trace(file: #file, function: #function, line: #line))
    }

    func containerDidFetchTasks() {
        reloadTableView()
        updateNavigationTitle()
    }

    func containerDidUpdateTasks() {
        fetchCompletedTasks()
        reloadTableView()
        updateNavigationTitle()
    }

    func containerDidDeleteTasks() {
        reloadTableView()
        fetchCompletedTasks()
        updateNavigationTitle()
    }

    // MARK: - UISegmentedControl

    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            remoteLogManager?.logCustomEvent(type: String(describing: CompletedMasterViewController.self), key: #function, value: "\(segmentedControl.selectedSegmentIndex)")
        }
    }

    @IBAction func handleSortCriteria(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // Latest
            self.tasks = self.tasks?.sorted(byKeyPath: "updated_at", ascending: false)
            remoteLogManager?.logCustomEvent(type: String(describing: CompletedMasterViewController.self), key: #function, value: "\(sender.selectedSegmentIndex)")
        } else {
            // Oldest
            self.tasks = self.tasks?.sorted(byKeyPath: "updated_at", ascending: true)
            remoteLogManager?.logCustomEvent(type: String(describing: CompletedMasterViewController.self), key: #function, value: "\(sender.selectedSegmentIndex)")
        }
        self.tableView.reloadData()
    }

    // MARK: - UINavigationController

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
        if let count = tasks?.count {
            DispatchQueue.main.async {
                self.navigationItem.title = String(describing: count) + " Completed Tasks"
            }
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchCompletedTasks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBarController()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? DetailViewController {
            guard let selectedIndexPath = tableView.indexPathForSelectedRow, let selectedTask = tasks?[selectedIndexPath.row] else {
                print(trace(file: #file, function: #function, line: #line))
                remoteLogManager?.logCustomEvent(type: String(describing: CompletedMasterViewController.self), key: #function, value: String(describing: tasks))
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CompletedCell.id, for: indexPath) as? CompletedCell else {
            // Warning: extremely verbose
            print(trace(file: #file, function: #function, line: #line))
            remoteLogManager?.logCustomEvent(type: String(describing: CompletedMasterViewController.self), key: #function, value: "Failed to dequeue: \(String(describing: CompletedCell.self))")
            return UITableViewCell()
        }
        let task = tasks?[indexPath.row]
        cell.completedTask = task
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

