//
//  CompletedTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class CompletedTasksViewController: BaseViewController, PersistentContainerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerPreviewingDelegate, TaskEditorViewControllerDelegate, MainTasksViewControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegateMosaicLayout {

    // MARK: - API

    var completedTasks: [Results<Task>]?
    var realmManager: RealmManager?
    var notificationToken: NotificationToken?

    weak var tasksPageViewController: TasksPageViewController?
    let PAGE_INDEX = 1 // provides index data for parent pageViewController
    static let storyboard_id = String(describing: CompletedTasksViewController.self)

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionViewMosaicLayout: UICollectionViewMosaicLayout!

    // MARK: - PersistentContainerDelegate

    private func setupPersistentContainerDelegate() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    private func setupRealmNotificationsForCollectionView() {
        notificationToken = self.completedTasks!.first?.observe({ [weak self] (changes) in
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
        if self.completedTasks == nil || self.completedTasks?.isEmpty == true {
            self.realmManager?.fetchTasks(predicate: Task.completedPredicate, sortedBy: Task.createdAtKeyPath, ascending: false)
        }
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didFetchTasks tasks: Results<Task>?) {
        guard let fetchedTasks = tasks else { return }
        self.completedTasks = [Results<Task>]()
        self.completedTasks!.append(fetchedTasks)
        self.setupRealmNotificationsForCollectionView()
    }

    func persistentContainer(_ manager: RealmManager, didDelete objects: [Object]?) {
        if self.isEditing == true {
            // exit edit mode
            self.isEditing = false
        }
    }

    // MARK: - Notifications

    func observeNotificationForTaskCompletion() {
        NotificationCenter.default.addObserver(self, selector: #selector(performInitialFetch(notification:)), name: NSNotification.Name(rawValue: NotificationKey.TaskCompletion), object: nil)
    }

    // MARK: - MainTasksViewControllerDelegate

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // FIXME: when in editing mode and scrolling very fast, some items may not be visible, and the collectionView is not fast enough to turn them into editing mode.
        super.setEditing(editing, animated: animated)
        self.collectionView?.allowsMultipleSelection = editing
        guard let indexPaths = self.collectionView?.indexPathsForVisibleItems else { return }
        for indexPath in indexPaths {
            self.collectionView?.deselectItem(at: indexPath, animated: false)
            if let cell = self.collectionView?.cellForItem(at: indexPath) as? CompletedTaskCell {
                cell.editing = editing
            }
        }
    }

    private func setupMainTasksViewControllerDelegate() {
        self.tasksPageViewController?.mainTasksViewController?.completedTasksDelegate = self
    }

    func collectionViewEditMode(_ viewController: MainTasksViewController, didTapEdit button: UIBarButtonItem, editMode isEnabled: Bool) {
        self.isEditing = isEnabled
    }

    func collectionViewEditMode(_ viewController: MainTasksViewController, didTapTrash button: UIBarButtonItem) {
        if self.isEditing == true {
            guard let tasks = self.completedTasks else { return }
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

    // MARK: - TaskEditorViewControllerDelegate

    func taskEditorViewController(_ viewController: TaskEditorViewController, didCancelTask task: Task?, at indexPath: IndexPath?) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func taskEditorViewController(_ viewController: TaskEditorViewController, didUpdateTask task: Task, at indexPath: IndexPath) {
        viewController.dismiss(animated: true, completion: nil)
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
        taskEditorViewController?.selectedTask = self.completedTasks?[selectedIndexPath.section][selectedIndexPath.item]
        if let selectedCell = self.collectionView.cellForItem(at: selectedIndexPath) as? CompletedTaskCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return self.isEditing ? nil : taskEditorViewController
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupViewControllerPreviewingDelegate()
        self.setupPersistentContainerDelegate()
        self.observeNotificationForTaskCompletion()
        self.setupMainTasksViewControllerDelegate()
        self.performInitialFetch(notification: nil)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.CompletedTaskCellToItemsViewController {
            guard let itemsViewController = segue.destination as? ItemsViewController, let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else {
                print(trace(file: #file, function: #function, line: #line))
                return
            }
            itemsViewController.selectedTask = self.completedTasks?[selectedIndexPath.section][selectedIndexPath.item]
        }
    }

    // MARK: - UICollectionView

    private func setupCollectionView() {
        self.isEditing = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.register(UINib(nibName: CompletedTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: CompletedTaskCell.cell_id)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditing == false {
            self.performSegue(withIdentifier: Segue.CompletedTaskCellToItemsViewController, sender: self)
        } else {
            if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? CompletedTaskCell {
                selectedCell.isSelected = true
            }
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return insets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.collectionView.frame.width / 2) - 16 - 8 // cell leading & cell trailling space to offset (collectionView.insets + interItemSpacing)
        let cellHeight: CGFloat = 16 + (0) + 8 + 15 + 15 + 15 + 16
        // REMARK: titleLabelTopMargin + (titleLabelHeight) + titleLabelBottomMargin + subtitleLabelHeight + dateLabelHeight + statsLabelHeight + statsLabelBottomMargin (see CompletedTaskCell.xib for references)
        if let task = self.completedTasks?[indexPath.section][indexPath.item] {
            let estimatedWidthForTitle = cellWidth - 16 - 16
            let estimateHeightForTitle = task.title.heightForText(systemFont: 15, width: estimatedWidthForTitle) // titleLabel's leading and trailling margin to container's leading & trailling == 16 * 2
            return CGSize(width: cellWidth, height: estimateHeightForTitle + cellHeight)
        }
        return CGSize(width: cellWidth, height: cellHeight + 44) // 44 is the estimated minimum height for titleLabel
    }

    // MARK: - UICollectionViewDelegateMosaicLayout

    private func setupCollectionViewDelegateMosaicLayout() {
        collectionViewMosaicLayout.numberOfColumns = 0
    }

    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        let cellWidth = self.collectionView.frame.width / 2 - 16 - 8 // cell leading & cell trailling space to offset (collectionView.insets + interItemSpacing)
        let cellHeight: CGFloat = 16 + (0) + 8 + 15 + 15 + 15 + 16 // without titleLabel's height
        if let task = self.completedTasks?[indexPath.section][indexPath.item] {
            let estimatedWidthForTitle = cellWidth - 16 - 16
            let estimatedHeightForTitle = task.title.heightForText(systemFont: 15, width: estimatedWidthForTitle)
            return cellHeight + estimatedHeightForTitle
        }
        return cellHeight + 44
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return completedTasks?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return completedTasks?[section].count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let completedTaskCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CompletedTaskCell.cell_id, for: indexPath) as? CompletedTaskCell else {
            return BaseCollectionViewCell()
        }
        let task = completedTasks?[indexPath.section][indexPath.item]
        completedTaskCell.completedTask = task
        return completedTaskCell
    }

}











