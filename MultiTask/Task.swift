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
    dynamic var title = ""
    dynamic var is_completed = false
    dynamic var created_at = NSDate()
    dynamic var updated_at: NSDate? = nil
    dynamic var expired_at: NSDate? = nil
    dynamic var completed_at: NSDate? = nil

    var items = List<Item>()
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

    static func getDescendingDateSortDescriptor() -> NSSortDescriptor {
        let descriptor = NSSortDescriptor(key: "created_at", ascending: false)
        return descriptor
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
