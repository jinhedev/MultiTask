//
//  MainPendingTaskCell.swift
//  MultiTask
//
//  Created by rightmeow on 12/7/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class MainPendingTasksCell: BaseCollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, PersistentContainerDelegate, MainTasksViewControllerDelegate {

    // MARK: - API

    var isEditing: Bool = false {
        didSet {
            self.setEditing()
        }
    }

    weak var mainTasksViewController: MainTasksViewController? {
        didSet {
            self.setupMainTasksViewControllerDelegate()
        }
    }

    var pendingTasks: [Results<Task>]?
    var realmManager: RealmManager?
    var notificationToken: NotificationToken?

    static let cell_id = String(describing: MainPendingTasksCell.self)
    static let nibName = String(describing: MainPendingTasksCell.self)

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!

    private func setEditing() {
        // FIXME: when scrolling very fast in edit mode, some items may not be visible, and the collectionView is not fast enough to turn them into editing mode.
        self.collectionView?.allowsMultipleSelection = isEditing
        guard let indexPaths = self.collectionView?.indexPathsForVisibleItems else { return }
        for indexPath in indexPaths {
            self.collectionView?.deselectItem(at: indexPath, animated: false)
            if let cell = self.collectionView?.cellForItem(at: indexPath) as? PendingTaskCell {
                cell.isEditing = isEditing
            }
        }
    }

    @objc func enableEditingMode() {
        self.isEditing = true
    }

    // MARK: - MainTasksViewControllerDelegate

    private func setupMainTasksViewControllerDelegate() {
        self.mainTasksViewController?.delegateForPendingTasksCell = self
    }

    func mainTasksViewController(_ viewController: MainTasksViewController, didTapEdit button: UIBarButtonItem, isEditing: Bool) {
        self.isEditing = isEditing
    }

    func mainTasksViewController(_ viewController: MainTasksViewController, didTapTrash button: UIBarButtonItem) {
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
        } else {
            print(trace(file: #file, function: #function, line: #line))
        }
    }

    // MARK: - PersistentContainerDelegate

    private func setupPersistentContainerDelegate() {
        self.realmManager = RealmManager()
        self.realmManager!.delegate = self
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

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        if let navigationController = self.mainTasksViewController?.navigationController as? BaseNavigationController {
            navigationController.scheduleNavigationPrompt(with: error.localizedDescription, duration: 5)
        }
    }

    func persistentContainer(_ manager: RealmManager, didFetchTasks tasks: Results<Task>?) {
        if let fetchedTasks = tasks, !fetchedTasks.isEmpty {
            self.collectionView.backgroundView?.isHidden = true
            self.pendingTasks = [Results<Task>]()
            self.pendingTasks!.append(fetchedTasks)
            self.setupRealmNotificationsForCollectionView()
        } else {
            self.collectionView.backgroundView?.isHidden = false
        }
    }

    func persistentContainer(_ manager: RealmManager, didDeleteTasks tasks: [Task]?) {
        if self.isEditing == true {
            // exit edit mode
            self.isEditing = false
        }
    }

    @objc func performInitialFetch(notification: Notification?) {
        if self.pendingTasks == nil || self.pendingTasks?.isEmpty == true {
            self.realmManager?.fetchTasks(predicate: Task.pendingPredicate, sortedBy: Task.createdAtKeyPath, ascending: false)
        }
    }

    // MARK: - Notifications

    func observeNotificationForTaskPendingFetch() {
        NotificationCenter.default.addObserver(self, selector: #selector(performInitialFetch(notification:)), name: NSNotification.Name(rawValue: NotificationKey.TaskPending), object: nil)
    }

    func observeNotificationForEditingMode() {
        NotificationCenter.default.addObserver(self, selector: #selector(enableEditingMode), name: NSNotification.Name(rawValue: NotificationKey.CollectionViewEditingMode), object: nil)
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
        self.setupCollectionView()
        self.setupCollectionViewFlowLayout()
        self.setupPersistentContainerDelegate()
        self.observeNotificationForTaskPendingFetch()
        self.observeNotificationForEditingMode()
        // initial fetch
        self.performInitialFetch(notification: nil)
        if let pathToSandbox = RealmManager.pathForDefaultContainer?.absoluteString {
            print(pathToSandbox)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - BaseCollectionViewCell

    private func setupCell() {
        self.backgroundColor = Color.inkBlack
        self.isEditing = false
    }

    // MARK: - CollectionView

    private func setupCollectionView() {
        self.collectionView.indicatorStyle = .white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: PendingTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: PendingTaskCell.cell_id)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let highlightedCell = self.collectionView.cellForItem(at: indexPath) as? PendingTaskCell {
            highlightedCell.isHighlighted = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let highlightedCell = self.collectionView.cellForItem(at: indexPath) as? PendingTaskCell {
            highlightedCell.isHighlighted = false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditing == false {
            if let itemsViewController = UIStoryboard(name: "TasksTab", bundle: nil).instantiateViewController(withIdentifier: ItemsViewController.storyboard_id) as? ItemsViewController, let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first {
                itemsViewController.selectedTask = self.pendingTasks?[selectedIndexPath.section][selectedIndexPath.item]
                self.mainTasksViewController?.navigationController?.pushViewController(itemsViewController, animated: true)
            }
        } else {
            if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? PendingTaskCell {
                selectedCell.isSelected = true
            }
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    private func setupCollectionViewFlowLayout() {
        self.collectionViewFlowLayout.scrollDirection = .vertical
    }

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
            let titleWidth: CGFloat = cellWidth - 16 - 16 - 16 - 16
            let estimateHeightForTitle = task.title.heightForText(systemFont: 15, width: titleWidth) // (the container's leading margin to View's leading == 16) + (titleLabel's leading margin to container's leading == 16), same for the trailling
            return CGSize(width: cellWidth, height: estimateHeightForTitle + cellHeight)
        }
        return CGSize(width: cellWidth, height: cellHeight + 44) // 44 is the estimated minimum height for titleLabel when none is provided
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: PendingTaskCell.cell_id, for: indexPath) as? PendingTaskCell {
            let task = self.pendingTasks?[indexPath.section][indexPath.item]
            cell.task = task
            cell.isEditing = isEditing
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pendingTasks?[section].count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.pendingTasks?.count ?? 0
    }

}
