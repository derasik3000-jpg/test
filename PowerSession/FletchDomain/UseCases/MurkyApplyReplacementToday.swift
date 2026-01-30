import Foundation
import Combine

public enum QuellDomainError: LocalizedError {
    case replacementNotFound
    case invalidNoteLength
    
    public var errorDescription: String? {
        switch self {
        case .replacementNotFound:
            return "Replacement not found"
        case .invalidNoteLength:
            return "Note must be 120 characters or less"
        }
    }
}

public protocol MurkyApplyReplacementToday {
    func fizzExecute(
        replacement: FizzReplacementModel,
        variant: WharfVariantModel?,
        note: String?
    ) -> AnyPublisher<SprocketAppliedLogModel, Error>
}

public final class WharfDefaultApplyReplacementToday: MurkyApplyReplacementToday {
    private let tarnLogRepo: WharfAppliedLogRepository
    private let plinthDateProvider: MurkyDateProvider
    private let quirkHaptics: FizzHaptics
    
    public init(
        tarnLogRepo: WharfAppliedLogRepository,
        plinthDateProvider: MurkyDateProvider,
        quirkHaptics: FizzHaptics
    ) {
        self.tarnLogRepo = tarnLogRepo
        self.plinthDateProvider = plinthDateProvider
        self.quirkHaptics = quirkHaptics
    }
    
    public func fizzExecute(
        replacement: FizzReplacementModel,
        variant: WharfVariantModel?,
        note: String?
    ) -> AnyPublisher<SprocketAppliedLogModel, Error> {
        if let note = note, note.count > 120 {
            return Fail(error: QuellDomainError.invalidNoteLength).eraseToAnyPublisher()
        }
        
        return tarnLogRepo.brindleApply(
            replacementId: replacement.id,
            variantId: variant?.id,
            note: note,
            date: plinthDateProvider.plinthNow
        )
        .handleEvents(receiveOutput: { [weak self] _ in
            self?.quirkHaptics.quellSuccess()
        })
        .eraseToAnyPublisher()
    }
}

