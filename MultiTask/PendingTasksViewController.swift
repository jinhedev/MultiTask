//
//  PendingTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class PendingTasksViewController: BaseViewController, PersistentContainerDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIViewControllerPreviewingDelegate, TaskEditorViewControllerDelegate, MainTasksViewControllerDelegate {

    // MARK: - API

    var pendingTasks: [Results<Task>]?
    var notificationToken: NotificationToken?
    weak var tasksPageViewController: TasksPageViewController?
    static let storyboard_id = String(describing: PendingTasksViewController.self)
    let PAGE_INDEX = 0 // provides index data for parent pageViewController

    // MARK: - PersistentContainerDelegate

    var realmManager: RealmManager?

    private func setupPersistentContainerDelegate() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    private func setupRealmNotificationsForCollectionView() {
        notificationToken = self.pendingTasks!.first?.observe({ [weak self] (changes) in
            guard let collectionView = self?.collectionView else { return }
            switch changes {
            case .initial:
                collectionView.reloadData()
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                collectionView.applyChanges(deletions: deletions, insertions: insertions, updates: modifications)
            case .error(let err):
                print(trace(file: #file, function: #function, line: #line))
                print(err.localizedDescription)
            }
        })
    }

    @objc func performInitialFetch(notification: Notification?) {
        if self.pendingTasks == nil || self.pendingTasks?.isEmpty == true {
            self.realmManager?.fetchTasks(predicate: Task.pendingPredicate, sortedBy: Task.createdAtKeyPath, ascending: false)
        }
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didFetchTasks tasks: Results<Task>?) {
        guard let fetchedTasks = tasks else { return }
        self.pendingTasks = [Results<Task>]()
        self.pendingTasks!.append(fetchedTasks)
        self.setupRealmNotificationsForCollectionView()
    }

    func persistentContainer(_ manager: RealmManager, didDelete objects: [Object]?) {
        if self.isEditing == true {
            // exit edit mode
            self.isEditing = false
        }
    }

    // MARK: - Notifications

    func observeNotificationForTaskPendingFetch() {
        NotificationCenter.default.addObserver(self, selector: #selector(performInitialFetch(notification:)), name: NSNotification.Name(rawValue: NotificationKey.TaskPending), object: nil)
    }

    // MARK: - MainTasksViewControllerDelegate

    override func setEditing(_ editing: Bool, animated: Bool) {
        // FIXME: when scrolling very fast in edit mode, some items may not be visible, and the collectionView is not fast enough to turn them into editing mode.
        super.setEditing(editing, animated: animated)
        self.collectionView?.allowsMultipleSelection = editing
        guard let indexPaths = self.collectionView?.indexPathsForVisibleItems else { return }
        for indexPath in indexPaths {
            self.collectionView?.deselectItem(at: indexPath, animated: false)
            if let cell = self.collectionView?.cellForItem(at: indexPath) as? TaskCell {
                cell.editing = editing
            }
        }
    }

    private func setupMainTasksViewControllerDelegate() {
        self.tasksPageViewController?.mainTasksViewController?.pendingTasksDelegate = self
    }

    func collectionViewEditMode(_ viewController: MainTasksViewController, didTapTrash button: UIBarButtonItem) {
        if self.isEditing == true {
            guard let tasks = self.pendingTasks else { return }
            var tasksToBeDeleted = [Task]()
            if let indexPaths = self.collectionView.indexPathsForSelectedItems {
                for indexPath in indexPaths {
                    let taskToBeDeleted = tasks[indexPath.section][indexPath.item]
                    tasksToBeDeleted.append(taskToBeDeleted)
                }
                self.realmManager?.deleteObjects(objects: tasksToBeDeleted)
            }
        }
    }

    func collectionViewEditMode(_ viewController: MainTasksViewController, didTapEdit button: UIBarButtonItem, editMode isEnabled: Bool) {
        self.isEditing = isEnabled
    }

    // MARK: - TaskEditorViewControllerDelegate

    func taskEditorViewController(_ viewController: TaskEditorViewController, didCancelTask task: Task?, at indexPath: IndexPath?) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func taskEditorViewController(_ viewController: TaskEditorViewController, didUpdateTask task: Task, at indexPath: IndexPath) {
        viewController.dismiss(animated: true, completion: nil)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupViewControllerPreviewingDelegate()
        self.setupPersistentContainerDelegate()
        self.observeNotificationForTaskPendingFetch()
        self.setupMainTasksViewControllerDelegate()
        // initial fetch
        self.performInitialFetch(notification: nil)
        if let pathToSandbox = realmManager?.pathForContainer?.absoluteString {
            print(pathToSandbox)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.PendingTaskCellToItemsViewController {
            guard let itemsViewController = segue.destination as? ItemsViewController, let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else {
                print(trace(file: #file, function: #function, line: #line))
                return
            }
            itemsViewController.selectedTask = self.pendingTasks?[selectedIndexPath.section][selectedIndexPath.item]
        }
    }

    // MARK: - UIViewControllerPreviewingDelegate

    private func setupViewControllerPreviewingDelegate() {
        self.registerForPreviewing(with: self, sourceView: self.collectionView)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if self.isEditing == false {
            self.present(viewControllerToCommit, animated: true, completion: nil)
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let selectedIndexPath = self.collectionView.indexPathForItem(at: location) else { return nil }
        let taskEditorViewController = storyboard?.instantiateViewController(withIdentifier: TaskEditorViewController.storyboard_id) as? TaskEditorViewController
        taskEditorViewController?.delegate = self
        taskEditorViewController?.selectedTask = self.pendingTasks?[selectedIndexPath.section][selectedIndexPath.item]
        if let selectedCell = self.collectionView.cellForItem(at: selectedIndexPath) as? TaskCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return self.isEditing ? nil : taskEditorViewController
    }

    // MARK: - UICollecitonView

    @IBOutlet weak var collectionView: UICollectionView!

    private func setupCollectionView() {
        self.isEditing = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: TaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: TaskCell.cell_id)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditing == false {
            self.performSegue(withIdentifier: Segue.PendingTaskCellToItemsViewController, sender: self)
        } else {
            if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? TaskCell {
                selectedCell.isSelected = true
            }
        }
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
        let cellHeight: CGFloat = 8 + 8 + 8 + 15 + 15 + 8 + 8 + 4
        // REMARK: containerViewTopMargin + titleLabelTopMargin + titleLabelBottomMargin + subtitleLabelHeight + dateLabelHeight + dateLabelBottomMargin + containerViewBottomMargin + errorOffset (see TaskCell.xib for references)
        if let task = self.pendingTasks?[indexPath.section][indexPath.item] {
            let estimateSize = CGSize(width: cellWidth, height: cellHeight)
            let estimatedFrame = NSString(string: task.title).boundingRect(with: estimateSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)], context: nil)
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
        pendingTaskCell.editing = isEditing
        return pendingTaskCell
    }

}
