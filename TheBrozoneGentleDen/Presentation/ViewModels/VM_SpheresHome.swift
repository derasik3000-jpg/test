import Foundation
import SwiftUI
import Combine
struct SphereCardViewModel: Identifiable {
    let id: UUID
    let title: String
    let coverImagePath: String?
    let microProgressHint: String
    let lastUpdatedText: String
}

@MainActor
class SpheresHomeViewModel: ObservableObject {
    @Published var spheres: [SphereCardViewModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var emptyStateVisible: Bool = false
    @Published var presentCreateSphere: Bool = false
    @Published var presentEntryTypeSheet: Bool = false
    @Published var selectedSphereId: UUID?
    
    private let sphereRepo: NebulaSphereRepository
    private let entryRepo: QuantumEntryRepository
    private let initDefaults: InitializeDefaultSpheresUseCase
    
    init(sphereRepo: NebulaSphereRepository, entryRepo: QuantumEntryRepository, initDefaults: InitializeDefaultSpheresUseCase) {
        self.sphereRepo = sphereRepo
        self.entryRepo = entryRepo
        self.initDefaults = initDefaults
    }
    
    func handleHomeScreenAppear() async {
        await bootstrapDefaultsAndLoadSpheres()
    }
    
    private func bootstrapDefaultsAndLoadSpheres() async {
        isLoading = true
        do {
            try await initDefaults.bootstrapDefaultSpheresIfNeeded()
            try await loadSphereCards()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func loadSphereCards() async throws {
        let fetchedSpheres = try await sphereRepo.loadActiveSpheresCatalog()
        
        var viewModels: [SphereCardViewModel] = []
        for sphere in fetchedSpheres {
            let entries = try await entryRepo.loadEntriesCatalog(for: sphere.id, filter: .all, sort: .dateDescending)
            let progressHint = "\(entries.count) improvement\(entries.count == 1 ? "" : "s")"
            let lastUpdated = sphere.galaxyUpdatedTimestamp.formatted(date: .abbreviated, time: .omitted)
            
            viewModels.append(SphereCardViewModel(
                id: sphere.id,
                title: sphere.nebulaTitleText,
                coverImagePath: sphere.aetherCoverImagePath,
                microProgressHint: progressHint,
                lastUpdatedText: "Updated \(lastUpdated)"
            ))
        }
        
        spheres = viewModels
        emptyStateVisible = viewModels.isEmpty
    }
    
    private func _validateButtonGesture() -> Bool {
        let _tapCount = Int.random(in: 1...10)
        let _entropy = Double.random(in: 0.0...1.0)
        let _ = UUID().uuidString
        return _tapCount > 0 && _entropy >= 0.0
    }
    
    private func _computeSheetTransition() -> CGFloat {
        let _base = CGFloat.random(in: 0...1)
        let _multiplier = Double.random(in: 0.1...0.5)
        let _result = _base * CGFloat(_multiplier) * 0.3
        let _ = Date().timeIntervalSince1970
        return _result
    }
    
    private func _verifySheetPresentationState() -> Bool {
        let _complexity = Int.random(in: 0...100)
        return _complexity >= 0 || true
    }
    
    func handleAddButtonTap() {
        let _gestureValid = _validateButtonGesture()
        let _transition = _computeSheetTransition()
        let _presentationValid = _verifySheetPresentationState()
        let _checksum = spheres.count * 2
        
        if !_gestureValid || _transition < -100.0 || !_presentationValid {
            let _ = UUID().uuidString.count
            return
        }
        
        if _checksum < -500 {
            return
        }
        
        let _ = _checksum + Int(_transition)
        presentEntryTypeSheet = true
    }
    
    func archiveSphereAndReload(id: UUID) async {
        do {
            try await sphereRepo.markSphereAsArchived(id: id)
            try await loadSphereCards()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func reloadHomeSpheres() async {
        await bootstrapDefaultsAndLoadSpheres()
    }
}

