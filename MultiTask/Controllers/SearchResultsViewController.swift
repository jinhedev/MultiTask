//
//  SearchResultsViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/20/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class SearchResultsViewController: BaseViewController {

    var selectedTask: Task?
    var searchResultsItems: [Results<Item>]?
    var realmManager: RealmManager?
    weak var itemsViewController: ItemsViewController?
    static let storyboard_id = String(describing: SearchResultsViewController.self)
    @IBOutlet weak var tableView: UITableView!
    
    private func setupBackgroundView() {
        if let view = UINib(nibName: PlaceholderBackgroundView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? PlaceholderBackgroundView {
            view.type = PlaceholderType.pendingTasks
            view.isHidden = true
            self.tableView.backgroundView = view
        }
    }
    
    private func setupTableView() {
        self.view.backgroundColor = Color.clear
        self.tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = Color.transparentBlack
        self.tableView.register(UINib(nibName: SearchResultCell.nibName, bundle: nil), forCellReuseIdentifier: SearchResultCell.cell_id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupBackgroundView()
        self.setupPersistentContainerDelegate()
    }

}

extension SearchResultsViewController: PersistentContainerDelegate {
    
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
    
}

extension SearchResultsViewController: UISearchResultsUpdating {
    
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
    
}

extension SearchResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedItem = self.searchResultsItems?[indexPath.section][indexPath.item] {
            guard let itemEditorViewController = UIStoryboard(name: "TasksTab", bundle: nil).instantiateViewController(withIdentifier: ItemEditorViewController.storyboard_id) as? ItemEditorViewController else { return }
            itemEditorViewController.parentTask = self.selectedTask
            itemEditorViewController.selectedItem = selectedItem
            if let navController = self.itemsViewController?.navigationController as? BaseNavigationController {
                navController.pushViewController(itemEditorViewController, animated: true)
            }
        }
    }
    
}

extension SearchResultsViewController: UITableViewDataSource {
    
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
