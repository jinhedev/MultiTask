//
//  NSDate.swift
//  MultiTask
//
//  Created by rightmeow on 12/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation

// MARK: - Human readable date

extension NSDate {

    /// dateFormatter is expensive...be warned!
    func toRelativeDate() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self as Date))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 30 * day
        let year = 365 * day
        if secondsAgo < minute {
            return "\(secondsAgo) sec ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) mins ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hrs ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        } else if secondsAgo < month {
            return "\(secondsAgo / week) weeks ago"
        } else if secondsAgo < year {
            return "\(secondsAgo / month) months ago"
        }
        return "\(secondsAgo / year) yrs ago"
    }

}

extension Date {

    static var currentInternationalTime: Int = {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let currentTimeString = dateFormatter.string(from: today)
        let time = Int(currentTimeString)
        return time!
    }()

}
