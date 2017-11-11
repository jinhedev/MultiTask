//
//  KeychainManager.swift
//  MultiTask
//
//  Created by rightmeow on 8/24/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import Locksmith

protocol KeychainDelegate {
    func keychainDidErr(error: Error)
    func keychainDidFetch(value: String)
    func keychainDidUpdate(isSuccess: Bool)
    func keychainDidDelete(isSuccess: Bool)
}

extension KeychainDelegate {
    func keychainDidFetch(value: String) {}
    func keychainDidUpdate(isSuccess: Bool) {}
    func keychainDidDelete(isSuccess: Bool){}
}

class KeychainManager: NSObject {

    var delegate: KeychainDelegate?

    // MARK: - Fetch

    func fetch(forType: KeychainType) -> String? {
        if let dictionary = Locksmith.loadDataForUserAccount(userAccount: KeychainSettings.keychainAccount,
                                                             inService: KeychainSettings.keychainService) as? [String : String] {
            let token = dictionary[forType.rawValue]!
            return token
        } else {
            return nil
        }
    }

    // MARK: - Update & Create

    func update(forType: KeychainType, value: String) {
        do {
            try Locksmith.updateData(data: [forType.rawValue : value],
                                     forUserAccount: KeychainSettings.keychainAccount,
                                     inService: KeychainSettings.keychainService)
            delegate?.keychainDidUpdate(isSuccess: true)
        } catch let err {
            delegate?.keychainDidErr(error: err)
        }
    }

    // MARK: - Delete

    func deleteAccount() {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: KeychainSettings.keychainAccount,
                                                   inService: KeychainSettings.keychainService)
            delegate?.keychainDidDelete(isSuccess: true)
        } catch let err {
            delegate?.keychainDidErr(error: err)
        }
    }

}

struct KeychainSettings {
    static let keychainAccount: String = "com.rightmeow.multitask.keychainAccount"
    static let keychainService: String = "com.rightmeow.multitask.keychainService"
    static let keychainGroup: String = "com.rightmeow.multitask.keychainGroup"
}

enum KeychainType: String {
    case accessToken = "access_token"
    case email = "email"
}
