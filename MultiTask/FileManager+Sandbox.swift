//
//  FileManager+Sandbox.swift
//  MultiTask
//
//  Created by rightmeow on 12/20/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation

// MARK: - App Sandbox

extension FileManager {

    func pathToSandbox() -> String {
        if let path = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first?.path {
            return path
        } else {
            let message = "application sandbox has not been setup yet"
            return message
        }
    }

}
