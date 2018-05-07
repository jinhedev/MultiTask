//
//  PlaceholderBackgroundView.swift
//  MultiTask
//
//  Created by rightmeow on 12/1/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

enum PlaceholderType {
    case pendingTasks
    case completedTasks
    case items
    case sketches
    case emptyResults
    case error
}

/**
 PlaceholderBackgroundView displays suggestions when no data is rendered on a normal viewController. It's a filler UI element.
 - remark: Make sure to set the type property during the instantiation process.
 */
class PlaceholderBackgroundView: UIView {

    var type: PlaceholderType? {
        didSet {
            guard let type = type else { return }
            switch type {
            case .completedTasks:
                self.tipsImageView.image = #imageLiteral(resourceName: "Whale") // <<-- image literal
                self.titleLabel.text = "No completed tasks..."
                self.subtitleLabel.text = "...yet"
                self.suggestionButton.isHidden = true
            case .pendingTasks:
                self.tipsImageView.image = #imageLiteral(resourceName: "Octopus") // <<-- image literal
                self.suggestionButton.setTitle("New Task", for: UIControlState.normal)
                self.titleLabel.text = "It's too quiet..."
                self.subtitleLabel.text = "Let's add a new task"
                self.suggestionButton.isHidden = true
            case .items:
                self.tipsImageView.image = #imageLiteral(resourceName: "Sunfish") // <<-- image literal
                self.titleLabel.text = "To begin, add an item"
                self.subtitleLabel.text = "\"An item is like a sub-task\""
                self.suggestionButton.isHidden = true
            case .sketches:
                self.tipsImageView.image = #imageLiteral(resourceName: "RubberDuck") // <<-- image literal
                self.titleLabel.text = "Use sketches"
                self.subtitleLabel.text = "For something that is hard to define in words"
                self.suggestionButton.isHidden = true
            case .emptyResults:
                self.tipsImageView.isHidden = true
                self.titleLabel.isHidden = true
                self.subtitleLabel.text = "No results found"
                self.suggestionButton.isHidden = true
            case .error:
                self.tipsImageView.image = #imageLiteral(resourceName: "DeadEmoji") // <<-- image literal
                self.titleLabel.text = "Error"
                self.subtitleLabel.isHidden = true
                self.suggestionButton.isHidden = false
            }
        }
    }

    static let nibName = String(describing: PlaceholderBackgroundView.self)

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tipsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var suggestionButton: UIButton!
    @IBOutlet weak var suggestionButtonHeightConstraint: NSLayoutConstraint!

    @IBAction func handleSuggestion(_ sender: UIButton) {
        // TODO: create a new protocol to handle this
    }
    
    func setView(isHidden: Bool, type: PlaceholderType) {
        self.isHidden = isHidden
        self.type = type
    }

    private func setupView() {
        self.backgroundColor = Color.clear
        self.containerView.backgroundColor = Color.clear
        self.tipsImageView.backgroundColor = Color.clear
        self.tipsImageView.tintColor = Color.white
        self.tipsImageView.contentMode = UIViewContentMode.scaleAspectFill
        self.titleLabel.backgroundColor = Color.clear
        self.titleLabel.textColor = Color.white
        self.subtitleLabel.backgroundColor = Color.clear
        self.subtitleLabel.textColor = Color.lightGray
        self.suggestionButton.backgroundColor = Color.clear
        self.suggestionButton.setTitleColor(Color.mandarinOrange, for: UIControlState.normal)
        self.suggestionButton.layer.cornerRadius = suggestionButtonHeightConstraint.constant / 2
        self.suggestionButton.layer.borderColor = Color.mandarinOrange.cgColor
        self.suggestionButton.layer.borderWidth = 1
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

}

