import CoreData
import Foundation

final class DailyMetricsRepositoryImpl: DailyMetricsRepositoryProtocol {
    private let coreDataStack: CoreDataStackProvider
    
    init(coreDataStack: CoreDataStackProvider = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchMetrics(dayIdentifier: String) async throws -> DailyMetricsDTO? {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request = CDDailyMetrics.fetchRequest()
            request.predicate = NSPredicate(format: "dayIdentifier == %@", dayIdentifier)
            
            guard let entity = try context.fetch(request).first else { return nil }
            return self.mapToDTO(entity)
        }
    }
    
    func upsertMetrics(_ metricsData: DailyMetricsDTO) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let request = CDDailyMetrics.fetchRequest()
            request.predicate = NSPredicate(format: "dayIdentifier == %@", metricsData.dayIdentifier)
            
            let metrics = try context.fetch(request).first ?? CDDailyMetrics(context: context)
            
            metrics.dayIdentifier = metricsData.dayIdentifier
            metrics.morningMetric = Int16(metricsData.morningMetric)
            metrics.noonMetric = Int16(metricsData.noonMetric)
            metrics.eveningMetric = Int16(metricsData.eveningMetric)
            metrics.snackMetric = Int16(metricsData.snackMetric)
            metrics.averageMetric = Int16(metricsData.averageMetric)
            metrics.hasGoldStatus = metricsData.hasGoldStatus
            metrics.exportTimestamp = metricsData.exportTimestamp
            
            try context.save()
        }
    }
    
    func fetchRecentDays(dayCount: Int) async throws -> [DailyMetricsDTO] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request = CDDailyMetrics.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "dayIdentifier", ascending: false)]
            request.fetchLimit = dayCount
            
            let results = try context.fetch(request)
            return results.map { self.mapToDTO($0) }
        }
    }
    
    private func mapToDTO(_ entity: CDDailyMetrics) -> DailyMetricsDTO {
        DailyMetricsDTO(
            dayIdentifier: entity.dayIdentifier!,
            morningMetric: Int(entity.morningMetric),
            noonMetric: Int(entity.noonMetric),
            eveningMetric: Int(entity.eveningMetric),
            snackMetric: Int(entity.snackMetric),
            averageMetric: Int(entity.averageMetric),
            hasGoldStatus: entity.hasGoldStatus,
            exportTimestamp: entity.exportTimestamp
        )
    }
}

