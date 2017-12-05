//
//  SearchResultsViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/20/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class SearchResultsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, PersistentContainerDelegate, UIViewControllerPreviewingDelegate, ItemEditorViewControllerDelegate {

    // MARK: - API

    var selectedTask: Task?
    var searchResultsItems: [Results<Item>]?
    var realmManager: RealmManager?

    static let storyboard_id = String(describing: SearchResultsViewController.self)

    @IBOutlet weak var tableView: UITableView!

    // MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text {
            // REMARK: It is not meaningful to execute search with just 1 or 2 provided characters in a UX persepective, most importantly, adding this case to filter out 2 characters improves server's workload as well. i.e. Facebook, Reddit, etc.
            self.tableView.backgroundView?.isHidden = true
            if !searchString.isEmpty {
                if searchString.count > 2 {
                    guard let parentTask = self.selectedTask else { return }
                    self.realmManager?.fetchItems(parentTaskId: parentTask.id, predicate: Item.titlePredicate(by: searchString))
                } else {
                    // searchString.count is < 2, clears out results from the array
                    self.searchResultsItems?.removeAll()
                    self.tableView.reloadData()
                }
            } else {
                // user has not entered anything, clear out all remaining result from previous search
                self.searchResultsItems?.removeAll()
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - PersistentContainerDelegate

    private func setupPersistentContainerDelegate() {
        self.realmManager = RealmManager()
        self.realmManager!.delegate = self
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        if let navigationController = self.navigationController as? BaseNavigationController {
            navigationController.scheduleNavigationPrompt(with: error.localizedDescription, duration: 5)
        }
    }

    func persistentContainer(_ manager: RealmManager, didFetchItems items: Results<Item>?) {
        if let fetchedItems = items, !fetchedItems.isEmpty {
            self.tableView.backgroundView?.isHidden = true
            if self.searchResultsItems != nil {
                self.searchResultsItems!.removeAll()
            } else {
                self.searchResultsItems = [Results<Item>]()
            }
            self.searchResultsItems!.append(fetchedItems)
            self.tableView.reloadData()
        } else {
            self.searchResultsItems?.removeAll()
            self.tableView.reloadData()
            self.tableView.backgroundView?.isHidden = false
        }
    }

    // MARK: - ItemEditorViewControllerDelegate

    func itemEditorViewController(_ viewController: ItemEditorViewController, didCancelItem item: Item?, at indexPath: IndexPath?) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func itemEditorViewController(_ viewController: ItemEditorViewController, didAddItem item: Item, at indexPath: IndexPath?) {
        // this viewController does not handle adding new items
        viewController.dismiss(animated: true, completion: nil)
    }

    func itemEditorViewController(_ viewController: ItemEditorViewController, didUpdateItem item: Item, at indexPath: IndexPath) {
        viewController.dismiss(animated: true, completion: {
            self.tableView.reloadData()
        })
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupViewControllerPreviewingDelegate()
        self.setupPersistentContainerDelegate()
    }

    // MARK: - UIViewControllerPreviewingDelegate

    private func setupViewControllerPreviewingDelegate() {
        self.registerForPreviewing(with: self, sourceView: self.tableView)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return nil }
        let itemEditorViewController = storyboard?.instantiateViewController(withIdentifier: ItemEditorViewController.storyboard_id) as? ItemEditorViewController
        itemEditorViewController?.delegate = self
        itemEditorViewController?.parentTask = self.selectedTask
        itemEditorViewController?.selectedIndexPath = indexPath
        itemEditorViewController?.selectedItem = searchResultsItems?[indexPath.section][indexPath.row]
        // setting the peeking cell's animation
        if let selectedCell = self.tableView.cellForRow(at: indexPath) as? ItemCell {
            previewingContext.sourceRect = selectedCell.frame
        }
        return itemEditorViewController
    }

    // MARK: - UITableView

    private func setupTableView() {
        self.view.backgroundColor = Color.clear
        self.tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = Color.transparentBlack
        self.tableView.register(UINib(nibName: SearchResultCell.nibName, bundle: nil), forCellReuseIdentifier: SearchResultCell.cell_id)
        self.tableView.backgroundView = self.initPlaceholderBackgroundView(type: PlaceholderType.emptyResults)
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: scroll the itemsViewController to the selected item
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: SearchResultCell.cell_id, for: indexPath) as? SearchResultCell {
            let item = self.searchResultsItems?[indexPath.section][indexPath.row]
            cell.item = item
            return cell
        } else {
            return BaseTableViewCell()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.searchResultsItems?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResultsItems?[section].count ?? 0
    }

}