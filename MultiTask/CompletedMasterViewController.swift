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

class CompletedMasterViewController: UITableViewController, PersistentContainerDelegate {

    var tasks: Results<Task>?

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

    func setupRealmManager() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func realmErrorHandler(error: Error) {
        playErrorSound()
        scheduleNavigationPrompt(with: error.localizedDescription, duration: 4)
    }

    func didFetchTasks() {
        reloadTableView()
        updateNavigationTitle()
    }

    // MARK: - UISegmentedControl

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction func handleSortCriteria(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // Latest
            self.tasks = self.tasks?.sorted(byKeyPath: "updated_at", ascending: false)
        } else {
            // Oldest
            self.tasks = self.tasks?.sorted(byKeyPath: "updated_at", ascending: true)
        }
        self.tableView.reloadData()
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
                self.navigationItem.title = String(describing: count) + " Pending Tasks"
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchCompletedTasks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBarController()
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? DetailViewController {
            // set the navigationItem.title here
            guard let completedTasks = tasks, let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            detailViewController.navigationItem.title = completedTasks[selectedIndexPath.row].name
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CompletedCell.id, for: indexPath) as? CompletedCell else {
            return UITableViewCell()
        }
        cell.completedTask = tasks?[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let taskToBeDeleted = self.tasks?[indexPath.row]
            do {
                // delete and update
            } catch let err {
                print(err.localizedDescription)
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

