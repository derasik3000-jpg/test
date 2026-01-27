import Foundation
import Combine

@MainActor
final class SpanViewModel: ObservableObject {
    @Published private(set) var currentCycle: SpanCycleModel?
    @Published private(set) var workouts: [WorkoutEntryModel] = []
    @Published private(set) var ringData: CycleTargetActualRingData?
    @Published private(set) var barsData: CycleBarsSnapshot?
    @Published private(set) var finishBarsData: CycleFinishBarsSnapshot?
    @Published private(set) var offTrackData: OffTrackGridSnapshot?
    @Published private(set) var isLoading = false
    @Published private(set) var isMetricsLoading = false
    @Published private(set) var isInitialLoadComplete = false
    @Published var showingAddWorkout = false
    @Published var errorMessage: String?
    
    private let bounceVault: BounceVaultProtocol
    private let metricsVault: MetricsVaultProtocol
    private let clockProvider: ClockProvider
    private let haptics: TouchFeedback
    private var cancellables = Set<AnyCancellable>()
    
    init(bounceVault: BounceVaultProtocol, metricsVault: MetricsVaultProtocol, clockProvider: ClockProvider, haptics: TouchFeedback) {
        self.bounceVault = bounceVault
        self.metricsVault = metricsVault
        self.clockProvider = clockProvider
        self.haptics = haptics
    }
    
    func loadActiveCycle() {
        guard !isLoading else { return }
        isLoading = true
        print("loadActiveCycle: Starting")
        let anchor = bounceVault.anchorForCycle(at: clockProvider.currentMoment)
        print("loadActiveCycle: Anchor date = \(anchor)")
        
        bounceVault.fetchActivePlan()
            .flatMap { [weak self] blueprint -> AnyPublisher<SpanCycleModel, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "SpanVM", code: -1)).eraseToAnyPublisher()
                }
                let plan = blueprint ?? TaperBlueprint(reductionRate: 20, cutbackStyle: .volume)
                print("loadActiveCycle: Using blueprint \(plan.reductionRate)%")
                return self.bounceVault.retrieveOrBuildCycle(kickoff: anchor, blueprint: plan)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.isLoading = false
                        self?.isInitialLoadComplete = true
                        print("loadActiveCycle error: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] cycle in
                    guard let self = self else { return }
                    print("loadActiveCycle: Successfully loaded cycle \(cycle.id)")
                    self.loadAllDataBatch(for: cycle)
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadAllDataBatch(for cycle: SpanCycleModel) {
        let workoutsPublisher = bounceVault.fetchWorkouts(cycleKickoff: cycle.kickoff)
        let ringPublisher = metricsVault.cycleTargetActual(cycleKickoff: cycle.kickoff)
        let barsPublisher = metricsVault.cycleBars(cycleKickoff: cycle.kickoff)
        let finishBarsPublisher = metricsVault.cycleFinishBars(cycleKickoff: cycle.kickoff)
        let offTrackPublisher = metricsVault.offTrackGrid(cycleKickoff: cycle.kickoff)
        
        Publishers.Zip4(
            workoutsPublisher,
            ringPublisher,
            barsPublisher,
            Publishers.Zip(finishBarsPublisher, offTrackPublisher)
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("loadAllDataBatch error: \(error.localizedDescription)")
                }
                self?.isLoading = false
                self?.isMetricsLoading = false
                self?.isInitialLoadComplete = true
            },
            receiveValue: { [weak self] workouts, ring, bars, finishAndOffTrack in
                guard let self = self else { return }
                let (finishBars, offTrack) = finishAndOffTrack
                self.currentCycle = cycle
                self.workouts = workouts.sorted { $0.slotIndex < $1.slotIndex }
                self.ringData = ring
                self.barsData = bars
                self.finishBarsData = finishBars
                self.offTrackData = offTrack
                print("loadAllDataBatch: All data loaded, \(workouts.count) workouts")
            }
        )
        .store(in: &cancellables)
    }
    
    func refreshWorkouts() {
        guard let cycle = currentCycle else {
            print("refreshWorkouts: No current cycle")
            return
        }
        
        print("refreshWorkouts: Starting fetch for cycle \(cycle.kickoff)")
        
        bounceVault.fetchWorkouts(cycleKickoff: cycle.kickoff)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("refreshWorkouts error: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] workouts in
                    guard let self = self else { return }
                    print("refreshWorkouts: Received \(workouts.count) workouts")
                    
                    // Force UI update
                    self.objectWillChange.send()
                    
                    self.workouts = workouts.sorted { $0.slotIndex < $1.slotIndex }
                    print("refreshWorkouts: Updated workouts array, now has \(self.workouts.count) items")
                    print("refreshWorkouts: Workouts IDs: \(self.workouts.map { $0.id })")
                    
                    self.refreshMetrics()
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshMetrics() {
        guard let cycle = currentCycle else {
            return
        }
        
        class MetricsCounter {
            var completed: Set<String> = []
            let total: Set<String> = ["ring", "bars", "finish", "offTrack"]
            
            func checkComplete(_ metricId: String, onComplete: @escaping () -> Void) {
                completed.insert(metricId)
                if completed.count == total.count {
                    onComplete()
                }
            }
        }
        
        let counter = MetricsCounter()
        
        metricsVault.cycleTargetActual(cycleKickoff: cycle.kickoff)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in counter.checkComplete("ring") {} }, receiveValue: { [weak self] data in
                self?.ringData = data
            })
            .store(in: &cancellables)
        
        metricsVault.cycleBars(cycleKickoff: cycle.kickoff)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in counter.checkComplete("bars") {} }, receiveValue: { [weak self] data in
                self?.barsData = data
            })
            .store(in: &cancellables)
        
        metricsVault.cycleFinishBars(cycleKickoff: cycle.kickoff)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in counter.checkComplete("finish") {} }, receiveValue: { [weak self] data in
                self?.finishBarsData = data
            })
            .store(in: &cancellables)
        
        metricsVault.offTrackGrid(cycleKickoff: cycle.kickoff)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in counter.checkComplete("offTrack") {} }, receiveValue: { [weak self] data in
                self?.offTrackData = data
            })
            .store(in: &cancellables)
    }
    
    func toggleComplete(_ workoutId: UUID) {
        haptics.tapSelection()
        
        bounceVault.flipCompletion(workoutId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.refreshWorkouts()
                    self?.haptics.tapSuccess()
                }
            )
            .store(in: &cancellables)
    }
    
    func addWorkout(_ workout: WorkoutEntryModel) {
        guard let cycle = currentCycle else { return }
        
        bounceVault.insertWorkout(workout, cycleKickoff: cycle.kickoff)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        print("Error saving workout: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] savedWorkout in
                    guard let self = self else { return }
                    print("Workout saved successfully: \(savedWorkout.heading)")
                    
                    self.refreshWorkouts()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.showingAddWorkout = false
                        self.haptics.tapSuccess()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteWorkout(_ workoutId: UUID) {
        bounceVault.eraseWorkout(workoutId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.refreshWorkouts()
                }
            )
            .store(in: &cancellables)
    }
    
    func updateBlueprint(_ blueprint: TaperBlueprint) {
        guard let cycle = currentCycle else { return }
        
        bounceVault.recomputeBlueprint(cycleKickoff: cycle.kickoff, blueprint: blueprint)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.refreshWorkouts()
                }
            )
            .store(in: &cancellables)
    }
}

