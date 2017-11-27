//
//  Utilities.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

// MARK: - Error handler

func trace(file: String, function: String, line: Int) -> String {
    let trace = "\n" + "file: " + file + "\n" + "function: " + function + "\n" + "line: " + String(describing: line) + "\n"
    return trace
}

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

// MARK: - UIImageView

extension UIImageView {

    func fadeIn() {
        self.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
}

extension IndexPath {

    static func fromRow(_ row: Int) -> IndexPath {
        return IndexPath(row: row, section: 0)
    }

    static func fromItem(_ item: Int) -> IndexPath {
        return IndexPath(item: item, section: 0)
    }

}

// MARK: - UITableView

extension UITableView {

    func applyChanges(section: Int = 0, deletions: [Int], insertions: [Int], updates: [Int]) {
        performBatchUpdates({
            deleteRows(at: deletions.map(IndexPath.fromRow), with: UITableViewRowAnimation.automatic)
            insertRows(at: insertions.map(IndexPath.fromRow), with: UITableViewRowAnimation.automatic)
            reloadRows(at: updates.map(IndexPath.fromRow), with: UITableViewRowAnimation.automatic)
        }, completion: nil)
    }

}

// MARK: - UICollectionView

extension UICollectionView {

    func applyChanges(section: Int = 0, deletions: [Int], insertions: [Int], updates: [Int]) {
        performBatchUpdates({
            deleteItems(at: deletions.map(IndexPath.fromItem))
            insertItems(at: insertions.map(IndexPath.fromItem))
            reloadItems(at: updates.map(IndexPath.fromItem))
        }, completion: nil)
    }

}

// MARK: - NSString

extension String {

    func heightForText(systemFont size: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: size)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font : font], context: nil)
        return ceil(rect.height)
    }

}

// MARK: - UIView

extension UIView {

    func enableParallaxMotion(magnitude: Float) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = -magnitude
        yMotion.maximumRelativeValue = magnitude
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        addMotionEffect(group)
    }

}






















