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
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didFetchTasks tasks: Results<Task>?) {
        guard let fetchedTasks = tasks else { return }
        self.pendingTasks = [Results<Task>]()
        self.pendingTasks!.append(fetchedTasks)
        self.setupRealmNotificationsForCollectionView()
    }

    // MARK: - Notifications

    func observeNotificationForTaskPending() {
        NotificationCenter.default.addObserver(self, selector: #selector(performInitialFetch(notification:)), name: NSNotification.Name(rawValue: NotificationKey.TaskPending), object: nil)
    }

    @objc func performInitialFetch(notification: Notification?) {
        if self.pendingTasks == nil || self.pendingTasks?.isEmpty == true {
            self.realmManager?.fetchTasks(predicate: Task.pendingPredicate, sortedBy: Task.createdAtKeyPath, ascending: false)
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupViewControllerPreviewingDelegate()
        self.setupPersistentContainerDelegate()
        self.observeNotificationForTaskPending()
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
        return pendingTaskCell
    }

}

















