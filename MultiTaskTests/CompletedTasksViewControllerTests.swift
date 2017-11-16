//
//  CompletedTasksViewControllerTests.swift
//  MultiTaskTests
//
//  Created by rightmeow on 11/16/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import XCTest
@testable import MultiTask

class CompletedTasksViewControllerTests: XCTestCase {

    // MARK: - Lifecycle

    var sut: CompletedTasksViewController!

    override func setUp() {
        super.setUp()
        sut = UIStoryboard(name: "TasksTab", bundle: nil).instantiateViewController(withIdentifier: CompletedTasksViewController.storyboard_id) as! CompletedTasksViewController
        _ = sut.view
    }

    override func tearDown() {
        super.tearDown()
    }

}
