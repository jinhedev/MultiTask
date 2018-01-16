//
//  Theme.swift
//  MultiTask
//
//  Created by rightmeow on 12/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

enum Theme: Int {

    case dark, light

    private enum Keys {
        static let selectedTheme = "SelectedTheme"
    }

    static var current: Theme {
        let storeTheme = UserDefaults.standard.integer(forKey: Keys.selectedTheme)
        return Theme(rawValue: storeTheme) ?? .dark
    }

    var mainColor: Color {
        switch self {
        case .dark:
            return Color.mandarinOrange
        case .light:
            return Color.white
        }
    }

    var barStyle: UIBarStyle {
        switch self {
        case .dark:
            return .black
        case .light:
            return .default
        }
    }

    func apply() {
        UserDefaults.standard.set(rawValue, forKey: Keys.selectedTheme)
        UserDefaults.standard.synchronize()
        UIApplication.shared.delegate?.window??.tintColor = mainColor
        UINavigationBar.appearance().barStyle = barStyle
    }

}
