//
//  TaskHeaderView.swift
//  MultiTask
//
//  Created by rightmeow on 12/8/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

protocol TaskHeaderViewDelegate: NSObjectProtocol {
    func taskHeaderView(_ view: TaskHeaderView, didTapEdit button: UIButton)
}

class TaskHeaderView: UIView {

    // MARK: - API

    var selectedTask: Task? {
        didSet {
            self.configureView()
        }
    }

    weak var delegate: TaskHeaderViewDelegate?
    static let nibName = String(describing: TaskHeaderView.self)

    @IBOutlet var view: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!

    @IBAction func handleEdit(_ sender: UIButton) {
        self.delegate?.taskHeaderView(self, didTapEdit: sender)
    }

    // MARK: - View

    private func configureView() {
        guard let task = self.selectedTask else { return }
        self.titleTextView.text = task.title
        self.subtitleLabel.text = "Hash. " + task.id
        self.dateLabel.text = "Created. " + task.created_at.toRelativeDate()
        self.statsLabel.text = task.updated_at != nil ? "Updated. \(task.updated_at!.toRelativeDate())" : "Updated. nil"
    }

    private func setupView() {
        self.backgroundColor = Color.inkBlack
        self.addSubview(view)
        self.view.frame = self.bounds
        self.view.backgroundColor = Color.inkBlack
        self.containerView.backgroundColor = Color.midNightBlack
        self.containerView.layer.cornerRadius = 8
        self.containerView.layer.borderColor = Color.lightGray.cgColor
        self.containerView.layer.borderWidth = 1
        self.titleTextView.backgroundColor = Color.clear
        self.titleTextView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        self.titleTextView.textColor = Color.white
        self.titleTextView.indicatorStyle = .white
        self.subtitleLabel.backgroundColor = Color.clear
        self.subtitleLabel.textColor = Color.lightGray
        self.dateLabel.backgroundColor = Color.clear
        self.dateLabel.textColor = Color.lightGray
        self.statsLabel.backgroundColor = Color.clear
        self.statsLabel.textColor = Color.lightGray
        self.editButton.enableParallaxMotion(magnitude: 14)
        self.editButton.backgroundColor = Color.midNightBlack
        self.editButton.tintColor = Color.mandarinOrange
        self.editButton.contentMode = .scaleAspectFill
        self.editButton.setImage(#imageLiteral(resourceName: "Edit"), for: UIControlState.normal)
        self.editButton.layer.cornerRadius = 8
        self.editButton.layer.borderColor = Color.lightGray.cgColor
        self.editButton.layer.borderWidth = 1
    }

    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: TaskHeaderView.nibName, bundle: nil).instantiate(withOwner: self, options: nil)
        self.setupView()
    }

}
