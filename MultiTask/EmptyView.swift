//
//  TipsView.swift
//  MultiTask
//
//  Created by rightmeow on 12/1/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

/**
 EmptyView displays suggestions when no data is rendered on a normal viewController. It's a filler UI element.
 */
class EmptyView: UIView {

    static let nibName = String(describing: EmptyView.self)

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tipsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var suggestionButton: UIButton!

    @IBAction func handleSuggestion(_ sender: UIButton) {
        print(123)
    }

    private func setupView() {
        // ...
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

}
