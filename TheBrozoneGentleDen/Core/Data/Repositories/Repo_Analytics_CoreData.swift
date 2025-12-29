import Foundation
import CoreData

class CoreDataAuroraAnalyticsRepository: AuroraAnalyticsRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func computeDonutDataset(range: ChronoTimeRange, mode: CosmicDonutData.VisualizationMode) async throws -> CosmicDonutData {
        try await context.perform {
            let sphereRequest = CategoryRecord.fetchRequest()
            sphereRequest.predicate = NSPredicate(format: "voidArchivedFlag == NO AND celestialRadarVisibility == YES")
            sphereRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryRecord.orbitalSortPosition, ascending: true)]
            
            let spheres = try self.context.fetch(sphereRequest)
            
            if spheres.isEmpty {
                return CosmicDonutData(
                    meta: MetaChartInfo(title: "Radar Overview", subtitle: nil, updatedAt: Date()),
                    range: range,
                    mode: mode,
                    segments: [],
                    totalScore: 0,
                    emptyState: VoidEmptyState(
                        title: "Radar awakens when spheres have improvements",
                        subtitle: "Add your first progress photo",
                        ctaTitle: "Add Improvement",
                        ctaAction: nil
                    )
                )
            }
            
            var segments: [CosmicDonutData.CircularDataPoint] = []
            var totalScore = 0
            
            for sphere in spheres {
                guard let sphereId = sphere.zephyrId else { continue }
                
                let entryRequest = AdvancementRecord.fetchRequest()
                entryRequest.predicate = NSPredicate(format: "cosmicSphereLink == %@ AND temporalEventMoment >= %@ AND temporalEventMoment <= %@", sphere, range.start as NSDate, range.end as NSDate)
                
                let entries = try self.context.fetch(entryRequest)
                
                let completedPairs = entries.filter { entry in
                    let photos = (entry.spectrumImageFragments?.allObjects as? [ImageRecord]) ?? []
                    let hasBefore = photos.contains { $0.dimensionalRoleTag == 0 }
                    let hasAfter = photos.contains { $0.dimensionalRoleTag == 1 }
                    return hasBefore && hasAfter
                }.count
                
                let activityCount = entries.count
                
                let recencyFactor = entries.reduce(0.0) { sum, entry in
                    guard let eventDate = entry.temporalEventMoment else { return sum }
                    let daysAgo = Date().timeIntervalSince(eventDate) / 86400
                    return sum + max(0, 30 - daysAgo) / 30
                }
                
                let avgRating = entries.compactMap { entry in
                    entry.luminousAfterScore > 0 ? Double(entry.luminousAfterScore) : nil
                }.reduce(0.0, +) / max(1, Double(entries.filter { $0.luminousAfterScore > 0 }.count))
                
                let rawScore = Double(completedPairs * 4) + Double(activityCount) + recencyFactor + (avgRating * 2)
                let normalizedScore = min(100, Int(rawScore * 5))
                
                totalScore += normalizedScore
                
                segments.append(CosmicDonutData.CircularDataPoint(
                    id: UUID(),
                    sphereId: sphereId,
                    title: sphere.nebulaTitleText ?? "Unknown",
                    value: Double(normalizedScore),
                    normalizedValue: Double(normalizedScore) / 100.0,
                    isDimmed: normalizedScore < 10,
                    trendHint: normalizedScore > 20 ? .up(delta: 5) : .stable,
                    accessibilityLabel: "\(sphere.nebulaTitleText ?? "Unknown"): \(normalizedScore) points"
                ))
            }
            
            return CosmicDonutData(
                meta: MetaChartInfo(title: "Visual Progress Radar", subtitle: "\(range.start.formatted(date: .abbreviated, time: .omitted)) - \(range.end.formatted(date: .abbreviated, time: .omitted))", updatedAt: Date()),
                range: range,
                mode: mode,
                segments: segments,
                totalScore: totalScore,
                emptyState: nil
            )
        }
    }
    
    func computeBarDataset(range: ChronoTimeRange, granularity: TemporalBarData.TimeGranularity, scope: AnalyticsScope) async throws -> TemporalBarData {
        try await context.perform {
            let calendar = Calendar.current
            var bars: [TemporalBarData.ColumnMetric] = []
            
            var currentDate = range.start
            while currentDate <= range.end {
                let nextDate: Date
                switch granularity {
                case .day:
                    nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                case .week:
                    nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
                }
                
                let entryRequest = AdvancementRecord.fetchRequest()
                var predicates: [NSPredicate] = [
                    NSPredicate(format: "temporalEventMoment >= %@ AND temporalEventMoment < %@", currentDate as NSDate, nextDate as NSDate)
                ]
                
                if case .sphere(let sphereId) = scope {
                    predicates.append(NSPredicate(format: "cosmicSphereLink.zephyrId == %@", sphereId as CVarArg))
                }
                
                entryRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                
                let entries = try self.context.fetch(entryRequest)
                
                let pairsCompleted = entries.filter { entry in
                    let photos = (entry.spectrumImageFragments?.allObjects as? [ImageRecord]) ?? []
                    let hasBefore = photos.contains { $0.dimensionalRoleTag == 0 }
                    let hasAfter = photos.contains { $0.dimensionalRoleTag == 1 }
                    return hasBefore && hasAfter
                }.count
                
                let beforeOnly = entries.filter { entry in
                    let photos = (entry.spectrumImageFragments?.allObjects as? [ImageRecord]) ?? []
                    let hasBefore = photos.contains { $0.dimensionalRoleTag == 0 }
                    let hasAfter = photos.contains { $0.dimensionalRoleTag == 1 }
                    return hasBefore && !hasAfter
                }.count
                
                let stagesAdded = entries.filter { $0.morphicTypeValue == 1 }.count
                
                let milestoneRequest = AchievementRecord.fetchRequest()
                var milestonePredicates: [NSPredicate] = [
                    NSPredicate(format: "temporalAchievementDate >= %@ AND temporalAchievementDate < %@", currentDate as NSDate, nextDate as NSDate)
                ]
                if case .sphere(let sphereId) = scope {
                    milestonePredicates.append(NSPredicate(format: "cosmicSphereAnchor.zephyrId == %@", sphereId as CVarArg))
                }
                milestoneRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: milestonePredicates)
                let milestonesCount = try self.context.count(for: milestoneRequest)
                
                let value = pairsCompleted * 3 + beforeOnly * 1 + stagesAdded * 1 + milestonesCount * 2
                
                bars.append(TemporalBarData.ColumnMetric(
                    date: currentDate,
                    value: value,
                    breakdown: TemporalBarData.ColumnMetric.Breakdown(
                        beforeAfterPairsCompleted: pairsCompleted,
                        beforeOnlyCreated: beforeOnly,
                        stagesAdded: stagesAdded,
                        milestonesAdded: milestonesCount
                    ),
                    isHighlighted: false
                ))
                
                currentDate = nextDate
            }
            
            let series = TemporalBarData.BarSeries(
                id: "main",
                title: "Progress Activity",
                bars: bars,
                accessibilityLabel: "Progress activity over time"
            )
            
            return TemporalBarData(
                meta: MetaChartInfo(title: "Activity Timeline", subtitle: nil, updatedAt: Date()),
                range: range,
                granularity: granularity,
                series: [series],
                emptyState: bars.isEmpty ? VoidEmptyState(title: "No activity in this period", subtitle: nil, ctaTitle: "Add Improvement", ctaAction: nil) : nil
            )
        }
    }
    
    func computeTimelineDataset(range: ChronoTimeRange, scope: AnalyticsScope) async throws -> ChronicleTimelineData {
        try await context.perform {
            let entryRequest = AdvancementRecord.fetchRequest()
            var predicates: [NSPredicate] = [
                NSPredicate(format: "temporalEventMoment >= %@ AND temporalEventMoment <= %@", range.start as NSDate, range.end as NSDate)
            ]
            
            if case .sphere(let sphereId) = scope {
                predicates.append(NSPredicate(format: "cosmicSphereLink.zephyrId == %@", sphereId as CVarArg))
            }
            
            entryRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            entryRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AdvancementRecord.temporalEventMoment, ascending: false)]
            
            let entries = try self.context.fetch(entryRequest)
            
            let items: [ChronicleTimelineData.TimelineItem] = entries.compactMap { entry in
                guard let id = entry.zephyrId,
                      let sphereId = entry.cosmicSphereLink?.zephyrId,
                      let sphereTitle = entry.cosmicSphereLink?.nebulaTitleText,
                      let eventDate = entry.temporalEventMoment else {
                    return nil
                }
                
                let photos = (entry.spectrumImageFragments?.allObjects as? [ImageRecord]) ?? []
                let hasBefore = photos.contains { $0.dimensionalRoleTag == 0 }
                let hasAfter = photos.contains { $0.dimensionalRoleTag == 1 }
                
                let type: ChronicleTimelineData.TimelineItem.ItemType
                if entry.morphicTypeValue == 1 {
                    type = .stagesUpdate
                } else if hasBefore && hasAfter {
                    type = .beforeAfterCompleted
                } else {
                    type = .beforeOnly
                }
                
                let previewPath = photos.sorted { $0.sequentialOrderIndex < $1.sequentialOrderIndex }.first?.vortexStoragePath
                
                return ChronicleTimelineData.TimelineItem(
                    id: id,
                    date: eventDate,
                    sphereId: sphereId,
                    sphereTitle: sphereTitle,
                    type: type,
                    title: entry.prismaticTitleText,
                    previewPhotoPath: previewPath,
                    accessibilityLabel: "\(sphereTitle) - \(entry.prismaticTitleText ?? "Progress update")"
                )
            }
            
            return ChronicleTimelineData(
                meta: MetaChartInfo(title: "Timeline", subtitle: nil, updatedAt: Date()),
                range: range,
                items: items,
                emptyState: items.isEmpty ? VoidEmptyState(title: "No progress in this timeline", subtitle: nil, ctaTitle: "Add Improvement", ctaAction: nil) : nil
            )
        }
    }
}

