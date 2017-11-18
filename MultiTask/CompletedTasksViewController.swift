//
//  CompletedTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class CompletedTasksViewController: BaseViewController, PersistentContainerDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIViewControllerPreviewingDelegate {

    // MARK: - API

    var completedTasks: [Results<Task>]?
    var notificationToken: NotificationToken?
    static let storyboard_id = String(describing: CompletedTasksViewController.self)
    let PAGE_INDEX = 1 // provides index data for parent pageViewController

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
        itemsViewController?.selectedTask = self.completedTasks?[indexPath.section][indexPath.item]
        // setting the peeking cell's animation
        if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? TaskCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return itemsViewController
    }

    // MARK: - UICollectionView

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
            cell.task = completedTasks?[indexPath.section][indexPath.item]
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

    func updateTaskForCompletion(notification: Notification) {
        if let task = notification.userInfo?[NotificationKey.TaskCompletion] as? Task {
            realmManager?.updateObject(object: task, keyedValues: [Task.isCompletedKeyPath : true])
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
        if self.completedTasks == nil {
            // for initial fetch only
            self.completedTasks = [Results<Task>]()
            self.completedTasks!.append(tasks)
        } else {
            // called when task completed
            self.completedTasks?.removeAll()
            self.completedTasks?.append(tasks)
        }
        self.reloadCollectionView()
    }

    func persistentContainer(_ manager: RealmManager, didAdd objects: [Object]) {
        if completedTasks == nil {
            self.reloadCollectionView()
        } else {
            self.insertItemsAtCollectionViewTopIndexPath()
        }
    }

    func persistentContainer(_ manager: RealmManager, didUpdate object: Object) {
        realmManager?.fetchTasks(predicate: Task.completedPredicate)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPersistentContainerDelegate()
        self.setupCollectionView()
        self.setupViewControllerPreviewingDelegate()
        self.observeNotificationForTaskCompletion()
        self.realmManager?.fetchTasks(predicate: Task.completedPredicate)
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
        if segue.identifier == Segue.CompletedTaskCellToItemsViewController {
            guard let itemsViewController = segue.destination as? ItemsViewController else {
                print(trace(file: #file, function: #function, line: #line))
                return
            }
            guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else {
                print(trace(file: #file, function: #function, line: #line))
                return
            }
            itemsViewController.selectedTask = self.completedTasks?[selectedIndexPath.section][selectedIndexPath.item]
        }
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segue.CompletedTaskCellToItemsViewController, sender: self)
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
        let cellHeight: CGFloat = 8 + 8 + 8 + 15 + 15 + 8 + 8 + 4 // containerViewTopMargin + titleLabelTopMargin + titleLabelBottomMargin + subtitleLabelHeight + dateLabelHeight + dateLabelBottomMargin + containerViewBottomMargin + errorOffset (see TaskCell.xib for references)
        if let task = self.completedTasks?[indexPath.section][indexPath.item] {
            let estimateSize = CGSize(width: cellWidth, height: cellHeight)
            let estimatedFrame = NSString(string: task.title).boundingRect(with: estimateSize, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 15)], context: nil)
            return CGSize(width: cellWidth, height: estimatedFrame.height + cellHeight)
        }
        return CGSize(width: cellWidth, height: cellHeight + 44) // 44 is the estimated height for titleLabel
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return completedTasks?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return completedTasks?[section].count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let completedTaskCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.cell_id, for: indexPath) as? TaskCell else {
            return BaseCollectionViewCell()
        }
        let task = completedTasks?[indexPath.section][indexPath.item]
        completedTaskCell.task = task
        return completedTaskCell
    }

}











