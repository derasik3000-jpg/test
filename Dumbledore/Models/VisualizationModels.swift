// VisualizationModels.swift
import Foundation

// MARK: - Donut Chart Models
public struct UsefulDonutModel {
    public let dayKey: Date
    public let usefulMinutes: Int
    public let dailyGoalMinutes: Int
    
    public var progress: Double {
        min(Double(usefulMinutes) / Double(max(dailyGoalMinutes, 1)), 1)
    }
}

// MARK: - Pie Chart Models
public struct TopicSlice: Identifiable {
    public let id = UUID()
    public let topicTag: String
    public let minutes: Int
    public let share: Double
}

public struct TopicPieModel {
    public let range: ClosedRange<Date>
    public let totalMinutes: Int
    public let slices: [TopicSlice]
}

// MARK: - Bar Chart Models
public struct DayBar: Identifiable {
    public let id = UUID()
    public let dayKey: Date
    public let minutes: Int
    public let reachedGoal: Bool
}

public struct BarSeries {
    public let bars: [DayBar]
}

// MARK: - Timeline Models
public enum Speaker {
    case ai, user
}

public struct TurnMark: Identifiable {
    public let id = UUID()
    public let kind: Kind
    public let payload: String?
    
    public enum Kind {
        case goalHit, newWord, hint, pronunciation
    }
}

public struct DialogTurn: Identifiable {
    public let id = UUID()
    public let ts: Date
    public let speaker: Speaker
    public let text: String
    public let marks: [TurnMark]
}

public struct DialogTimelineModel {
    public let scenarioTitle: String
    public let turns: [DialogTurn]
}

// MARK: - Heatmap Models
public enum WeakType {
    case lexis, grammar, pronunciation
}

public struct HeatCell: Identifiable {
    public let id = UUID()
    public let dayKey: Date
    public let type: WeakType
    public let intensity: Double
}

public struct WeakHeatmapModel {
    public let cells: [HeatCell]
}
