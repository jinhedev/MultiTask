//
//  UIView+Animation.swift
//  MultiTask
//
//  Created by rightmeow on 12/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

// MARK: - UIView

extension UIView {

    func enableParallaxMotion(magnitude: Float) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = -magnitude
        yMotion.maximumRelativeValue = magnitude
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        addMotionEffect(group)
    }

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

    func animateBlink(withDuration: TimeInterval, toColor: UIColor, fromColor: UIColor) {
        UIView.animate(withDuration: withDuration, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.backgroundColor = toColor
        }) { (completed) in
            self.backgroundColor = fromColor
        }
    }

}
