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
    func didRegister(_ manager: RealmManager, user: User)
    // fetch
    func persistentContainer(_ manager: RealmManager, didFetch objects: Results<Object>?)
    func persistentContainer(_ manager: RealmManager, didFetchUsers users: Results<User>?)
    // create
    func persistentContainer(_ manager: RealmManager, didAddObjects objects: [Object])
    // update
    func persistentContainer(_ manager: RealmManager, didUpdateObject object: Object)
    // delete
    func didPurgeDatabase(_ manager: RealmManager)
}

extension PersistentContainerDelegate {
    // auth
    func didRegister(_ manager: RealmManager, user: User) {}
    // fetch
    func persistentContainer(_ manager: RealmManager, didFetch objects: Results<Object>?) {}
    func persistentContainer(_ manager: RealmManager, didFetchUsers users: Results<User>?) {}
    // create
    func persistentContainer(_ manager: RealmManager, didAddObjects objects: [Object]) {}
    // update
    func persistentContainer(_ manager: RealmManager, didUpdateObject object: Object) {}
    // delete
    func didPurgeDatabase(_ manager: RealmManager) {}
}

var defaultRealm: Realm!

func setupRealm() {
    let config = Realm.Configuration(fileURL: URL.inDocumentDirectory(fileName: "default.realm"), schemaVersion: 0, migrationBlock: nil, objectTypes: [Task.self, Item.self, User.self, Sketch.self])
    defaultRealm = try! Realm(configuration: config)
}

class RealmManager: NSObject {

    weak var delegate: PersistentContainerDelegate?
    static var pathForDefaultContainer: URL? { return Realm.Configuration.defaultConfiguration.fileURL }
    static var pathForStaticContainer: URL? { return URL.inDocumentDirectory(fileName: "static.realm") }
    static var pathForTestContainer: URL? { return URL.inDocumentDirectory(fileName: "test.realm") }
    static var pathForSafeContainer: URL? { return URL.inDocumentDirectory(fileName: "safe.realm") }

    // MARK: - Database

    func purgeDatabase() {
        do {
            try defaultRealm.write {
                defaultRealm.deleteAll()
            }
            delegate?.didPurgeDatabase(self)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    // MARK: - Authentication

    func register(newUser: User) {
        do {
            try defaultRealm.write {
                defaultRealm.add(newUser, update: true)
            }
            delegate?.didRegister(self, user: newUser)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    // MARK: - Fetch

    func fetchExistingUsers() {
        let users = defaultRealm.objects(User.self)
        delegate?.persistentContainer(self, didFetchUsers: users)
    }

    func fetch(ofType: Object.Type, predicate: NSPredicate, sortedBy keyPath: String, ascending: Bool) {
        let objects = defaultRealm.objects(ofType).filter(predicate).sorted(byKeyPath: keyPath, ascending: ascending)
        delegate?.persistentContainer(self, didFetch: objects)
    }

    // MARK: - Create

    func addObjects(objects: [Object]) {
        do {
            try defaultRealm.write {
                defaultRealm.add(objects, update: true)
            }
            delegate?.persistentContainer(self, didAddObjects: objects)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    // MARK: - Update

    func updateObject(object: Object, keyedValues: [String : Any]) {
        do {
            try defaultRealm.write {
                object.setValuesForKeys(keyedValues)
                defaultRealm.add(object, update: true)
            }
            delegate?.persistentContainer(self, didUpdateObject: object)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

}
