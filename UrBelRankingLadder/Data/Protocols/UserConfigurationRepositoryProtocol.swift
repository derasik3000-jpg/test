import Foundation

protocol UserConfigurationRepositoryProtocol {
    func loadConfiguration() async throws -> UserConfigurationDTO
    func saveConfiguration(_ configData: UserConfigurationDTO) async throws
}

