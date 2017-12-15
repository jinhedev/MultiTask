//
//  UIImageView.swift
//  MultiTask
//
//  Created by rightmeow on 12/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

// MARK: - UIImageView

extension UIImageView {

    func fadeIn() {
        self.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }, completion: nil)
    }

    func fadeOut() {
        self.alpha = 1.0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0.0
        }
    }

}
