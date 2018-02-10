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

struct NotificationKey {
    static let TaskPending = "TaskPending"
    static let TaskCompletion = "TaskCompletion"
    static let TaskUpdate = "TaskUpdate"
    static let SketchCreation = "SketchCreation"
    static let PendingTaskCellEditingMode = "PendingTaskCellEditingMode"
    static let CompletedTaskCellEditingMode = "CompletedTaskCellEditingMode"
    static let SketchCellEditingMode = "SketchCellEditingMode"
    static let CollectionViewCommitTrash = "CollectionViewCommitTrash"
}

struct LocalNotificationConfiguration {
    static let id = "localNotificationID"
    static let attachment_id = "localNotificationAttachmentID"
}

// MARK: - Amplitude

struct LogEventType {
    static let relamError = "relamError"
}
