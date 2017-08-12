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
    func realmErrorHandler(error: Error)
    func didLogin()
    func didLogout()
    func didFetchTasks()
    func didCreateTasks()
    func didUpdateTasks()
    func didDeleteTasks()
}

extension PersistentContainerDelegate {
    func didLogin() {}
    func didLogout() {}
    func didFetchTasks() {}
    func didCreateTasks() {}
    func didUpdateTasks() {}
    func didDeleteTasks() {}
}

let realm = try! Realm()

class RealmManager: NSObject {

    var delegate: PersistentContainerDelegate?

    // MARK: - Authentication

    func login() {
        delegate?.didLogin()
    }

    func logout() {
        deleteDatabase()
        delegate?.didLogout()
    }

    // MARK: - Database wildcard methods

    func deleteDatabase() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch let err {
            delegate?.realmErrorHandler(error: err)
        }
    }

    // MARK: - Get

    func getOrderedTasks(predicate: NSPredicate) -> Results<Task>? {
        let tasks = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "created_at", ascending: false)
        delegate?.didFetchTasks()
        return tasks
    }

    // MARK: - Delete

    func deleteObjects(objects: [Object]) {
        do {
            try realm.write {
                realm.delete(objects)
            }
            delegate?.didDeleteTasks()
        } catch let err {
            delegate?.realmErrorHandler(error: err)
        }
    }

    // MARK: - Create

    func createObjects(objects: [Object]) {
        do {
            try realm.write {
                realm.add(objects, update: true)
            }
            delegate?.didCreateTasks()
        } catch let err {
            delegate?.realmErrorHandler(error: err)
        }
    }

    // MARK: - Update

    func updateObject(object: Object, keyedValues: [String : Any]) {
        do {
            try realm.write {
                object.setValuesForKeys(keyedValues)
                realm.add(object)
            }
            delegate?.didUpdateTasks()
        } catch let err {
            delegate?.realmErrorHandler(error: err)
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
                }
            }
            delegate?.didUpdateTasks()
        } catch let err {
            delegate?.realmErrorHandler(error: err)
        }
    }

    func appendItem(to task: Task, with item: Item) {
        do {
            try realm.write {
                task.items.append(item)
                realm.add(task)
            }
            delegate?.didUpdateTasks()
        } catch let err {
            delegate?.realmErrorHandler(error: err)
        }
    }

}












