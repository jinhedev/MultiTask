//
//  PendingDetailViewController.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class ItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PersistentContainerDelegate, Loggable {

    // MARK: - API

    var selectedTask: Task?
    static let destinationSegueID = String(describing: ItemsViewController.self)

    // MARK: - NotificationCenter

//    private var completionSwitchObserver: NSObjectProtocol?

//    private func setupNotificationForCompletionSwitch() {
//        let notificationName = NSNotification.Name(CompletionSiwtchNotifications.notificationName)
//        completionSwitchObserver = NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: OperationQueue.main) { (notification: Notification) in
//            if let item = notification.userInfo?[CompletionSiwtchNotifications.key] as? Item {
//                let is_completed = item.is_completed
//                self.realmManager?.updateObject(object: item, keyedValues: ["is_completed" : !is_completed, "updated_at" : NSDate()])
//                guard let task = self.selectedTask else {
//                    print(trace(file: #file, function: #function, line: #line))
//                    return
//                }
//                self.realmManager?.checkOrUpdateItemsForCompletion(in: task)
//            }
//        }
//    }

//    private func removeNotificationForCompletionSwitch() {
//        if let observer = completionSwitchObserver {
//            NotificationCenter.default.removeObserver(observer)
//            completionSwitchObserver = nil
//        } else {
//            print(trace(file: #file, function: #function, line: #line))
//        }
//    }

    // MARK: - PersistentContainerDelegate

    var realmManager: RealmManager?

    func createItem(note: String) {
        guard let task = selectedTask else {
            print(trace(file: #file, function: #function, line: #line))
            return
        }
        let newItem = Item(id: NSUUID().uuidString, note: note, is_completed: false, created_at: NSDate(), updated_at: NSDate())
        realmManager?.appendItem(to: task, with: newItem)
    }

    private func setupRealmManager() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func container(_ manager: RealmManager, didErr error: Error) {
        playAlertSound(type: AlertSoundType.error)
        scheduleNavigationPrompt(with: error.localizedDescription, duration: 4)
        print(trace(file: #file, function: #function, line: #line))
    }

    func containerDidUpdateTasks(_ manager: RealmManager) {
        guard let itemCount = selectedTask?.items.count, let numberOfCompletedItems = selectedTask?.items.filter({$0.is_completed == true}).count else { return }
        if (itemCount != 0) && (itemCount == numberOfCompletedItems) {
            self.scheduleNavigationPrompt(with: "Task Completed", duration: 4)
        }
        // reload cell at indexPath
        reloadTableView()
    }

    func containerDidDeleteTasks(_ manager: RealmManager) {
        guard let task = self.selectedTask else {
            print(trace(file: #file, function: #function, line: #line))
            return
        }
        self.realmManager?.checkOrUpdateItemsForCompletion(in: task)
    }

    // MARK: - UINavigationBar

    @IBAction func handleAdd(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Item", message: "Add a new item", preferredStyle: UIAlertControllerStyle.alert)
        var alertTextField: UITextField!
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Note"
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.autocapitalizationType = .sentences
        }
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            guard let note = alertTextField.text , !note.isEmpty else { return }
            self.createItem(note: note)
            guard let task = self.selectedTask else { return }
            self.realmManager?.checkOrUpdateItemsForCompletion(in: task)
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

    private func setupNavigationController() {
        navigationController?.navigationBar.barTintColor = Color.midNightBlack
    }

    // MARK: - UITabBar

    private func setupTabBarController() {
        tabBarController?.tabBar.barTintColor = Color.midNightBlack
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
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationController()
        setupRealmManager()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        removeNotificationForCompletionSwitch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBarController()
//        setupNotificationForCompletionSwitch()
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let itemCell = self.tableView.dequeueReusableCell(withIdentifier: ItemCell.cell_id, for: indexPath) as? ItemCell else {
            return UITableViewCell()
        }
        let item = selectedTask?.items[indexPath.item]
        itemCell.item = item
        return itemCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTask?.items.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // TODO: implement this
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) in
            if let itemToBeDeleted = self.selectedTask?.items[indexPath.row] {
                self.realmManager?.deleteObjects(objects: [itemToBeDeleted])
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            } else {
                print(trace(file: #file, function: #function, line: #line))
            }
        }
        return [deleteAction]
    }

}







































