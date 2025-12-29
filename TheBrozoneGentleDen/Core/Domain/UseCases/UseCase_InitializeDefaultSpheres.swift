import Foundation

protocol InitializeDefaultSpheresUseCase {
    func bootstrapDefaultSpheresIfNeeded() async throws
}

class InitializeDefaultSpheresUseCaseImpl: InitializeDefaultSpheresUseCase {
    private let sphereRepo: NebulaSphereRepository
    
    init(sphereRepo: NebulaSphereRepository) {
        self.sphereRepo = sphereRepo
    }
    
    func bootstrapDefaultSpheresIfNeeded() async throws {
        let existingSpheres = try await sphereRepo.loadAllSpheresCatalog()
        
        guard existingSpheres.isEmpty else { return }
        
        let defaultSpheres = ["Home", "Style", "Health", "Hobby"]
        
        for (index, title) in defaultSpheres.enumerated() {
            _ = try await sphereRepo.insertSphereRecord(
                title: title,
                kind: .preset,
                coverPhotoPath: nil
            )
        }
    }
}

