//
//  MultiTaskUITests.swift
//  MultiTaskUITests
//
//  Created by rightmeow on 8/13/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import XCTest

class MultiTaskUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSearchControl() {
        // Given
        let searchSearchField = app.tables.searchFields["Search"]
        // Then
        snapshot("01NoEntries")
        searchSearchField.tap()
        if searchSearchField.isSelected {
            XCTAssert(app.keyboards.count > 0, "The keyboard is not shown")
        }
        // can't
        searchSearchField.typeText("Shopping")
        snapshot("02UserEntries")
        app.tables.containing(.searchField, identifier:"Search").element.swipeDown()
    }
    
}
