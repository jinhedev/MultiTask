//
//  ErrorCell.swift
//  MultiTask
//
//  Created by rightmeow on 11/4/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

protocol ErrorCellDelegate: NSObjectProtocol {
    func errorCell(_ errorCell: ErrorCell, didTapRetry button: UIButton)
}

class ErrorCell: BaseCollectionViewCell {

    var delegate: ErrorCellDelegate?
    static let cell_id = String(describing: ErrorCell.self)
    static let nibName = String(describing: ErrorCell.self)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var retryButton: UIButton!

    @IBAction func handleRetry(_ sender: UIButton) {
        self.delegate?.errorCell(self, didTapRetry: sender)
    }

    private func setupCell() {
        self.errorImageView.backgroundColor = Color.clear
        self.retryButton.backgroundColor = Color.clear
        self.retryButton.setTitle("Retry", for: UIControlState.normal)
        self.retryButton.setTitleColor(Color.white, for: UIControlState.normal)
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
