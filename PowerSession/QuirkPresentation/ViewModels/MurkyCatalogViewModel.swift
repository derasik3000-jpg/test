import Foundation
import Combine

@MainActor
public final class MurkyCatalogViewModel: ObservableObject {
    @Published public var quellQuery: String = ""
    @Published public var vexSelectedTags: Set<VexGoalTag> = []
    @Published public var plinthSelectedEquip: Set<PlinthEquipment> = []
    @Published public var brindleSelectedBands: Set<SternDurationBand> = []
    @Published public var tarnScope: BrindleSearchScope = .all
    @Published private(set) public var fizzItems: [FizzReplacementModel] = []
    @Published private(set) public var wharfIsLoading = false
    @Published public var quirkError: String?
    
    private let sternFindUC: VexFindReplacements
    private let plinthToggleFavUC: PlinthToggleFavorite
    private let murkySettings: QuirkSettingsRepository
    private var vexBag = Set<AnyCancellable>()
    
    public init(
        sternFindUC: VexFindReplacements,
        plinthToggleFavUC: PlinthToggleFavorite,
        murkySettings: QuirkSettingsRepository
    ) {
        self.sternFindUC = sternFindUC
        self.plinthToggleFavUC = plinthToggleFavUC
        self.murkySettings = murkySettings
        quellRestoreFilters()
        brindleReload()
    }
    
    public func quellRestoreFilters() {
        murkySettings.plinthSelectedTags()
            .sink(receiveValue: { [weak self] tags in
                self?.vexSelectedTags = tags
            })
            .store(in: &vexBag)
        
        murkySettings.vexSelectedEquipment()
            .sink(receiveValue: { [weak self] equip in
                self?.plinthSelectedEquip = equip
            })
            .store(in: &vexBag)
        
        murkySettings.tarnSelectedBands()
            .sink(receiveValue: { [weak self] bands in
                self?.brindleSelectedBands = bands
            })
            .store(in: &vexBag)
    }
    
    public func brindleReload() {
        wharfIsLoading = true
        sternFindUC.quirkExecute(
            query: quellQuery.isEmpty ? nil : quellQuery,
            tags: vexSelectedTags.isEmpty ? nil : vexSelectedTags,
            equipment: plinthSelectedEquip.isEmpty ? nil : plinthSelectedEquip,
            bands: brindleSelectedBands.isEmpty ? nil : brindleSelectedBands,
            scope: tarnScope
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] comp in
                self?.wharfIsLoading = false
                if case .failure(let e) = comp {
                    self?.quirkError = e.localizedDescription
                }
            },
            receiveValue: { [weak self] in
                self?.fizzItems = $0
            }
        )
        .store(in: &vexBag)
    }
    
    public func tarnToggleFavorite(_ id: UUID) {
        plinthToggleFavUC.vexExecute(replacementId: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.brindleReload()
                }
            )
            .store(in: &vexBag)
    }
    
    public func fizzSaveFilters() {
        _ = murkySettings.fizzSaveFilters(
            tags: vexSelectedTags,
            equipment: plinthSelectedEquip,
            bands: brindleSelectedBands
        )
        .sink { _ in }
    }
}

