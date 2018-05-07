//
//  SaveDataController.swift
//  MultiTask
//
//  Created by rightmeow on 12/23/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import RealmSwift

protocol SaveDataViewControllerDelegate: NSObjectProtocol {
    func saveDataViewController(_ viewController: SaveDataViewController, didTapSave button: UIButton, withTitle: String)
    func saveDataViewController(_ viewController: SaveDataViewController, didTapCancel button: UIButton)
}

class SaveDataViewController: BaseViewController, UITextFieldDelegate {

    // MRAK: - API

    var sketch: Sketch?
    var sketchTitle = ""
    weak var delegate: SaveDataViewControllerDelegate?
    static let storyboard_id = String(describing: SaveDataViewController.self)
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBAction func handleSave(_ sender: UIButton) {
        if self.titleTextField.text?.isEmpty == false {
            self.delegate?.saveDataViewController(self, didTapSave: sender, withTitle: self.titleTextField.text!)
        } else {
            self.titleTextField.animateJitter(repeatCount: 5, duration: 0.03)
            self.titleTextField.attributedPlaceholder = NSAttributedString(string: "title must not be blank", attributes: [NSAttributedStringKey.foregroundColor : Color.roseScarlet])
        }
    }

    @IBAction func handleCancel(_ sender: UIButton) {
        self.delegate?.saveDataViewController(self, didTapCancel: sender)
    }

    private func setupView() {
        self.view.backgroundColor = Color.clear
        self.titleLabel.backgroundColor = Color.clear
        self.titleLabel.textColor = Color.white
        self.titleLabel.text = "Choose a sketch title"
        self.titleTextField.backgroundColor = Color.midNightBlack
        self.titleTextField.textColor = Color.white
        self.titleTextField.attributedPlaceholder = NSAttributedString(string: "sketch_title", attributes: [NSAttributedStringKey.foregroundColor : Color.darkGray])
        self.titleTextField.text = self.sketch?.title
        self.saveButton.layer.cornerRadius = 8
        self.saveButton.backgroundColor = Color.seaweedGreen
        self.cancelButton.backgroundColor = Color.midNightBlack
        self.cancelButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.cancelButton.layer.cornerRadius = 8
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.titleTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.titleTextField.resignFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

}
