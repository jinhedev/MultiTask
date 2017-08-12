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

    func completeTask(task: Task) {
        do {
            try realm.write {
                task.is_completed = true
                realm.add(task, update: true)
            }
            delegate?.didUpdateTasks()
        } catch let err {
            delegate?.realmErrorHandler(error: err)
        }
    }

    func updateTask(task: Task, with item: Item) {
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












