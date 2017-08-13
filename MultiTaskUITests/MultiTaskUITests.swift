//
//  MultiTaskUITests.swift
//  MultiTaskUITests
//
//  Created by rightmeow on 8/13/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import XCTest

class MultiTaskUITests: XCTestCase {
    
    func testExample() {
        // 1
        let app = XCUIApplication()
        setupSnapshot(app)
        // 2
        let chipCountTextField = app.textFields["chip count"]
        chipCountTextField.tap()
        chipCountTextField.typeText("10")
        // 3
        let bigBlindTextField = app.textFields["big blind"]
        bigBlindTextField.tap()
        bigBlindTextField.typeText("100")
        // 4
        snapshot("01UserEntries")
        // 5
        app.buttons["what should I do"].tap()
        snapshot("02Suggestion")
    }
    
}
