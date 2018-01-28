//
//  Constant.swift
//  MultiTask
//
//  Created by rightmeow on 1/24/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import Foundation

let kOnboardingCompletion = "kOnboardingCompletion"
let kSessionToken = "kSessionToken"
let kDeviceToken = "kDeviceToken"
let kApiKey = "kApiKey"
let kUserAuthentication = "kUserAuthentication"

struct KeychainConfiguration {
    static let serviceName = "multitask"
    static let accessGroup: String? = Bundle.main.bundleIdentifier!
    static let account = "multitask_session_token
}
