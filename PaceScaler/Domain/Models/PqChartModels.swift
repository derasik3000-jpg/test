import Foundation
import CoreGraphics

struct RitualDonutData {
    let date: Date
    let done: Int
    let total: Int
    let caption: String
    let isComplete: Bool
    
    var ratio: CGFloat {
        total == 0 ? 0 : CGFloat(done) / CGFloat(total)
    }
}

struct CalmBadgeData {
    let isCalm: Bool
}

struct WeekBar {
    let date: Date
    let ratio: CGFloat
    let isCalm: Bool
}

struct WeekBarsData {
    let items: [WeekBar]
}

struct RitualTimelineData {
    let date: Date
    let points: [StepPoint]
}

struct PairBarData {
    let rating: Int
    let ratio: CGFloat
}

