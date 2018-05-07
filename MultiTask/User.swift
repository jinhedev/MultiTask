//
//  User.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import Amplitude
import RealmSwift

class User: Object {

    @objc dynamic var id = ""
    @objc dynamic var email = ""
    @objc dynamic var displayName = ""
    @objc dynamic var avatar = ""
    @objc dynamic var created_at: NSDate = NSDate()
    @objc dynamic var updated_at: NSDate? = nil
    var tasks = List<Task>()
    
    private var isValid: Bool {
        if !id.isEmpty || !email.isEmpty || !displayName.isEmpty || !avatar.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func all() -> Results<User> {
        let results = defaultRealm.objects(User.self)
        return results
    }
    
    func mostUpdated() -> Results<User> {
        let results = self.all().sorted(byKeyPath: "created_at", ascending: false)
        return results
    }
    
    func delete() {
        do {
            try defaultRealm.write {
                for task in self.tasks {
                    for item in task.items {
                        defaultRealm.delete(item)
                    }
                    defaultRealm.delete(task)
                }
                defaultRealm.delete(self)
            }
        } catch let err {
            print(err.localizedDescription)
            Amplitude.instance().logEvent(LogEventType.realmError)
        }
    }
    
    func findBy(displayName: String) -> Results<User> {
        let displayNamePredicate = NSPredicate(format: "displayName contains[c] %@", displayName)
        let results = defaultRealm.objects(User.self).filter(displayNamePredicate)
        return results
    }
    
    func save() {
        if self.isValid {
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

    convenience init(email: String, displayName: String, avatar: String) {
        self.init()
        self.id = String.random(length: 17)
        self.email = email
        self.avatar = avatar
        self.displayName = displayName
        self.created_at = NSDate()
    }

}
