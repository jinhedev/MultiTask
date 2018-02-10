//
//  SketchTests.swift
//  MultiTaskTests
//
//  Created by rightmeow on 2/8/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import XCTest
import RealmSwift
@testable import MultiTask

class SketchTests: XCTestCase {

    var sut: Sketch!
    
    override func setUp() {
        super.setUp()
        self.sut = Sketch()
        self.sut.created_at = NSDate()
        self.sut.title = "test title"
        self.sut.id = UUID().uuidString
        self.sut.imageData = NSData()
    }
    
    override func tearDown() {
        super.tearDown()
        self.sut = nil
    }

    // MARK: - Tests

    func test_sketch_should_be_valid() {
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

    func test_title_should_have_max_length() {
        var longString = ""
        while longString.count < 129 {
            longString.append("a")
        }
        self.sut.title = longString
        XCTAssertFalse(sut.isValid())
    }
    
}
