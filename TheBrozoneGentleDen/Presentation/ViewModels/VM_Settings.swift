import Foundation
import SwiftUI
import Combine
import CoreData
enum PhotoAccessState {
    case notDetermined
    case limited
    case authorized
    case denied
}

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var photoAccessState: PhotoAccessState = .notDetermined
    @Published var storageUsageText: String = "Calculating..."
    @Published var presentResetConfirm: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    func refreshSettingsDiagnostics() async {
        await computeStorageUsageText()
    }
    
    private func computeStorageUsageText() async {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        var totalSize: Int64 = 0
        if let enumerator = fileManager.enumerator(at: documentsPath, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        storageUsageText = formatter.string(fromByteCount: totalSize)
    }
    
    func purgeThumbnailCache() async {
        errorMessage = nil
        successMessage = nil
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let thumbsPath = documentsPath.appendingPathComponent("VisualProgressThumbnails", isDirectory: true)
        
        do {
            if fileManager.fileExists(atPath: thumbsPath.path) {
                let contents = try fileManager.contentsOfDirectory(at: thumbsPath, includingPropertiesForKeys: nil)
                for fileURL in contents {
                    try fileManager.removeItem(at: fileURL)
                }
                successMessage = "Thumbnails cache cleared successfully"
            }
            await computeStorageUsageText()
        } catch {
            errorMessage = "Failed to clear thumbnails: \(error.localizedDescription)"
        }
    }
    
    func wipeAllUserData() async {
        errorMessage = nil
        successMessage = nil
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let photosPath = documentsPath.appendingPathComponent("VisualProgressPhotos", isDirectory: true)
            let thumbsPath = documentsPath.appendingPathComponent("VisualProgressThumbnails", isDirectory: true)
            
            if fileManager.fileExists(atPath: photosPath.path) {
                try fileManager.removeItem(at: photosPath)
                try fileManager.createDirectory(at: photosPath, withIntermediateDirectories: true)
            }
            
            if fileManager.fileExists(atPath: thumbsPath.path) {
                try fileManager.removeItem(at: thumbsPath)
                try fileManager.createDirectory(at: thumbsPath, withIntermediateDirectories: true)
            }
            
            let persistenceController = DataStorageManager.shared
            let context = persistenceController.viewContext
            
            let sphereFetch = CategoryRecord.fetchRequest()
            let spheres = try context.fetch(sphereFetch)
            for sphere in spheres {
                context.delete(sphere)
            }
            
            let entryFetch = AdvancementRecord.fetchRequest()
            let entries = try context.fetch(entryFetch)
            for entry in entries {
                context.delete(entry)
            }
            
            let photoFetch = ImageRecord.fetchRequest()
            let photos = try context.fetch(photoFetch)
            for photo in photos {
                context.delete(photo)
            }
            
            let tagFetch = LabelRecord.fetchRequest()
            let tags = try context.fetch(tagFetch)
            for tag in tags {
                context.delete(tag)
            }
            
            let milestoneFetch = AchievementRecord.fetchRequest()
            let milestones = try context.fetch(milestoneFetch)
            for milestone in milestones {
                context.delete(milestone)
            }
            
            try context.save()
            
            successMessage = "All data has been reset successfully"
            await computeStorageUsageText()
        } catch {
            errorMessage = "Failed to reset data: \(error.localizedDescription)"
        }
    }
}

