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

class DetailViewController: UITableViewController, PersistentContainerDelegate {

    // MARK: - API

    var selectedTask: Task?
    static let destinationSegueID = String(describing: DetailViewController.self)

    // MARK: - NotificationCenter

    private var completionSwitchObserver: NSObjectProtocol?

    private func setupNotificationForCompletionSwitch() {
        let notificationName = NSNotification.Name(CompletionSiwtchNotifications.notificationName)
        completionSwitchObserver = NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: OperationQueue.main) { (notification: Notification) in
            if let item = notification.userInfo?[CompletionSiwtchNotifications.key] as? Item {
                let is_completed = item.is_completed
                self.realmManager?.updateObject(object: item, keyedValues: ["is_completed" : !is_completed, "updated_at" : NSDate()])
                guard let task = self.selectedTask else { return }
                self.realmManager?.checkOrUpdateItemsForCompletion(in: task)
            }
        }
    }

    private func removeNotificationForCompletionSwitch() {
        if let observer = completionSwitchObserver {
            NotificationCenter.default.removeObserver(observer)
            completionSwitchObserver = nil
        }
    }

    // MARK: - PersistentContainerDelegate

    var realmManager: RealmManager?

    func createItem(note: String) {
        guard let task = selectedTask else { return }
        let newItem = Item(id: NSUUID().uuidString, note: note, is_completed: false, created_at: NSDate(), updated_at: NSDate())
        realmManager?.appendItem(to: task, with: newItem)
    }

    func setupRealmManager() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func realmErrorHandler(error: Error) {
        playErrorSound()
        scheduleNavigationPrompt(with: error.localizedDescription, duration: 4)
    }

    func didUpdateTasks() {
        reloadTableView()
    }

    func didDeleteTasks() {
        reloadTableView()
    }

    // MARK: - AVAudioPlayer

    private var player: AVAudioPlayer?

    private func playErrorSound() {
        guard let sound = NSDataAsset(name: "Error") else {
            print("sound file not found")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeWAVE)
            DispatchQueue.main.async {
                guard let player = self.player else { return }
                player.play() // schwoof
            }
        } catch let err {
            print(err.localizedDescription)
        }
    }

    // MARK: - NavigationController

    @IBAction func handleAdd(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Item", message: "Add a new item", preferredStyle: UIAlertControllerStyle.alert)
        var alertTextField: UITextField!
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Note"
            textField.keyboardAppearance = UIKeyboardAppearance.dark
        }
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            guard let note = alertTextField.text , !note.isEmpty else { return }
            // add thing items to realm
            self.createItem(note: note)
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupRealmManager()
        setupNotificationForCompletionSwitch()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotificationForCompletionSwitch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBarController()
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTask?.items.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.id, for: indexPath) as? ItemCell else {
            return UITableViewCell()
        }
        let item = selectedTask?.items[indexPath.row]
        cell.item = item
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) in
            if let itemToBeDeleted = self.selectedTask?.items[indexPath.row] {
                self.realmManager?.deleteObjects(objects: [itemToBeDeleted])
                self.realmManager?.checkOrUpdateItemsForCompletion(in: self.selectedTask!)
            }
        }
        return [deleteAction]
    }

}
