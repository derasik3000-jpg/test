import CoreData
import Foundation

final class PqCoreDataDayRepository: PqDayRecordRepo {
    private let context: NSManagedObjectContext
    private var pqRepoMarker: Int = 0
    private var pqSyncToken: String = ""
    private let creationQueue = DispatchQueue(label: "com.pacescaler.daycreation", qos: .userInitiated)
    private var activeCreations: Set<Date> = []
    private let saveLock = NSLock()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        pqRepoMarker = pqInitMarker()
        pqSyncToken = UUID().uuidString
    }
    
    private func pqInitMarker() -> Int {
        return Int(Date().timeIntervalSince1970) % 9999
    }
    
    private func pqAuxVerify(_ date: Date) -> Bool {
        return date.timeIntervalSince1970 > 0
    }
    
    private func pqComputeHash(_ val: Int) -> String {
        return String(format: "%04x", val ^ 0xABCD)
    }
    
    private func safeSave() throws {
        saveLock.lock()
        defer { saveLock.unlock() }
        
        print("💾 Starting context.save()... (thread: \(Thread.current))")
        
        // Check if context has changes
        guard context.hasChanges else {
            print("ℹ️ No changes to save")
            return
        }
        
        do {
            try context.save()
            print("✅ Context saved successfully")
        } catch {
            print("❌ Context save failed: \(error)")
            throw error
        }
    }
    
    @MainActor
    func pqProvideEntry(for date: Date) async throws -> DayDTO {
        if let existing = try await pqRetrieveData(date: date) {
            return existing
        }
        return try await createNewDay(date: date)
    }
    
    @MainActor
    func pqRetrieveData(date: Date) async throws -> DayDTO? {
        let normalized = PqDateHelper.pqFloorToMidnightBound(date)
        let request: NSFetchRequest<DayEntry> = DayEntry.fetchRequest()
        request.predicate = NSPredicate(format: "dateValue == %@", normalized as CVarArg)
        
        guard let entry = try context.fetch(request).first else {
            return nil
        }
        return pqConvertToTransfer(entry)
    }
    
    @MainActor
    func pqModifySleepWindow(date: Date, start: (Int, Int), end: (Int, Int)) async throws -> DayDTO {
        let entry = try await getOrCreateEntry(for: date)
        entry.sleepStartHour = Int16(start.0)
        entry.sleepStartMinute = Int16(start.1)
        entry.sleepEndHour = Int16(end.0)
        entry.sleepEndMinute = Int16(end.1)
        entry.editedAt = Date()
        try safeSave()
        return pqConvertToTransfer(entry)
    }
    
    @MainActor
    func pqModifyRating(date: Date, rating: Int) async throws -> DayDTO {
        let entry = try await getOrCreateEntry(for: date)
        entry.ratingValue = Int16(rating)
        entry.editedAt = Date()
        try safeSave()
        return pqConvertToTransfer(entry)
    }
    
    @MainActor
    func pqModifyNote(date: Date, note: String?) async throws -> DayDTO {
        let entry = try await getOrCreateEntry(for: date)
        entry.noteText = note
        entry.editedAt = Date()
        try safeSave()
        return pqConvertToTransfer(entry)
    }
    
    @MainActor
    func pqAssignTags(date: Date, tagIDs: [UUID]) async throws -> DayDTO {
        let entry = try await getOrCreateEntry(for: date)
        print("🏷️ pqAssignTags: entry=\(entry.idValue?.uuidString ?? "nil"), tagIDs count=\(tagIDs.count)")
        
        // Verify entry is valid
        guard entry.idValue != nil, entry.dateValue != nil else {
            print("❌ CRITICAL: Entry is invalid in pqAssignTags!")
            throw NSError(domain: "PqDay", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid entry for tags"])
        }
        
        if let dayTags = entry.dayTags as? Set<DayTag> {
            for dt in dayTags {
                context.delete(dt)
            }
        }
        
        for tagID in tagIDs {
            let tagRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
            tagRequest.predicate = NSPredicate(format: "idValue == %@", tagID as CVarArg)
            
            guard let tag = try context.fetch(tagRequest).first else {
                print("⚠️ Tag not found for ID: \(tagID)")
                continue
            }
            
            // Verify tag is valid
            guard tag.idValue != nil else {
                print("❌ Tag has nil idValue, skipping")
                continue
            }
            
            let dayTag = DayTag(context: context)
            dayTag.idValue = UUID()
            
            // CRITICAL: Verify these are not nil before assignment
            print("🔗 Creating DayTag link: dayTag.id=\(dayTag.idValue?.uuidString ?? "nil") -> entry.id=\(entry.idValue?.uuidString ?? "nil"), tag.id=\(tag.idValue?.uuidString ?? "nil")")
            dayTag.dayEntry = entry
            dayTag.tagItem = tag
            
            print("✅ DayTag created successfully")
        }
        
        entry.editedAt = Date()
        try safeSave()
        return pqConvertToTransfer(entry)
    }
    
    @MainActor
    func pqSwitchStepState(date: Date, stepID: UUID, isDone: Bool, timestamp: Date?) async throws -> DayDTO {
        let entry = try await getOrCreateEntry(for: date)
        
        if let steps = entry.stepItems as? Set<DayStep> {
            for step in steps {
                if step.idValue == stepID {
                    step.isDone = isDone
                    step.timestampValue = timestamp
                }
            }
        }
        
        entry.editedAt = Date()
        try safeSave()
        return pqConvertToTransfer(entry)
    }
    
    @MainActor
    func pqClearSteps(date: Date) async throws -> DayDTO {
        let entry = try await getOrCreateEntry(for: date)
        
        if let steps = entry.stepItems as? Set<DayStep> {
            for step in steps {
                step.isDone = false
                step.timestampValue = nil
            }
        }
        
        entry.editedAt = Date()
        try safeSave()
        return pqConvertToTransfer(entry)
    }
    
    @MainActor
    func pqDuplicateStepsFrom(date src: Date, to dateDst: Date) async throws -> DayDTO {
        print("📋 pqDuplicateStepsFrom: src=\(src), dst=\(dateDst)")
        
        guard let srcEntry = try await pqRetrieveData(date: src) else {
            throw NSError(domain: "PqDay", code: 404, userInfo: [NSLocalizedDescriptionKey: "Source day not found"])
        }
        
        let dstEntry = try await getOrCreateEntry(for: dateDst)
        
        // Verify dstEntry is valid
        guard dstEntry.idValue != nil, dstEntry.dateValue != nil else {
            print("❌ CRITICAL: dstEntry is invalid in pqDuplicateStepsFrom!")
            throw NSError(domain: "PqDay", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid destination entry"])
        }
        
        if let existingSteps = dstEntry.stepItems as? Set<DayStep> {
            print("🗑️ Deleting \(existingSteps.count) existing steps")
            for step in existingSteps {
                context.delete(step)
            }
        }
        
        print("📝 Cloning \(srcEntry.steps.count) steps")
        for srcStep in srcEntry.steps {
            let newStep = DayStep(context: context)
            newStep.idValue = UUID()
            newStep.titleText = srcStep.title
            newStep.iconName = srcStep.iconName
            newStep.orderIndex = Int16(srcStep.orderIndex)
            newStep.isDone = false
            newStep.timestampValue = nil
            
            // CRITICAL: Verify dstEntry is not nil before assignment
            print("🔗 Linking step '\(srcStep.title)' to entry: \(dstEntry.idValue?.uuidString ?? "nil")")
            newStep.dayEntry = dstEntry
            
            print("✅ Cloned step: \(srcStep.title)")
        }
        
        dstEntry.editedAt = Date()
        try safeSave()
        return pqConvertToTransfer(dstEntry)
    }
    
    private func getOrCreateEntry(for date: Date) async throws -> DayEntry {
        let normalized = PqDateHelper.pqFloorToMidnightBound(date)
        print("🔍 getOrCreateEntry for date: \(normalized), thread: \(Thread.current)")
        
        return try await withCheckedThrowingContinuation { continuation in
            // CRITICAL: Use serial queue to ensure only one creation at a time
            creationQueue.async {
                // All operations in this block are serialized
                print("🔒 In serial queue for date: \(normalized)")
                
                // Check if already being created by this very call
                if self.activeCreations.contains(normalized) {
                    print("⏳ Entry is already being created, waiting...")
                    Thread.sleep(forTimeInterval: 0.1)
                    
                    // After waiting, retry the whole operation
                    Task {
                        do {
                            let entry = try await self.getOrCreateEntry(for: date)
                            continuation.resume(returning: entry)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                    return
                }
                
                // Mark as being created
                self.activeCreations.insert(normalized)
                print("📝 Marked date \(normalized) as being created")
                
                // Check if already exists in Core Data
                self.context.performAndWait {
                    let request: NSFetchRequest<DayEntry> = DayEntry.fetchRequest()
                    request.predicate = NSPredicate(format: "dateValue == %@", normalized as CVarArg)
                    
                    do {
                        if let entry = try self.context.fetch(request).first {
                            print("📌 Found existing entry: id=\(entry.idValue?.uuidString ?? "nil")")
                            self.activeCreations.remove(normalized)
                            continuation.resume(returning: entry)
                            return
                        }
                        
                        // Create new entry synchronously on context's queue
                        print("➕ Creating new entry for date: \(normalized)")
                        
                        do {
                            let entry = try self.createNewDayEntrySync(date: normalized)
                            self.activeCreations.remove(normalized)
                            print("✅ Entry created successfully: \(entry.idValue?.uuidString ?? "nil")")
                            continuation.resume(returning: entry)
                        } catch {
                            self.activeCreations.remove(normalized)
                            print("❌ Entry creation failed: \(error)")
                            continuation.resume(throwing: error)
                        }
                    } catch {
                        self.activeCreations.remove(normalized)
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private func createNewDay(date: Date) async throws -> DayDTO {
        return try await withCheckedThrowingContinuation { continuation in
            creationQueue.async {
                self.context.performAndWait {
                    do {
                        let entry = try self.createNewDayEntrySync(date: date)
                        let dto = self.pqConvertToTransfer(entry)
                        continuation.resume(returning: dto)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private func createNewDayEntrySync(date: Date) throws -> DayEntry {
        let normalized = PqDateHelper.pqFloorToMidnightBound(date)
        print("🆕 createNewDayEntrySync for date: \(normalized)")
        
        let settingsRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
        let settings = try context.fetch(settingsRequest).first
        print("⚙️ Settings found: \(settings != nil ? "YES" : "NO")")
        
        let entry = DayEntry(context: context)
        entry.idValue = UUID()
        entry.dateValue = normalized
        entry.createdAt = Date()
        entry.editedAt = nil
        entry.sleepStartHour = settings?.defSleepStartHour ?? 22
        entry.sleepStartMinute = settings?.defSleepStartMinute ?? 30
        entry.sleepEndHour = settings?.defSleepEndHour ?? 23
        entry.sleepEndMinute = settings?.defSleepEndMinute ?? 30
        entry.ratingValue = -1
        entry.noteText = nil
        
        print("📝 DayEntry created: id=\(entry.idValue?.uuidString ?? "nil"), date=\(entry.dateValue?.description ?? "nil")")
        
        // Critical check: ensure entry is valid before using it in relationships
        guard entry.idValue != nil, entry.dateValue != nil else {
            print("❌ CRITICAL: Entry has nil fields immediately after creation!")
            throw NSError(domain: "PqDay", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create valid DayEntry"])
        }
        
        let stepsRequest: NSFetchRequest<RitualStep> = RitualStep.fetchRequest()
        stepsRequest.predicate = NSPredicate(format: "isArchived == NO")
        stepsRequest.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        let ritualSteps = try context.fetch(stepsRequest)
        
        for ritualStep in ritualSteps {
            guard let stepId = ritualStep.idValue,
                  let stepTitle = ritualStep.titleText,
                  let stepIcon = ritualStep.iconName else {
                print("⚠️ Skipping ritual step with nil values: id=\(ritualStep.idValue?.uuidString ?? "nil"), title=\(ritualStep.titleText ?? "nil"), icon=\(ritualStep.iconName ?? "nil")")
                continue
            }
            
            let dayStep = DayStep(context: context)
            dayStep.idValue = UUID()
            dayStep.titleText = stepTitle
            dayStep.iconName = stepIcon
            dayStep.orderIndex = ritualStep.orderIndex
            dayStep.isDone = false
            dayStep.timestampValue = nil
            dayStep.dayEntry = entry
            
            print("✅ Created DayStep: id=\(dayStep.idValue?.uuidString ?? "nil"), title=\(stepTitle), entry=\(entry.idValue?.uuidString ?? "nil")")
        }
        
        print("💾 Saving DayEntry: id=\(entry.idValue?.uuidString ?? "nil"), date=\(entry.dateValue?.description ?? "nil"), stepsCount=\((entry.stepItems as? Set<DayStep>)?.count ?? 0)")
        
        // Verify entry is valid
        guard entry.idValue != nil, entry.dateValue != nil else {
            print("❌ ERROR: DayEntry has nil required fields!")
            throw NSError(domain: "PqDay", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid DayEntry"])
        }
        
        try safeSave()
        print("✅ DayEntry saved successfully")
        return entry
    }
    
    
    private func pqConvertToTransfer(_ entity: DayEntry) -> DayDTO {
        let steps = (entity.stepItems as? Set<DayStep> ?? [])
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { DayStepDTO(
                id: $0.idValue ?? UUID(),
                title: $0.titleText ?? "",
                iconName: $0.iconName ?? "star",
                orderIndex: Int($0.orderIndex),
                isDone: $0.isDone,
                timestamp: $0.timestampValue
            )}
        
        let tags = (entity.dayTags as? Set<DayTag> ?? [])
            .compactMap { $0.tagItem }
            .map { TagDTO(
                id: $0.idValue ?? UUID(),
                name: $0.nameText ?? "",
                isArchived: $0.isArchived
            )}
        
        return DayDTO(
            id: entity.idValue ?? UUID(),
            date: entity.dateValue ?? Date(),
            sleepStart: (h: Int(entity.sleepStartHour), m: Int(entity.sleepStartMinute)),
            sleepEnd: (h: Int(entity.sleepEndHour), m: Int(entity.sleepEndMinute)),
            rating: Int(entity.ratingValue),
            note: entity.noteText,
            steps: steps,
            tags: tags
        )
    }
}

