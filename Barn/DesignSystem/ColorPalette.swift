//
//  ColorPalette.swift
//  DAYTRACE
//
//  Design System - RAL Color Palette
//

import UIKit

enum ColorPalette {
    // RAL 9005 — Jet Black (теперь фон)
    static let background = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
    
    // Темно-серый для карточек
    static let surface = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
    
    // RAL 1018 — Zinc Yellow (теперь акцент)
    static let primary = UIColor(red: 0.98, green: 0.84, blue: 0.22, alpha: 1.0)
    
    // Derived colors
    static let textOnSurface = UIColor.white
    static let textOnPrimary = UIColor.black
    static let surfaceAlpha = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.9)
}
