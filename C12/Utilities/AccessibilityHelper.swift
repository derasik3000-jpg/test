//
//  AccessibilityHelper.swift
//  PULSE
//
//  Accessibility Utilities
//

import UIKit

extension UIView {
    
    func setupAccessibility(label: String, hint: String? = nil, traits: UIAccessibilityTraits = .none) {
        isAccessibilityElement = true
        accessibilityLabel = label
        accessibilityHint = hint
        accessibilityTraits = traits
    }
    
    func setMinimumTapTarget(size: CGSize = CGSize(width: 44, height: 44)) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: size.width),
            heightAnchor.constraint(greaterThanOrEqualToConstant: size.height)
        ])
    }
}

extension UIButton {
    
    func configurePulseAccessibility(label: String, hint: String? = nil) {
        setupAccessibility(label: label, hint: hint, traits: .button)
    }
}
