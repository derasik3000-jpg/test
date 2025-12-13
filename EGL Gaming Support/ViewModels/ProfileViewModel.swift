import Foundation
import SwiftUI
import Combine

@MainActor
class GamingProfileViewModel: ObservableObject {
    @Published var preference: GamingPreference
    @Published var points: Int = 0
    @Published var isLoading: Bool = false
    @Published var allPhotos: [GamingRecord] = []
    
    private let preferenceRepository: GamingPreferenceRepositoryProtocol
    private let pointsCalculator: GamingPointsCalculator
    private let recordRepository: GamingRecordRepositoryProtocol?
    private let programRepository: GamingProgramRepositoryProtocol?
    
    init(
        preferenceRepository: GamingPreferenceRepositoryProtocol,
        pointsCalculator: GamingPointsCalculator,
        recordRepository: GamingRecordRepositoryProtocol? = nil,
        programRepository: GamingProgramRepositoryProtocol? = nil
    ) {
        self.preferenceRepository = preferenceRepository
        self.pointsCalculator = pointsCalculator
        self.recordRepository = recordRepository
        self.programRepository = programRepository
        self.preference = preferenceRepository.get()
    }
    
    func loadData() {
        isLoading = true
        preference = preferenceRepository.get()
        points = pointsCalculator.totalPoints()
        loadPhotos()
        isLoading = false
    }
    
    func loadPhotos() {
        guard let recordRepository = recordRepository else { return }
        allPhotos = recordRepository.active().filter { record in
            guard let imageData = record.imageData, !imageData.isEmpty else { return false }
            return true
        }
    }
    
    func allProgramPhotos() -> [GamingProgram] {
        guard let programRepository = programRepository else { return [] }
        return programRepository.active().filter { program in
            guard let imageData = program.imageData, !imageData.isEmpty else { return false }
            return true
        }
    }
    
    func updateIconColor(_ hex: String) throws {
        var draft = GamingPreferenceDraft(
            iconColorHex: hex,
            iconViewType: preference.iconViewType,
            lastExportDate: preference.lastExportDate
        )
        draft.iconColorHex = hex
        preference = try preferenceRepository.update(draft)
    }
    
    func updateIconViewType(_ type: String) throws {
        var draft = GamingPreferenceDraft(
            iconColorHex: preference.iconColorHex,
            iconViewType: type,
            lastExportDate: preference.lastExportDate
        )
        draft.iconViewType = type
        preference = try preferenceRepository.update(draft)
    }
    
    func getBadgeTier() -> String {
        if points >= 100 {
            return "Game Pro"
        } else if points >= 50 {
            return "Game Master"
        } else if points >= 25 {
            return "Gamer"
        } else {
            return "Beginner"
        }
    }
}

