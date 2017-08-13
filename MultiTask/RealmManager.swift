//
//  RealmManager.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import RealmSwift

protocol PersistentContainerDelegate {
    func containerDidErr(error: Error)
    func containerDidLogin()
    func containerDidLogout()
    func containerDidFetchTasks()
    func containerDidCreateTasks()
    func containerDidUpdateTasks()
    func containerDidDeleteTasks()
}

extension PersistentContainerDelegate {
    func containerDidLogin() {}
    func containerDidLogout() {}
    func containerDidFetchTasks() {}
    func containerDidCreateTasks() {}
    func containerDidUpdateTasks() {}
    func containerDidDeleteTasks() {}
}

let realm = try! Realm()

class RealmManager: NSObject {

    var delegate: PersistentContainerDelegate?

    // MARK: - Authentication

    func login() {
        delegate?.containerDidLogin()
    }

    func logout() {
        deleteDatabase()
        delegate?.containerDidLogout()
    }

    // MARK: - Database wildcard methods

    func deleteDatabase() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch let err {
            delegate?.containerDidErr(error: err)
        }
    }

    // MARK: - Get

    func getOrderedTasks(predicate: NSPredicate) -> Results<Task>? {
        let tasks = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "created_at", ascending: false)
        delegate?.containerDidFetchTasks()
        return tasks
    }

    // MARK: - Delete

    func deleteObjects(objects: [Object]) {
        do {
            try realm.write {
                realm.delete(objects)
            }
            delegate?.containerDidDeleteTasks()
        } catch let err {
            delegate?.containerDidErr(error: err)
        }
    }

    // MARK: - Create

    func createObjects(objects: [Object]) {
        do {
            try realm.write {
                realm.add(objects, update: true)
            }
            delegate?.containerDidCreateTasks()
        } catch let err {
            delegate?.containerDidErr(error: err)
        }
    }

    // MARK: - Update

    func updateObject(object: Object, keyedValues: [String : Any]) {
        do {
            try realm.write {
                object.setValuesForKeys(keyedValues)
                realm.add(object)
            }
            delegate?.containerDidUpdateTasks()
        } catch let err {
            delegate?.containerDidErr(error: err)
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
                    playAlertSound(type: AlertSoundType.success)
                } else {
                    task.is_completed = false
                    realm.add(task)
                }
            }
            delegate?.containerDidUpdateTasks()
        } catch let err {
            delegate?.containerDidErr(error: err)
        }
    }

    func appendItem(to task: Task, with item: Item) {
        do {
            try realm.write {
                task.items.append(item)
                realm.add(task)
            }
            delegate?.containerDidUpdateTasks()
        } catch let err {
            delegate?.containerDidErr(error: err)
        }
    }

}

class UserDefaultsManager: NSObject {

    var delegate: PersistentContainerDelegate?

    // MARK: - Create

    func createObject() {

    }

}










