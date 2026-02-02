import SwiftUI
import CoreData
import Combine

class DegubaHomeViewModel: ObservableObject {
    @Published var evubewTodaySessions: [AxemobSessionModel] = []
    @Published var cuqavuDailySummary: CuqavuDailySummaryModel?
    @Published var axemobCurrentMood: Int16 = 3
    @Published var ehonohShowNewSession = false
    
    private let degubaLoadDashboard: CuqavuLoadDashboardUseCase
    private let evubewCalculateSummary: DegubaCalculateSummaryUseCase
    
    init(context: NSManagedObjectContext = DegubaPersistenceController.shared.container.viewContext) {
        self.degubaLoadDashboard = CuqavuLoadDashboardUseCase(context: context)
        self.evubewCalculateSummary = DegubaCalculateSummaryUseCase(context: context)
    }
    
    func cuqavuLoadData() {
        let result = degubaLoadDashboard.axemobExecute()
        evubewTodaySessions = result.sessions
        cuqavuDailySummary = result.summary
        
        if cuqavuDailySummary == nil && !evubewTodaySessions.isEmpty {
            cuqavuDailySummary = evubewCalculateSummary.evubewExecuteForDate(Date())
        }
        
        if let lastSession = evubewTodaySessions.first {
            axemobCurrentMood = lastSession.mood
        }
    }
    
    func axemobGetTotalMinutesToday() -> Int {
        return evubewTodaySessions.reduce(0) { $0 + Int($1.durationMin) }
    }
    
    func ehonohGetEnergyDataPoints() -> [Double] {
        return evubewTodaySessions.reversed().map { Double($0.energyLevel) }
    }
    
    func degubaGetTimeLabels() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return evubewTodaySessions.reversed().map { formatter.string(from: $0.startTime) }
    }
    
    func cuqavuGetCurrentMood() -> Int16 {
        return axemobCurrentMood
    }
}

