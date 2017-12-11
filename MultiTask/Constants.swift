//
//  Constants.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
    typealias Color = UIColor
#elseif os(OSX)
    import AppKit
    typealias Color = NSColor
#endif

// MARK: - App Configs

struct Configuration {
    static let appId = Bundle.main.bundleIdentifier!
}

// MARK: - Segue IDs

struct Segue {
    static let AddButtonToTaskEditorViewController = "AddButtonToTaskEditorViewController"
    static let AvatarButtonToSettingsViewController = "AvatarButtonToSettingsViewController"
    static let EditButtonToTaskEditorViewController = "EditButtonToTaskEditorViewController"
    static let PendingTaskCellToItemsViewController = "PendingTaskCellToItemsViewController"
    static let ItemsViewControllerToItemEditorViewController = "ItemsViewControllerToItemEditorViewController"
    static let ProfileCellToWebsViewController = "ProfileCellToWebsViewController"
    static let AgreementCellToWebsViewController = "AgreementCellToWebsViewController"
    static let SupportCellToWebsViewController = "SupportCellToWebsViewController"
    static let BugCellToWebsViewController = "BugCellToWebsViewController"
}

// MARK: - Notification

struct NotificationKey {
    static let TaskPending = "TaskPending"
    static let TaskCompletion = "TaskCompletion"
    static let TaskUpdate = "TaskUpdate"
    static let CollectionViewEditingMode = "CollectionViewEditingMode"
    static let CollectionViewCommitTrash = "CollectionViewCommitTrash"
}

// MARK: - Web URL String

struct ExternalWebServiceUrlString {
    static let Trello = "https://trello.com/b/8fgpP9ZL/multitask-ios-client"
    static let TrelloApp = ""
    static let FAQ = "https://www.reddit.com/r/StarfishApp/"
    static let FAQRedditApp = ""
    static let Terms = "https://github.com/jinhedev/MultiTask/blob/develop/LICENSE.md"
    static let Test = "https://www.apple.com"
}

// MARK: - Color

extension Color {
    static var inkBlack: Color { return #colorLiteral(red: 0.05882352941, green: 0.05882352941, blue: 0.05882352941, alpha: 1) }
    static var midNightBlack: Color { return  #colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 1) }
    static var transparentBlack: Color { return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.75) }
    static var seaweedGreen: Color { return #colorLiteral(red: 0.4470588235, green: 0.5607843137, blue: 0.2549019608, alpha: 1) }
    static var roseScarlet: Color { return #colorLiteral(red: 0.5607843137, green: 0.1960784314, blue: 0.2156862745, alpha: 1) }
    static var candyWhite: Color { return #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) }
    static var mandarinOrange: Color { return #colorLiteral(red: 0.7411764706, green: 0.3921568627, blue: 0.2235294118, alpha: 1) }
    static var metallicGold: Color { return #colorLiteral(red: 0.831372549, green: 0.6862745098, blue: 0.2156862745, alpha: 1) }
    static var deepSeaBlue: Color { return #colorLiteral(red: 0.1568627451, green: 0.1725490196, blue: 0.231372549, alpha: 1) }
    static var mediumBlueGray: Color { return #colorLiteral(red: 0.3294117647, green: 0.3294117647, blue: 0.368627451, alpha: 1) }
    static var mildBlueGray: Color { return #colorLiteral(red: 0.4117647059, green: 0.4117647059, blue: 0.4588235294, alpha: 1) }
    static var lightBlue: Color { return #colorLiteral(red: 0.9098039216, green: 0.9254901961, blue: 0.9450980392, alpha: 1) }
    static var miamiBlue: Color { return #colorLiteral(red: 0, green: 0.5254901961, blue: 0.9764705882, alpha: 1) }
}




















