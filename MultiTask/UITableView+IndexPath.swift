//
//  UITableView+IndexPath.swift
//  MultiTask
//
//  Created by rightmeow on 12/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

extension IndexPath {

    static func fromRow(_ row: Int) -> IndexPath {
        return IndexPath(row: row, section: 0)
    }

}

// MARK: - UITableView

extension UITableView {

    func applyChanges(section: Int = 0, deletions: [Int], insertions: [Int], updates: [Int]) {
        performBatchUpdates({
            deleteRows(at: deletions.map(IndexPath.fromRow), with: UITableViewRowAnimation.automatic)
            insertRows(at: insertions.map(IndexPath.fromRow), with: UITableViewRowAnimation.automatic)
            reloadRows(at: updates.map(IndexPath.fromRow), with: UITableViewRowAnimation.automatic)
        }, completion: nil)
    }

}
