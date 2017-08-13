//
//  Constants.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation

// MARK: - Realm Object Server

struct Constants {

    static let remoteHost = "52.14.43.212"
    static let realmPath = "multitask"

    static let remoteServerURL = URL(string: "realm://\(remoteHost):9080/~/\(realmPath)")
    static let syncAuthURL = URL(string: "http://\(remoteHost): 9080")!

    static let appID = Bundle.main.bundleIdentifier!

}

// MARK: - Currency

struct Currency {
    static let AUD = "AUD"
    static let CAD = "CAD"
    static let EURO = "EURO"
    static let GBP = "GBP"
    static let RMB = "RMB"
    static let RUB = "RUB"
    static let HKD = "HKD"
    static let INR = "INR"
    static let JPY = "JPY"
    static let SGD = "SGD"
    static let NZD = "NZD"
    static let USD = "USD"
}

// MARK: - Color customization

#if os(iOS)
    import UIKit
    typealias Color = UIColor
#elseif os(OSX)
    import AppKit
    typealias Color = NSColor
#endif

extension Color {

    static var inkBlack: Color { return #colorLiteral(red: 0.05882352941, green: 0.05882352941, blue: 0.05882352941, alpha: 1) }
    static var midNightBlack: Color { return  #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1) }
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
























