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
        snapshot("00LaunchScreen")
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
        searchSearchField.typeText("Shopping")
        snapshot("02UserEntries")
        app.tables.containing(.searchField, identifier:"Search").element.swipeDown()
    }

    func testAddNewTaskAndNewItem() {
        app.navigationBars.buttons["Add"].tap()
        let newTaskAlert = app.alerts["New Task"]
        let taskNameTextField = newTaskAlert.collectionViews.textFields["Task Name"]
        taskNameTextField.typeText("car")
        snapshot("03ButtonTapped")
        newTaskAlert.buttons["Add"].tap()
        snapshot("04ButtonTapped")

    }

}














