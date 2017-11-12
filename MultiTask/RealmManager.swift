//
//  RealmManager.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import RealmSwift

protocol PersistentContainerDelegate: NSObjectProtocol {
    // error
    func persistentContainer(_ manager: RealmManager, didErr error: Error)
    // auth
    func persistentContainer(_ manager: RealmManager, didLogin: Bool)
    func persistentContainer(_ manager: RealmManager, didLogout: Bool)
    // fetch
    func persistentContainer(_ manager: RealmManager, didFetch tasks: Results<Task>)
    // create
    func persistentContainer(_ manager: RealmManager, didAdd objects: [Object])
    // update
    func persistentContainer(_ manager: RealmManager, didUpdate object: Object)
    // delete
    func persistentContainer(_ manager: RealmManager, didDelete objects: [Object])
}

extension PersistentContainerDelegate {
    // auth
    func persistentContainer(_ manager: RealmManager, didLogin: Bool) {}
    func persistentContainer(_ manager: RealmManager, didLogout: Bool) {}
    // fetch
    func persistentContainer(_ manager: RealmManager, didFetch tasks: Results<Task>) {}
    // create
    func persistentContainer(_ manager: RealmManager, didAdd objects: [Object]) {}
    // update
    func persistentContainer(_ manager: RealmManager, didUpdate object: Object) {}
    // delete
    func persistentContainer(_ manager: RealmManager, didDelete objects: [Object]) {}
}

var realm = try! Realm() // A realm instance for local persistent container

class RealmManager: NSObject {

    weak var delegate: PersistentContainerDelegate?
    var pathForContainer: URL? { return Realm.Configuration.defaultConfiguration.fileURL }

    // MARK: - Database

    func migrateDatabase() {
        // TODO: implement this
    }

    func purgeDatabase() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    // MARK: - App Settings

    var isOnboardingCompleted: Bool {
        let settings = realm.objects(AppSetting.self).sorted(byKeyPath: "created_at", ascending: false)
        if settings.isEmpty || settings.first?.isOnboardingCompleted == false {
            return false
        } else {
            return true
        }
    }

    // MARK: - Authentication

    func login(user: String, pass: String) {
        delegate?.persistentContainer(self, didLogin: true)
    }

    func logout() {
        purgeDatabase()
        delegate?.persistentContainer(self, didLogout: true)
    }

    // MARK: - Fetch

    func fetchTasks(predicate: NSPredicate) {
        let tasks = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "created_at", ascending: false)
        delegate?.persistentContainer(self, didFetch: tasks)
    }

    // MARK: - Delete

    func deleteObjects(objects: [Object]) {
        do {
            try realm.write {
                realm.delete(objects)
            }
            delegate?.persistentContainer(self, didDelete: objects)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    // MARK: - Create

    func addObjects(objects: [Object]) {
        do {
            try realm.write {
                realm.add(objects, update: true)
            }
            delegate?.persistentContainer(self, didAdd: objects)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    // MARK: - Update

    func updateObject(object: Object, keyedValues: [String : Any]) {
        do {
            try realm.write {
                object.setValuesForKeys(keyedValues)
                realm.add(object)
            }
            delegate?.persistentContainer(self, didUpdate: object)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    func checkOrUpdateItemsForCompletion(in task: Task) {
        let items = task.items
        do {
            try realm.write {
                var n: Int = 0
                for item in items {
                    if item.is_completed == true {
                        n += 1
                    }
                }
                if items.count > 0 && n == items.count {
                    task.is_completed = true
                    realm.add(task)
                } else {
                    task.is_completed = false
                    realm.add(task)
                }
            }
            delegate?.persistentContainer(self, didUpdate: task)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    func appendItem(to task: Task, with item: Item) {
        do {
            try realm.write {
                task.items.append(item)
                realm.add(task)
            }
            delegate?.persistentContainer(self, didUpdate: task)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

}










