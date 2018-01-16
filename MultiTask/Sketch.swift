//
//  Sketch.swift
//  MultiTask
//
//  Created by rightmeow on 12/20/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class Sketch: Object {

    // MARK: - API

    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var imageData: NSData? = nil
    @objc dynamic var created_at: NSDate = NSDate()
    @objc dynamic var updated_at: NSDate? = nil

    static let createdAtKeyPath = "created_at" // called in RealmManager for its sorting logic

    static let allPredicate = NSPredicate(format: "id != %@", "")

    // MARK: - Lifecycle

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String) {
        self.init()
        self.id = UUID().uuidString
        self.title = title
        self.imageData = nil
        self.created_at = NSDate()
        self.updated_at = nil
    }


}
