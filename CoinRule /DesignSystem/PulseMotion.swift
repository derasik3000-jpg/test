//
//  PulseMotion.swift
//  PULSE
//
//  Design System - Animations
//

import UIKit

struct PulseMotion {
    
    // MARK: - Timing
    
    static let fast: TimeInterval = 0.2
    static let standard: TimeInterval = 0.3
    static let slow: TimeInterval = 0.5
    static let pulse: TimeInterval = 1.5
    
    // MARK: - Easing
    
    static let easeOut = CAMediaTimingFunction(name: .easeOut)
    static let easeInOut = CAMediaTimingFunction(name: .easeInEaseOut)
    static let spring = CAMediaTimingFunction(controlPoints: 0.5, 1.5, 0.5, 1.0)
    
    // MARK: - Reduce Motion Check
    
    static var isReduceMotionEnabled: Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
    
    // MARK: - Pulse Animation
    
    static func createPulseAnimation(duration: TimeInterval = pulse) -> CAAnimationGroup {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.2
        scaleAnimation.duration = duration / 2
        scaleAnimation.autoreverses = true
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.6
        opacityAnimation.duration = duration / 2
        opacityAnimation.autoreverses = true
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.duration = duration
        group.repeatCount = .infinity
        group.timingFunction = easeInOut
        
        return group
    }
    
    // MARK: - Stroke Animation
    
    static func createStrokeAnimation(duration: TimeInterval = pulse) -> CAAnimationGroup {
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        strokeStart.fromValue = 0
        strokeStart.toValue = 1
        strokeStart.duration = duration
        
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = 0
        strokeEnd.toValue = 1
        strokeEnd.duration = duration
        
        let group = CAAnimationGroup()
        group.animations = [strokeStart, strokeEnd]
        group.duration = duration
        group.timingFunction = easeInOut
        
        return group
    }
    
    // MARK: - Orbit Animation
    
    static func createOrbitAnimation(radius: CGFloat, duration: TimeInterval = 3.0) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position")
        
        let path = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        animation.path = path.cgPath
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.calculationMode = .paced
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        return animation
    }
    
    // MARK: - Fade Transition
    
    static func fadeTransition(duration: TimeInterval = standard) -> CATransition {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = duration
        transition.timingFunction = easeOut
        return transition
    }
    
    // MARK: - Spring Animation Helper
    
    static func springAnimate(duration: TimeInterval = standard, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        if isReduceMotionEnabled {
            UIView.animate(withDuration: fast, animations: animations, completion: completion)
        } else {
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: animations, completion: completion)
        }
    }
}
