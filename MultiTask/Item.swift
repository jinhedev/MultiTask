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

    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var is_completed: Bool = false
    @objc dynamic var created_at: NSDate = NSDate()
    @objc dynamic var updated_at: NSDate? = nil
    @objc dynamic var expired_at: NSDate? = nil
    @objc dynamic var completed_at: NSDate? = nil
    @objc dynamic var delegate: String = ""
    
    let task = LinkingObjects(fromType: Task.self, property: "items")
    static let titleKeyPath = "title" // called in RealmManager for updating
    static let createdAtKeyPath = "created_at" // called in RealmManager for its sorting logic
    static let updatedAtKeyPath = "updated_at" // called in RealmManager for its updating logic
    static let completedAtKeyPath = "completed_at" // called in RealmManager for its updating logic
    static let isCompletedKeyPath = "is_completed" // called in RealmManager for its updating logic

    static func getTitlePredicate(value: String) -> NSPredicate {
        let predicate = NSPredicate(format: "title contains[c] %@", value)
        return predicate
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






























