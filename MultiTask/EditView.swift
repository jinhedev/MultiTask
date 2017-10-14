//
//  NewTaskView.swift
//  MultiTask
//
//  Created by rightmeow on 8/14/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

protocol EditViewDelegate: NSObjectProtocol {
    func editView(_ view: EditView, didSave inputText: String)
    func editView(_ view: EditView, didCancel sender: UIButton)
}

class EditView: UIView {

    // MARK: - API

    weak var delegate: EditViewDelegate?
    static let nibName = String(describing: EditView.self)
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    @IBAction func handleCancel(_ sender: UIButton) {
        self.delegate?.editView(self, didCancel: sender)
    }

    @IBAction func handleSave(_ sender: UIButton) {
        // TODO: implement this
        self.delegate?.editView(self, didSave: self.inputTextView.text)
    }

    func present() {
        self.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.alpha = 1
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.transform = .identity
        }) { (completed: Bool) in
            //
        }
    }

    // MARK: - Setup

    private func setupView() {
        self.inputTextView.backgroundColor = Color.midNightBlack
        self.inputTextView.textColor = Color.white
        self.inputTextView.layer.cornerRadius = 5
        self.inputTextView.layer.shadowColor = Color.red.cgColor
        self.inputTextView.layer.shadowRadius = 10
        self.inputTextView.layer.shadowOpacity = 1.0
        self.inputTextView.layer.shadowPath = UIBezierPath(rect: self.inputTextView.frame).cgPath
        self.inputTextView.layer.shouldRasterize = true
        self.cancelButton.backgroundColor = Color.midNightBlack
        self.cancelButton.setTitleColor(Color.white, for: UIControlState.normal)
        self.saveButton.backgroundColor = Color.seaweedGreen
        self.saveButton.setTitleColor(Color.white, for: UIControlState.normal)
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

}
