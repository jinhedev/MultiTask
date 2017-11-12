//
//  PendingTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class PendingTasksViewController: BaseViewController, PersistentContainerDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    // MARK: - API

    var pendingTasks: [Results<Task>]?
    var notificationToken: NotificationToken?
    static let storyboard_id = String(describing: PendingTasksViewController.self)

    // MARK: - UICollecitonView

    @IBOutlet weak var collectionView: UICollectionView!

    /**
     Reload the whole collectionView on a main thread.
     - warning: Reloading the whole collectionView is expensive. Only use this method for the initial reload at the first time collectionView is set at viewDidLoad.
     */
    private func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    private func setupCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: TaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: TaskCell.cell_id)
    }

    // MARK: - PersistentContainerDelegate

    var realmManager: RealmManager?

    private func setupPersistentContainerDelegate() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didFetch tasks: Results<Task>) {
        if self.pendingTasks == nil {
            self.pendingTasks = [Results<Task>]()
            self.pendingTasks!.append(tasks)
        } else {
            self.pendingTasks!.append(tasks)
        }
        self.reloadCollectionView()
    }

    func persistentContainer(_ manager: RealmManager, didUpdate object: Object) {
        // TODO: implement this
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupPersistentContainerDelegate()
        realmManager?.fetchTasks(predicate: Task.pendingPredicate)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.PendingTaskCellToItemsViewController {
            guard let itemsViewController = segue.destination as? ItemsViewController else {
                print(trace(file: #file, function: #function, line: #line))
                return
            }
            guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else {
                print(trace(file: #file, function: #function, line: #line))
                return
            }
            itemsViewController.selectedTask = self.pendingTasks?[selectedIndexPath.section][selectedIndexPath.item]
        }
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segue.PendingTaskCellToItemsViewController, sender: self)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.collectionView.frame.width
        let cellHeight: CGFloat = 128
        return CGSize(width: cellWidth, height: cellHeight)
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pendingTasks?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pendingTasks?[section].count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let pendingTaskCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.cell_id, for: indexPath) as? TaskCell else {
            return BaseCollectionViewCell()
        }
        let task = pendingTasks?[indexPath.section][indexPath.item]
        pendingTaskCell.task = task
        return pendingTaskCell
    }

}

















