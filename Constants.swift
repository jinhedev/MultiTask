//
//  Constants.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation

struct Constants {

    static let remoteHost = "52.14.43.212"
    static let realmPath = "multitask"

    static let remoteServerURL = URL(string: "realm://\(remoteHost):9080/~/\(realmPath)")
    static let syncAuthURL = URL(string: "http://\(remoteHost): 9080")!

    static let appID = Bundle.main.bundleIdentifier!

}
