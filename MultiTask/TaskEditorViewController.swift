//
//  EditTaskViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/4/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

protocol TaskEditorViewControllerDelegate: NSObjectProtocol {
    func taskEditorViewController(_ viewController: TaskEditorViewController, didTap saveButton: UIButton, toSave task: Task)
}

class TaskEditorViewController: BaseViewController, UITextViewDelegate, UIViewControllerTransitioningDelegate {

    // MARK: - API

    static let storyboard_id = String(describing: TaskEditorViewController.self)
    var delegate: TaskEditorViewControllerDelegate?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var taskTitleTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    @IBAction func handleCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func handleSave(_ sender: UIButton) {
        if !taskTitleTextView.text.isEmpty {
            let newTask = self.createNewTask(taskTitle: taskTitleTextView.text)
            self.delegate?.taskEditorViewController(self, didTap: sender, toSave: newTask)
            self.dismiss(animated: true, completion: nil)
        }
    }

    func createNewTask(taskTitle: String) -> Task {
        let task = Task()
        task.id = NSUUID().uuidString
        task.title = taskTitle
        return task
    }

    private func setupView() {
        self.titleLabel.textColor = Color.lightGray
        self.titleLabel.backgroundColor = Color.clear
        self.titleLabel.text = "Title of the task"
        self.taskTitleTextView.text.removeAll()
        self.taskTitleTextView.tintColor = Color.mandarinOrange
        self.taskTitleTextView.backgroundColor = Color.midNightBlack
        self.taskTitleTextView.layer.cornerRadius = 5
        self.taskTitleTextView.clipsToBounds = true
        self.cancelButton.backgroundColor = Color.midNightBlack
        self.cancelButton.layer.cornerRadius = 5
        self.cancelButton.clipsToBounds = true
        self.cancelButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.cancelButton.setTitle("Cancel", for: UIControlState.normal)
        self.saveButton.backgroundColor = Color.seaweedGreen
        self.saveButton.layer.cornerRadius = 5
        self.saveButton.clipsToBounds = true
        self.saveButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.saveButton.setTitle("Save", for: UIControlState.normal)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.taskTitleTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.taskTitleTextView.resignFirstResponder()
    }

}
