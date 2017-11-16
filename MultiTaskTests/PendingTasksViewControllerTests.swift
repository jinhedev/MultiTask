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

    // MARK: - Lifecycle

    var sut: PendingTasksViewController!
    
    override func setUp() {
        super.setUp()
        sut = UIStoryboard(name: "TasksTab", bundle: nil).instantiateViewController(withIdentifier: PendingTasksViewController.storyboard_id) as! PendingTasksViewController
        _ = sut.view
    }

    override func tearDown() {
        super.tearDown()
    }
    
}
