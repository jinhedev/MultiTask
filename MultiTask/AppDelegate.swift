//
//  AppDelegate.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PersistentContainerDelegate {

    var window: UIWindow?
    var realmManager: RealmManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // APNS
        setupRemoteNotification()
        // Realm
        setupRealm()
        setupPersistentContainerDelegate()
        if realmManager?.isOnboardingCompleted == true {
            print("fetch app settings and setup themes and other environment objects")
        } else {
            print("go to onboarding")
        }
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

    // MARK: - Remote notification

    func setupRemoteNotification() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (completed: Bool, error: Error?) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                if completed == true {
                    print("request for remote notification granted")
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

    // MARK: - PersistentContainerDelegate

    func setupPersistentContainerDelegate() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        print(error.localizedDescription)
    }

}
