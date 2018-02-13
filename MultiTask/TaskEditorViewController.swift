//
//  EditTaskViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/4/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

protocol TaskEditorViewControllerDelegate: NSObjectProtocol {
    func taskEditorViewController(_ viewController: TaskEditorViewController, didUpdateTask task: Task)
    func taskEditorViewController(_ viewController: TaskEditorViewController, didAddTask task: Task)
}

class TaskEditorViewController: BaseViewController, UITextViewDelegate, PersistentContainerDelegate {

    // MARK: - API

    var realmManager: RealmManager?
    var selectedTask: Task?
    weak var delegate: TaskEditorViewControllerDelegate?
    static let storyboard_id = String(describing: TaskEditorViewController.self)

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!

    @IBAction func handleSave(_ sender: UIButton) {
        self.titleTextView.resignFirstResponder()
        if !titleTextView.text.isEmpty {
            if self.selectedTask != nil {
                // update an existing task
                self.selectedTask!.save()
            } else {
                // add a new task
                let newTask = self.createNewTask(taskTitle: titleTextView.text)
                newTask.save()
            }
        }
    }

    func createNewTask(taskTitle: String) -> Task {
        let task = Task(title: taskTitle, items: List<Item>(), is_completed: false)
        return task
    }

    private func setupView() {
        self.view.backgroundColor = Color.inkBlack
        self.scrollView.delaysContentTouches = false
        self.containerView.backgroundColor = Color.clear
        self.containerView.clipsToBounds = true
        self.contentContainerView.backgroundColor = Color.inkBlack
        self.titleLabel.textColor = Color.lightGray
        self.titleLabel.backgroundColor = Color.clear
        self.titleLabel.isHidden = false
        self.titleLabel.text = self.selectedTask == nil ? "Add a new task" : "Edit a task"
        self.subtitleLabel.textColor = Color.lightGray
        self.subtitleLabel.backgroundColor = Color.clear
        self.titleTextView.tintColor = Color.mandarinOrange
        self.titleTextView.text = self.selectedTask == nil ? "" : selectedTask!.title
        self.titleTextView.backgroundColor = Color.midNightBlack
        self.titleTextView.layer.cornerRadius = 8
        self.titleTextView.clipsToBounds = true
        self.titleTextView.delegate = self
        self.saveButton.backgroundColor = Color.seaweedGreen
        self.saveButton.layer.cornerRadius = 8
        self.saveButton.clipsToBounds = true
        self.saveButton.setTitleColor(Color.inkBlack, for: UIControlState.disabled)
        self.saveButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.saveButton.setTitle("Save", for: UIControlState.normal)
        self.saveButton.isEnabled = false
        if self.selectedTask == nil {
            self.subtitleLabel.isHidden = true
        } else {
            self.subtitleLabel.text = "Hash. " + selectedTask!.id
        }
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        self.saveButton.isEnabled = textView.text.count > 2 ? true : false
    }

    // MARK: - PersistentContainerDelegate

    private func setupPersistentContainerDelegate() {
        realmManager = RealmManager()
        realmManager!.delegate = self
    }

    func persistentContainer(_ manager: RealmManager, didErr error: Error) {
        if let navigationController = self.navigationController as? BaseNavigationController {
            navigationController.scheduleNavigationPrompt(with: error.localizedDescription, duration: 5)
        }
    }

    func persistentContainer(_ manager: RealmManager, didUpdateObject object: Object) {
        if let task = self.selectedTask {
            self.delegate?.taskEditorViewController(self, didUpdateTask: task)
        } else {
            print(trace(file: #file, function: #function, line: #line))
            if let navController = self.navigationController as? BaseNavigationController {
                navController.popViewController(animated: true)
            }
        }
    }

    func persistentContainer(_ manager: RealmManager, didAddObjects objects: [Object]) {
        if let newTask = objects.first as? Task {
            self.delegate?.taskEditorViewController(self, didAddTask: newTask)
        } else {
            print(trace(file: #file, function: #function, line: #line))
            if let navController = self.navigationController as? BaseNavigationController {
                navController.popViewController(animated: true)
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupPersistentContainerDelegate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.titleTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.titleTextView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
