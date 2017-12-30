//
//  String.swift
//  MultiTask
//
//  Created by rightmeow on 12/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

// MARK: - NSString

extension String {

    func heightForText(systemFont size: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: size)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font : font], context: nil)
        return ceil(rect.height)
    }

    /// WARNING: do not use this method to generate a password
    static func random(length: Int) -> String {
        let letters = "abcdefghjklmnpqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ12345789"
        let randomLength = UInt32(letters.count)
        let randomString: String = (0 ..< length).reduce(String()) { accum, _ in
            let randomOffset = arc4random_uniform(randomLength)
            let randomIndex = letters.index(letters.startIndex, offsetBy: Int(randomOffset))
            return accum.appending(String(letters[randomIndex]))
        }
        return randomString
    }

    /**
     Makes a string into a plural form.
     - parameter count: the number of objects in the same context.
     - warning: It doesn't work for all kinds of words. i.e. ...es or ...ies
     */
    func pluralize(count: Int) -> String {
        if count > 1 {
            let pluralizedString = self + "s"
            return pluralizedString
        } else {
            return self
        }
    }

}
