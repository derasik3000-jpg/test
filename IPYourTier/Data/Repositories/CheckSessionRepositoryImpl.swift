import Foundation
import CoreData

public class CheckSessionRepositoryImpl: CheckSessionRepository {
    private let stack: PersistenceStackController
    
    public init(stack: PersistenceStackController = .shared) {
        self.stack = stack
    }
    
    public func createIncomplete(zone: ZoneDTO, at: Date) -> CheckSessionDTO {
        let context = stack.context
        let entity = CheckSession(context: context)
        
        entity.id = UUID()
        entity.createdAt = at
        entity.status = 0
        // Persist under non-conflicting attribute name 'zoneCode'
        entity.zoneCode = Int16(zone.rawValue)
        entity.setValue(Int16(zone.rawValue), forKey: "zoneCode")
        print("🧩 Repo.createIncomplete set zoneCode: raw=\(zone.rawValue), entity.zoneCode=\(entity.zoneCode)")
        
        entity.painMove = 0
        entity.painRest = false
        entity.popSound = false
        entity.edema = false
        entity.heat = false
        entity.instability = false
        entity.romPercent = 100
        entity.painNRS = 0
        entity.morningStiffness = false
        entity.betterWithLoadReduction = -1
        entity.symptomStart = 0
        entity.redFlag = false
        
        entity.riskScore = 0
        entity.riskLevel = 0
        entity.recommendationCode = 0
        
        stack.save()
        let dto = entity.toDTO()
        print("🧪 Repo.createIncomplete after save dto.zone=\(dto.zone.rawValue) \(dto.zone.displayName)")
        return dto
    }
    
    public func updateAnswers(sessionId: UUID, answers: [String: Any]) -> CheckSessionDTO {
        let context = stack.context
        let request: NSFetchRequest<CheckSession> = CheckSession.requestMaterialization()
        request.predicate = NSPredicate(format: "id == %@", sessionId as CVarArg)
        
        guard let entity = try? context.fetch(request).first else {
            fatalError("Session not found")
        }
        
        for (key, value) in answers {
            switch key {
            case "zone": entity.zoneCode = Int16(value as? Int ?? 0)
            case "painMove": entity.painMove = Int16(value as? Int ?? 0)
            case "painRest": entity.painRest = value as? Bool ?? false
            case "popSound": entity.popSound = value as? Bool ?? false
            case "edema": entity.edema = value as? Bool ?? false
            case "heat": entity.heat = value as? Bool ?? false
            case "instability": entity.instability = value as? Bool ?? false
            case "romPercent": entity.romPercent = Int16(value as? Int ?? 100)
            case "painNRS": entity.painNRS = Int16(value as? Int ?? 0)
            case "morningStiffness": entity.morningStiffness = value as? Bool ?? false
            case "betterWithLoadReduction": entity.betterWithLoadReduction = Int16(value as? Int ?? -1)
            case "symptomStart": entity.symptomStart = Int16(value as? Int ?? 0)
            case "redFlag": entity.redFlag = value as? Bool ?? false
            default: break
            }
        }
        
        stack.save()
        return entity.toDTO()
    }
    
    public func complete(sessionId: UUID, riskScore: Int, riskLevel: Int, recommendationCode: Int) -> CheckSessionDTO {
        let context = stack.context
        let request: NSFetchRequest<CheckSession> = CheckSession.requestMaterialization()
        request.predicate = NSPredicate(format: "id == %@", sessionId as CVarArg)
        
        guard let entity = try? context.fetch(request).first else {
            print("❌ CheckSessionRepo: Session not found for completion: \(sessionId)")
            fatalError("Session not found")
        }
        
        print("✅ CheckSessionRepo: Completing session \(sessionId)")
        print("   Risk Score: \(riskScore), Risk Level: \(riskLevel)")
        
        entity.status = 1
        entity.riskScore = Int16(riskScore)
        entity.riskLevel = Int16(riskLevel)
        entity.recommendationCode = Int16(recommendationCode)
        
        stack.save()
        updateTrendCache()
        
        print("💾 CheckSessionRepo: Session completed and saved")
        return entity.toDTO()
    }
    
    public func byId(_ id: UUID) -> CheckSessionDTO? {
        let context = stack.context
        let request: NSFetchRequest<CheckSession> = CheckSession.requestMaterialization()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try? context.fetch(request).first else {
            return nil
        }
        
        return entity.toDTO()
    }
    
    public func recent(days: Int) -> [CheckSessionDTO] {
        let context = stack.context
        let request: NSFetchRequest<CheckSession> = CheckSession.requestMaterialization()
        
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        request.predicate = NSPredicate(format: "createdAt >= %@ AND status == 1", startDate as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        guard let results = try? context.fetch(request) else {
            print("❌ CheckSessionRepo: Failed to fetch recent sessions")
            return []
        }
        
        print("📊 CheckSessionRepo: Loaded \(results.count) recent sessions (last \(days) days)")
        return results.map { $0.toDTO() }
    }
    
    public func filter(zone: ZoneDTO?, from: Date, to: Date) -> [CheckSessionDTO] {
        let context = stack.context
        let request: NSFetchRequest<CheckSession> = CheckSession.requestMaterialization()
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", from as CVarArg, to as CVarArg),
            NSPredicate(format: "status == 1")
        ]
        
        if let zone = zone {
            predicates.append(NSPredicate(format: "zoneCode == %d", zone.rawValue))
            print("🔍 CheckSessionRepo: Filtering by zone: \(zone.displayName)")
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        guard let results = try? context.fetch(request) else {
            print("❌ CheckSessionRepo: Failed to fetch filtered sessions")
            return []
        }
        
        print("📊 CheckSessionRepo: Loaded \(results.count) filtered sessions (from \(from) to \(to))")
        return results.map { $0.toDTO() }
    }
    
    public func setReminder(sessionId: UUID, at: Date?) -> CheckSessionDTO {
        let context = stack.context
        let request: NSFetchRequest<CheckSession> = CheckSession.requestMaterialization()
        request.predicate = NSPredicate(format: "id == %@", sessionId as CVarArg)
        
        guard let entity = try? context.fetch(request).first else {
            fatalError("Session not found")
        }
        
        entity.reminderAt = at
        stack.save()
        return entity.toDTO()
    }
    
    public func setNote(sessionId: UUID, note: String?) -> CheckSessionDTO {
        let context = stack.context
        let request: NSFetchRequest<CheckSession> = CheckSession.requestMaterialization()
        request.predicate = NSPredicate(format: "id == %@", sessionId as CVarArg)
        
        guard let entity = try? context.fetch(request).first else {
            fatalError("Session not found")
        }
        
        entity.note = note
        stack.save()
        return entity.toDTO()
    }
    
    public func expungeAll() {
        stack.expungeAll(CheckSession.self)
        updateTrendCache()
    }
    
    private func updateTrendCache() {
        let context = stack.context
        
        for windowDays in [7, 30] {
            let startDate = Calendar.current.date(byAdding: .day, value: -windowDays, to: Date())!
            let sessions = filter(zone: nil, from: startDate, to: Date())
            
            var low = 0, mid = 0, high = 0, red = 0
            for session in sessions {
                switch session.riskLevel {
                case 0: low += 1
                case 1: mid += 1
                case 2: high += 1
                case 3: red += 1
                default: break
                }
            }
            
            let request: NSFetchRequest<TrendCache> = TrendCache.requestMaterialization()
            request.predicate = NSPredicate(format: "windowDays == %d", windowDays)
            
            let cache: TrendCache
            if let existing = try? context.fetch(request).first {
                cache = existing
            } else {
                cache = TrendCache(context: context)
                cache.id = UUID()
                cache.windowDays = Int16(windowDays)
            }
            
            cache.lowCount = Int16(low)
            cache.midCount = Int16(mid)
            cache.highCount = Int16(high)
            cache.redCount = Int16(red)
            cache.updatedAt = Date()
        }
        
        stack.save()
    }
}

