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
    func taskEditorViewController(_ viewController: TaskEditorViewController, didUpdateTask task: Task, at indexPath: IndexPath)
    func taskEditorViewController(_ viewController: TaskEditorViewController, didAddTask task: Task, at indexPath: IndexPath?)
    func taskEditorViewController(_ viewController: TaskEditorViewController, didCancelTask task: Task?, at indexPath: IndexPath?)
}

extension TaskEditorViewControllerDelegate {
    func taskEditorViewController(_ viewController: TaskEditorViewController, didUpdateTask task: Task, at indexPath: IndexPath) {}
    func taskEditorViewController(_ viewController: TaskEditorViewController, didAddTask task: Task, at indexPath: IndexPath?) {}
    func taskEditorViewController(_ viewController: TaskEditorViewController, didCancelTask task: Task?, at indexPath: IndexPath?) {}
}

class TaskEditorViewController: BaseViewController, UITextViewDelegate, PersistentContainerDelegate {

    // MARK: - API

    var realmManager: RealmManager?
    var selectedTask: Task?

    var selectedIndexPath: IndexPath?
    weak var delegate: TaskEditorViewControllerDelegate?
    static let storyboard_id = String(describing: TaskEditorViewController.self)

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    @IBAction func handleCancel(_ sender: UIButton) {
        self.titleTextView.resignFirstResponder()
        self.delegate?.taskEditorViewController(self, didCancelTask: self.selectedTask, at: nil)
    }

    @IBAction func handleSave(_ sender: UIButton) {
        self.titleTextView.resignFirstResponder()
        if !titleTextView.text.isEmpty {
            if self.selectedTask != nil {
                // update the task
                self.realmManager?.updateObject(object: self.selectedTask!, keyedValues: [Task.titleKeyPath : self.titleTextView.text])
            } else {
                // add a new task
                let newTask = self.createNewTask(taskTitle: titleTextView.text)
                self.realmManager?.addObjects(objects: [newTask])
            }
        }
    }

    func createNewTask(taskTitle: String) -> Task {
        let task = Task(title: taskTitle, items: List<Item>(), is_completed: false)
        return task
    }

    private func setupView() {
        if self.selectedTask == nil {
            self.titleLabel.text = "Add a new task"
            self.titleTextView.text?.removeAll()
        } else {
            self.titleLabel.text = "Edit a task"
            self.titleTextView.text = selectedTask?.title
        }
        self.view.backgroundColor = Color.transparentBlack
        self.scrollView.delaysContentTouches = false
        self.containerView.backgroundColor = Color.clear
        self.containerView.clipsToBounds = true
        self.contentContainerView.enableParallaxMotion(magnitude: 16)
        self.contentContainerView.backgroundColor = Color.inkBlack
        self.contentContainerView.layer.borderColor = Color.midNightBlack.cgColor
        self.contentContainerView.layer.borderWidth = 3
        self.contentContainerView.layer.cornerRadius = 8
        self.contentContainerView.clipsToBounds = true
        self.titleLabel.textColor = Color.lightGray
        self.titleLabel.backgroundColor = Color.clear
        self.titleTextView.tintColor = Color.mandarinOrange
        self.titleTextView.backgroundColor = Color.midNightBlack
        self.titleTextView.layer.cornerRadius = 8
        self.titleTextView.clipsToBounds = true
        self.titleTextView.delegate = self
        self.cancelButton.backgroundColor = Color.midNightBlack
        self.cancelButton.layer.cornerRadius = 8
        self.cancelButton.clipsToBounds = true
        self.cancelButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.cancelButton.setTitle("Cancel", for: UIControlState.normal)
        self.saveButton.backgroundColor = Color.seaweedGreen
        self.saveButton.layer.cornerRadius = 8
        self.saveButton.clipsToBounds = true
        self.saveButton.setTitleColor(Color.inkBlack, for: UIControlState.disabled)
        self.saveButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.saveButton.setTitle("Save", for: UIControlState.normal)
        self.saveButton.isEnabled = false
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
        print(error.localizedDescription)
    }

    func persistentContainer(_ manager: RealmManager, didUpdate object: Object) {
        if let task = self.selectedTask, let indexPath = self.selectedIndexPath {
            self.delegate?.taskEditorViewController(self, didUpdateTask: task, at: indexPath)
        } else {
            print(trace(file: #file, function: #function, line: #line))
            self.dismiss(animated: true, completion: nil)
        }
    }

    func persistentContainer(_ manager: RealmManager, didAdd objects: [Object]) {
        if let newTask = objects.first as? Task {
            self.delegate?.taskEditorViewController(self, didAddTask: newTask, at: nil)
        } else {
            print(trace(file: #file, function: #function, line: #line))
            self.dismiss(animated: true, completion: nil)
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

}
