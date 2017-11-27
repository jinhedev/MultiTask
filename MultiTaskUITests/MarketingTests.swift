//
//  MarketingTests.swift
//  MultiTaskUITests
//
//  Created by rightmeow on 11/27/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import XCTest

class MarketingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testMarketingScreenshots() {
        let app = XCUIApplication()
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
        }
        app.buttons["FirstRunViewController.button"].tap()
        snapshot("01Task")
        app.buttons["HomeView.settingsButton"].tap()
        snapshot("02Settings")
    }
    
}
