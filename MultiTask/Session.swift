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

    dynamic var access_token: String = ""
    dynamic var created_at: NSDate = NSDate()
    dynamic var updated_at: NSDate = NSDate()

    let user = LinkingObjects(fromType: User.self, property: "sessions")

}
