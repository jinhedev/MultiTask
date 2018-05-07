//
//  Item.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import RealmSwift
import Amplitude

final class Item: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var is_completed: Bool = false
    @objc dynamic var created_at: NSDate = NSDate()
    @objc dynamic var updated_at: NSDate? = nil
    @objc dynamic var expired_at: NSDate? = nil
    @objc dynamic var delegate: String = ""
    let task = LinkingObjects(fromType: Task.self, property: "items")

    static func titlePredicate(by searchString: String) -> NSPredicate {
        let predicate = NSPredicate(format: "title contains[c] %@", searchString)
        return predicate
    }

    static func isCompletedPredicate(isCompleted: Bool) -> NSPredicate {
        let predicate = NSPredicate(format: "is_completed == %@", NSNumber(booleanLiteral: isCompleted))
        return predicate
    }

    /**c
     If task is already marked is_completed == true, this method will return false, so that the controller can toggle its completion state to pending if needed. If task is marked is_completed == false, this method will return true, so that the controller can toggle its completion state to completed if needed.
     */
    var shouldComplete: Bool {
        if self.is_completed == true {
            return false
        } else {
            return true
        }
    }
    
    func update(is_completed: Bool) {
        do {
            try defaultRealm.write {
                self.is_completed = is_completed
                self.updated_at = NSDate()
            }
        } catch let err {
            print(err.localizedDescription)
            Amplitude.instance().logEvent(LogEventType.realmError)
        }
    }
    
    var isValid: Bool {
        if id.isEmpty || title.isEmpty || title.count <= 3 || title.count > 512 {
            return false
        } else {
            return true
        }
    }
    
    static func all() -> Results<Item> {
        let results = defaultRealm.objects(Item.self)
        return results
    }
    
    static func findBy(title: String) -> Results<Item> {
        let titlePredicate = NSPredicate(format: "title  contains[c] %@", title)
        let results = defaultRealm.objects(Item.self).filter(titlePredicate)
        return results
    }
    
    func delete() {
        do {
            try defaultRealm.write {
                defaultRealm.delete(self)
            }
        } catch let err {
            print(err.localizedDescription)
            Amplitude.instance().logEvent(LogEventType.realmError)
        }
    }
    
    func save() {
        if self.isValid == true {
            do {
                try defaultRealm.write {
                    self.updated_at = NSDate()
                    defaultRealm.add(self, update: true)
                }
            } catch let err {
                Amplitude.instance().logEvent(LogEventType.realmError)
                print(err.localizedDescription)
            }
        } else {
            print("invalid format")
        }
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String) {
        self.init()
        self.id = UUID().uuidString
        self.title = title
        self.is_completed = false
        self.created_at = NSDate()
        self.updated_at = nil
        self.expired_at = nil
        self.delegate = ""
    }

}
