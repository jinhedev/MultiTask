//
//  PopAnimator.swift
//  MultiTask
//
//  Created by rightmeow on 10/15/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - API

    let duration = 1.0
    var isPresenting = true
    var dismissCompletion: (() -> Void)?
    var originFrame = CGRect.zero

    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let topView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let editView = isPresenting ? topView : transitionContext.view(forKey: UITransitionContextViewKey.from)!

        let initialFrame = isPresenting ? (originFrame) : (CGRect(x: editView.frame.origin.x, y: editView.frame.origin.y, width: editView.frame.size.width, height: editView.frame.size.height / 2))
        let finalFrame = isPresenting ? (CGRect(x: editView.frame.origin.x, y: editView.frame.origin.y, width: editView.frame.size.width, height: editView.frame.size.height / 2)) : (originFrame)

        let xScaleFactor = isPresenting ? (initialFrame.width / finalFrame.width) : (finalFrame.width / initialFrame.width)
        let yScaleFactor = isPresenting ? (initialFrame.height / finalFrame.height) : (finalFrame.height / initialFrame.height)
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        if isPresenting == true {
            editView.transform = scaleTransform
            editView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            editView.clipsToBounds = true
        }
        containerView.addSubview(topView)
        containerView.bringSubview(toFront: editView)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
            editView.transform = self.isPresenting ? CGAffineTransform.identity : scaleTransform
            editView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { (completed: Bool) in
            if self.isPresenting == false {
                self.dismissCompletion?()
            }
            transitionContext.completeTransition(true)
        }
    }

}












