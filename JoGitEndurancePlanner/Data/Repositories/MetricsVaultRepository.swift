import Foundation
import CoreData
import Combine

final class MetricsVaultRepository: MetricsVaultProtocol {
    private let coordinator: PersistenceCoordinator
    private let bounceVault: BounceVaultProtocol
    
    init(coordinator: PersistenceCoordinator = .shared, bounceVault: BounceVaultProtocol) {
        self.coordinator = coordinator
        self.bounceVault = bounceVault
    }
    
    func cycleTargetActual(cycleKickoff: Date) -> AnyPublisher<CycleTargetActualRingData, Error> {
        bounceVault.fetchWorkouts(cycleKickoff: cycleKickoff)
            .map { [weak self] workouts -> CycleTargetActualRingData in
                guard let self = self else {
                    return CycleTargetActualRingData(targetRate: 20, achievedRate: 0, segments: [], verdictText: "")
                }
                
                let completed = workouts.filter { $0.markedComplete }
                guard !completed.isEmpty else {
                    return CycleTargetActualRingData(
                        targetRate: 20,
                        achievedRate: 0,
                        segments: [],
                        verdictText: "No workouts completed"
                    )
                }
                
                let totalPlan = completed.reduce(0) { $0 + $1.scheduledDuration }
                let totalReduced = completed.reduce(0) { $0 + $1.adjustedDuration }
                
                let actualRate = totalPlan > 0 ? Int(round((1.0 - Double(totalReduced) / Double(totalPlan)) * 100.0)) : 0
                let targetRate = 20
                
                let verdict: String
                let diff = abs(actualRate - targetRate)
                if diff <= 3 {
                    verdict = "On Target"
                } else if actualRate < targetRate - 3 {
                    verdict = "Shortfall"
                } else {
                    verdict = "Over-Reduced"
                }
                
                let segments = [
                    SegmentInfo(caption: "Target", magnitude: Double(targetRate), fraction: Double(targetRate) / 100.0, tint: "#9DB3CF", fillPattern: 0),
                    SegmentInfo(caption: "Actual", magnitude: Double(actualRate), fraction: Double(actualRate) / 100.0, tint: "#0EBAEF", fillPattern: 0)
                ]
                
                return CycleTargetActualRingData(
                    targetRate: targetRate,
                    achievedRate: actualRate,
                    segments: segments,
                    verdictText: verdict
                )
            }.eraseToAnyPublisher()
    }
    
    func styleDivision(cycleKickoff: Date) -> AnyPublisher<StyleDivisionRingData, Error> {
        bounceVault.fetchWorkouts(cycleKickoff: cycleKickoff)
            .map { workouts -> StyleDivisionRingData in
                let volumeCount = workouts.filter { $0.scheduledDuration != $0.adjustedDuration }.count
                let intensityCount = workouts.filter { $0.effortMarker != $0.easedEffortMarker || $0.repeatsCount != $0.easedRepeatsCount }.count
                
                let total = volumeCount + intensityCount
                guard total > 0 else {
                    return StyleDivisionRingData(segments: [], explanation: "No reductions applied")
                }
                
                let segments = [
                    SegmentInfo(caption: "Volume", magnitude: Double(volumeCount), fraction: Double(volumeCount) / Double(total), tint: "#0EBAEF", fillPattern: 0),
                    SegmentInfo(caption: "Intensity", magnitude: Double(intensityCount), fraction: Double(intensityCount) / Double(total), tint: "#2EC27E", fillPattern: 0)
                ]
                
                return StyleDivisionRingData(
                    segments: segments,
                    explanation: "Volume counts minute reductions; Intensity counts effort/reps changes"
                )
            }.eraseToAnyPublisher()
    }
    
    func cycleBars(cycleKickoff: Date) -> AnyPublisher<CycleBarsSnapshot, Error> {
        bounceVault.fetchWorkouts(cycleKickoff: cycleKickoff)
            .map { workouts -> CycleBarsSnapshot in
                var dayRecords: [Int: (planned: Int, eased: Int, completed: Int, hasAny: Bool)] = [:]
                
                for workout in workouts {
                    let idx = workout.slotIndex
                    let current = dayRecords[idx] ?? (0, 0, 0, false)
                    dayRecords[idx] = (
                        current.planned + workout.scheduledDuration,
                        current.eased + workout.adjustedDuration,
                        current.completed + (workout.markedComplete ? workout.adjustedDuration : 0),
                        current.hasAny || workout.markedComplete
                    )
                }
                
                let records = (0..<7).map { idx -> SlotBarRecord in
                    let data = dayRecords[idx] ?? (0, 0, 0, false)
                    let dropRate = data.planned > 0 ? Int(round((1.0 - Double(data.eased) / Double(data.planned)) * 100.0)) : 0
                    return SlotBarRecord(
                        slotIndex: idx,
                        plannedTime: data.planned,
                        easedTime: data.eased,
                        completedTime: data.completed,
                        dropRate: dropRate,
                        hasCompletion: data.hasAny
                    )
                }
                
                return CycleBarsSnapshot(records: records)
            }.eraseToAnyPublisher()
    }
    
    func cycleFinishBars(cycleKickoff: Date) -> AnyPublisher<CycleFinishBarsSnapshot, Error> {
        bounceVault.fetchWorkouts(cycleKickoff: cycleKickoff)
            .map { workouts -> CycleFinishBarsSnapshot in
                var dayCounts: [Int: (total: Int, done: Int)] = [:]
                
                for workout in workouts {
                    let idx = workout.slotIndex
                    let current = dayCounts[idx] ?? (0, 0)
                    dayCounts[idx] = (current.total + 1, current.done + (workout.markedComplete ? 1 : 0))
                }
                
                let records = (0..<7).map { idx -> SlotFinishBarRecord in
                    let data = dayCounts[idx] ?? (0, 0)
                    return SlotFinishBarRecord(slotIndex: idx, totalCount: data.total, finishedCount: data.done)
                }
                
                return CycleFinishBarsSnapshot(records: records)
            }.eraseToAnyPublisher()
    }
    
    func trendTimeline(lastCount: Int, upTo: Date) -> AnyPublisher<TrendTimelineSnapshot, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "MetricsVault", code: -1)))
                return
            }
            
            let request: NSFetchRequest<DeloadWeek> = DeloadWeek.fetchRequest()
            request.predicate = NSPredicate(format: "weekStart <= %@", upTo as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "weekStart", ascending: false)]
            request.fetchLimit = lastCount
            
            do {
                let weeks = try self.coordinator.context.fetch(request)
                var markers: [TrendMarker] = []
                
                for week in weeks {
                    let sessionsRequest: NSFetchRequest<DeloadSession> = DeloadSession.fetchRequest()
                    sessionsRequest.predicate = NSPredicate(format: "week == %@", week)
                    let sessions = try self.coordinator.context.fetch(sessionsRequest)
                    
                    let completed = sessions.filter { $0.isDone }
                    let totalPlan = completed.reduce(0) { $0 + Int($1.planMinutes) }
                    let totalReduced = completed.reduce(0) { $0 + Int($1.reducedMinutes) }
                    
                    let actualRate = totalPlan > 0 ? Int(round((1.0 - Double(totalReduced) / Double(totalPlan)) * 100.0)) : 0
                    let targetRate = Int(week.targetPercent)
                    
                    let verdict: String
                    let diff = abs(actualRate - targetRate)
                    if diff <= 3 {
                        verdict = "On Target"
                    } else if actualRate < targetRate - 3 {
                        verdict = "Shortfall"
                    } else {
                        verdict = "Over"
                    }
                    
                    markers.append(TrendMarker(
                        cycleKickoff: week.weekStart ?? Date(),
                        targetRate: targetRate,
                        achievedRate: actualRate,
                        verdictLabel: verdict
                    ))
                }
                
                promise(.success(TrendTimelineSnapshot(markers: markers.reversed())))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func offTrackGrid(cycleKickoff: Date) -> AnyPublisher<OffTrackGridSnapshot, Error> {
        bounceVault.fetchWorkouts(cycleKickoff: cycleKickoff)
            .map { workouts -> OffTrackGridSnapshot in
                var dayData: [Int: (planned: Int, eased: Int, actual: Int)] = [:]
                
                for workout in workouts {
                    let idx = workout.slotIndex
                    let current = dayData[idx] ?? (0, 0, 0)
                    dayData[idx] = (
                        current.planned + workout.scheduledDuration,
                        current.eased + workout.adjustedDuration,
                        current.actual + (workout.markedComplete ? workout.adjustedDuration : 0)
                    )
                }
                
                var rows: [OffTrackSlotRow] = []
                
                for (idx, data) in dayData.sorted(by: { $0.key < $1.key }) {
                    let targetRate = 20
                    let actualRate = data.planned > 0 ? Int(round((1.0 - Double(data.eased) / Double(data.planned)) * 100.0)) : 0
                    let diff = abs(actualRate - targetRate)
                    
                    if diff > 3 {
                        let suggestion: String
                        if actualRate < targetRate {
                            suggestion = "Add \(targetRate - actualRate)% more reduction"
                        } else {
                            suggestion = "Reduce by \(actualRate - targetRate)% less"
                        }
                        
                        rows.append(OffTrackSlotRow(
                            slotIndex: idx,
                            plannedTime: data.planned,
                            easedTime: data.eased,
                            actualRate: actualRate,
                            suggestion: suggestion
                        ))
                    }
                }
                
                return OffTrackGridSnapshot(rows: rows)
            }.eraseToAnyPublisher()
    }
}

