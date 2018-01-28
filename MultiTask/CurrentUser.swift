//
//  CurrentUser.swift
//  MultiTask
//
//  Created by rightmeow on 1/27/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import Foundation

class CurrentUser: NSObject {

    static let shared = CurrentUser()

    var id: String?
    var name: String?
    var email: String?
    var avatar: String?
    var created_at: NSDate?
    var updated_at: NSDate?

    func isValid() -> Bool {
        true false
    }

    func isAuthenticated() -> Bool {
        if hasSessionToken() && !isSessionTokenExpired() {
            return true
        } else {
            return false
        }
    }

    /// - warning: if the server side expires a token manually, I will also need to handle the same error anyway.
    func isSessionTokenExpired() -> Bool {
        // TODO: implement this
        return false
    }

    func sessionToken() -> String {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
            let pass = try passwordItem.readPassword()
            return pass
        } catch let err {
            fatalError("Error getting keychain - \(err)")
        }
    }

    func hasSessionToken() -> Bool {
        return UserDefaults.standard.bool(forKey: kSessionToken)
    }

    func updateSessionToken(token: String) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(token)
            UserDefaults.standard.set(true, forKey: kSessionToken)
        } catch let err {
            fatalError("Error updating keychain - \(err)")
        }
    }

    func forgetSessionToken() {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.account, accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.deleteItem()
            UserDefaults.standard.set(false, forKey: kSessionToken)
        } catch let err {
            fatalError("Error forgeting keychain - \(err)")
        }
    }

}
