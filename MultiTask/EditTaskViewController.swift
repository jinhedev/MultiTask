//
//  EditTaskViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/4/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

protocol EditTaskViewControllerDelegate: NSObjectProtocol {
    func editTaskViewController(_ viewController: EditTaskViewController, didTap saveButton: UIButton, toSave task: Task)
}

class EditTaskViewController: BaseViewController, UITextViewDelegate, UIViewControllerTransitioningDelegate {

    // MARK: - API

    static let storyboard_id = String(describing: EditTaskViewController.self)
    var delegate: EditTaskViewControllerDelegate?
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
        // TODO: implement this
        let task = Task()
        self.delegate?.editTaskViewController(self, didTap: sender, toSave: task)
        self.dismiss(animated: true, completion: nil)
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
