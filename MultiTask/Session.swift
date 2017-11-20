//
//  Session.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import RealmSwift

final class Session: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var access_token: String = ""
    @objc dynamic var created_at: NSDate = NSDate()
    @objc dynamic var updated_at: NSDate = NSDate()
    @objc dynamic var expire_at: NSDate = NSDate()

    let user = LinkingObjects(fromType: User.self, property: "sessions")

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id: String, access_token: String, created_at: NSDate, updated_at: NSDate, expire_at: NSDate) {
        self.init()
        self.id = id
        self.access_token = access_token
        self.created_at = created_at
        self.updated_at = updated_at
        self.expire_at = expire_at
    }

}
