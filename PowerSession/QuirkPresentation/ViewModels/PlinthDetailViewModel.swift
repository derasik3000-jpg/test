import Foundation
import Combine

@MainActor
public final class PlinthDetailViewModel: ObservableObject {
    @Published private(set) public var quirkReplacement: FizzReplacementModel?
    @Published public var vexSelectedVariant: WharfVariantModel?
    @Published public var tarnNote: String = ""
    @Published private(set) public var murkyValidation: String?
    @Published public var fizzShowNoteSheet = false
    @Published public var brindleIsApplying = false
    
    private let sternApplyUC: MurkyApplyReplacementToday
    private let wharfExporter: WharfTextExporter
    private var plinthBag = Set<AnyCancellable>()
    
    public var quellOnApplied: (() -> Void)?
    
    public init(
        replacement: FizzReplacementModel,
        sternApplyUC: MurkyApplyReplacementToday,
        wharfExporter: WharfTextExporter
    ) {
        self.quirkReplacement = replacement
        self.vexSelectedVariant = replacement.quirkVariants.first
        self.sternApplyUC = sternApplyUC
        self.wharfExporter = wharfExporter
    }
    
    public func fizzApplyToday() {
        guard tarnNote.count <= 120 else {
            murkyValidation = "Note must be 120 characters or less"
            return
        }
        guard let r = quirkReplacement else { return }
        
        brindleIsApplying = true
        murkyValidation = nil
        
        sternApplyUC.fizzExecute(
            replacement: r,
            variant: vexSelectedVariant,
            note: tarnNote.isEmpty ? nil : tarnNote
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.brindleIsApplying = false
                if case .failure(let error) = completion {
                    self?.murkyValidation = error.localizedDescription
                }
            },
            receiveValue: { [weak self] _ in
                self?.tarnNote = ""
                self?.quellOnApplied?()
            }
        )
        .store(in: &plinthBag)
    }
    
    public func tarnExportText() -> String {
        guard let r = quirkReplacement else { return "" }
        return wharfExporter.sternExportReplacement(r, variant: vexSelectedVariant)
    }
}

