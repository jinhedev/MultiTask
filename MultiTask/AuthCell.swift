//
//  AuthCell.swift
//  MultiTask
//
//  Created by rightmeow on 10/26/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

protocol AuthCellDelegate: NSObjectProtocol {
    func authCell(_ authCell: AuthCell, didTapLogin button: UIButton)
    func authCell(_ authCell: AuthCell, didTapSignup button: UIButton)
}

/**
 AuthCell is a placeholder of user sign up and login. It is a aesthetic replacement for a empty collectionView.
 */
class AuthCell: BaseCollectionViewCell {

    // MARK: - API

    var appSetting: AppSetting? { didSet { self.configureCell(with: appSetting) } }
    weak var delegate: AuthCellDelegate?
    static let cell_id = String(describing: AuthCell.self)
    static let nibName = String(describing: AuthCell.self)

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    @IBAction func handleLogin(_ sender: UIButton) {
        self.delegate?.authCell(self, didTapLogin: sender)
    }

    @IBAction func handleSignup(_ sender: UIButton) {
        self.delegate?.authCell(self, didTapSignup: sender)
    }

    private func configureCell(with appSetting: AppSetting?) {
        if let setting = appSetting {
            // TODO: implement this
            print(setting)
        }
    }

    private func setupCell() {
        self.containerView.backgroundColor = Color.clear
        self.infoImageView.backgroundColor = Color.clear
        self.titleLabel.backgroundColor = Color.clear
        self.loginButton.backgroundColor = Color.clear
        self.signupButton.backgroundColor = Color.clear
    }

    private func defaultDataForReuse() {
        // TODO: implement this
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.defaultDataForReuse()

    }

}
