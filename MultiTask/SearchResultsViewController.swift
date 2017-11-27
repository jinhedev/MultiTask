//
//  SearchResultsViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/20/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    // MARK: - API

    var items: [Item]?
    static let storyboard_id = String(describing: SearchResultsViewController.self)

    @IBOutlet weak var tableView: UITableView!

    // MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text {
            if !searchString.isEmpty {
                print(searchString)
            } else {
                // search string is empty now
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
    }

    // MARK: - UITableView

    private func setupTableView() {
        self.view.backgroundColor = Color.clear
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = Color.transparentBlack
        self.tableView.register(UINib(nibName: SearchResultCell.nibName, bundle: nil), forCellReuseIdentifier: SearchResultCell.cell_id)
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: SearchResultCell.cell_id, for: indexPath) as? SearchResultCell {
            return cell
        } else {
            return BaseTableViewCell()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

}

















