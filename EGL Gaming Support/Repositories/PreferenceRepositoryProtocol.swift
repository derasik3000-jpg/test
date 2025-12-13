import Foundation

protocol GamingPreferenceRepositoryProtocol {
    func update(_ draft: GamingPreferenceDraft) throws -> GamingPreference
    func get() -> GamingPreference
}

