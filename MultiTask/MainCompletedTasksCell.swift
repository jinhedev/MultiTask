//
//  MainTaskCell.swift
//  MultiTask
//
//  Created by rightmeow on 12/6/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class MainCompletedTasksCell: BaseCollectionViewCell, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, PersistentContainerDelegate, MainTasksViewControllerDelegate {

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

    var completedTasks: [Results<Task>]?
    var realmManager: RealmManager?
    var notificationToken: NotificationToken?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    static let cell_id = String(describing: MainCompletedTasksCell.self)
    static let nibName = String(describing: MainCompletedTasksCell.self)

    private func setEditing() {
        // FIXME: when scrolling very fast in edit mode, some items may not be visible, and the collectionView is not fast enough to turn them into editing mode.
        self.collectionView?.allowsMultipleSelection = isEditing
        guard let indexPaths = self.collectionView?.indexPathsForVisibleItems else { return }
        for indexPath in indexPaths {
            self.collectionView?.deselectItem(at: indexPath, animated: false)
            if let cell = self.collectionView?.cellForItem(at: indexPath) as? CompletedTaskCell {
                cell.isEditing = isEditing
            }
        }
    }

    @objc func enableEditingMode() {
        self.isEditing = true
    }

    // MARK: - PersistentContainerDelegate

    private func setupPersistentContainerDelegate() {
        self.realmManager = RealmManager()
        self.realmManager!.delegate = self
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
        if let navigationController = self.mainTasksViewController?.navigationController as? BaseNavigationController {
            navigationController.scheduleNavigationPrompt(with: error.localizedDescription, duration: 5)
        }
    }

    func persistentContainer(_ manager: RealmManager, didFetchTasks tasks: Results<Task>?) {
        if let fetchedTasks = tasks, !fetchedTasks.isEmpty {
            self.collectionView.backgroundView?.isHidden = true
            self.completedTasks = [Results<Task>]()
            self.completedTasks!.append(fetchedTasks)
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

    // MARK: - MainTasksViewControllerDelegate

    private func setupMainTasksViewControllerDelegate() {
        self.mainTasksViewController?.delegateForCompletedTasksCell = self
    }

    func mainTasksViewController(_ viewController: MainTasksViewController, didTapEdit button: UIBarButtonItem, isEditing: Bool) {
        self.isEditing = isEditing
    }

    func mainTasksViewController(_ viewController: MainTasksViewController, didTapTrash button: UIBarButtonItem) {
        if self.isEditing == true {
            guard let tasks = self.completedTasks else { return }
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

    // MAKR: - Notifications

    func observeNotificationForTaskCompletion() {
        NotificationCenter.default.addObserver(self, selector: #selector(performInitialFetch(notification:)), name: NSNotification.Name(rawValue: NotificationKey.TaskCompletion), object: nil)
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
        self.observeNotificationForTaskCompletion()
        self.observeNotificationForEditingMode()
        self.performInitialFetch(notification: nil)
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
        self.collectionView.register(UINib(nibName: CompletedTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: CompletedTaskCell.cell_id)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let highlightedCell = self.collectionView.cellForItem(at: indexPath) as? CompletedTaskCell {
            highlightedCell.isHighlighted = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let highlightedCell = self.collectionView.cellForItem(at: indexPath) as? CompletedTaskCell {
            highlightedCell.isHighlighted = false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditing == false {
            if let itemsViewController = UIStoryboard(name: "TasksTab", bundle: nil).instantiateViewController(withIdentifier: ItemsViewController.storyboard_id) as? ItemsViewController, let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first {
                itemsViewController.selectedTask = self.completedTasks?[selectedIndexPath.section][selectedIndexPath.item]
                self.mainTasksViewController?.navigationController?.pushViewController(itemsViewController, animated: true)
            }
        } else {
            if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? CompletedTaskCell {
                selectedCell.isSelected = true
            }
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    private func setupCollectionViewFlowLayout() {
        self.collectionViewFlowLayout.scrollDirection = .vertical
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return insets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.collectionView.frame.width / 2) - 16 - 8 // cell leading & cell trailling space to offset (collectionView.insets + interItemSpacing)
        let cellHeight: CGFloat = 16 + (0) + 8 + 15 + 15 + 15 + 16
        return CGSize(width: cellWidth, height: cellHeight + 22) // 44 is the estimated minimum height for titleLabel
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CompletedTaskCell.cell_id, for: indexPath) as? CompletedTaskCell {
            let task = self.completedTasks?[indexPath.section][indexPath.item]
            cell.completedTask = task
            cell.isEditing = isEditing
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.completedTasks?[section].count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.completedTasks?.count ?? 0
    }

}
