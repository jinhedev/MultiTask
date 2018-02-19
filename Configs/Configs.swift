//
//  Config.swift
//  MultiTask
//
//  Created by rightmeow on 1/24/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import Foundation

class Configs: NSObject {

    static let shared = Configs()

    // app_versions

    var displayName: String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
    }

    var releaseVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }

    var buildVersion: String {
        return Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
    }

    // document_path

    func documentDirectory() -> String {
        let path = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first?.path
        return path!
    }

    // bundle_id

    var bundleId: String {
        return Bundle.main.bundleIdentifier!
    }

    // device_token

    func hasDeviceToken() -> Bool {
        return UserDefaults.standard.bool(forKey: kDeviceToken)
    }
    
    func deviceToken() -> String {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "multitask_device_token", accessGroup: KeychainConfiguration.accessGroup)
            let pass = try passwordItem.readPassword()
            return pass
        } catch let err {
            fatalError("Error retrieving from keychain - \(err)")
        }
    }

    func saveDeviceToken(token: String) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "multitask_device_token", accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(token)
            UserDefaults.standard.set(true, forKey: kDeviceToken)
        } catch let err {
            fatalError("Error updating keychain - \(err)")
        }
    }

    // api_key

    func apiKey() -> String {
        return UserDefaults.standard.string(forKey: kApiKey)!
    }

    // onboarding

    func isOnboardingCompleted() -> Bool {
        let isOnboardingCompleted = UserDefaults.standard.bool(forKey: kOnboarding)
        return isOnboardingCompleted
    }

    func saveOnboarding(isCompleted: Bool) {
        UserDefaults.standard.set(isCompleted, forKey: kOnboarding)
    }

    // amplitude

    func amplitudeApiKey() -> String {
        let key = Bundle.main.object(forInfoDictionaryKey: "AMPLITUDE_API_KEY") as! String
        return key
    }

}
