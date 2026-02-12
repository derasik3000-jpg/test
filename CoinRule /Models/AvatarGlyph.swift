//
//  AvatarGlyph.swift
//  PULSE
//
//  Data Model - Avatar Glyph
//

import Foundation

struct AvatarGlyph: Codable {
    var emoji: String
    var shape: Shape
    var backgroundColor: String
    
    enum Shape: String, Codable, CaseIterable {
        case circle
        case square
        case triangle
        case hexagon
        
        var displayName: String {
            rawValue.capitalized
        }
    }
    
    init(emoji: String = "✨", shape: Shape = .circle, backgroundColor: String = "pulseBackground") {
        self.emoji = emoji
        self.shape = shape
        self.backgroundColor = backgroundColor
    }
}
