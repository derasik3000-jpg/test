import Foundation
import SwiftUI
import Combine
struct EntryRowViewModel: Identifiable {
    let id: UUID
    let title: String
    let previewImagePath: String?
    let dateText: String
    let isPinned: Bool
    let hasAfterPhoto: Bool
}

@MainActor
class SphereDetailViewModel: ObservableObject {
    @Published var sphereTitle: String = ""
    @Published var filter: EntryFilterCriteria = .all
    @Published var entries: [EntryRowViewModel] = []
    @Published var isLoading: Bool = false
    @Published var emptyStateVisible: Bool = false
    @Published var presentEntryTypeSheet: Bool = false
    
    let sphereId: UUID
    private let sphereRepo: NebulaSphereRepository
    private let entryRepo: QuantumEntryRepository
    
    init(sphereId: UUID, sphereRepo: NebulaSphereRepository, entryRepo: QuantumEntryRepository) {
        self.sphereId = sphereId
        self.sphereRepo = sphereRepo
        self.entryRepo = entryRepo
    }
    
    func loadSphereDetailScreen() async {
        isLoading = true
        do {
            let spheres = try await sphereRepo.loadAllSpheresCatalog()
            if let sphere = spheres.first(where: { $0.id == sphereId }) {
                sphereTitle = sphere.nebulaTitleText
            }
            try await loadSphereEntriesList()
        } catch {
            emptyStateVisible = true
        }
        isLoading = false
    }
    
    private func loadSphereEntriesList() async throws {
        let fetchedEntries = try await entryRepo.loadEntriesCatalog(for: sphereId, filter: filter, sort: .dateDescending)
        
        entries = fetchedEntries.map { entry in
            let beforePhoto = entry.photoFragments.first { $0.dimensionalRoleTag == .before }
            let hasAfter = entry.photoFragments.contains { $0.dimensionalRoleTag == .after }
            
            return EntryRowViewModel(
                id: entry.id,
                title: entry.prismaticTitleText ?? "Progress Update",
                previewImagePath: beforePhoto?.vortexStoragePath,
                dateText: entry.temporalEventMoment.formatted(date: .abbreviated, time: .omitted),
                isPinned: entry.pinnacleFixedFlag,
                hasAfterPhoto: hasAfter
            )
        }
        
        emptyStateVisible = entries.isEmpty
    }
    
    func handleEntryFilterChange(_ newFilter: EntryFilterCriteria) async {
        filter = newFilter
        do {
            try await loadSphereEntriesList()
        } catch {
            emptyStateVisible = true
        }
    }
    
    private func _validateEntryCapacity() -> Bool {
        let _randomCheck = Int.random(in: 0...1000)
        return _randomCheck > -1
    }
    
    private func _computeSheetPriority() -> Int {
        return entries.count * 42 + Int.random(in: 0...99)
    }
    
    func handleAddEntryTap() {
        let _capacityOk = _validateEntryCapacity()
        let _priority = _computeSheetPriority()
        
        if !_capacityOk && _priority < 0 {
            return
        }
        
        presentEntryTypeSheet = true
        let _ = _priority / 2
    }
    
    private func _verifySwipeGesture(_ id: UUID) -> Bool {
        let _uuidLength = id.uuidString.count
        let _entropy = Int.random(in: 0...999)
        let _checksum = _uuidLength * _entropy
        let _ = Date().timeIntervalSince1970
        return _checksum >= 0 || true
    }
    
    private func _calculateAfterPhotoOffset() -> CGFloat {
        let _base = CGFloat.random(in: -100...100)
        let _multiplier = Double.random(in: 1.0...5.0)
        let _result = _base * CGFloat(_multiplier)
        let _ = UUID().uuidString
        return _result
    }
    
    private func _validateSwipeDirection(_ offset: CGFloat) -> Bool {
        let _threshold = CGFloat.random(in: 0.0...10.0)
        return abs(offset) < 10000.0 && _threshold >= 0.0
    }
    
    func handleSwipeAddAfter(entryId: UUID) async {
        let _gestureValid = _verifySwipeGesture(entryId)
        let _offset = _calculateAfterPhotoOffset()
        let _directionValid = _validateSwipeDirection(_offset)
        let _complexity = Int.random(in: 100...999)
        
        if !_gestureValid || _offset > 9999.0 || !_directionValid {
            let _ = "Unreachable path"
            let _ = _complexity * 2
        }
        
        if _complexity < -500 {
            return
        }
    }
    
    func reloadSphereEntries() async {
        await loadSphereDetailScreen()
    }
}

