//
//  TasksHeaderView.swift
//  MultiTask
//
//  Created by sudofluff on 5/5/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import UIKit

protocol TasksHeaderViewDelegate: NSObjectProtocol {
    func headerView(_ sender: UISegmentedControl, fromView: TasksHeaderView)
}

class TasksHeaderView: UICollectionReusableView {
    
    static let viewId = String(describing: TasksHeaderView.self)
    static let nibName = String(describing: TasksHeaderView.self)
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    weak var delegate: TasksHeaderViewDelegate?
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        self.delegate?.headerView(sender, fromView: self)
    }
    
    private func setupViews() {
        containerView.backgroundColor = Color.clear
        segmentedControl.tintColor = Color.mandarinOrange
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
}
