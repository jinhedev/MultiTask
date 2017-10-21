//
//  EditViewController.swift
//  MultiTask
//
//  Created by rightmeow on 10/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

protocol EditViewDelegate: NSObjectProtocol {
    func editView(_ controller: EditViewController, didSave input: String)
}

class EditViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextViewDelegate {

    // MARK: - API

    static let storyboard_id = String(describing: EditViewController.self)
    var delegate: EditViewDelegate?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    @IBAction func handleCancel(_ sender: UIButton) {
        // TODO: implement this
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func handleSave(_ sender: UIButton) {
        // TODO: implement this
        self.delegate?.editView(self, didSave: inputTextView.text)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    private func setupView() {
        self.view.backgroundColor = Color.clear
        self.scrollView.backgroundColor = Color.clear
        self.containerView.backgroundColor = Color.clear
        self.inputTextView.backgroundColor = Color.midNightBlack
        self.inputTextView.textColor = Color.white
        self.inputTextView.layer.cornerRadius = 5
        self.cancelButton.backgroundColor = Color.midNightBlack
        self.cancelButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.cancelButton.layer.cornerRadius = 5
        self.saveButton.backgroundColor = Color.seaweedGreen
        self.saveButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.saveButton.layer.cornerRadius = 5
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.inputTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.inputTextView.resignFirstResponder()
    }

}














