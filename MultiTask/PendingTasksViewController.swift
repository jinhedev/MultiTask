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
    var realmManager: RealmManager?
    var notificationToken: NotificationToken?

    weak var tasksPageViewController: TasksPageViewController?
    let PAGE_INDEX = 0 // provides index data for parent pageViewController
    var placeholderBackgroundView: PlaceholderBackgroundView?
    static let storyboard_id = String(describing: PendingTasksViewController.self)

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    // MARK: - PersistentContainerDelegate

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
        if let fetchedTasks = tasks, !fetchedTasks.isEmpty {
            self.placeholderBackgroundView?.isHidden = true
            self.pendingTasks = [Results<Task>]()
            self.pendingTasks!.append(fetchedTasks)
            self.setupRealmNotificationsForCollectionView()
        } else {
            self.placeholderBackgroundView?.isHidden = false
        }
    }

    func persistentContainer(_ manager: RealmManager, didDeleteTasks tasks: [Task]?) {
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
            if let cell = self.collectionView?.cellForItem(at: indexPath) as? PendingTaskCell {
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
                self.realmManager?.deleteTasks(tasks: tasksToBeDeleted)
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

    // MARK: - EmptyView

    private func setupEmptyView() {
        if let view = UINib(nibName: PlaceholderBackgroundView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? PlaceholderBackgroundView {
            self.placeholderBackgroundView = view
            self.placeholderBackgroundView!.type = PlaceholderType.pendingTasks
            self.collectionView.backgroundView = self.placeholderBackgroundView
            self.placeholderBackgroundView!.isHidden = true
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupEmptyView()
        self.setupViewControllerPreviewingDelegate()
        self.setupPersistentContainerDelegate()
        self.observeNotificationForTaskPendingFetch()
        self.setupMainTasksViewControllerDelegate()
        // initial fetch
        self.performInitialFetch(notification: nil)
        if let pathToSandbox = RealmManager.pathForDefaultContainer?.absoluteString {
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
        if let selectedCell = self.collectionView.cellForItem(at: selectedIndexPath) as? PendingTaskCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return self.isEditing ? nil : taskEditorViewController
    }

    // MARK: - UICollecitonView

    private func setupCollectionView() {
        self.isEditing = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: PendingTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: PendingTaskCell.cell_id)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditing == false {
            self.performSegue(withIdentifier: Segue.PendingTaskCellToItemsViewController, sender: self)
        } else {
            if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? PendingTaskCell {
                selectedCell.isSelected = true
            }
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return insets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.collectionView.frame.width
        let cellHeight: CGFloat = 8 + 16 + (0) + 8 + 15 + 15 + 16 + 8
        // REMARK: containerViewTopMargin + titleLabelTopMargin + (titleLabelHeight) + titleLabelBottomMargin + subtitleLabelHeight + dateLabelHeight + dateLabelBottomMargin + containerViewBottomMargin (see TaskCell.xib for references)
        if let task = self.pendingTasks?[indexPath.section][indexPath.item] {
            let estimateHeightForTitle = task.title.heightForText(systemFont: 15, width: cellWidth - 32 - 32) // (the container's leading margin to View's leading == 16) + (titleLabel's leading margin to container's leading == 16), same for the trailling
            return CGSize(width: cellWidth, height: estimateHeightForTitle + cellHeight)
        }
        return CGSize(width: cellWidth, height: cellHeight + 44) // 44 is the estimated minimum height for titleLabel when none is provided
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pendingTasks?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pendingTasks?[section].count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let pendingTaskCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: PendingTaskCell.cell_id, for: indexPath) as? PendingTaskCell else {
            return BaseCollectionViewCell()
        }
        let task = pendingTasks?[indexPath.section][indexPath.item]
        pendingTaskCell.task = task
        pendingTaskCell.editing = isEditing
        return pendingTaskCell
    }

}
