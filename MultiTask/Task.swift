//
//  Task.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import Amplitude
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
    static let noEmptyItemsPredicate = NSPredicate(format: "items >= %@", 1)

    static func getTitlePredicate(value: String) -> NSPredicate {
        let predicate = NSPredicate(format: "title contains[c] %@", value)
        return predicate
    }

    func isValid() -> Bool {
        if id.isEmpty || title.isEmpty || title.count <= 3 || title.count > 128 {
            return false
        } else {
            return true
        }
    }

    static func all() -> Results<Task> {
        let results = defaultRealm.objects(Task.self).sorted(byKeyPath: "created_at", ascending: false)
        return results
    }
    
    static func pending() -> Results<Task> {
        let pendingPredicate = NSPredicate(format: "SUBQUERY(items, $item, $item.is_completed == false).@count > 0")
        let emptyItemsPredicate = NSPredicate(format: "items.@count == 0")
        let comppoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [pendingPredicate, emptyItemsPredicate])
        let results = Task.all().filter(comppoundPredicate)
        return results
    }
    
    static func completed() -> Results<Task> {
        // TODO: refactor the predicate to use a sub query
        let completedPredicate = NSPredicate(format: "SUBQUERY(items, $item, $item.is_completed == true).@count > 0")
        let nonEmptyItemsPredicate = NSPredicate(format: "items.@count > 0")
        let emptyPendingPredicate = NSPredicate(format: "SUBQUERY(items, $item, $item.is_completed == false).@count <= 0")
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [completedPredicate, nonEmptyItemsPredicate, emptyPendingPredicate])
        let results = Task.all().filter(compoundPredicate)
        return results
    }
    
    static func findBy(title: String) -> Results<Task> {
        let titlePredicate = NSPredicate(format: "title contains[c] %@", title)
        let results = defaultRealm.objects(Task.self).filter(titlePredicate)
        return results
    }

    func save() {
        if self.isValid() {
            do {
                try defaultRealm.write {
                    self.is_completed = self.shouldComplete() ? true : false
                    defaultRealm.add(self, update: true)
                }
            } catch let err {
                Amplitude.instance().logEvent(LogEventType.relamError)
                print(err.localizedDescription)
                fatalError(err.localizedDescription)
            }
        }
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

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String, items: List<Item>) {
        self.init()
        self.id = UUID().uuidString
        self.title = title
        self.items = items
        self.is_completed = false
        self.created_at = NSDate()
        self.updated_at = nil
        self.expired_at = nil
    }

}
