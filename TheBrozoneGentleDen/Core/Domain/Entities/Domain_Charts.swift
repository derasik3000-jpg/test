import Foundation

struct ChronoTimeRange {
    enum TimeframeCategory {
        case week
        case month
        case last90Days
        case custom(Date, Date)
    }
    
    let kind: TimeframeCategory
    let start: Date
    let end: Date
}

struct VoidEmptyState {
    let title: String
    let subtitle: String?
    let ctaTitle: String?
    let ctaAction: (() -> Void)?
}

struct MetaChartInfo {
    let title: String
    let subtitle: String?
    let updatedAt: Date
}

struct CosmicDonutData {
    let meta: MetaChartInfo
    let range: ChronoTimeRange
    let mode: VisualizationMode
    let segments: [CircularDataPoint]
    let totalScore: Int
    let emptyState: VoidEmptyState?
    
    enum VisualizationMode {
        case balance
        case normalizedScore
    }
    
    struct CircularDataPoint: Identifiable {
        let id: UUID
        let sphereId: UUID
        let title: String
        let value: Double
        let normalizedValue: Double
        let isDimmed: Bool
        let trendHint: TrendHint?
        let accessibilityLabel: String
    }
    
    enum TrendHint {
        case up(delta: Double)
        case down(delta: Double)
        case stable
    }
}

struct TemporalBarData {
    let meta: MetaChartInfo
    let range: ChronoTimeRange
    let granularity: TimeGranularity
    let series: [BarSeries]
    let emptyState: VoidEmptyState?
    
    enum TimeGranularity {
        case day
        case week
    }
    
    struct BarSeries {
        let id: String
        let title: String
        let bars: [ColumnMetric]
        let accessibilityLabel: String
    }
    
    struct ColumnMetric {
        let date: Date
        let value: Int
        let breakdown: Breakdown
        let isHighlighted: Bool
        
        struct Breakdown {
            let beforeAfterPairsCompleted: Int
            let beforeOnlyCreated: Int
            let stagesAdded: Int
            let milestonesAdded: Int
        }
    }
}

struct ChronicleTimelineData {
    let meta: MetaChartInfo
    let range: ChronoTimeRange
    let items: [TimelineItem]
    let emptyState: VoidEmptyState?
    
    struct TimelineItem: Identifiable {
        let id: UUID
        let date: Date
        let sphereId: UUID
        let sphereTitle: String
        let type: ItemType
        let title: String?
        let previewPhotoPath: String?
        let accessibilityLabel: String
        
        enum ItemType {
            case beforeAfterCompleted
            case beforeOnly
            case stagesUpdate
            case milestone
        }
    }
}

enum AnalyticsScope {
    case global
    case sphere(UUID)
}

