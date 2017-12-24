//
//  UIImageView+Image.swift
//  MultiTask
//
//  Created by rightmeow on 12/23/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

extension UIImageView {

    func imageWithCurrentContext() -> UIImage? {
        UIGraphicsBeginImageContext(self.frame.size)
        self.image?.draw(in: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
