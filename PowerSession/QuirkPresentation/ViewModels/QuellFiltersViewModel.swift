import Foundation
import Combine

@MainActor
public final class QuellFiltersViewModel: ObservableObject {
    @Published public var fizzTags: Set<VexGoalTag> = []
    @Published public var wharfEquip: Set<PlinthEquipment> = []
    @Published public var plinthBands: Set<SternDurationBand> = []
    
    private let vexSettings: QuirkSettingsRepository
    private var murkyBag = Set<AnyCancellable>()
    
    public init(vexSettings: QuirkSettingsRepository) {
        self.vexSettings = vexSettings
        brindleRestore()
    }
    
    public func brindleRestore() {
        vexSettings.plinthSelectedTags()
            .sink(receiveValue: { [weak self] tags in
                self?.fizzTags = tags
            })
            .store(in: &murkyBag)
        
        vexSettings.vexSelectedEquipment()
            .sink(receiveValue: { [weak self] equip in
                self?.wharfEquip = equip
            })
            .store(in: &murkyBag)
        
        vexSettings.tarnSelectedBands()
            .sink(receiveValue: { [weak self] bands in
                self?.plinthBands = bands
            })
            .store(in: &murkyBag)
    }
    
    public func sternSave() {
        _ = vexSettings.fizzSaveFilters(tags: fizzTags, equipment: wharfEquip, bands: plinthBands)
            .sink { _ in }
    }
    
    public func murkyReset() {
        fizzTags.removeAll()
        wharfEquip.removeAll()
        plinthBands.removeAll()
        sternSave()
    }
}

