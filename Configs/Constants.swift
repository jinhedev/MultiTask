//
//  Constant.swift
//  MultiTask
//
//  Created by rightmeow on 1/24/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import Foundation

// MARK: - Generals

let kOnboardingCompletion = "kOnboardingCompletion"
let kSessionToken = "kSessionToken"
let kDeviceToken = "kDeviceToken"
let kApiKey = "kApiKey"
let kUserAuthentication = "kUserAuthentication"

// MARK: - Keychain

struct KeychainConfiguration {
    static let serviceName = "multitask"
    static let accessGroup: String? = Bundle.main.bundleIdentifier!
    static let account = "multitask_session_token"
}

// MARK: - Segue

struct Segue {
    static let AddButtonToTaskEditorViewController = "AddButtonToTaskEditorViewController"
    static let AddButtonToSketchEditorViewController = "AddButtonToSketchEditorViewController"
    static let PendingContainerViewToPendingTasksViewController = "PendingContainerViewToPendingTasksViewController"
    static let CompletedContainerViewToPendingTasksViewController = "CompletedContainerViewToPendingTasksViewController"
    static let SketchCellToSketchEditorViewController = "SketchCellToSketchEditorViewController"
    static let AvatarButtonToSettingsViewController = "AvatarButtonToSettingsViewController"
    static let EditButtonToTaskEditorViewController = "EditButtonToTaskEditorViewController"
    static let SketchEditViewControllerToSaveDataViewController = "SketchEditViewControllerToSaveDataViewController"
    static let PendingTaskCellToItemsViewController = "PendingTaskCellToItemsViewController"
    static let ItemsViewControllerToItemEditorViewController = "ItemsViewControllerToItemEditorViewController"
    static let ProfileCellToAvatarsViewController = "ProfileCellToAvatarsViewController"
    static let AgreementCellToWebsViewController = "AgreementCellToWebsViewController"
    static let SupportCellToWebsViewController = "SupportCellToWebsViewController"
    static let BugCellToWebsViewController = "BugCellToWebsViewController"
}

// MARK: - Notification

extension Notification.Name {
    static let TaskPending = Notification.Name("TaskPending")
    static let TaskCompletion = Notification.Name("TaskCompletion")
    static let TaskUpdate = Notification.Name("TaskUpdate")
    static let SketchCreation = Notification.Name("SketchCreation")
    static let PendingTaskCellEditingMode = Notification.Name("PendingTaskCellEditingMode")
    static let CompletedTaskCellEditingMode = Notification.Name("CompletedTaskCellEditingMode")
    static let SketchCellEditingMode = Notification.Name("SketchCellEditingMode")
    static let CollectionViewCommitTrash = Notification.Name("CollectionViewCommitTrash")
}

struct LocalNotificationConfiguration {
    static let id = "localNotificationID"
    static let attachment_id = "localNotificationAttachmentID"
}

// MARK: - Amplitude

struct LogEventType {
    static let realmError = "realmError"
}
