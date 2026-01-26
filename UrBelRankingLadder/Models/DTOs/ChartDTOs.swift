import Foundation

public enum SectorCategoryKey: String, Codable, CaseIterable {
    case vegetables
    case protein
    case carbs
}

public struct DonutSegmentDTO: Identifiable, Hashable, Codable {
    public let id: UUID
    public let categoryKey: SectorCategoryKey
    public let displayTitle: String
    public let targetPortionCount: Double
    public let actualPortionCount: Double
    public let fillPercentage: Double
    public let excessAmount: Double
    public let colorHexValue: String
    public let voiceOverText: String
    
    public init(id: UUID, categoryKey: SectorCategoryKey, displayTitle: String, targetPortionCount: Double, actualPortionCount: Double, fillPercentage: Double, excessAmount: Double, colorHexValue: String, voiceOverText: String) {
        self.id = id
        self.categoryKey = categoryKey
        self.displayTitle = displayTitle
        self.targetPortionCount = targetPortionCount
        self.actualPortionCount = actualPortionCount
        self.fillPercentage = fillPercentage
        self.excessAmount = excessAmount
        self.colorHexValue = colorHexValue
        self.voiceOverText = voiceOverText
    }
}

public struct MealPlateVisualizationDTO: Identifiable, Hashable, Codable {
    public let id: UUID
    public let dayIdentifier: String
    public let timeSlotRaw: String
    public let segmentCollection: [DonutSegmentDTO]
    public let balanceMetric: Int
    public let suggestionText: String
    public let hasGoldQuality: Bool
    
    public init(id: UUID, dayIdentifier: String, timeSlotRaw: String, segmentCollection: [DonutSegmentDTO], balanceMetric: Int, suggestionText: String, hasGoldQuality: Bool) {
        self.id = id
        self.dayIdentifier = dayIdentifier
        self.timeSlotRaw = timeSlotRaw
        self.segmentCollection = segmentCollection
        self.balanceMetric = balanceMetric
        self.suggestionText = suggestionText
        self.hasGoldQuality = hasGoldQuality
    }
}

public struct DailyContributionSegmentDTO: Identifiable, Hashable {
    public let id: UUID
    public let timeSlotRaw: String
    public let metricValue: Int
    public let contributionWeight: Double
    public let contributionPercent: Int
    public let displayLabel: String
    public let voiceOverText: String
    
    public init(id: UUID, timeSlotRaw: String, metricValue: Int, contributionWeight: Double, contributionPercent: Int, displayLabel: String, voiceOverText: String) {
        self.id = id
        self.timeSlotRaw = timeSlotRaw
        self.metricValue = metricValue
        self.contributionWeight = contributionWeight
        self.contributionPercent = contributionPercent
        self.displayLabel = displayLabel
        self.voiceOverText = voiceOverText
    }
}

public struct DayOverviewDonutDTO: Identifiable, Hashable {
    public let id: UUID
    public let dayIdentifier: String
    public let segmentCollection: [DailyContributionSegmentDTO]
    public let averageMetric: Int
    public let hasGoldQuality: Bool
    
    public init(id: UUID, dayIdentifier: String, segmentCollection: [DailyContributionSegmentDTO], averageMetric: Int, hasGoldQuality: Bool) {
        self.id = id
        self.dayIdentifier = dayIdentifier
        self.segmentCollection = segmentCollection
        self.averageMetric = averageMetric
        self.hasGoldQuality = hasGoldQuality
    }
}

public struct DayMetricBarDTO: Identifiable, Hashable {
    public let id: UUID
    public let dayIdentifier: String
    public let averageMetric: Int
    public let hasGoldQuality: Bool
    public let voiceOverText: String
    
    public init(id: UUID, dayIdentifier: String, averageMetric: Int, hasGoldQuality: Bool, voiceOverText: String) {
        self.id = id
        self.dayIdentifier = dayIdentifier
        self.averageMetric = averageMetric
        self.hasGoldQuality = hasGoldQuality
        self.voiceOverText = voiceOverText
    }
}

public struct WeeklyBarsVisualizationDTO: Identifiable, Hashable {
    public let id: UUID
    public let dayBars: [DayMetricBarDTO]
    public let maxValueHint: Int
    public let captionText: String
    
    public init(id: UUID, dayBars: [DayMetricBarDTO], maxValueHint: Int, captionText: String) {
        self.id = id
        self.dayBars = dayBars
        self.maxValueHint = maxValueHint
        self.captionText = captionText
    }
}

public struct TimelineSlotSegmentDTO: Identifiable, Hashable {
    public let id: UUID
    public let timeSlotRaw: String
    public let metricValue: Int
    public let displayLabel: String
    public let voiceOverText: String
    
    public init(id: UUID, timeSlotRaw: String, metricValue: Int, displayLabel: String, voiceOverText: String) {
        self.id = id
        self.timeSlotRaw = timeSlotRaw
        self.metricValue = metricValue
        self.displayLabel = displayLabel
        self.voiceOverText = voiceOverText
    }
}

public struct DayTimelineVisualizationDTO: Identifiable, Hashable {
    public let id: UUID
    public let dayIdentifier: String
    public let slotSegments: [TimelineSlotSegmentDTO]
    
    public init(id: UUID, dayIdentifier: String, slotSegments: [TimelineSlotSegmentDTO]) {
        self.id = id
        self.dayIdentifier = dayIdentifier
        self.slotSegments = slotSegments
    }
}

