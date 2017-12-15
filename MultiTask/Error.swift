//
//  Error.swift
//  MultiTask
//
//  Created by rightmeow on 12/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation

// MARK: - Error handler

func trace(file: String, function: String, line: Int) -> String {
    let trace = "\n" + "file: " + file + "\n" + "function: " + function + "\n" + "line: " + String(describing: line) + "\n"
    return trace
}
