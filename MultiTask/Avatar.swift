//
//  Avatar.swift
//  MultiTask
//
//  Created by rightmeow on 12/19/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation

final class Avatar {

    var name: String

    init(nameDictionary: Dictionary<String, String>) {
        self.name = nameDictionary["Avatar"]!
    }

}
