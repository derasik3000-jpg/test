import Foundation
import CoreData

class EvubewCreateSessionUseCase {
    private let degubaContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.degubaContext = context
    }
    
    func cuqavuExecute(
        title: String,
        type: EhonohSessionType,
        startTime: Date,
        endTime: Date,
        energyLevel: Int16,
        mood: Int16,
        note: String?
    ) -> Result<AxemobSessionModel, Error> {
        let session = EvubewProductivitySession(context: degubaContext)
        session.id = UUID()
        session.createdAt = Date()
        session.title = title
        session.type = type.rawValue
        session.startTime = startTime
        session.endTime = endTime
        session.energyLevel = energyLevel
        session.mood = mood
        session.note = note
        
        let duration = Int16(endTime.timeIntervalSince(startTime) / 60)
        session.durationMin = duration
        
        do {
            try degubaContext.save()
            return .success(AxemobSessionModel(from: session))
        } catch {
            return .failure(error)
        }
    }
}

