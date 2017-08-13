//
//  Utilities.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

// MARK: - Application sound notification

var avaPlayer: AVAudioPlayer?

enum AlertSoundType: String {
    case error = "Error"
    case success = "Success"
}

func playAlertSound(type: AlertSoundType) {
    guard let sound = NSDataAsset(name: type.rawValue) else {
        print(trace(file: #file, function: #function, line: #line))
        return
    }
    do {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try AVAudioSession.sharedInstance().setActive(true)
        avaPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeWAVE)
        DispatchQueue.main.async {
            guard let player = avaPlayer else { return }
            player.play()
        }
    } catch let err {
        print(trace(file: #file, function: #function, line: #line))
        print(err.localizedDescription)
    }
}

// MARK: - JSON

func prettyPrintJson(_ object: AnyObject?) -> String {
    var prettyResult: String = ""
    if object == nil {
        return ""
    } else if let resultArray = object as? [AnyObject] {
        var entries: String = ""
        for index in 0..<resultArray.count {
            if (index == 0) {
                entries = "\(resultArray[index])"
            } else {
                entries = "\(entries), \(prettyPrintJson(resultArray[index]))"
            }
        }
        prettyResult = "[\(entries)]"
    } else if object is NSDictionary  {
        let objectAsDictionary: [String: AnyObject] = object as! [String: AnyObject]
        prettyResult = "{"
        var entries: String = ""
        for (key,_) in objectAsDictionary {
            entries = "\"\(entries), \"\(key)\":\(prettyPrintJson(objectAsDictionary[key]))"
        }
        prettyResult = "{\(entries)}"
        return prettyResult
    } else if let objectAsNumber = object as? NSNumber {
        prettyResult = "\(objectAsNumber.stringValue)"
    } else if let objectAsString = object as? NSString {
        prettyResult = "\"\(objectAsString)\""
    }
    return prettyResult
}

// MARK: - Error handler

func trace(file: String, function: String, line: Int) -> String {
    let trace = "\n" + "file: " + file + "\n" + "function: " + function + "\n" + "line: " + String(describing: line) + "\n"
    return trace
}

// MARK: - Human readable date

extension NSDate {

    func toRelativeDate() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self as Date))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        if secondsAgo < minute {
            return "\(secondsAgo) seconds ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) minutes ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        }
        return "\(secondsAgo / week) weeks ago"
    }

}

















