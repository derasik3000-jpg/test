import Foundation
import Combine

protocol BounceVaultProtocol {
    func fetchActivePlan() -> AnyPublisher<TaperBlueprint?, Never>
    func storePlan(_ plan: TaperBlueprint) -> AnyPublisher<TaperBlueprint, Error>
    
    func anchorForCycle(at date: Date) -> Date
    func retrieveOrBuildCycle(kickoff: Date, blueprint: TaperBlueprint) -> AnyPublisher<SpanCycleModel, Error>
    func finalizeCycle(_ cycleId: UUID, digest: CycleDigest?) -> AnyPublisher<Void, Error>
    
    func fetchWorkouts(cycleKickoff: Date) -> AnyPublisher<[WorkoutEntryModel], Error>
    func insertWorkout(_ workout: WorkoutEntryModel, cycleKickoff: Date) -> AnyPublisher<WorkoutEntryModel, Error>
    func modifyWorkout(_ workout: WorkoutEntryModel) -> AnyPublisher<WorkoutEntryModel, Error>
    func eraseWorkout(_ id: UUID) -> AnyPublisher<Void, Error>
    func flipCompletion(_ id: UUID) -> AnyPublisher<WorkoutEntryModel, Error>
    
    func recomputeBlueprint(cycleKickoff: Date, blueprint: TaperBlueprint) -> AnyPublisher<[WorkoutEntryModel], Error>
}

protocol MetricsVaultProtocol {
    func cycleTargetActual(cycleKickoff: Date) -> AnyPublisher<CycleTargetActualRingData, Error>
    func styleDivision(cycleKickoff: Date) -> AnyPublisher<StyleDivisionRingData, Error>
    func cycleBars(cycleKickoff: Date) -> AnyPublisher<CycleBarsSnapshot, Error>
    func cycleFinishBars(cycleKickoff: Date) -> AnyPublisher<CycleFinishBarsSnapshot, Error>
    func trendTimeline(lastCount: Int, upTo: Date) -> AnyPublisher<TrendTimelineSnapshot, Error>
    func offTrackGrid(cycleKickoff: Date) -> AnyPublisher<OffTrackGridSnapshot, Error>
}

protocol ConfigVaultProtocol {
    func isHapticsOn() -> AnyPublisher<Bool, Never>
    func setHaptics(_ enabled: Bool) -> AnyPublisher<Void, Never>
}

protocol ClockProvider {
    var currentMoment: Date { get }
}

protocol TouchFeedback {
    func tapSelection()
    func tapSuccess()
    func tapWarning()
}

protocol PlainTextExporter {
    func buildExport(cycle: SpanCycleModel, digest: CycleDigest) -> String
}

