//
//  PendingDetailViewController.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class ItemsViewController: BaseViewController {

    // MARK: - API

    var soundEffectManager: SoundEffectManager?
    var selectedTask: Task?
    var notificationToken: NotificationToken?
    var itemEditorViewController: ItemEditorViewController?
    var searchController: UISearchController!
    var pendingAction: UIContextualAction!
    var completeAction: UIContextualAction!
    var deleteAction: UIContextualAction!
    static let storyboard_id = String(describing: ItemsViewController.self)
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    private func setupSearchController() {
        guard let searchResultsViewController = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: SearchResultsViewController.storyboard_id) as? SearchResultsViewController else { return }
        searchResultsViewController.itemsViewController = self
        self.searchController = UISearchController(searchResultsController: searchResultsViewController)
        searchResultsViewController.selectedTask = self.selectedTask
        self.searchController.searchResultsUpdater = searchResultsViewController
        self.searchController.searchBar.barStyle = .black
        self.searchController.searchBar.tintColor = Color.mandarinOrange
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func observeItemsForChanges() {
        notificationToken = self.selectedTask?.items.observe({ [weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                tableView.applyChanges(deletions: deletions, insertions: insertions, updates: modifications)
            case .error(let err):
                print(trace(file: #file, function: #function, line: #line))
                print(err.localizedDescription)
            }
        })
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // initial setups
        self.setupNavigationBar()
        self.setupUITableViewDelegate()
        self.setupUITableViewDataSource()
        self.setupTableView()
        self.setupBackgroundView()
        self.setupSearchController()
        self.setupSoundEffectDelegate()
        self.setupViewControllerPreviewingDelegate()
        // initial actions
        self.observeItemsForChanges()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.ItemsViewControllerToItemEditorViewController {
            itemEditorViewController = segue.destination as? ItemEditorViewController
            itemEditorViewController?.hidesBottomBarWhenPushed = true
            itemEditorViewController?.parentTask = self.selectedTask
            itemEditorViewController?.itemEditorAction = ItemEditorAction.AddNewItem
        } else if segue.identifier == Segue.EditButtonToTaskEditorViewController {
            if let taskEditorViewController = segue.destination as? TaskEditorViewController {
                taskEditorViewController.hidesBottomBarWhenPushed = true
                taskEditorViewController.selectedTask = self.selectedTask
            }
        }
    }
    
    // MARK: - BackgroundView
    
    private func setupBackgroundView() {
        if let view = UINib(nibName: PlaceholderBackgroundView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? PlaceholderBackgroundView {
            view.type = PlaceholderType.pendingTasks
            view.isHidden = true
            self.tableView.backgroundView = view
        }
    }

    // MARK: - NavigationBar

    private func setupNavigationBar() {
        self.navigationItem.title?.removeAll()
    }

    @IBAction func handleAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Segue.ItemsViewControllerToItemEditorViewController, sender: self)
    }

    // MARK: - UITableView

    private func setupTableView() {
        self.tableView.backgroundColor = Color.inkBlack
        self.tableView.register(UINib(nibName: ItemCell.nibName, bundle: nil), forCellReuseIdentifier: ItemCell.cell_id)
    }

}

extension ItemsViewController: SoundEffectDelegate {
    
    private func setupSoundEffectDelegate() {
        self.soundEffectManager = SoundEffectManager()
        self.soundEffectManager!.delegate = self
    }
    
    func soundEffect(_ manager: SoundEffectManager, didPlaySoundEffect soundEffect: SoundEffect, player: AVAudioPlayer) {
        // implement this if needed
    }
    
    func soundEffect(_ manager: SoundEffectManager, didErr error: Error) {
        if let navigationController = self.navigationController as? BaseNavigationController {
            navigationController.scheduleNavigationPrompt(with: error.localizedDescription, duration: 5)
        }
    }
    
}

extension ItemsViewController: UIViewControllerPreviewingDelegate {
    
    private func setupViewControllerPreviewingDelegate() {
        self.registerForPreviewing(with: self, sourceView: self.tableView)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let navController = self.navigationController as? BaseNavigationController {
            viewControllerToCommit.hidesBottomBarWhenPushed = true
            navController.pushViewController(viewControllerToCommit, animated: true)
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return nil }
        let itemEditorViewController = storyboard?.instantiateViewController(withIdentifier: ItemEditorViewController.storyboard_id) as? ItemEditorViewController
        itemEditorViewController?.parentTask = self.selectedTask
        itemEditorViewController?.itemEditorAction = ItemEditorAction.UpdateExistingItem
        itemEditorViewController?.selectedItem = self.selectedTask?.items[indexPath.row]
        // setting the peeking cell's animation
        if let selectedCell = self.tableView.cellForRow(at: indexPath) as? ItemCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return itemEditorViewController
    }
    
}

extension ItemsViewController: UITableViewDelegate {
    
    private func setupUITableViewDelegate() {
        self.tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let selectedItem = self.selectedTask?.items[indexPath.row] else { return nil }
        // user marks item for pending
        pendingAction = UIContextualAction(style: UIContextualAction.Style.normal, title: nil) { (action, view, is_success) in
            selectedItem.pend()
            is_success(true)
        }
        pendingAction.image = #imageLiteral(resourceName: "Code") // <<-- watch out for image literal
        pendingAction.backgroundColor = Color.mandarinOrange
        // user marks item for completion
        completeAction = UIContextualAction(style: UIContextualAction.Style.normal, title: nil) { (action, view, is_success) in
            selectedItem.complete()
            is_success(true)
        }
        completeAction.image = #imageLiteral(resourceName: "Tick") // <<-- watch out for image literal. It's almost invisible.
        completeAction.backgroundColor = Color.seaweedGreen
        // if this cell has been completed, show pendingAction, if not, show doneAction
        if selectedItem.shouldComplete() {
            let swipeActionConfigurations = UISwipeActionsConfiguration(actions: [completeAction])
            swipeActionConfigurations.performsFirstActionWithFullSwipe = true
            return swipeActionConfigurations
        } else {
            let swipeActionConfigurations = UISwipeActionsConfiguration(actions: [pendingAction])
            swipeActionConfigurations.performsFirstActionWithFullSwipe = true
            return swipeActionConfigurations
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let selectedItem = self.selectedTask?.items[indexPath.row] else { return nil }
        deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: nil) { (action, view, is_success) in
            selectedItem.delete()
            is_success(true)
        }
        deleteAction.image = #imageLiteral(resourceName: "Trash") // <<-- watch out for image literal
        deleteAction.backgroundColor = Color.roseScarlet
        let swipeActionConfigurations = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActionConfigurations.performsFirstActionWithFullSwipe = false
        return swipeActionConfigurations
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension ItemsViewController: UITableViewDataSource {
    
    private func setupUITableViewDataSource() {
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = self.tableView.dequeueReusableCell(withIdentifier: ItemCell.cell_id, for: indexPath) as? ItemCell {
            let item = self.selectedTask?.items[indexPath.row]
            itemCell.item = item
            return itemCell
        } else {
            return BaseTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedTask?.items.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
