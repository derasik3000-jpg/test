//
//  SnapshotComposer.swift
//  DAYTRACE
//
//  Snapshot image generator
//

import UIKit

final class SnapshotComposer {
    
    func generateSnapshot(for trace: DailyTrace, avatar: UserAvatar) -> UIImage {
        let size = CGSize(width: 400, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Background
            ColorPalette.background.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Card
            let cardRect = CGRect(x: 20, y: 40, width: 360, height: 520)
            ColorPalette.surface.setFill()
            UIBezierPath(roundedRect: cardRect, cornerRadius: 16).fill()
            
            // Avatar
            let avatarAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 60),
                .foregroundColor: UIColor.white
            ]
            let avatarText = avatar.emoji as NSString
            avatarText.draw(at: CGPoint(x: 170, y: 60), withAttributes: avatarAttributes)
            
            // Date
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            let dateString = formatter.string(from: trace.date)
            
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            (dateString as NSString).draw(at: CGPoint(x: 40, y: 140), withAttributes: dateAttributes)
            
            // Mood
            let moodEmoji: String
            switch trace.mood {
            case .low: moodEmoji = "😔"
            case .neutral: moodEmoji = "😐"
            case .high: moodEmoji = "😊"
            }
            
            let moodAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40)
            ]
            (moodEmoji as NSString).draw(at: CGPoint(x: 320, y: 130), withAttributes: moodAttributes)
            
            // Actions
            let actionsTitle = "Actions:"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            (actionsTitle as NSString).draw(at: CGPoint(x: 40, y: 200), withAttributes: titleAttributes)
            
            var yOffset: CGFloat = 230
            for action in trace.actions.prefix(8) {
                let stateEmoji: String
                switch action.state {
                case .done: stateEmoji = "✅"
                case .skipped: stateEmoji = "⏭️"
                case .pending: stateEmoji = "⏳"
                }
                
                let actionText = "\(stateEmoji) \(action.text)"
                let actionAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.8)
                ]
                (actionText as NSString).draw(at: CGPoint(x: 40, y: yOffset), withAttributes: actionAttributes)
                yOffset += 25
            }
            
            // Footer
            let footerText = "DAYTRACE"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: ColorPalette.primary
            ]
            (footerText as NSString).draw(at: CGPoint(x: 160, y: 540), withAttributes: footerAttributes)
        }
        
        return image
    }
}
