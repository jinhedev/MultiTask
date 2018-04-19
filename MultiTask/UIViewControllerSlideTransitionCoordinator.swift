//
//  UIViewControllerSlideTransitionCoordinator.swift
//  MultiTask
//
//  Created by rightmeow on 12/23/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

enum UIViewControllerTransitioningDirection {

    case top, right, bottom, left

    var bounds: CGRect {
        return UIScreen.main.bounds
    }

    func offSetWithFrame(viewFrame: CGRect) -> CGRect {
        switch self {
        case .top:
            return viewFrame.offsetBy(dx: 0, dy: -bounds.size.height)
        case .right:
            return viewFrame.offsetBy(dx: bounds.size.width, dy: 0)
        case .bottom:
            return viewFrame.offsetBy(dx: 0, dy: bounds.size.height)
        case .left:
            return viewFrame.offsetBy(dx: -bounds.size.width, dy: 0)
        }
    }

}

class UIViewControllerSlideTransitionCoordinator: NSObject {

    var isPresenting: Bool = true
    private let duration: TimeInterval = 0.4
    private var transitioningDirection: UIViewControllerTransitioningDirection

    init(transitioningDirection: UIViewControllerTransitioningDirection) {
        self.transitioningDirection = transitioningDirection
    }

}

extension UIViewControllerSlideTransitionCoordinator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // FIXME: dear me, please refactor this piece of $#@$%^&
        let containerView = transitionContext.containerView
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        let finalViewControllerFrame = transitionContext.finalFrame(for: toViewController)
        containerView.addSubview(toViewController.view)
        if isPresenting {
            toViewController.view.frame = transitioningDirection.offSetWithFrame(viewFrame: finalViewControllerFrame)
//            containerView.addSubview(toViewController.view)
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [.curveLinear], animations: {
                fromViewController.view.alpha = 0.0
                toViewController.view.frame = finalViewControllerFrame
            }) { (completed) in
                transitionContext.completeTransition(true)
            }
        } else {
//            containerView.addSubview(toViewController.view)
            UIView.animate(withDuration: duration*1.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [.curveLinear], animations: {
                fromViewController.view.alpha = 0.0
                fromViewController.view.frame = CGRect(x: 0, y: -finalViewControllerFrame.height, width: finalViewControllerFrame.width, height: finalViewControllerFrame.height)
                toViewController.view.alpha = 1.0
            }) { (completed) in
                transitionContext.completeTransition(true)
            }
        }
    }
    
}
