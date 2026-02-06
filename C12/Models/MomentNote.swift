//
//  MomentNote.swift
//  PULSE
//
//  Data Model - Moment Note
//

import Foundation

struct MomentNote: Codable {
    let id: UUID
    let timestamp: Date
    let content: String
    let mood: Mood
    
    init(content: String, mood: Mood) {
        self.id = UUID()
        self.timestamp = Date()
        self.content = content
        self.mood = mood
    }
}
