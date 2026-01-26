import SwiftUI
import Combine

public class CheckFlowVM: ObservableObject {
    public enum Stage {
        case start
        case question(index: Int, total: Int)
        case result(session: CheckSessionDTO)
    }
    
    @Published public var stage: Stage = .start
    @Published public var progress: Double = 0
    @Published public var selectedZone: ZoneDTO?
    
    @Published public var painMove: Int = 0
    @Published public var painRest: Bool = false
    @Published public var popSound: Bool = false
    @Published public var edema: Bool = false
    @Published public var heat: Bool = false
    @Published public var instability: Bool = false
    @Published public var romPercent: Int = 100
    @Published public var painNRS: Int = 0
    @Published public var morningStiffness: Bool = false
    @Published public var betterWithLoadReduction: Int = -1
    @Published public var symptomStart: Int = 0
    @Published public var redFlag: Bool = false
    
    private var currentSessionId: UUID?
    private let startUC: StartCheckUC
    private let updateUC: UpdateAnswerUC
    private let completeUC: CompleteCheckUC
    private let donutUC: BuildRiskDonutUC
    private let featureUC: BuildFeatureStackedUC
    
    public init(
        startUC: StartCheckUC,
        updateUC: UpdateAnswerUC,
        completeUC: CompleteCheckUC,
        donutUC: BuildRiskDonutUC,
        featureUC: BuildFeatureStackedUC
    ) {
        self.startUC = startUC
        self.updateUC = updateUC
        self.completeUC = completeUC
        self.donutUC = donutUC
        self.featureUC = featureUC
    }
    
    public func startCheck(zone: ZoneDTO) {
        print("🚀 ViewModel.startCheck CALLED with zone: \(zone.rawValue) \(zone.displayName)")
        print("📍 Current stage before: \(stage)")
        
        let session = startUC.performInvocation(zone: zone, now: Date())
        print("📦 Session created: \(session.id)")
        
        currentSessionId = session.id
        selectedZone = zone
        
        // Redundantly persist zone to avoid any default overrides
        let updated = updateUC.performInvocation(sessionId: session.id, key: "zone", value: zone.rawValue)
        print("✅ ViewModel.update zone persisted as: \(updated.zone.rawValue) \(updated.zone.displayName)")
        
        stage = .question(index: 1, total: 8)
        progress = 1.0 / 8.0
        
        print("📍 Current stage after: \(stage)")
        print("📊 Progress: \(progress)")
    }
    
    public func answerQuestion(index: Int) {
        guard let sessionId = currentSessionId else { return }
        
        switch index {
        case 1:
            _ = updateUC.performInvocation(sessionId: sessionId, key: "painMove", value: painMove)
        case 2:
            _ = updateUC.performInvocation(sessionId: sessionId, key: "painRest", value: painRest)
        case 3:
            _ = updateUC.performInvocation(sessionId: sessionId, key: "popSound", value: popSound)
        case 4:
            _ = updateUC.performInvocation(sessionId: sessionId, key: "edema", value: edema)
            _ = updateUC.performInvocation(sessionId: sessionId, key: "heat", value: heat)
            _ = updateUC.performInvocation(sessionId: sessionId, key: "instability", value: instability)
        case 5:
            _ = updateUC.performInvocation(sessionId: sessionId, key: "romPercent", value: romPercent)
        case 6:
            _ = updateUC.performInvocation(sessionId: sessionId, key: "painNRS", value: painNRS)
        case 7:
            _ = updateUC.performInvocation(sessionId: sessionId, key: "morningStiffness", value: morningStiffness)
            _ = updateUC.performInvocation(sessionId: sessionId, key: "betterWithLoadReduction", value: betterWithLoadReduction)
        case 8:
            _ = updateUC.performInvocation(sessionId: sessionId, key: "symptomStart", value: symptomStart)
        default:
            break
        }
        
        let nextIndex = index + 1
        if nextIndex > 8 {
            completeCheck()
        } else {
            stage = .question(index: nextIndex, total: 8)
            progress = Double(nextIndex) / 8.0
        }
    }
    
    public func previousQuestion(index: Int) {
        let prevIndex = index - 1
        if prevIndex < 1 {
            stage = .start
            progress = 0
        } else {
            stage = .question(index: prevIndex, total: 8)
            progress = Double(prevIndex) / 8.0
        }
    }
    
    private func completeCheck() {
        guard let sessionId = currentSessionId else { return }
        
        let completed = completeUC.performInvocation(sessionId: sessionId)
        stage = .result(session: completed)
    }
    
    public func riskDonut() -> RiskDonutModel? {
        guard let sessionId = currentSessionId else { return nil }
        return donutUC.performInvocation(sessionId: sessionId)
    }
    
    public func featureStack() -> FeatureStackedModel? {
        guard let sessionId = currentSessionId else { return nil }
        return featureUC.performInvocation(sessionId: sessionId)
    }
    
    public func reset() {
        stage = .start
        progress = 0
        currentSessionId = nil
        selectedZone = nil
        
        painMove = 0
        painRest = false
        popSound = false
        edema = false
        heat = false
        instability = false
        romPercent = 100
        painNRS = 0
        morningStiffness = false
        betterWithLoadReduction = -1
        symptomStart = 0
        redFlag = false
    }
}

