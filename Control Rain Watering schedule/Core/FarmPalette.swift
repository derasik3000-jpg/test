//
//  FarmPalette.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

/// Color palette based on RAL standards for farming theme
struct FarmPalette {
    
    // MARK: - Primary Colors (RAL Standards)
    
    /// RAL 1004 - Golden yellow (Cards/Accents)
    static let goldenHarvest = UIColor(red: 205/255, green: 164/255, blue: 52/255, alpha: 1.0)
    
    /// RAL 7037 - Dusty grey (Secondary elements)
    static let dustyField = UIColor(red: 125/255, green: 127/255, blue: 120/255, alpha: 1.0)
    
    /// RAL 9005 - Jet black (Main background)
    static let richSoil = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1.0)
    
    // MARK: - Derived Shades
    
    /// Light golden for backgrounds
    static let sunlitField = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1.0) // Black background
    
    /// White for cards
    static let morningMist = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    
    /// White for text
    static let fertileEarth = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    
    /// Semi-transparent overlay
    static let cropShadow = UIColor(red: 205/255, green: 164/255, blue: 52/255, alpha: 0.3)
    
    /// Success green (for growth indicators)
    static let sproutGreen = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0)
    
    /// Warning amber (for attention)
    static let droughtWarning = UIColor(red: 255/255, green: 152/255, blue: 0/255, alpha: 1.0)
    
    /// Error red (for critical states)
    static let wilted = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 1.0)
    
    /// Water blue (for irrigation indicators)
    static let freshWater = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1.0)
    
    /// Dark card background
    static let darkCard = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
}

// MARK: - Typography

struct FarmTypography {
    
    static let seedling = UIFont.systemFont(ofSize: 12, weight: .regular)
    static let crop = UIFont.systemFont(ofSize: 14, weight: .regular)
    static let harvest = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let barn = UIFont.systemFont(ofSize: 20, weight: .semibold)
    static let silo = UIFont.systemFont(ofSize: 24, weight: .bold)
    static let windmill = UIFont.systemFont(ofSize: 32, weight: .bold)
}

// MARK: - Spacing

struct FarmSpacing {
    
    static let furrow: CGFloat = 4
    static let seedGap: CGFloat = 8
    static let rowSpacing: CGFloat = 12
    static let plotMargin: CGFloat = 16
    static let fieldPadding: CGFloat = 20
    static let barnGap: CGFloat = 24
    static let acreSpace: CGFloat = 32
}

// MARK: - Corner Radius

struct FarmRadius {
    
    static let seed: CGFloat = 4
    static let sprout: CGFloat = 8
    static let crop: CGFloat = 12
    static let barn: CGFloat = 16
    static let silo: CGFloat = 20
}
