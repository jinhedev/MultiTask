//
//  ItemTests.swift
//  MultiTaskTests
//
//  Created by rightmeow on 2/9/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import XCTest
import RealmSwift
@testable import MultiTask

class ItemTests: XCTestCase {

    var sut: Item!
    
    override func setUp() {
        super.setUp()
        self.sut = Item()
        self.sut.created_at = NSDate()
        self.sut.title = "test item"
        self.sut.id = UUID().uuidString
        self.sut.is_completed = false
    }
    
    override func tearDown() {
        super.tearDown()
        self.sut = nil
    }

    // MARK: - Tests

    func test_item_should_be_valid() {
        XCTAssertTrue(sut.isValid())
    }

    func test_id_should_be_present() {
        self.sut.id = ""
        XCTAssertFalse(sut.isValid())
    }

    func test_title_should_be_present() {
        self.sut.title = ""
        XCTAssertFalse(sut.isValid())
    }

    func test_title_should_have_min_length() {
        var shortString = ""
        while shortString.count < 3 {
            shortString.append("a")
        }
        self.sut.title = shortString
        XCTAssertFalse(sut.isValid())
    }
    
}
