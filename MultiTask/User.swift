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

    dynamic var id = ""
    dynamic var email = ""
    dynamic var session: Session?

    var sessions = List<Session>()

    override static func primaryKey() -> String? {
        return "id"
    }

}
