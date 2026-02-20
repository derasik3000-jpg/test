

import Foundation
import Combine


final class EpisodeForgeViewModel: ObservableObject {

    @Published var companionId: UUID = UUID()
    @Published var selectedKind: SymptomKind = .vomiting
    @Published var customTitle: String = ""
    @Published var severity: SeverityLevel = .mild
    @Published var occurrenceCount: Int = 1
    @Published var durationMinutes: Int? = nil
    @Published var occurredAt: Date = Date()
    @Published var note: String = ""

    var canSave: Bool {
        if selectedKind == .custom {
            return !customTitle.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return true
    }

    func prepare(companionId: UUID) {
        self.companionId = companionId
    }

    func save() {
        let episode = SymptomEpisode(
            companionId: companionId,
            kind: selectedKind,
            customTitle: selectedKind == .custom ? customTitle.trimmingCharacters(in: .whitespaces) : nil,
            occurredAt: occurredAt,
            severity: severity,
            occurrenceCount: occurrenceCount,
            durationMinutes: durationMinutes,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        GroveStorage.shared.saveEpisode(episode)
    }
}
