import Foundation
import CoreData

protocol SettingRepository {
    func getInt(_ key: String, default: Int) -> Int
    func getBool(_ key: String, default: Bool) -> Bool
    func getString(_ key: String, default: String?) -> String?
    func setInt(_ key: String, _ value: Int)
    func setBool(_ key: String, _ value: Bool)
    func setString(_ key: String, _ value: String?)
}

final class SettingRepositoryImpl: SettingRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getInt(_ key: String, default defaultValue: Int) -> Int {
        guard let entity = fetchSetting(key: key) else { return defaultValue }
        return Int(entity.intValue)
    }
    
    func getBool(_ key: String, default defaultValue: Bool) -> Bool {
        guard let entity = fetchSetting(key: key) else { return defaultValue }
        return entity.boolValue
    }
    
    func getString(_ key: String, default defaultValue: String?) -> String? {
        guard let entity = fetchSetting(key: key) else { return defaultValue }
        return entity.stringValue
    }
    
    func setInt(_ key: String, _ value: Int) {
        let entity = getOrCreateSetting(key: key)
        entity.intValue = Int32(value)
        entity.updatedAt = Date()
        try? context.save()
    }
    
    func setBool(_ key: String, _ value: Bool) {
        let entity = getOrCreateSetting(key: key)
        entity.boolValue = value
        entity.updatedAt = Date()
        try? context.save()
    }
    
    func setString(_ key: String, _ value: String?) {
        let entity = getOrCreateSetting(key: key)
        entity.stringValue = value
        entity.updatedAt = Date()
        try? context.save()
    }
    
    private func fetchSetting(key: String) -> SettingEntity? {
        let fetchRequest: NSFetchRequest<SettingEntity> = SettingEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        return try? context.fetch(fetchRequest).first
    }
    
    private func getOrCreateSetting(key: String) -> SettingEntity {
        if let existing = fetchSetting(key: key) {
            return existing
        }
        let entity = SettingEntity(context: context)
        entity.key = key
        entity.updatedAt = Date()
        return entity
    }
}

