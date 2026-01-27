import Foundation
import UIKit

struct UserProfile: Codable {
    var name: String
    var photoData: Data?
    
    init(name: String = "", photoData: Data? = nil) {
        self.name = name
        self.photoData = photoData
    }
    
    var photo: UIImage? {
        guard let data = photoData else { return nil }
        return UIImage(data: data)
    }
    
    mutating func setPhoto(_ image: UIImage?) {
        guard let image = image else {
            photoData = nil
            return
        }
        // Compress image to reasonable size
        photoData = image.jpegData(compressionQuality: 0.7)
    }
}


