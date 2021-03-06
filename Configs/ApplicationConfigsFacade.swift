//
//  ApplicationConfigsFacade.swift
//  MultiTask
//
//  Created by rightmeow on 1/24/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import Foundation

class ApplicationConfigsFacade: NSObject {

    static let shared = ApplicationConfigsFacade()

    // bundle
    
    var pathForInfoPList: String {
        return Bundle.main.path(forResource: "Info", ofType: "plist")!
    }
    
    var displayName: String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    }

    var bundleName: String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
    }

    var releaseVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }

    var buildVersion: String {
        return Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
    }
    
    var bundleId: String {
        return Bundle.main.bundleIdentifier!
    }

    // document_path in application's sandbox

    var pathForDocumentDirectory: String {
        let path = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first?.path
        return path!
    }

    // device_token

    var hasDeviceToken: Bool {
        return UserDefaults.standard.bool(forKey: kDeviceToken)
    }
    
    var deviceToken: String {
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

    // onboarding

    var isOnboardingCompleted: Bool {
        let isOnboardingCompleted = UserDefaults.standard.bool(forKey: kOnboarding)
        return isOnboardingCompleted
    }

    func setOnboarding(isCompleted: Bool) {
        UserDefaults.standard.set(isCompleted, forKey: kOnboarding)
    }
    
    // tutorial
    // similar to onboarding, but tutorial offers update info to users who have just updated to a later version of the app
    
    var isTutorialCompleted: Bool {
        return false
    }
    
    /// The integer value associated with the specified key. If the specified key doesn‘t exist, this method returns 0.
    var currentTutorialStage: Int {
        return 0
    }
    
    func saveTutorialProgress(at stage: Int) {
        UserDefaults.standard.set(stage, forKey: kTutorial)
    }

    // amplitude

    var amplitudeApiKey: String {
        let key = Bundle.main.object(forInfoDictionaryKey: "AMPLITUDE_API_KEY") as! String
        return key
    }

}
