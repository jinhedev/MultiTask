//
//  MainTasksViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/10/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

class MainTasksViewController: BaseViewController, UISearchResultsUpdating, UIViewControllerTransitioningDelegate, TaskEditorViewControllerDelegate {

    // MARK: - API

    static let storyboard_id = String(describing: MainTasksViewController.self)

    // MARK: - TaskEditorViewControllerDelegate

    func taskEditorViewController(_ viewController: TaskEditorViewController, didTapSave button: UIButton, toSave task: Task) {
        self.tasksPageViewController?.pendingTasksViewController?.realmManager?.addObjects(objects: [task])
    }

    func taskEditorViewController(_ viewController: TaskEditorViewController, didTapCancel button: UIButton) {
        // TODO: implement this if needed
    }

    // MARK: - MenuBarContainerView

    @IBOutlet weak var menuBarContainerView: UIView!

    var menuBarViewController: MenuBarViewController?

    private func setupMenuBarContainerView() {
        self.menuBarContainerView.backgroundColor = Color.clear
    }

    // MARK: - TasksContainerView

    @IBOutlet weak var tasksContainerView: UIView!
    var tasksPageViewController: TasksPageViewController?

    private func setupTasksContainerView() {
        self.tasksContainerView.backgroundColor = Color.clear
    }

    // MARK: - UINavigationBar

    @IBOutlet weak var addButton: UIBarButtonItem!

    @IBAction func handleAdd(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Segue.AddButtonToTaskEditorViewController, sender: self)
    }

    // MARK: - UISearchController & UISearchResultsUpdating

    let searchController = UISearchController(searchResultsController: nil)

    private func setupSearchController() {
        // FIXME: problem with searchController being overlaid by MenuBarViewController
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = Color.white
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        searchController.searchBar.placeholder = "Search"
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
    }

    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text {
            // TODO: implement this
            print(searchString)
        }
    }

    // MARK: - UIRefreshControl

    let refreshControl = UIRefreshControl()

    private func setupRefreshControl() {
        refreshControl.tintColor = Color.lightGray
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTasksContainerView()
        self.setupMenuBarContainerView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.MenuBarContainerViewToMenuBarViewController {
            menuBarViewController = segue.destination as? MenuBarViewController
            menuBarViewController?.mainTasksViewController = self
        } else if segue.identifier == Segue.AddButtonToTaskEditorViewController {
            if let taskEditorViewController = segue.destination as? TaskEditorViewController {
                taskEditorViewController.delegate = self
            }
        } else if segue.identifier == Segue.TasksContainerViewToPageViewController {
            tasksPageViewController = segue.destination as? TasksPageViewController
            tasksPageViewController?.mainTasksViewController = self
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.tasksContainerView.alpha = (size.width > size.height) ? 0.25 : 0.55
        }, completion: nil)
    }

    // MARK: - UIViewControllerTransitioningDelegate

    let popTransitionAnimator = PopTransitionAnimator()

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let addButtonView = self.addButton.value(forKey: "view") as? UIView {
            let barButtonFrame = addButtonView.frame
            popTransitionAnimator.originFrame = barButtonFrame
            popTransitionAnimator.isPresenting = true
            return popTransitionAnimator
        } else {
            return nil
        }
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // TODO: - implement this
        popTransitionAnimator.isPresenting = false
        return popTransitionAnimator
    }

}








