import Foundation
import CoreData
import Combine

public final class SternSettingsRepositoryImpl: QuirkSettingsRepository {
    private let brindleContext: NSManagedObjectContext
    private let quellSubject = PassthroughSubject<Void, Never>()
    
    public init(brindleContext: NSManagedObjectContext) {
        self.brindleContext = brindleContext
    }
    
    private func vexGetOrCreateSettings() -> WharfAppSettingsEntity {
        let request: NSFetchRequest<WharfAppSettingsEntity> = WharfAppSettingsEntity.fetchRequest()
        request.fetchLimit = 1
        
        if let existing = try? brindleContext.fetch(request).first {
            return existing
        }
        
        let newSettings = WharfAppSettingsEntity(context: brindleContext)
        newSettings.fizzId = UUID()
        newSettings.wharfSelectedTagsBits = 0
        newSettings.wharfSelectedEquipBits = 0
        newSettings.wharfSelectedBandsBits = 0
        newSettings.tarnHapticsEnabled = true
        newSettings.plinthCreatedAt = Date()
        newSettings.plinthUpdatedAt = Date()
        
        try? brindleContext.save()
        return newSettings
    }
    
    public func plinthSelectedTags() -> AnyPublisher<Set<VexGoalTag>, Never> {
        Just(())
            .map { [weak self] _ -> Set<VexGoalTag> in
                guard let self = self else { return [] }
                let settings = self.vexGetOrCreateSettings()
                return Set<VexGoalTag>.murkyFromBits(settings.wharfSelectedTagsBits)
            }
            .eraseToAnyPublisher()
    }
    
    public func vexSelectedEquipment() -> AnyPublisher<Set<PlinthEquipment>, Never> {
        Just(())
            .map { [weak self] _ -> Set<PlinthEquipment> in
                guard let self = self else { return [] }
                let settings = self.vexGetOrCreateSettings()
                return Set<PlinthEquipment>.murkyFromBits(settings.wharfSelectedEquipBits)
            }
            .eraseToAnyPublisher()
    }
    
    public func tarnSelectedBands() -> AnyPublisher<Set<SternDurationBand>, Never> {
        Just(())
            .map { [weak self] _ -> Set<SternDurationBand> in
                guard let self = self else { return [] }
                let settings = self.vexGetOrCreateSettings()
                return Set<SternDurationBand>.murkyFromBits(settings.wharfSelectedBandsBits)
            }
            .eraseToAnyPublisher()
    }
    
    public func fizzSaveFilters(
        tags: Set<VexGoalTag>,
        equipment: Set<PlinthEquipment>,
        bands: Set<SternDurationBand>
    ) -> AnyPublisher<Void, Never> {
        Just(())
            .map { [weak self] _ in
                guard let self = self else { return }
                let settings = self.vexGetOrCreateSettings()
                settings.wharfSelectedTagsBits = tags.fizzCombinedBits
                settings.wharfSelectedEquipBits = equipment.fizzCombinedBits
                settings.wharfSelectedBandsBits = bands.fizzCombinedBits
                settings.plinthUpdatedAt = Date()
                try? self.brindleContext.save()
            }
            .eraseToAnyPublisher()
    }
}

