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

    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var is_completed: Bool = false
    @objc dynamic var created_at: NSDate = NSDate()
    @objc dynamic var updated_at: NSDate? = nil
    @objc dynamic var expired_at: NSDate? = nil

    var items = List<Item>()
    let user = LinkingObjects(fromType: User.self, property: "tasks")
    static let titleKeyPath = "title" // called in RealmManager for its updating 
    static let createdAtKeyPath = "created_at" // called in RealmManager for its sorting logic
    static let updatedAtKeyPath = "updated_at" // called in RealmManager for its updating logic
    static let isCompletedKeyPath = "is_completed" // called in RealmManager for its updating logic

    static let pendingPredicate = NSPredicate(format: "is_completed == %@", NSNumber(booleanLiteral: false))
    static let completedPredicate = NSPredicate(format: "is_completed == %@", NSNumber(booleanLiteral: true))
    static let noEmptyItemsPredicate = NSPredicate(format: "items >= %@", 1)

    static func getTitlePredicate(value: String) -> NSPredicate {
        let predicate = NSPredicate(format: "title contains[c] %@", value)
        return predicate
    }

    func shouldComplete() -> Bool {
        let itemsCount = self.items.count
        let completedItems = self.items.filter { $0.is_completed == true }
        let completedItemsCount = completedItems.count
        if completedItemsCount == itemsCount && itemsCount > 0 {
            return true
        } else {
            return false
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
    }

}
