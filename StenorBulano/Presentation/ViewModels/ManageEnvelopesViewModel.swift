import Foundation
import Combine

struct EnvelopeModel: Identifiable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

final class ManageEnvelopesViewModel: ObservableObject {
    @Published var envelopes: [EnvelopeModel] = []
    @Published var weekId: UUID?
    
    private let setupUC: SetupWeekUseCase
    private let envRepo: EnvelopeRepository
    
    init(setupUC: SetupWeekUseCase, envRepo: EnvelopeRepository) {
        self.setupUC = setupUC
        self.envRepo = envRepo
    }
    
    func load() {
        if let (w, env) = try? setupUC.currentWeek() {
            weekId = w.id
            envelopes = env.sorted { $0.orderIndex < $1.orderIndex }
                .map { EnvelopeModel(id: $0.id, name: $0.name) }
        }
    }
    
    func addEnvelope() {
        envelopes.append(EnvelopeModel(name: "New Envelope"))
    }
    
    func removeEnvelope(at index: Int) {
        guard envelopes.count > 1 else { return }
        envelopes.remove(at: index)
    }
    
    func save(onComplete: @escaping () -> Void) {
        guard let wid = weekId else { return }
        let names = envelopes.map { $0.name }
        
        do {
            _ = try setupUC.renameEnvelopes(weekId: wid, names: names)
            NotificationCenter.default.post(name: NSNotification.Name("EnvelopesUpdated"), object: nil)
            onComplete()
        } catch {
            print("Error saving envelopes: \(error)")
        }
    }
}

