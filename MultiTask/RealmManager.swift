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
    func container(_ manager: RealmManager, didErr error: Error)
    func containerDidLogin()
    func containerDidLogout()
    func containerDidFetch(_ manager: RealmManager, tasks: Results<Task>)
    func containerDidCreateTasks(_ manager: RealmManager)
    func containerDidUpdateTasks(_ manager: RealmManager)
    func containerDidDeleteTasks(_ manager: RealmManager)
}

extension PersistentContainerDelegate {
    func containerDidLogin() {}
    func containerDidLogout() {}
    func containerDidFetch(_ manager: RealmManager, tasks: Results<Task>) {}
    func containerDidCreateTasks(_ manager: RealmManager) {}
    func containerDidUpdateTasks(_ manager: RealmManager) {}
    func containerDidDeleteTasks(_ manager: RealmManager) {}
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
            delegate?.container(self, didErr: err)
        }
    }

    // MARK: - App Settings

    var isOnboardingCompleted: Bool {
        let settings = realm.objects(AppSettings.self).sorted(byKeyPath: "created_at", ascending: false)
        if settings.isEmpty || settings.first?.isOnboardingCompleted == false {
            return false
        } else {
            return true
        }
    }

    // MARK: - Authentication

    func login(user: String, pass: String) {
        let credentials = SyncCredentials.usernamePassword(username: user, password: pass, register: false)
        SyncUser.logIn(with: credentials, server: WebServiceConfigurations.syncAuthURL) { user, error in
            if let err = error {
                self.delegate?.container(self, didErr: err)
            } else {
                // remote login to realm object server
                guard let user = user else {
                    print(trace(file: #file, function: #function, line: #line))
                    return
                }
                var configuration = Realm.Configuration.defaultConfiguration
                configuration.syncConfiguration = SyncConfiguration(user: user, realmURL: WebServiceConfigurations.remoteServerURL)
                Realm.Configuration.defaultConfiguration = configuration

                let remoteRealm = try! Realm() // A realm instance for remote realm object server
                self.delegate?.containerDidLogin()
            }
        }
    }

    func logout() {
        purgeDatabase()
        delegate?.containerDidLogout()
    }

    // MARK: - Get

    func fetchTasks(predicate: NSPredicate) {
        let tasks = realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "created_at", ascending: false)
        delegate?.containerDidFetch(self, tasks: tasks)
    }

    // MARK: - Delete

    func deleteObjects(objects: [Object]) {
        do {
            try realm.write {
                realm.delete(objects)
            }
            delegate?.containerDidDeleteTasks(self)
        } catch let err {
            delegate?.container(self, didErr: err)
        }
    }

    // MARK: - Create

    func createObjects(objects: [Object]) {
        do {
            try realm.write {
                realm.add(objects, update: true)
            }
            delegate?.containerDidCreateTasks(self)
        } catch let err {
            delegate?.container(self, didErr: err)
        }
    }

    // MARK: - Update

    func updateObject(object: Object, keyedValues: [String : Any]) {
        do {
            try realm.write {
                object.setValuesForKeys(keyedValues)
                realm.add(object)
            }
            delegate?.containerDidUpdateTasks(self)
        } catch let err {
            delegate?.container(self, didErr: err)
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
            delegate?.containerDidUpdateTasks(self)
        } catch let err {
            delegate?.container(self, didErr: err)
        }
    }

    func appendItem(to task: Task, with item: Item) {
        do {
            try realm.write {
                task.items.append(item)
                realm.add(task)
            }
            delegate?.containerDidUpdateTasks(self)
        } catch let err {
            delegate?.container(self, didErr: err)
        }
    }

}










