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
    func persistentContainer(_ manager: RealmManager, didFetchTasks tasks: Results<Task>?)
    func persistentContainer(_ manager: RealmManager, didFetchItems items: Results<Item>?)
    // create
    func persistentContainer(_ manager: RealmManager, didAdd objects: [Object])
    // update
    func persistentContainer(_ manager: RealmManager, didUpdate object: Object)
    // delete
    func persistentContainer(_ manager: RealmManager, didDeleteTasks tasks: [Task]?)
    func persistentContainer(_ manager: RealmManager, didDeleteItems items: [Item]?)
}

extension PersistentContainerDelegate {
    // auth
    func persistentContainer(_ manager: RealmManager, didLogin: Bool) {}
    func persistentContainer(_ manager: RealmManager, didLogout: Bool) {}
    // fetch
    func persistentContainer(_ manager: RealmManager, didFetchTasks tasks: Results<Task>?) {}
    func persistentContainer(_ manager: RealmManager, didFetchItems items: Results<Item>?) {}
    // create
    func persistentContainer(_ manager: RealmManager, didAdd objects: [Object]) {}
    // update
    func persistentContainer(_ manager: RealmManager, didUpdate object: Object) {}
    // delete
    func persistentContainer(_ manager: RealmManager, didDeleteTasks tasks: [Task]?) {}
    func persistentContainer(_ manager: RealmManager, didDeleteItems items: [Item]?) {}
}

var realm: Realm!

func setupRealm() {
    let config = Realm.Configuration(fileURL: URL.inDocumentDirectory(fileName: "default.realm"), schemaVersion: 0, migrationBlock: nil, objectTypes: [Task.self, Item.self, AppSetting.self, Session.self, User.self])
    realm = try! Realm(configuration: config)
}

class RealmManager: NSObject {

    weak var delegate: PersistentContainerDelegate?
    static var pathForDefaultContainer: URL? { return Realm.Configuration.defaultConfiguration.fileURL }
    static var pathForStaticContainer: URL? { return URL.inDocumentDirectory(fileName: "static.realm") }
    static var pathForSafeContainer: URL? { return URL.inDocumentDirectory(fileName: "safe.realm") }

    // MARK: - Database

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
        let settings = realm.objects(AppSetting.self).sorted(byKeyPath: AppSetting.dateKeyPath, ascending: false)
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

    func fetchTasks(predicate: NSPredicate, sortedBy keyPath: String, ascending: Bool) {
        let tasks = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: keyPath, ascending: ascending)
        if !tasks.isEmpty {
            delegate?.persistentContainer(self, didFetchTasks: tasks)
        }
    }

    func fetchItems(parentTaskId: String, sortedBy keyPath: String, ascending: Bool) {
        let items = realm.object(ofType: Task.self, forPrimaryKey: parentTaskId)?.items.sorted(byKeyPath: keyPath, ascending: ascending)
        delegate?.persistentContainer(self, didFetchItems: items)
    }

    func fetchItems(parentTaskId: String, predicate: NSPredicate) {
        let items = realm.object(ofType: Task.self, forPrimaryKey: parentTaskId)?.items.filter(predicate).sorted(byKeyPath: Item.createdAtKeyPath, ascending: false)
        delegate?.persistentContainer(self, didFetchItems: items)
    }

    // MARK: - Delete

    func deleteTasks(tasks: [Task]) {
        do {
            try realm.write {
                realm.delete(tasks)
            }
            delegate?.persistentContainer(self, didDeleteTasks: tasks)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    func deleteItems(items: [Item]) {
        do {
            try realm.write {
                realm.delete(items)
            }
            delegate?.persistentContainer(self, didDeleteItems: items)
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

    /**
     Append an item object to the item array of its belonging task.
     - remark: Calling this delegate method will trigger the didAdd protocol.
     */
    func appendItem(_ item: Item, into parentTask: Task) {
        do {
            try realm.write {
                parentTask.items.append(item)
                realm.add(parentTask)
            }
            delegate?.persistentContainer(self, didAdd: [item])
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

}
