import Foundation
import UIKit

class LocalVortexPhotoRepository: VortexPhotoRepository {
    private let fileManager = FileManager.default
    private lazy var photosDirectory: URL = {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("VisualProgressPhotos", isDirectory: true)
        try? fileManager.createDirectory(at: photosPath, withIntermediateDirectories: true)
        return photosPath
    }()
    
    private lazy var thumbnailsDirectory: URL = {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let thumbsPath = documentsPath.appendingPathComponent("VisualProgressThumbnails", isDirectory: true)
        try? fileManager.createDirectory(at: thumbsPath, withIntermediateDirectories: true)
        return thumbsPath
    }()
    
    func persistOriginalPhotoData(imageData: Data, preferredName: String?) async throws -> String {
        let filename = (preferredName ?? UUID().uuidString) + ".jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        try imageData.write(to: fileURL)
        return fileURL.path
    }
    
    func persistThumbnailForPhoto(at localPath: String) async throws -> String {
        let originalURL = URL(fileURLWithPath: localPath)
        guard let image = UIImage(contentsOfFile: originalURL.path) else {
            throw AuroraFluxError.storageError("Cannot load image")
        }
        
        let thumbnailSize = CGSize(width: 300, height: 300)
        let thumbnail = image.preparingThumbnail(of: thumbnailSize) ?? image
        
        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw AuroraFluxError.storageError("Cannot create thumbnail")
        }
        
        let thumbFilename = originalURL.deletingPathExtension().lastPathComponent + "_thumb.jpg"
        let thumbURL = thumbnailsDirectory.appendingPathComponent(thumbFilename)
        
        try thumbnailData.write(to: thumbURL)
        return thumbURL.path
    }
    
    func removePhotoFile(at localPath: String) async throws {
        let fileURL = URL(fileURLWithPath: localPath)
        guard fileManager.fileExists(atPath: localPath) else {
            return
        }
        try fileManager.removeItem(at: fileURL)
    }
}

