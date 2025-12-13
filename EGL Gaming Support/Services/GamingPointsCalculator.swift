import Foundation

class GamingPointsCalculator {
    private let markRepository: GamingMarkRepositoryProtocol
    
    init(markRepository: GamingMarkRepositoryProtocol) {
        self.markRepository = markRepository
    }
    
    func addPoints(for action: GamingActionType) {
        let points = action.pointsValue
        let today = Date()
        try? markRepository.upsert(date: today, delta: points, note: action.description)
    }
    
    func totalPoints() -> Int {
        return Int(markRepository.totalCount())
    }
    
    func dayPoints(_ date: Date) -> Int {
        let marks = markRepository.range(from: date, to: date)
        return marks.reduce(0) { $0 + Int($1.count) }
    }
}

enum GamingActionType {
    case addRecord
    case addProgram
    case completeStep
    case addPlan
    
    var pointsValue: Int {
        switch self {
        case .addRecord, .addProgram, .completeStep, .addPlan:
            return 5
        }
    }
    
    var description: String {
        switch self {
        case .addRecord:
            return "Added record"
        case .addProgram:
            return "Added program"
        case .completeStep:
            return "Completed step"
        case .addPlan:
            return "Added plan"
        }
    }
}

