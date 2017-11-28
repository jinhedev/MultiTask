//
//  ItemsViewControllerTests.swift
//  MultiTaskTests
//
//  Created by rightmeow on 11/27/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import XCTest
@testable import MultiTask

class ItemsViewControllerTests: XCTestCase {

    // MARK: - Mocks

    var sut: ItemsViewController!

    // MARK: - Tests

    func testPersistentContainerDelegateReference() {
        XCTAssertTrue(sut.realmManager!.delegate === sut, "incorrect pointer to location.")
    }

    func testUITableViewDelegateReference() {
        XCTAssertTrue(sut.tableView.delegate === sut, "incorrect pointer to location.")
    }

    func testUITableViewDataSourceReference() {
        XCTAssertTrue(sut.tableView.dataSource === sut, "incorrect pointer to location.")
    }

    func testNotificationTokenForNil() {
        if sut.items != nil {
            XCTAssertNotNil(sut.notificationToken, "If items != nil, token must be instantiated.")
        } else {
            XCTAssertNil(sut.notificationToken, "If items == nil, token must be nil too.")
        }
    }

    // MARK: - Setups

    func testSetupsForNil() {
        XCTAssertNotNil(sut.tableView, "tableView must not be nil")
        XCTAssertNotNil(sut.tableView.delegate, "tableView.delegate must not be nil")
        XCTAssertNotNil(sut.tableView.dataSource, "tableView.dataSource must not be nil")
        XCTAssertNotNil(sut.realmManager, "realmManager must not be nil")
    }
    
    override func setUp() {
        super.setUp()
        sut = UIStoryboard(name: "TasksTab", bundle: nil).instantiateViewController(withIdentifier: ItemsViewController.storyboard_id) as! ItemsViewController
        _ = sut.view
    }
    
    override func tearDown() {
        super.tearDown()
        self.sut = nil
    }
    
}
