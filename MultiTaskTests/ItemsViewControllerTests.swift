//
//  ItemsViewControllerTests.swift
//  MultiTaskUITests
//
//  Created by rightmeow on 11/16/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import XCTest
@testable import MultiTask

class ItemsViewControllerTests: XCTestCase {

    // MARK: - Lifecycle

    var sut: ItemsViewController!
    
    override func setUp() {
        super.setUp()
        sut = UIStoryboard(name: "TasksTab", bundle: nil).instantiateViewController(withIdentifier: ItemsViewController.storyboard_id) as! ItemsViewController
        _ = sut.view
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - UISearchController

    func test_navigationItemHasSearchController() {
        guard let searchBar = sut.navigationItem.searchController?.searchBar else {
            XCTFail()
            return
        }
        XCTAssertGreaterThanOrEqual(searchBar.frame.size.height, 56)
    }

    func test_updateSearchResults() {
        let searchExpectation = expectation(description: "Fetch")
        let searchBar = UISearchBar()
        searchBar.text = "asd"
        let mockApiClient = MockAPIClient()
        sut.apiClient = mockApiClient

    }

    // MARK: - PersistentContainerDelegate

    func test_persistentContainerDelegateNotNil() {
        XCTAssertNotNil(sut.realmManager?.delegate)
    }

    // MARK: - Notification

    // MARK: - UITableView



    // MARK: - ItemEditorContainerView && ItemEditorViewControllerDelegate

    

}

extension ItemsViewControllerTests {

    class MockAPIClient: APIClientProtocol {

    }

}










