import Foundation
import Combine

@MainActor
final class BlueprintViewModel: ObservableObject {
    @Published var selectedBlueprint: TaperBlueprint
    @Published var customRate: Int = 20
    @Published private(set) var activeBlueprint: TaperBlueprint?
    
    private let bounceVault: BounceVaultProtocol
    private let haptics: TouchFeedback
    var cancellables = Set<AnyCancellable>()
    
    let presets: [TaperBlueprint] = [
        TaperBlueprint(reductionRate: 15, cutbackStyle: .volume, label: "Mild –15%"),
        TaperBlueprint(reductionRate: 20, cutbackStyle: .volume, label: "Standard –20%"),
        TaperBlueprint(reductionRate: 25, cutbackStyle: .volume, label: "Deep –25%")
    ]
    
    init(bounceVault: BounceVaultProtocol, haptics: TouchFeedback) {
        self.bounceVault = bounceVault
        self.haptics = haptics
        self.selectedBlueprint = presets[1]
        
        loadActiveBlueprint()
    }
    
    func loadActiveBlueprint() {
        bounceVault.fetchActivePlan()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] blueprint in
                self?.activeBlueprint = blueprint ?? self?.presets[1]
                self?.selectedBlueprint = blueprint ?? self?.presets[1] ?? TaperBlueprint()
            })
            .store(in: &cancellables)
    }
    
    func applyBlueprint(_ blueprint: TaperBlueprint, completion: @escaping () -> Void) {
        haptics.tapSelection()
        
        bounceVault.storePlan(blueprint)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] saved in
                    guard let self = self else { return }
                    self.activeBlueprint = saved
                    // Recompute current week's sessions immediately so changes are visible
                    let anchor = self.bounceVault.anchorForCycle(at: Date())
                    self.bounceVault.recomputeBlueprint(cycleKickoff: anchor, blueprint: saved)
                        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                        .store(in: &self.cancellables)
                    
                    self.haptics.tapSuccess()
                    completion()
                }
            )
            .store(in: &cancellables)
    }
    
    func createCustomBlueprint(rate: Int, style: CutbackStyle) -> TaperBlueprint {
        TaperBlueprint(reductionRate: rate, cutbackStyle: style, label: "Custom –\(rate)%")
    }
}

