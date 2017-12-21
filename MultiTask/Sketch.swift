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
    @objc dynamic var image: UIImage? = nil
    @objc dynamic var created_at: NSDate = NSDate()
    @objc dynamic var updated_at: NSDate? = nil

    // MARK: - Lifecycle

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String) {
        self.init()
        self.id = UUID().uuidString
        self.title = title
        self.image = nil
        self.created_at = NSDate()
        self.updated_at = nil
    }


}
