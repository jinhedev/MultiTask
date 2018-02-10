//
//  NotificationManager.swift
//  MultiTask
//
//  Created by rightmeow on 8/21/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import UserNotifications

protocol NotificationDelegate: NSObjectProtocol {
    func notification(_ manager: Any, didErr error: Error)
}

extension NotificationDelegate {
}

class NotificationManager: NSObject {

    static let shared = NotificationManager()

    weak var delegate: NotificationDelegate?

    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval) {
        // image content
        let content = UNMutableNotificationContent()
        let iconURL = Bundle.main.url(forResource: "icon", withExtension: "png")!
        let imageAttachment = try! UNNotificationAttachment(identifier: LocalNotificationConfiguration.attachment_id, url: iconURL, options: nil)
        content.attachments.append(imageAttachment)
        // time trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        // request
        let request = UNNotificationRequest(identifier: LocalNotificationConfiguration.id, content: content, trigger: trigger)
        // notification
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error: Error?) in
            if let err = error {
                print(err.localizedDescription)
                print(trace(file: #file, function: #function, line: #line))
            } else {
                print("Notification scheduled successfully!")
            }
        })
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings: UNNotificationSettings) in
            if settings.authorizationStatus == .authorized {
                self.scheduleNotification(title: "Time's Up!", body: "name of the task", timeInterval: 7.0)
            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted: Bool, error: Error?) in
                    if let err = error {
                        fatalError(err.localizedDescription)
                    } else {
                        if granted == true {
                            self.scheduleNotification(title: "Time's Up!", body: "name of the task", timeInterval: 7.0)                        }
                    }
                }
            }
        }
    }

}

