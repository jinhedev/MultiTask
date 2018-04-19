//
//  Sketch.swift
//  MultiTask
//
//  Created by rightmeow on 12/20/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import Amplitude
import RealmSwift

class Sketch: Object {

    // MARK: - API

    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var imageData: NSData? = nil
    @objc dynamic var created_at: NSDate = NSDate()
    @objc dynamic var updated_at: NSDate? = nil
    static let createdAtKeyPath = "created_at" // called in RealmManager for its sorting logic

    var isValid: Bool {
        if id.isEmpty || title.isEmpty || title.count <= 3 || title.count > 128 {
            return false
        } else {
            return true
        }
    }
    
    static func all() -> Results<Sketch> {
        let results = defaultRealm.objects(Sketch.self)
        return results
    }
    
    static func mostUpdated() -> Results<Sketch> {
        let results = Sketch.all().sorted(byKeyPath: "created_at", ascending: false)
        return results
    }
    
    func findBy(title: String) -> Results<Sketch> {
        let titlePredicate = NSPredicate(format: "title contains[c] %@", title)
        let results = defaultRealm.objects(Sketch.self).filter(titlePredicate)
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
    
    // MARK: - Lifecycle

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String, imageData: NSData) {
        self.init()
        self.id = UUID().uuidString
        self.title = title
        self.imageData = imageData
        self.created_at = NSDate()
    }


}
