//
//  User.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import RealmSwift

final class User: Object {

    @objc dynamic var id = ""
    @objc dynamic var email = ""
    @objc dynamic var created_at: NSDate = NSDate()
    @objc dynamic var updated_at: NSDate? = nil

    var sessions = List<Session>()
    var tasks = List<Task>()

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(email: String) {
        self.init()
        self.id = String.random(length: 17)
        self.email = email
        self.created_at = NSDate()
    }

}
