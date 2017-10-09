//
//  Setting.swift
//  MultiTask
//
//  Created by rightmeow on 9/13/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

/// AppSettings is a data class persisted locally to replace Swift's UserDefault.
final class AppSettings: Object {

    dynamic var settings_id: String = ""
    dynamic var isOnboardingCompleted: Bool = false
    dynamic var systemVersion: String = ""
    dynamic var created_at: NSDate = NSDate()
    dynamic var updated_at: NSDate = NSDate()

    var currentVersion: String {
        return UIDevice.current.systemVersion
    }

    override static func primaryKey() -> String? {
        return "settings_id"
    }

}
