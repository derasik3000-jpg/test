//
//  PulseInk.swift
//  PULSE
//
//  Design System - Colors
//

import UIKit

extension UIColor {
    
    // MARK: - Color Palette
    
    /// Black - Background
    static let pulseBackground = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
    
    /// Dark Grey - Surfaces
    static let pulseSurface = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
    
    /// Gold - Accent/Primary
    static let pulsePrimary = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0)
    
    // MARK: - Semantic Colors
    
    static let pulseText = pulsePrimary
    static let pulseTextSecondary = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
    static let pulseAccent = pulsePrimary
    
    // MARK: - Mood Colors
    
    static let pulseCalm = UIColor(red: 100/255, green: 180/255, blue: 220/255, alpha: 1.0)
    static let pulseNeutral = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
    static let pulseIntense = UIColor(red: 220/255, green: 80/255, blue: 80/255, alpha: 1.0)
    
    // MARK: - Alpha Variants
    
    static let pulseSurfaceLight = pulseSurface.withAlphaComponent(0.5)
    static let pulsePrimaryLight = pulsePrimary.withAlphaComponent(0.1)
}
