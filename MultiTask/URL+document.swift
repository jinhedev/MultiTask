//
//  URL+document.swift
//  MultiTask
//
//  Created by rightmeow on 12/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation

// MARK: - URL + Document

extension URL {

    static func inDocumentDirectory(fileName: String) -> URL {
        let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return URL(fileURLWithPath: dir, isDirectory: true).appendingPathComponent(fileName)
    }

}
