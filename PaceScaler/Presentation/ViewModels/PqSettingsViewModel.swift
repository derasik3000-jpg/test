import Foundation

@MainActor
final class PqSettingsViewModel {
    private let stepsRepo: PqRitualFlowRepo
    private let settingsRepo: PqConfigRepo
    private let tagsRepo: PqTagDataRepo
    
    private(set) var steps: [RitualStepDTO] = []
    private(set) var settings: SettingsDTO?
    private(set) var tags: [TagDTO] = []
    
    var onUpdate: (() -> Void)?
    
    init(stepsRepo: PqRitualFlowRepo, settingsRepo: PqConfigRepo, tagsRepo: PqTagDataRepo) {
        self.stepsRepo = stepsRepo
        self.settingsRepo = settingsRepo
        self.tagsRepo = tagsRepo
    }
    
    func pqDidBecomeVisible() {
        Task { await pqRefreshState() }
    }
    
    private func pqRefreshState() async {
        do {
            steps = try await stepsRepo.pqFetchAllRecords()
            settings = try await settingsRepo.pqRetrieveData()
            tags = try await tagsRepo.pqFetchAllRecords()
            onUpdate?()
        } catch {
            print("Error reloading settings: \(error)")
        }
    }
    
    func upsertStep(_ s: RitualStepDTO) {
        Task {
            do {
                try await stepsRepo.pqMergeRecord(s)
                await pqRefreshState()
            } catch {
                print("Error upserting step: \(error)")
            }
        }
    }
    
    func reorder(_ ids: [UUID]) {
        Task {
            do {
                try await stepsRepo.pqRearrangeOrder(idsInOrder: ids)
                await pqRefreshState()
            } catch {
                print("Error reordering: \(error)")
            }
        }
    }
    
    func archiveStep(id: UUID, _ flag: Bool) {
        Task {
            do {
                try await stepsRepo.pqSetArchiveState(id: id, isArchived: flag)
                await pqRefreshState()
            } catch {
                print("Error archiving step: \(error)")
            }
        }
    }
    
    func saveSettings(_ s: SettingsDTO) {
        Task {
            do {
                try await settingsRepo.pqPersistData(s)
                await pqRefreshState()
            } catch {
                print("Error saving settings: \(error)")
            }
        }
    }
    
    func createTag(_ name: String) {
        Task {
            do {
                _ = try await tagsRepo.pqInsertNew(name: name)
                await pqRefreshState()
            } catch {
                print("Error creating tag: \(error)")
            }
        }
    }
    
    func archiveTag(_ id: UUID, flag: Bool) {
        Task {
            do {
                try await tagsRepo.pqSetArchiveState(id: id, isArchived: flag)
                await pqRefreshState()
            } catch {
                print("Error archiving tag: \(error)")
            }
        }
    }
    
    var activeSteps: [RitualStepDTO] {
        steps.filter { !$0.isArchived }.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var archivedSteps: [RitualStepDTO] {
        steps.filter { $0.isArchived }.sorted { $0.orderIndex < $1.orderIndex }
    }
}

