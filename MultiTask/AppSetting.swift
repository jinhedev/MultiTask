//
//  Setting.swift
//  MultiTask
//
//  Created by rightmeow on 9/13/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import RealmSwift

/// AppSettings is a data class persisted locally to replace Swift's UserDefault.
final class AppSetting: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var isOnboardingCompleted: Bool = false
    @objc dynamic var systemVersion: String = ""
    @objc dynamic var theme: String = ""
    @objc dynamic var created_at: NSDate = NSDate()
    @objc dynamic var updated_at: NSDate = NSDate()

    static var dateKeyPath = "created_at" // called in RealmManager for its sorting logic

    // MARK: - Lifecycle

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id: String, isOnboardingCompleted: Bool, systemVersion: String, theme: String, created_at: NSDate, updated_at: NSDate) {
        self.init()
        self.id = id
        self.isOnboardingCompleted = isOnboardingCompleted
        self.systemVersion = systemVersion
        self.theme = theme
        self.created_at = created_at
        self.updated_at = updated_at
    }

}
