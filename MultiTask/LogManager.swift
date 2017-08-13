//
//  PinpointAnalyticsLogger.swift
//  MultiTask
//
//  Created by rightmeow on 8/12/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import AWSPinpoint

protocol Loggable {
    func didLogged()
}

extension Loggable {
    func didLogged(event: AWSPinpointEvent) {
        print("Event type: ", event.eventType)
        print("Event timestamp: ", event.eventTimestamp)
        print("Event session: ", event.session)
        print("Event attributes: ", event.allAttributes())
        print("Event metrics: ", event.allMetrics())
    }
}

class RemoteLogManager: NSObject {

    // MARK: - Events

    var delegate: Loggable?

    /// type: View Controller, key: Method, value: Error or Event
    /// refactor this
    func logCustomEvent(type: String, key: String, value: String) {
        guard let pinpointAnalyticsClient = AWSMobileClient.sharedInstance.pinpoint?.analyticsClient else {
            print(trace(file: #file, function: #function, line: #line))
            return
        }
        let event = pinpointAnalyticsClient.createEvent(withEventType: type)
        event.addAttribute(value, forKey: key)
        pinpointAnalyticsClient.record(event)
        pinpointAnalyticsClient.submitEvents()
        delegate?.didLogged(event: event)
    }

    func logCustomEvent(sender: Any, method: String, value: Any, metrics: [String : NSNumber]?) {
        guard let pinpointAnalyticsClient = AWSMobileClient.sharedInstance.pinpoint?.analyticsClient else {
            print(trace(file: #file, function: #function, line: #line))
            return
        }
        let type = String(describing: sender)
        let key = method
        let value = String(describing: value)

        let event = pinpointAnalyticsClient.createEvent(withEventType: type)
        event.addAttribute(value, forKey: key)
        if metrics != nil {
            event.addMetric(metrics!.values.first!, forKey: metrics!.keys.first!)
        }

        pinpointAnalyticsClient.record(event)
        pinpointAnalyticsClient.submitEvents()
        delegate?.didLogged(event: event)
    }

    // MARK: - Monetization

    func logMonetizationEvent(productID: String, price: Double, quantity: Int, currency: String) {
        guard let pinpointAnalyticsClient = AWSMobileClient.sharedInstance.pinpoint?.analyticsClient else {
            print(trace(file: #file, function: #function, line: #line))
            return
        }
        let event = pinpointAnalyticsClient.createVirtualMonetizationEvent(withProductId: productID, withItemPrice: price, withQuantity: quantity, withCurrency: currency)
        pinpointAnalyticsClient.record(event)
        pinpointAnalyticsClient.submitEvents()
        delegate?.didLogged(event: event)
    }

    func logAppleMonetizationEvent(transaction: SKPaymentTransaction, product: SKProduct) {
        guard let pinpointAnalyticsClient = AWSMobileClient.sharedInstance.pinpoint?.analyticsClient else {
            print(trace(file: #file, function: #function, line: #line))
            return
        }
        let event = pinpointAnalyticsClient.createAppleMonetizationEvent(with: transaction, with: product)
        pinpointAnalyticsClient.record(event)
        pinpointAnalyticsClient.submitEvents()
        delegate?.didLogged(event: event)
    }

}












