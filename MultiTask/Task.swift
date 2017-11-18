//
//  Task.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import RealmSwift

final class Task: Object {

    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var is_completed: Bool = false
    dynamic var created_at: NSDate = NSDate()
    dynamic var updated_at: NSDate? = nil
    dynamic var expired_at: NSDate? = nil
    dynamic var completed_at: NSDate? = nil

    var items = List<Item>()
    static let titleKeyPath = "title" // called in RealmManager for its updating 
    static let createdAtKeyPath = "created_at" // called in RealmManager for its sorting logic
    static let updatedAtKeyPath = "updated_at" // called in RealmManager for its updating logic
    static let completedAtKeyPath = "completed_at" // called in RealmManager for its updating logic
    static let isCompletedKeyPath = "is_completed" // called in RealmManager for its updating logic

    static let pendingPredicate = NSPredicate(format: "is_completed == %@", NSNumber(booleanLiteral: false))
    static let completedPredicate = NSPredicate(format: "is_completed == %@", NSNumber(booleanLiteral: true))

    static func getTitlePredicate(value: String) -> NSPredicate {
        let predicate = NSPredicate(format: "title contains[c] %@", value)
        return predicate
    }

    /**
     If all items in this task are marked completed, but this task itself is not marked completed, then it will return true; if only some items in this task are marked completed, but the task itself is marked completed, then it will return false. Nil will be return when task is already in sync when the current state of all of its items.
     */
    func shouldComplete() -> Bool? {
        let itemsCount = self.items.count
        let completedItems = self.items.filter { $0.is_completed == true }
        let completedItemsCount = completedItems.count
        if self.is_completed == true {
            if completedItemsCount != itemsCount {
                return false
            } else {
                // task itself is marked completed and all its embeded items are marked completed. All is good. Ignore.
                return nil
            }
        } else {
            if completedItemsCount == itemsCount {
                return true
            } else {
                // task itself is marked not completed and only some of its embeded items are marked completed. All is good. Ignore.
                return nil
            }
        }
    }

    // MARK: - Lifecycle

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String, items: List<Item>, is_completed: Bool) {
        self.init()
        self.id = UUID().uuidString
        self.title = title
        self.items = items
        self.is_completed = is_completed
        self.created_at = NSDate()
        self.updated_at = nil
        self.expired_at = nil
        self.completed_at = nil
    }

}
