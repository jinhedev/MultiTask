//
//  PendingTasksViewController.swift
//  MultiTask
//
//  Created by sudofluff on 2/10/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import UIKit
import Amplitude
import RealmSwift

class PendingTasksViewController: BaseViewController {
    
    var pendingTasks: Results<Task>? { didSet { self.observeTasksForChanges() } }
    var realmNotificationToken: NotificationToken?
    var mainTasksViewController: MainTasksViewController?
    static let storyboard_id = String(describing: PendingTasksViewController.self)
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.collectionView.allowsMultipleSelection = isEditing
        let indexPaths = self.collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            self.collectionView.deselectItem(at: indexPath, animated: false)
            if let cell = self.collectionView.cellForItem(at: indexPath) as? PendingTaskCell {
                cell.isEditing = isEditing
            }
        }
    }
    
    func observeTasksForChanges() {
        realmNotificationToken = self.pendingTasks?.observe({ [weak self] (changes) in
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
    
    func deleteTasks(indexPaths: [IndexPath]) {
        guard let tasks = self.pendingTasks, indexPaths.count > 0 else { return }
        // FIXME: is there a way to minimise the number of write operations to the db???
        for indexPath in indexPaths {
            let taskToBeDeleted = tasks[indexPath.item]
            do {
                try defaultRealm.write {
                    defaultRealm.delete(taskToBeDeleted.items)
                    defaultRealm.delete(taskToBeDeleted)
                }
            } catch let err {
                print(err.localizedDescription)
                Amplitude.instance().logEvent(LogEventType.realmError)
            }
        }
    }
    
    @objc func commitTrash() {
        if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems {
            deleteTasks(indexPaths: selectedIndexPaths)
        }
    }
    
    @objc func editMode(notification: Notification) {
        if let isEditing = notification.userInfo?["isEditing"] as? Bool {
            self.isEditing = isEditing
        }
    }
    
    private func setupBackgroundView() {
        if let view = UINib(nibName: PlaceholderBackgroundView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? PlaceholderBackgroundView {
            view.type = PlaceholderType.pendingTasks
            view.isHidden = true
            self.collectionView.backgroundView = view
        }
    }
    
    private func setupUICollectionView() {
        self.collectionView.indicatorStyle = .white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.backgroundColor = Color.inkBlack
        self.collectionView.scrollsToTop = true
        self.collectionView.register(UINib(nibName: PendingTaskCell.nibName, bundle: nil), forCellWithReuseIdentifier: PendingTaskCell.cell_id)
    }
    
    // MARK: - Notification
    
    func observeNotificationForEditMode() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.editMode(notification:)), name: NSNotification.Name.EditMode, object: nil)
    }
    
    func observeNotificationForCommitingTrash() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.commitTrash), name: NSNotification.Name.CommitTrash, object: nil)
    }
    
    func removeNotificationForEditMode() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.EditMode, object: nil)
    }
    
    func removeNotificationForCommitingTrash() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.CommitTrash, object: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial setups
        self.setupBackgroundView()
        self.setupUICollectionView()
        self.setupUICollectionViewDelegate()
        self.setupUICollectionViewDataSource()
        self.setupUICollectionViewDelegateFlowLayout()
        self.setupUIViewControllerPreviewingDelegate()
        // initial actions
        self.pendingTasks = Task.pending()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.observeNotificationForEditMode()
        self.observeNotificationForCommitingTrash()
        if let tasks = self.pendingTasks {
            if tasks.count <= 0 {
                self.collectionView.backgroundView?.isHidden = false
            } else {
                self.collectionView.backgroundView?.isHidden = true
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNotificationForEditMode()
        self.removeNotificationForCommitingTrash()
    }
    
}

extension PendingTasksViewController: UIViewControllerPreviewingDelegate {
    
    private func setupUIViewControllerPreviewingDelegate() {
        self.registerForPreviewing(with: self, sourceView: self.collectionView)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let navController = self.navigationController as? BaseNavigationController {
            viewControllerToCommit.hidesBottomBarWhenPushed = true
            navController.pushViewController(viewControllerToCommit, animated: true)
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else { return nil }
        let taskEditorViewController = storyboard?.instantiateViewController(withIdentifier: TaskEditorViewController.storyboard_id) as? TaskEditorViewController
        taskEditorViewController?.selectedTask = self.pendingTasks?[indexPath.item]
        if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? PendingTaskCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return taskEditorViewController
    }
    
}

extension PendingTasksViewController: UICollectionViewDelegate {
    
    private func setupUICollectionViewDelegate() {
        self.collectionView.delegate = self
    }
    
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
            if let itemsViewController = UIStoryboard(name: "TasksTab", bundle: nil).instantiateViewController(withIdentifier: ItemsViewController.storyboard_id) as? ItemsViewController, let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                itemsViewController.selectedTask = self.pendingTasks?[selectedIndexPath.item]
                self.mainTasksViewController?.navigationController?.pushViewController(itemsViewController, animated: true)
            }
        } else {
            if let selectedCell = self.collectionView.cellForItem(at: indexPath) as? PendingTaskCell {
                selectedCell.isSelected = true
            }
        }
    }
    
}

extension PendingTasksViewController: UICollectionViewDataSource {
    
    private func setupUICollectionViewDataSource() {
        self.collectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pendingTasks?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: PendingTaskCell.cell_id, for: indexPath) as? PendingTaskCell {
            let task = self.pendingTasks?[indexPath.item]
            cell.pendingTask = task
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }
    
}

extension PendingTasksViewController: UICollectionViewDelegateFlowLayout {
    
    private func setupUICollectionViewDelegateFlowLayout() {
        self.collectionViewFlowLayout.scrollDirection = .vertical
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.collectionView.frame.width
        let cellHeight: CGFloat = 8 + 16 + (0) + 8 + 15 + 15 + 16 + 8
        // REMARK: containerViewTopMargin + titleLabelTopMargin + (titleLabelHeight) + titleLabelBottomMargin + subtitleLabelHeight + dateLabelHeight + dateLabelBottomMargin + containerViewBottomMargin (see TaskCell.xib for references)
        if let task = self.pendingTasks?[indexPath.item] {
            let titleWidth: CGFloat = cellWidth - 16 - 16 - 16 - 16
            let estimateHeightForTitle = task.title.heightForText(systemFont: 15, width: titleWidth) // (the container's leading margin to View's leading == 16) + (titleLabel's leading margin to container's leading == 16), same for the trailling
            return CGSize(width: cellWidth, height: estimateHeightForTitle + cellHeight)
        }
        return CGSize(width: cellWidth, height: cellHeight + 44) // 44 is the estimated minimum height for titleLabel when none is provided
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}
