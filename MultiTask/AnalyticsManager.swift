//
//  PinpointAnalyticsLogger.swift
//  MultiTask
//
//  Created by rightmeow on 8/12/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation

protocol Loggable {
}

extension Loggable {
}

class AnalyticsManager: NSObject {

    // MARK: - Events

    var delegate: Loggable?

    /// type: View Controller, key: Method, value: Error or Event
    func logCustomEvent(sender: Any, method: String, value: Any, metrics: [String : NSNumber]?) {

    }

    // MARK: - Monetization

    func logGenericMonetizationEvent(productID: String, price: Double, quantity: Int, currency: String) {

    }

}












