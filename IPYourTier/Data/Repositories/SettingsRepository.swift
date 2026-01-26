import Foundation

public protocol SettingsRepository {
    func load() -> PreferenceSnapshot
    func save(_ settings: PreferenceSnapshot)
}

