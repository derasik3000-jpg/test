import Foundation

public struct QylexTimeSlice: Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let minutes: Int
    public let percent: Double
    public let a11yText: String
    
    public init(id: UUID, name: String, minutes: Int, percent: Double, a11yText: String) {
        self.id = id
        self.name = name
        self.minutes = minutes
        self.percent = percent
        self.a11yText = a11yText
    }
}

public struct TylorDonutModel: Equatable {
    public let title: String
    public let slices: [QylexTimeSlice]
    public let caption: String
    
    public init(title: String, slices: [QylexTimeSlice], caption: String) {
        self.title = title
        self.slices = slices
        self.caption = caption
    }
}

public struct VylexConversionBar: Identifiable, Equatable {
    public let id: UUID
    public let block: String
    public let percent: Double
    public let attempts: Int
    public let a11yText: String
    
    public init(id: UUID, block: String, percent: Double, attempts: Int, a11yText: String) {
        self.id = id
        self.block = block
        self.percent = percent
        self.attempts = attempts
        self.a11yText = a11yText
    }
}

public struct RykorBarsModel: Equatable {
    public let title: String
    public let bars: [VylexConversionBar]
    
    public init(title: String, bars: [VylexConversionBar]) {
        self.title = title
        self.bars = bars
    }
}

public struct NyloxSessionBlockBand: Identifiable, Equatable {
    public let id: UUID
    public let type: String
    public let startMin: Double
    public let durationMin: Double
    public let attempts: Int
    public let conversion: Double?
    public let a11yText: String
    
    public init(id: UUID, type: String, startMin: Double, durationMin: Double, attempts: Int, conversion: Double?, a11yText: String) {
        self.id = id
        self.type = type
        self.startMin = startMin
        self.durationMin = durationMin
        self.attempts = attempts
        self.conversion = conversion
        self.a11yText = a11yText
    }
}

public struct ZylorTimelineModel: Equatable {
    public let title: String
    public let totalMinutes: Double
    public let bands: [NyloxSessionBlockBand]
    
    public init(title: String, totalMinutes: Double, bands: [NyloxSessionBlockBand]) {
        self.title = title
        self.totalMinutes = totalMinutes
        self.bands = bands
    }
}

public struct HyloxMissLabelBar: Identifiable, Equatable {
    public let id: UUID
    public let label: String
    public let count: Int
    public let percent: Double
    public let a11yText: String
    
    public init(id: UUID, label: String, count: Int, percent: Double, a11yText: String) {
        self.id = id
        self.label = label
        self.count = count
        self.percent = percent
        self.a11yText = a11yText
    }
}

public struct QyrexMissLabelsModel: Equatable {
    public let title: String
    public let bars: [HyloxMissLabelBar]
    
    public init(title: String, bars: [HyloxMissLabelBar]) {
        self.title = title
        self.bars = bars
    }
}

public struct KylexPacePoint: Identifiable, Equatable {
    public let id: UUID
    public let minuteIndex: Int
    public let attempts: Int
    
    public init(id: UUID, minuteIndex: Int, attempts: Int) {
        self.id = id
        self.minuteIndex = minuteIndex
        self.attempts = attempts
    }
}

public struct VyroxSparkModel: Equatable {
    public let title: String
    public let points: [KylexPacePoint]
    
    public init(title: String, points: [KylexPacePoint]) {
        self.title = title
        self.points = points
    }
}

