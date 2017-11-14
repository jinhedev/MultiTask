//
//  Item.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import RealmSwift

final class Item: Object {

    dynamic var id = ""
    dynamic var title = ""
    dynamic var is_completed = false
    dynamic var created_at = NSDate()
    dynamic var updated_at: NSDate? = nil
    dynamic var expired_at: NSDate? = nil
    dynamic var completed_at: NSDate? = nil
    dynamic var delegate: String = ""
    
    let task = LinkingObjects(fromType: Task.self, property: "items")
    static let createdAtKeyPath = "created_at" // called in RealmManager for its sorting logic
    static let updatedAtKeyPath = "updated_at" // called in RealmManager for its updating logic
    static let completedAtKeyPath = "completed_at" // called in RealmManager for its updating logic
    static let isCompletedKeyPath = "is_completed" // called in RealmManager for its updating logic

    static func getTitlePredicate(value: String) -> NSPredicate {
        let predicate = NSPredicate(format: "title contains[c] %@", value)
        return predicate
    }

    static func getDescendingDateSortDescriptor() -> NSSortDescriptor {
        let descriptor = NSSortDescriptor(key: "created_at", ascending: false)
        return descriptor
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String, is_completed: Bool) {
        self.init()
        self.id = UUID().uuidString
        self.title = title
        self.is_completed = is_completed
        self.created_at = NSDate()
        self.updated_at = nil
        self.expired_at = nil
        self.completed_at = nil
        self.delegate = ""
    }

}






























