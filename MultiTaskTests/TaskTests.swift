//
//  TaskTests.swift
//  MultiTaskTests
//
//  Created by rightmeow on 2/8/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import XCTest
import RealmSwift
@testable import MultiTask

class TaskTests: XCTestCase {

    var sut: Task!
    
    override func setUp() {
        super.setUp()
        self.sut = Task()
        self.sut.created_at = NSDate()
        self.sut.title = "test"
        self.sut.id = UUID().uuidString
    }
    
    override func tearDown() {
        super.tearDown()
        self.sut = nil
    }

    func test_task_should_be_valid() {
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
        var shortString = "a"
        while shortString.count < 3 {
            shortString.append("a")
        }
        self.sut.title = shortString
        XCTAssertFalse(sut.isValid())
    }

}
