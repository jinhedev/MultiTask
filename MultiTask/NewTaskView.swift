//
//  NewTaskView.swift
//  MultiTask
//
//  Created by rightmeow on 8/14/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class NewTaskView: UIView {

    // MARK: - API

    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputTextView: UITextView!

    @IBOutlet weak var alarmContainerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var alarmSwitch: UISwitch!

    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var setButton: UIButton!

    @IBAction func handleCancel(_ sender: UIButton) {
        // implement this
    }

    @IBAction func handleSet(_ sender: UIButton) {
        // implement this
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

    private func setupViews() {
        // background color
        self.backgroundColor = Color.clear
        inputContainerView.backgroundColor = Color.clear
        inputTextView.backgroundColor = Color.midNightBlack
        alarmContainerView.backgroundColor = Color.clear
        datePicker.backgroundColor = Color.midNightBlack
        buttonContainerView.backgroundColor = Color.clear
        cancelButton.backgroundColor = Color.midNightBlack
        setButton.backgroundColor = Color.midNightBlack
        // rounded corners
        inputTextView.layer.cornerRadius = 5
        datePicker.layer.cornerRadius = 22
        cancelButton.layer.cornerRadius = 5
        setButton.layer.cornerRadius = 5
        // textColor
        inputTextView.textColor = Color.white
        datePicker.tintColor = Color.white
        alarmSwitch.onTintColor = Color.orange
        cancelButton.tintColor = Color.orange
        setButton.tintColor = Color.orange
    }

    // MARK: - Lifecycle

    private let nibName = String(describing: NewTaskView.self)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: nibName, bundle: nil).instantiate(withOwner: self, options: nil)
        setupViews()
    }


}
