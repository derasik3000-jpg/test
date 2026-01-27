import Foundation
import Combine

protocol UserProfileRepositoryProtocol {
    func loadProfile() -> AnyPublisher<UserProfile, Never>
    func saveProfile(_ profile: UserProfile) -> AnyPublisher<Void, Never>
}

final class UserProfileRepository: UserProfileRepositoryProtocol {
    private let userDefaults = UserDefaults.standard
    private let profileKey = "user_profile"
    
    func loadProfile() -> AnyPublisher<UserProfile, Never> {
        Future { promise in
            if let data = self.userDefaults.data(forKey: self.profileKey),
               let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
                print("UserProfile: Loaded profile - name: \(profile.name), hasPhoto: \(profile.photoData != nil)")
                promise(.success(profile))
            } else {
                print("UserProfile: No saved profile found, returning empty")
                promise(.success(UserProfile()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveProfile(_ profile: UserProfile) -> AnyPublisher<Void, Never> {
        Future { promise in
            if let data = try? JSONEncoder().encode(profile) {
                self.userDefaults.set(data, forKey: self.profileKey)
                self.userDefaults.synchronize()
                print("UserProfile: Saved profile - name: \(profile.name), hasPhoto: \(profile.photoData != nil), dataSize: \(data.count) bytes")
                promise(.success(()))
            } else {
                print("UserProfile: Failed to encode profile")
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}

