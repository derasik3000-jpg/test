import Foundation
import Combine

final class SetupViewModel: ObservableObject {
    @Published var names: [String] = ["Food", "Transport", "Other"]
    @Published var weekId: UUID?
    
    private let uc: SetupWeekUseCase
    
    init(uc: SetupWeekUseCase) {
        self.uc = uc
    }
    
    func load() {
        if let (w, env) = try? uc.currentWeek() {
            weekId = w.id
            names = env.sorted { $0.orderIndex < $1.orderIndex }.map { $0.name }
        }
    }
    
    func save(onComplete: @escaping () -> Void) {
        guard let wid = weekId else { return }
        _ = try? uc.renameEnvelopes(weekId: wid, names: names)
        onComplete()
    }
}

