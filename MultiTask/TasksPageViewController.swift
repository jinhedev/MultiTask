//
//  MainTasksPageViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/11/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class TasksPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIScrollViewDelegate {

    var pendingTasksViewController: PendingTasksViewController?
    var completedTasksViewController: CompletedTasksViewController?
    var mainTasksViewController: MainTasksViewController?
    var pages: [BaseViewController]!

    static let storyboard_id = String(describing: TasksPageViewController.self)

    private func getViewController(withIdentifier identifier: String, in storyboard: String) -> BaseViewController {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier) as! BaseViewController
    }

    private func setupPageViewController() {
        let pendingTasksViewController = self.getViewController(withIdentifier: PendingTasksViewController.storyboard_id, in: "TasksTab")
        let completedTasksViewController = self.getViewController(withIdentifier: CompletedTasksViewController.storyboard_id, in: "TasksTab")
        pages = [pendingTasksViewController, completedTasksViewController]
        self.dataSource = self
        if let firstViewController = pages.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
        }
    }

    // MARK: - UIScrollViewDelegate

    private func setupUIScrollViewDelegate() {
        for view in self.view.subviews {
            if let view = view as? UIScrollView {
                view.delegate = self
                break
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(123)
    }

    func scrollToPageIndex(pageIndex: Int) {
        let indexPath = IndexPath(item: pageIndex, section: 0)
        // manually scroll pageView to the next or previous page by menuIndex
//        self.collectionView.scrollToItem(at: indexPath, at: [], animated: true)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPageViewController()
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: CompletedTasksViewController.self) {
            return getViewController(withIdentifier: PendingTasksViewController.storyboard_id, in: "TasksTab")
        } else if viewController.isKind(of: PendingTasksViewController.self) {
            return nil
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: PendingTasksViewController.self) {
            return getViewController(withIdentifier: CompletedTasksViewController.storyboard_id, in: "TasksTab")
        } else if viewController.isKind(of: CompletedTasksViewController.self) {
            return nil
        }
        return nil
    }

}












