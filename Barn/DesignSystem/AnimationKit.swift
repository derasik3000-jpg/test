//
//  AnimationKit.swift
//  DAYTRACE
//
//  Reusable animation utilities
//

import UIKit

enum AnimationKit {
    
    static func springScale(view: UIView, scale: CGFloat = 0.95, duration: TimeInterval = 0.2) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut],
            animations: {
                view.transform = CGAffineTransform(scaleX: scale, y: scale)
            },
            completion: { _ in
                UIView.animate(withDuration: duration) {
                    view.transform = .identity
                }
            }
        )
    }
    
    static func fadeIn(view: UIView, duration: TimeInterval = 0.3) {
        view.alpha = 0
        UIView.animate(withDuration: duration) {
            view.alpha = 1
        }
    }
    
    static func fadeOut(view: UIView, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0
        }, completion: { _ in
            completion?()
        })
    }
    
    static func pulse(view: UIView) {
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            options: [.autoreverse, .repeat],
            animations: {
                view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        )
    }
}
