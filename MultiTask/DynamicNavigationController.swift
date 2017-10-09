//
//  DynamicNavigationController.swift
//  MultiTask
//
//  Created by rightmeow on 10/1/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

protocol DynamicNavigationControllerDelegate: NSObjectProtocol {
    func navigationItem(_ navigationController: UINavigationController, willPrompt prompt: String)
}

extension DynamicNavigationControllerDelegate {
    func navigationItem(_ navigationController: DynamicNavigationController, willPrompt prompt: String) {}
}

class DynamicNavigationController: UINavigationController {

    // MARK: - API

    var timer: Timer?
    var dynamicDelegate: DynamicNavigationControllerDelegate?

	func scheduleNavigationPrompt(with message: String, duration: TimeInterval) {
        DispatchQueue.main.async {
            self.navigationItem.prompt = message
            self.timer = Timer.scheduledTimer(timeInterval: duration,
                                              target: self,
                                              selector: #selector(self.removePrompt),
                                              userInfo: nil,
                                              repeats: false)
            self.timer?.tolerance = 5
        }
    }

    @objc func removePrompt() {
        if navigationItem.prompt != nil {
            DispatchQueue.main.async {
                self.navigationItem.prompt = nil
            }
        }
    }

    private func setupNavigationBar() {
        self.navigationBar.barTintColor = Color.midNightBlack
        self.navigationBar.isTranslucent = false
        self.navigationBar.layer.shadowColor = Color.black.cgColor
        self.navigationBar.layer.shadowRadius = 3.0
        self.navigationBar.layer.shadowOpacity = 0.5
    }

    // MARK: - UISearchController

    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEnabled = false { didSet { setupSearchBar() } }

    private func setupSearchBar() {
        
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: observe error message for navigationItem.prompt
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // TODO: remove observer of error message
    }

}

















