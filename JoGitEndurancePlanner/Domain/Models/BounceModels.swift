import Foundation

enum CutbackStyle: Int, CaseIterable {
    case volume = 0
    case intensity = 1
    case both = 2
    
    var displayName: String {
        switch self {
        case .volume: return "Volume"
        case .intensity: return "Intensity"
        case .both: return "Both"
        }
    }
}

struct TaperBlueprint: Identifiable, Equatable, Hashable {
    let id: UUID
    var reductionRate: Int
    var cutbackStyle: CutbackStyle
    var label: String?
    
    init(id: UUID = UUID(), reductionRate: Int = 20, cutbackStyle: CutbackStyle = .volume, label: String? = nil) {
        self.id = id
        self.reductionRate = reductionRate
        self.cutbackStyle = cutbackStyle
        self.label = label
    }
}

struct SpanCycleModel: Identifiable, Equatable {
    let id: UUID
    var kickoff: Date
    var closure: Date
    var blueprint: TaperBlueprint
    var workouts: [WorkoutEntryModel]
    
    init(id: UUID = UUID(), kickoff: Date, closure: Date, blueprint: TaperBlueprint, workouts: [WorkoutEntryModel] = []) {
        self.id = id
        self.kickoff = kickoff
        self.closure = closure
        self.blueprint = blueprint
        self.workouts = workouts
    }
}

struct WorkoutEntryModel: Identifiable, Equatable {
    let id: UUID
    var slotIndex: Int
    var heading: String
    var scheduledDuration: Int
    var adjustedDuration: Int
    var effortMarker: String?
    var easedEffortMarker: String?
    var repeatsCount: Int?
    var easedRepeatsCount: Int?
    var markedComplete: Bool
    var memo: String?
    
    init(id: UUID = UUID(), slotIndex: Int, heading: String, scheduledDuration: Int, adjustedDuration: Int,
         effortMarker: String? = nil, easedEffortMarker: String? = nil,
         repeatsCount: Int? = nil, easedRepeatsCount: Int? = nil,
         markedComplete: Bool = false, memo: String? = nil) {
        self.id = id
        self.slotIndex = slotIndex
        self.heading = heading
        self.scheduledDuration = scheduledDuration
        self.adjustedDuration = adjustedDuration
        self.effortMarker = effortMarker
        self.easedEffortMarker = easedEffortMarker
        self.repeatsCount = repeatsCount
        self.easedRepeatsCount = easedRepeatsCount
        self.markedComplete = markedComplete
        self.memo = memo
    }
}

struct CycleDigest {
    let targetRate: Int
    let achievedRate: Int
    let verdict: DigestVerdict
    
    enum DigestVerdict {
        case acceptable
        case shortfall
        case excessive
    }
}

struct SegmentInfo: Identifiable, Equatable {
    let id: UUID
    let caption: String
    let magnitude: Double
    let fraction: Double?
    let tint: String
    let fillPattern: Int
    
    init(id: UUID = UUID(), caption: String, magnitude: Double, fraction: Double? = nil, tint: String, fillPattern: Int = 0) {
        self.id = id
        self.caption = caption
        self.magnitude = magnitude
        self.fraction = fraction
        self.tint = tint
        self.fillPattern = fillPattern
    }
}

struct CycleTargetActualRingData {
    let targetRate: Int
    let achievedRate: Int
    let segments: [SegmentInfo]
    let verdictText: String
}

struct StyleDivisionRingData {
    let segments: [SegmentInfo]
    let explanation: String
}

struct SlotBarRecord: Identifiable, Equatable {
    let id: UUID
    let slotIndex: Int
    let plannedTime: Int
    let easedTime: Int
    let completedTime: Int
    let dropRate: Int
    let hasCompletion: Bool
    
    init(id: UUID = UUID(), slotIndex: Int, plannedTime: Int, easedTime: Int, completedTime: Int, dropRate: Int, hasCompletion: Bool) {
        self.id = id
        self.slotIndex = slotIndex
        self.plannedTime = plannedTime
        self.easedTime = easedTime
        self.completedTime = completedTime
        self.dropRate = dropRate
        self.hasCompletion = hasCompletion
    }
}

struct CycleBarsSnapshot {
    let records: [SlotBarRecord]
}

struct SlotFinishBarRecord: Identifiable, Equatable {
    let id: UUID
    let slotIndex: Int
    let totalCount: Int
    let finishedCount: Int
    
    init(id: UUID = UUID(), slotIndex: Int, totalCount: Int, finishedCount: Int) {
        self.id = id
        self.slotIndex = slotIndex
        self.totalCount = totalCount
        self.finishedCount = finishedCount
    }
}

struct CycleFinishBarsSnapshot {
    let records: [SlotFinishBarRecord]
}

struct TrendMarker: Identifiable, Equatable {
    let id: UUID
    let cycleKickoff: Date
    let targetRate: Int
    let achievedRate: Int
    let verdictLabel: String
    
    init(id: UUID = UUID(), cycleKickoff: Date, targetRate: Int, achievedRate: Int, verdictLabel: String) {
        self.id = id
        self.cycleKickoff = cycleKickoff
        self.targetRate = targetRate
        self.achievedRate = achievedRate
        self.verdictLabel = verdictLabel
    }
}

struct TrendTimelineSnapshot {
    let markers: [TrendMarker]
}

struct OffTrackSlotRow: Identifiable, Equatable {
    let id: UUID
    let slotIndex: Int
    let plannedTime: Int
    let easedTime: Int
    let actualRate: Int
    let suggestion: String
    
    init(id: UUID = UUID(), slotIndex: Int, plannedTime: Int, easedTime: Int, actualRate: Int, suggestion: String) {
        self.id = id
        self.slotIndex = slotIndex
        self.plannedTime = plannedTime
        self.easedTime = easedTime
        self.actualRate = actualRate
        self.suggestion = suggestion
    }
}

struct OffTrackGridSnapshot {
    let rows: [OffTrackSlotRow]
}

