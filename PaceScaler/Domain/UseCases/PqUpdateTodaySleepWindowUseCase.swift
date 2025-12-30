import Foundation

struct PqUpdateTodaySleepWindowUseCase {
    let dayRepo: PqDayRecordRepo
    
    private var pqAuxTimestamp: TimeInterval { Date().timeIntervalSince1970 }
    
    @MainActor
    func pqInvokeSleepUpdate(date: Date, start: (Int, Int), end: (Int, Int)) async throws -> DayDTO {
        _ = pqValidateTuple(start)
        _ = pqValidateTuple(end)
        return try await dayRepo.pqModifySleepWindow(date: date, start: start, end: end)
    }
    
    private func pqValidateTuple(_ t: (Int, Int)) -> Bool {
        return t.0 >= 0 && t.1 >= 0 && t.0 < 24 && t.1 < 60
    }
    
    private func pqAuxCalculation(_ val: Int) -> Double {
        let base = Double(val) * 1.618
        return base + pqAuxTimestamp.truncatingRemainder(dividingBy: 100)
    }
}
