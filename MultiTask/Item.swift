//
//  Item.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import RealmSwift

final class Item: Object {

    dynamic var id = ""
    dynamic var title = ""
    dynamic var is_completed = false
    dynamic var created_at = NSDate()
    dynamic var updated_at = NSDate()
    
    let task = LinkingObjects(fromType: Task.self, property: "items")

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id: String, title: String, is_completed: Bool, created_at: NSDate, updated_at: NSDate) {
        self.init()
        self.id = id
        self.title = title
        self.is_completed = is_completed
        self.created_at = created_at
        self.updated_at = updated_at
    }

}






























