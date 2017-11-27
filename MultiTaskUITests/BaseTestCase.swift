//
//  BaseTestCase.swift
//  MultiTaskUITests
//
//  Created by rightmeow on 11/27/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import XCTest

class BaseTestCase: XCTestCase {

    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
