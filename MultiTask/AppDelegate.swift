                                                                                                                                                                                                                                                      //
//  AppDelegate.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import Amplitude

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var realmManager: RealmManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // APNS
        self.setupRemoteNotification(application)
        // Realm
        setupRealm() // see RealmManager
        self.setupPersistentContainerDelegate()
        self.performInitialFetch()
        self.setupAmplitude()
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    // MARK: - Amplitude

    private func setupAmplitude() {
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().minTimeBetweenSessionsMillis = 5000
        Amplitude.instance().initializeApiKey("7fd645043b8a91f7adedab334dcb593a")
    }

}

extension AppDelegate: PersistentContainerDelegate {
    
    func setupPersistentContainerDelegate() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }
    
    func performInitialFetch() {
        self.realmManager?.fetchExistingUsers()
    }
    
    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }
    
    func persistentContainer(_ manager: RealmManager, didFetchUsers users: Results<User>?) {
        guard let fetchedUsers = users else { return }
        if fetchedUsers.isEmpty {
            let newUser = User(email: "", displayName: "", avatar: "Snail")
            self.realmManager!.register(newUser: newUser)
        } else {
            // user does exist in local machine, safely ignore.
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func setupRemoteNotification(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (completed: Bool, error: Error?) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                if completed == true {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info: ", notification.request.content.userInfo)
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info: ", response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Configs.shared.saveDeviceToken(token: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }

}

