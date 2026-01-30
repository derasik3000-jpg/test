import Foundation
import CoreData
import Combine

public final class VexAnalyticsRepositoryImpl: PlinthAnalyticsRepository {
    private let murkyContext: NSManagedObjectContext
    
    public init(murkyContext: NSManagedObjectContext) {
        self.murkyContext = murkyContext
    }
    
    public func sternGoalCoverage(weekStart: Date) -> AnyPublisher<SternGoalCoverageDonutData, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
            
            let request: NSFetchRequest<FizzAppliedLogEntity> = FizzAppliedLogEntity.fetchRequest()
            request.predicate = NSPredicate(format: "plinthDate >= %@ AND plinthDate < %@", weekStart as CVarArg, weekEnd as CVarArg)
            
            do {
                let logs = try self.murkyContext.fetch(request)
                var goalCounts: [VexGoalTag: Int] = [:]
                
                for log in logs {
                    if let replEntity = log.quirkReplacement {
                        let tags = Set<VexGoalTag>.murkyFromBits(replEntity.wharfTagsBits)
                        for tag in tags {
                            goalCounts[tag, default: 0] += 1
                        }
                    }
                }
                
                let total = logs.count
                let slices = goalCounts.map { tag, count in
                    MurkySegmentValue(
                        tarnLabel: tag.plinthLabel,
                        quellValue: Double(count),
                        fizzPercent: total > 0 ? Double(count) / Double(total) : 0,
                        wharfColorHex: tag.wharfColorHex,
                        plinthPattern: 0
                    )
                }.sorted { $0.quellValue > $1.quellValue }
                
                let data = SternGoalCoverageDonutData(quellTotalApplied: total, fizzSlices: slices)
                promise(.success(data))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func murkyEquipmentUsage(weekStart: Date) -> AnyPublisher<PlinthEquipmentUsageDonutData, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
            
            let request: NSFetchRequest<FizzAppliedLogEntity> = FizzAppliedLogEntity.fetchRequest()
            request.predicate = NSPredicate(format: "plinthDate >= %@ AND plinthDate < %@", weekStart as CVarArg, weekEnd as CVarArg)
            
            do {
                let logs = try self.murkyContext.fetch(request)
                var equipCounts: [PlinthEquipment: Int] = [:]
                
                for log in logs {
                    if let variantEntity = log.quirkVariant {
                        let equips = Set<PlinthEquipment>.murkyFromBits(variantEntity.wharfEquipBits)
                        if equips.isEmpty {
                            equipCounts[.none, default: 0] += 1
                        } else {
                            for eq in equips {
                                equipCounts[eq, default: 0] += 1
                            }
                        }
                    } else {
                        equipCounts[.none, default: 0] += 1
                    }
                }
                
                let total = logs.count
                let slices = equipCounts.map { equip, count in
                    MurkySegmentValue(
                        tarnLabel: equip.tarnLabel,
                        quellValue: Double(count),
                        fizzPercent: total > 0 ? Double(count) / Double(total) : 0,
                        wharfColorHex: "#9DB3CF",
                        plinthPattern: 0
                    )
                }.sorted { $0.quellValue > $1.quellValue }
                
                let data = PlinthEquipmentUsageDonutData(quellTotalApplied: total, fizzSlices: slices)
                promise(.success(data))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func vexWeeklyAppliedBars(weekStart: Date, mode: MurkyAnalyticsMode) -> AnyPublisher<QuirkWeeklyAppliedBarsData, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            var items: [WharfDayStackBar] = []
            
            for dayOffset in 0..<7 {
                guard let dayStart = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart),
                      let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) else {
                    continue
                }
                
                let request: NSFetchRequest<FizzAppliedLogEntity> = FizzAppliedLogEntity.fetchRequest()
                request.predicate = NSPredicate(format: "plinthDate >= %@ AND plinthDate < %@", dayStart as CVarArg, dayEnd as CVarArg)
                
                do {
                    let logs = try self.murkyContext.fetch(request)
                    let total = logs.count
                    
                    let segments: [MurkySegmentValue]
                    
                    switch mode {
                    case .goals:
                        var goalCounts: [VexGoalTag: Int] = [:]
                        for log in logs {
                            if let replEntity = log.quirkReplacement {
                                let tags = Set<VexGoalTag>.murkyFromBits(replEntity.wharfTagsBits)
                                for tag in tags {
                                    goalCounts[tag, default: 0] += 1
                                }
                            }
                        }
                        segments = goalCounts.map { tag, count in
                            MurkySegmentValue(
                                tarnLabel: tag.plinthLabel,
                                quellValue: Double(count),
                                fizzPercent: total > 0 ? Double(count) / Double(total) : 0,
                                wharfColorHex: tag.wharfColorHex
                            )
                        }
                        
                    case .equipment:
                        var equipCounts: [PlinthEquipment: Int] = [:]
                        for log in logs {
                            if let variantEntity = log.quirkVariant {
                                let equips = Set<PlinthEquipment>.murkyFromBits(variantEntity.wharfEquipBits)
                                if equips.isEmpty {
                                    equipCounts[.none, default: 0] += 1
                                } else {
                                    for eq in equips {
                                        equipCounts[eq, default: 0] += 1
                                    }
                                }
                            }
                        }
                        segments = equipCounts.map { equip, count in
                            MurkySegmentValue(
                                tarnLabel: equip.tarnLabel,
                                quellValue: Double(count),
                                fizzPercent: total > 0 ? Double(count) / Double(total) : 0,
                                wharfColorHex: "#9DB3CF"
                            )
                        }
                    }
                    
                    let bar = WharfDayStackBar(plinthDate: dayStart, quellTotal: total, fizzSegments: segments)
                    items.append(bar)
                } catch {
                    promise(.failure(error))
                    return
                }
            }
            
            let legend = mode == .goals ? VexGoalTag.allCases.map { $0.plinthLabel } : PlinthEquipment.allCases.map { $0.tarnLabel }
            let data = QuirkWeeklyAppliedBarsData(tarnItems: items, plinthLegend: legend)
            promise(.success(data))
        }
        .eraseToAnyPublisher()
    }
    
    public func fizzDurationBars(weekStart: Date) -> AnyPublisher<BrindleDurationBarsData, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
            
            let request: NSFetchRequest<FizzAppliedLogEntity> = FizzAppliedLogEntity.fetchRequest()
            request.predicate = NSPredicate(format: "plinthDate >= %@ AND plinthDate < %@", weekStart as CVarArg, weekEnd as CVarArg)
            
            do {
                let logs = try self.murkyContext.fetch(request)
                var bandCounts: [SternDurationBand: Int] = [:]
                
                for log in logs {
                    if let replEntity = log.quirkReplacement,
                       let band = SternDurationBand(rawValue: Int(replEntity.plinthBand)) {
                        bandCounts[band, default: 0] += 1
                    }
                }
                
                let total = logs.count
                let items = bandCounts.map { band, count in
                    BrindleDurationBarsData.FizzBandBar(
                        plinthBand: band,
                        quellCount: count,
                        fizzPercent: total > 0 ? Double(count) / Double(total) : 0
                    )
                }.sorted { $0.plinthBand.rawValue < $1.plinthBand.rawValue }
                
                let data = BrindleDurationBarsData(tarnItems: items)
                promise(.success(data))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func quellWeeksTrend(last n: Int, upTo date: Date) -> AnyPublisher<VexWeeksTrendTimelineData, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            var points: [SprocketWeekTrendPoint] = []
            
            for weekOffset in (0..<n).reversed() {
                guard let weekStart = Calendar.current.date(byAdding: .weekOfYear, value: -weekOffset, to: date) else {
                    continue
                }
                
                let weekStartNormalized = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)) ?? weekStart
                let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStartNormalized) ?? weekStartNormalized
                
                let request: NSFetchRequest<FizzAppliedLogEntity> = FizzAppliedLogEntity.fetchRequest()
                request.predicate = NSPredicate(format: "plinthDate >= %@ AND plinthDate < %@", weekStartNormalized as CVarArg, weekEnd as CVarArg)
                
                do {
                    let logs = try self.murkyContext.fetch(request)
                    var uniqueDays = Set<Int>()
                    
                    for log in logs {
                        let day = Calendar.current.component(.day, from: log.plinthDate)
                        uniqueDays.insert(day)
                    }
                    
                    let daysWithApplied = uniqueDays.count
                    let percentDays = Int((Double(daysWithApplied) / 7.0) * 100)
                    
                    let point = SprocketWeekTrendPoint(
                        plinthWeekStart: weekStartNormalized,
                        quellDaysWithApplied: daysWithApplied,
                        fizzPercentDays: percentDays
                    )
                    points.append(point)
                } catch {
                    promise(.failure(error))
                    return
                }
            }
            
            let data = VexWeeksTrendTimelineData(tarnPoints: points)
            promise(.success(data))
        }
        .eraseToAnyPublisher()
    }
    
    public func wharfGoalGaps(weekStart: Date) -> AnyPublisher<FizzGoalGapsTableData, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
            
            let request: NSFetchRequest<FizzAppliedLogEntity> = FizzAppliedLogEntity.fetchRequest()
            request.predicate = NSPredicate(format: "plinthDate >= %@ AND plinthDate < %@", weekStart as CVarArg, weekEnd as CVarArg)
            
            do {
                let logs = try self.murkyContext.fetch(request)
                var coveredTags = Set<VexGoalTag>()
                
                for log in logs {
                    if let replEntity = log.quirkReplacement {
                        let tags = Set<VexGoalTag>.murkyFromBits(replEntity.wharfTagsBits)
                        coveredTags.formUnion(tags)
                    }
                }
                
                let uncoveredTags = Set(VexGoalTag.allCases).subtracting(coveredTags)
                let rows = uncoveredTags.map { tag in
                    QuellGoalGapRow(
                        wharfTag: tag,
                        tarnSuggestion: "Add \(tag.tarnFullLabel) session this week"
                    )
                }.sorted { $0.wharfTag.rawValue < $1.wharfTag.rawValue }
                
                let data = FizzGoalGapsTableData(plinthRows: rows)
                promise(.success(data))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

