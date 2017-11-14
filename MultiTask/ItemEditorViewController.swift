//
//  ItemEditorView.swift
//  MultiTask
//
//  Created by rightmeow on 11/12/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

protocol ItemEditorViewControllerDelegate: NSObjectProtocol {
    func itemEditorViewController(_ viewController: ItemEditorViewController, didTapSave button: UIButton, toSave item: Item)
    func itemEditorViewController(_ viewController: ItemEditorViewController, didTapCancel button: UIButton)
}

class ItemEditorViewController: BaseViewController, UITextViewDelegate {

    // MARK: - API

    var item: Item?
    var delegate: ItemEditorViewControllerDelegate?
    static let storyboard_id = String(describing: ItemEditorViewController.self)

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    @IBAction func handleCancel(_ sender: UIButton) {
        self.textViewDidEndEditing(titleTextView)
        self.delegate?.itemEditorViewController(self, didTapCancel: sender)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func handleSave(_ sender: UIButton) {
        self.textViewDidEndEditing(titleTextView)
        if !titleTextView.text.isEmpty {
            let newItem = self.createNewItem(itemTitle: titleTextView.text)
            self.delegate?.itemEditorViewController(self, didTapSave: sender, toSave: newItem)
            self.dismiss(animated: true, completion: nil)
        }
    }

    func createNewItem(itemTitle: String) -> Item {
        let item = Item(title: itemTitle, is_completed: false)
        return item
    }

    private func setupView() {
        if self.item == nil {
            self.titleLabel.text = "Add a new item"
            self.titleTextView.text?.removeAll()
        } else {
            self.titleLabel.text = "Edit a item"
            self.titleTextView.text = item?.title
        }
        self.view.backgroundColor = Color.transparentBlack
        self.scrollView.backgroundColor = Color.clear
        self.containerView.backgroundColor = Color.clear
        self.contentContainerView.backgroundColor = Color.inkBlack
        self.contentContainerView.layer.borderColor = Color.midNightBlack.cgColor
        self.contentContainerView.layer.borderWidth = 3
        self.contentContainerView.layer.cornerRadius = 8
        self.contentContainerView.clipsToBounds = true
        self.titleLabel.backgroundColor = Color.clear
        self.titleLabel.textColor = Color.white
        self.titleTextView.backgroundColor = Color.midNightBlack
        self.titleTextView.textColor = Color.white
        self.titleTextView.layer.cornerRadius = 8
        self.titleTextView.clipsToBounds = true
        self.titleTextView.becomeFirstResponder()
        self.titleTextView.tintColor = Color.mandarinOrange
        self.cancelButton.setTitle("Cancel", for: UIControlState.normal)
        self.cancelButton.layer.cornerRadius = 8
        self.cancelButton.backgroundColor = Color.midNightBlack
        self.cancelButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.saveButton.setTitle("Save", for: UIControlState.normal)
        self.saveButton.layer.cornerRadius = 8
        self.saveButton.backgroundColor = Color.seaweedGreen
        self.saveButton.setTitleColor(Color.white, for: UIControlState.normal)
    }

    // MARK: - UITextViewDelegate

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
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
















