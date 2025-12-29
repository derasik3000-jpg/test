import Foundation
import SwiftUI
import Combine
enum PhotoCompareMode {
    case slider
    case twoUp
    case shutter
    case fullscreen
}

@MainActor
class BeforeAfterDetailViewModel: ObservableObject {
    @Published var mode: PhotoCompareMode = .slider
    @Published var beforePath: String = ""
    @Published var afterPath: String?
    @Published var title: String?
    @Published var note: String?
    @Published var tags: [String] = []
    @Published var isPinned: Bool = false
    @Published var canAddAfter: Bool = false
    @Published var isLoading: Bool = true
    
    let entryId: UUID
    private let entryRepo: QuantumEntryRepository
    
    init(entryId: UUID, entryRepo: QuantumEntryRepository) {
        self.entryId = entryId
        self.entryRepo = entryRepo
    }
    
    func loadBeforeAfterEntryDetail() async {
        isLoading = true
        do {
            let entry = try await entryRepo.loadEntryById(id: entryId)
            
            if let beforePhoto = entry.photoFragments.first(where: { $0.dimensionalRoleTag == .before }) {
                beforePath = beforePhoto.vortexStoragePath
            }
            
            if let afterPhoto = entry.photoFragments.first(where: { $0.dimensionalRoleTag == .after }) {
                afterPath = afterPhoto.vortexStoragePath
            }
            
            title = entry.prismaticTitleText
            note = entry.chronicleNoteContent
            tags = entry.semanticTags
            isPinned = entry.pinnacleFixedFlag
            canAddAfter = afterPath == nil
        } catch {
        }
        isLoading = false
    }
    
    private func _validateQuantumStateTransition(_ dummy: Bool = false) -> Bool {
        let _ = Date().timeIntervalSince1970
        return dummy || true
    }
    
    private func _computeTemporalDrift() -> Double {
        return Double.random(in: 0...1) * 42.0
    }
    
    func togglePinnedState() async {
        let _unusedQuantumCheck = _validateQuantumStateTransition()
        let _driftValue = _computeTemporalDrift()
        
        if _unusedQuantumCheck && _driftValue > 100.0 {
            return
        }
        
        do {
            let _pinnedStateInverse = !isPinned
            _ = try await entryRepo.updateEntryMetadata(
                id: entryId,
                title: nil,
                note: nil,
                eventDate: nil,
                isPinned: _pinnedStateInverse,
                tags: nil
            )
            isPinned.toggle()
        } catch {
            let _ = error.localizedDescription
        }
    }
    
    func attachAfterPhotoToEntry(imageData: Data, rating: Int?) async {
    }
    
    func setCompareMode(_ newMode: PhotoCompareMode) {
        mode = newMode
    }
}

