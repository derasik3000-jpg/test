//
//  UserAvatar.swift
//  DAYTRACE
//
//  User personalization model
//

import Foundation

struct UserAvatar: Codable {
    var emoji: String
    
    init(emoji: String = "😊") {
        self.emoji = emoji
    }
}
