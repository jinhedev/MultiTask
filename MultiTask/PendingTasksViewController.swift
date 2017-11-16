//
//  PendingTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class PendingTasksViewController: BaseViewController, PersistentContainerDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIViewControllerPreviewingDelegate {

    // MARK: - API

    var pendingTasks: [Results<Task>]?
    var notificationToken: NotificationToken?
    static let storyboard_id = String(describing: PendingTasksViewController.self)
    let PAGE_INDEX = 0 // provides index data for parent pageViewController

    // MARK: - UIViewControllerPreviewingDelegate

    private func setupViewControllerPreviewingDelegate() {
        self.registerForPreviewing(with: self, sourceView: self.collectionView)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else { return nil }
        let itemsViewController = storyboard?.instantiateViewController(withIdentifier: ItemsViewController.storyboard_id) as? ItemsViewController
        itemsViewController?.selectedTask = self.pendingTasks?[indexPath.section][indexPath.item]
        // setting the peeking cell's animation
        if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? TaskCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return itemsViewController
    }

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

    func deleteItemAtCollectionView(indexPath: [IndexPath]) {
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: indexPath)
        }, completion: nil)
    }

    func insertItemsAtCollectionViewTopIndexPath() {
        let topIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: [topIndexPath])
        }, completion: nil)
    }

    func updateRowAtCollectionView(indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? TaskCell {
            cell.task = pendingTasks?[indexPath.section][indexPath.item]
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [indexPath])
            }, completion: nil)
        }
    }

    private func setupCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: TaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: TaskCell.cell_id)
    }

    // MARK: - Notification

    private func observeNotificationForTaskCompletion() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTaskForCompletion(notification:)), name: NSNotification.Name(rawValue: NotificationKey.TaskCompletion), object: nil)
    }

    private func observeNotificationForTaskUpdate() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTaskForUpdate(notification:)), name: Notification.Name(rawValue: NotificationKey.TaskUpdate), object: nil)
    }

    @objc func updateTaskForCompletion(notification: Notification) {
        if let task = notification.userInfo?[NotificationKey.TaskCompletion] as? Task {
            realmManager?.updateObject(object: task, keyedValues: [Task.isCompletedKeyPath : true, Task.updatedAtKeyPath : NSDate(), Task.completedAtKeyPath : NSDate()])
        }
    }

    @objc func updateTaskForUpdate(notification: Notification) {
        if let task = notification.userInfo?[NotificationKey.TaskUpdate] as? Task {
            realmManager?.updateObject(object: task, keyedValues: [Task.updatedAtKeyPath : NSDate()])
        }
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

    func persistentContainer(_ manager: RealmManager, didFetchTasks tasks: Results<Task>) {
        if self.pendingTasks == nil {
            // for initial fetch only
            self.pendingTasks = [Results<Task>]()
            self.pendingTasks!.append(tasks)
        } else {
            // called at didUpdate
            self.pendingTasks?.removeAll()
            self.pendingTasks!.append(tasks)
        }
        self.reloadCollectionView()
    }

    func persistentContainer(_ manager: RealmManager, didAdd objects: [Object]) {
        if pendingTasks == nil {
            realmManager?.fetchTasks(predicate: Task.pendingPredicate)
        } else {
            self.insertItemsAtCollectionViewTopIndexPath()
        }
    }

    func persistentContainer(_ manager: RealmManager, didUpdate object: Object) {
        // TODO: implement this if needed
        realmManager?.fetchTasks(predicate: Task.pendingPredicate)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupViewControllerPreviewingDelegate()
        self.setupPersistentContainerDelegate()
        self.observeNotificationForTaskCompletion()
        self.observeNotificationForTaskUpdate()
        realmManager!.fetchTasks(predicate: Task.pendingPredicate)
        if let pathToSandbox = realmManager?.pathForContainer?.absoluteString {
            print(pathToSandbox)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadCollectionView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
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

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.collectionView.frame.width
        let cellHeight: CGFloat = 8 + 8 + 8 + 15 + 15 + 8 + 8 // containerViewTopMargin + titleLabelTopMargin + titleLabelBottomMargin + subtitleLabelHeight + dateLabelHeight + dateLabelBottomMargin + containerViewBottomMargin (see TaskCell.xib for references)
        if let task = self.pendingTasks?[indexPath.section][indexPath.item] {
            let estimateSize = CGSize(width: cellWidth, height: cellHeight)
            let estimatedFrame = NSString(string: task.title).boundingRect(with: estimateSize, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 15)], context: nil)
            return CGSize(width: cellWidth, height: estimatedFrame.height + cellHeight)
        }
        return CGSize(width: cellWidth, height: cellHeight + 44) // 44 is the estimated height for titleLabel
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

















