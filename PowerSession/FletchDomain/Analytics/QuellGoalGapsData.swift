import Foundation

public struct QuellGoalGapRow: Identifiable, Equatable {
    public let id: UUID
    public let wharfTag: VexGoalTag
    public let tarnSuggestion: String
    
    public init(id: UUID = UUID(), wharfTag: VexGoalTag, tarnSuggestion: String) {
        self.id = id
        self.wharfTag = wharfTag
        self.tarnSuggestion = tarnSuggestion
    }
}

public struct FizzGoalGapsTableData: Equatable {
    public let plinthRows: [QuellGoalGapRow]
    
    public init(plinthRows: [QuellGoalGapRow]) {
        self.plinthRows = plinthRows
    }
}

