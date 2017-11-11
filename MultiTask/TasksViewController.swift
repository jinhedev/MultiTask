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

class TasksViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, PersistentContainerDelegate, UISearchResultsUpdating, EditTaskViewControllerDelegate {

    // MARK: - API

    let PAGE_SIZE: Int = 20
    let CURRENT_PAGE: Int = 0

    var tasks: [Results<Task>]?
    var notificationToken: NotificationToken?
    static let storyboard_id = String(describing: TasksViewController.self)

    // MARK: - UISearchController & UISearchResultsUpdating

    let searchController = UISearchController(searchResultsController: nil)

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = Color.white
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        searchController.searchBar.placeholder = "Search"
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
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
        // TODO: implement this
    }

    private func setupRealmManager() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func createTask(taskName: String) {
        let task = Task()
        task.id = NSUUID().uuidString
        task.title = taskName
        realmManager?.createObjects(objects: [task])
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
//        scheduleNavigationPrompt(with: error.localizedDescription, duration: 4)
    }

    func persistentContainer(_ manager: RealmManager, didFetch tasks: Results<Task>) {
        if self.tasks == nil {
            self.tasks = [Results<Task>]()
            self.tasks!.append(tasks)
        } else {
            self.tasks!.append(tasks)
        }
        self.reloadTableView()
    }

    func persistentContainer(_ manager: RealmManager, didAdd objects: [Object]) {
        manager.fetchTasks(predicate: Task.pendingPredicate)
        reloadTableView()
    }

    func persistentContainer(_ manager: RealmManager, didUpdate object: Object) {
        realmManager?.fetchTasks(predicate: Task.pendingPredicate)
    }

    // MARK: - UINavigationBar
    
    @IBOutlet weak var addButton: UIBarButtonItem!

    @IBAction func handleAdd(_ sender: UIBarButtonItem) {
        // TODO: handle segue
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
        self.tableView.register(UINib(nibName: TaskCell.nibName, bundle: nil), forCellReuseIdentifier: TaskCell.cell_id)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupSearchController()
        self.setupRealmManager()
        self.setupNotifications()
        realmManager?.fetchTasks(predicate: Task.pendingPredicate)
        print(realmManager?.pathForContainer)
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
            itemsViewController.navigationItem.title = selectedTask.title
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

    let popTransitionAnimator = PopTransitionAnimator()

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
        if tasks != nil {
            guard let taskCell = tableView.dequeueReusableCell(withIdentifier: TaskCell.cell_id, for: indexPath) as? TaskCell else {
                print(trace(file: #file, function: #function, line: #line))
                return UITableViewCell()
            }
            let task = tasks?[indexPath.section][indexPath.row]
            taskCell.task = task
            return taskCell
        } else {
            return UITableViewCell()
        }
    }

    // MARK: - EditTaskViewControllerDelegate

    func editTaskViewController(_ viewController: EditTaskViewController, didTap saveButton: UIButton, toSave task: Task) {
        // TODO: implement this
        print(task)
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TaskCell {
            // TODO: animate end of editing
            print(cell)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let cell = tableView.cellForRow(at: indexPath) as? TaskCell {
            // TODO: animate editing
            print(cell)
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
        if tasks == nil {
            // user has not created any tasks, show a placeholder cell
            let tableViewHeight = self.tableView.frame.height
            return tableViewHeight
        } else {
            return 44
        }
    }

    // MARK: - UIViewControllerPreviewingDelegate
    // experiment with pop and peek to activate the edit mode
    
}












