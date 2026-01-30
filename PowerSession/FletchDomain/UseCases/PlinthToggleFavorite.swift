import Foundation
import Combine

public protocol PlinthToggleFavorite {
    func vexExecute(replacementId: UUID) -> AnyPublisher<FizzReplacementModel, Error>
}

public final class SternDefaultToggleFavorite: PlinthToggleFavorite {
    private let quirkRepo: SternReplacementRepository
    private let tarnHaptics: FizzHaptics
    
    public init(quirkRepo: SternReplacementRepository, tarnHaptics: FizzHaptics) {
        self.quirkRepo = quirkRepo
        self.tarnHaptics = tarnHaptics
    }
    
    public func vexExecute(replacementId: UUID) -> AnyPublisher<FizzReplacementModel, Error> {
        quirkRepo.quirkToggleFavorite(replacementId)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.tarnHaptics.tarnSelection()
            })
            .eraseToAnyPublisher()
    }
}

