//
//  MultiTaskTests.swift
//  MultiTaskTests
//
//  Created by rightmeow on 8/13/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import XCTest
@testable import MultiTask

class PendingTasksViewControllerTests: XCTestCase {

    // MARK: - Mocks

    var sut: PendingTasksViewController!
    var mockPendingTasks: [Task]!

    // MARK: - Tests

    func testPersistentContainerDelegateReference() {
        XCTAssertTrue(sut.realmManager!.delegate === sut, "incorrect pointer to location.")
    }

    func testUICollectionViewDelegateReference() {
        XCTAssertTrue(sut.collectionView.delegate === sut, "incorrect pointer to location.")
    }

    func testUICollectionViewDataSourceReference() {
        XCTAssertTrue(sut.collectionView.dataSource === sut, "incorrect pointer to location.")
    }

    func testUICollectionViewDelegateFlowLayoutReference() {
        XCTAssertTrue(sut.collectionView.collectionViewLayout === sut.collectionViewFlowLayout, "incorrect pointer to location.")
    }

    // MARK: - Setups

    func testSetupsForNil() {
        XCTAssertNotNil(sut.collectionView, "collectionView must not be nil")
        XCTAssertNotNil(sut.collectionView.delegate, "collectionView.delegate must not be nil")
        XCTAssertNotNil(sut.collectionView.dataSource, "collectionView.dataSource must not be nil")
        XCTAssertNotNil(sut.realmManager, "realmManager must not be nil")
        XCTAssertNotNil(sut.collectionViewFlowLayout, "collectionViewFlowLayout must not be nil")
        XCTAssertEqual(sut.PAGE_INDEX, 0) // pending must be first on the left
    }

    func testNotificationTokenForNil() {
        if sut.pendingTasks != nil {
            XCTAssertNotNil(sut.notificationToken, "If pendingTasks != nil, token must be instantiated.")
        } else {
            XCTAssertNil(sut.notificationToken, "If pendingTasks == nil, token must be nil too.")
        }
    }

    override func setUp() {
        super.setUp()
        sut = UIStoryboard(name: "TasksTab", bundle: nil).instantiateViewController(withIdentifier: PendingTasksViewController.storyboard_id) as! PendingTasksViewController
        _ = sut.view
    }

    override func tearDown() {
        super.tearDown()
        self.sut = nil
    }
    
}
