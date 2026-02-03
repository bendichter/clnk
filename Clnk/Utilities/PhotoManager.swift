import Foundation
import UIKit
import SwiftUI

/// Manages saving and loading review photos to the app's documents directory
class PhotoManager {
    static let shared = PhotoManager()
    
    private let fileManager = FileManager.default
    private let photosDirectoryName = "ReviewPhotos"
    
    private var photosDirectory: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(photosDirectoryName)
    }
    
    private init() {
        createPhotosDirectoryIfNeeded()
    }
    
    private func createPhotosDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: photosDirectory.path) {
            try? fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        }
    }
    
    /// Compress and save a UIImage, returns the photo ID (UUID string)
    func savePhoto(_ image: UIImage) -> String? {
        guard let compressedData = compressImage(image) else { return nil }
        
        let photoId = UUID().uuidString
        let fileURL = photosDirectory.appendingPathComponent("\(photoId).jpg")
        
        do {
            try compressedData.write(to: fileURL)
            return photoId
        } catch {
            print("Error saving photo: \(error)")
            return nil
        }
    }
    
    /// Load a photo by its ID
    func loadPhoto(id: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent("\(id).jpg")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    /// Delete a photo by its ID
    func deletePhoto(id: String) {
        let fileURL = photosDirectory.appendingPathComponent("\(id).jpg")
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Compress image to max 800x800, JPEG quality 0.7
    private func compressImage(_ image: UIImage) -> Data? {
        let maxSize: CGFloat = 800
        var scaledImage = image
        
        // Scale down if needed
        if image.size.width > maxSize || image.size.height > maxSize {
            let scale = min(maxSize / image.size.width, maxSize / image.size.height)
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }
        
        return scaledImage.jpegData(compressionQuality: 0.7)
    }
    
    /// Check if a photo ID looks like a saved photo (UUID format) vs emoji
    static func isPhotoId(_ string: String) -> Bool {
        // UUID format: 8-4-4-4-12 hex characters
        let uuidRegex = try? NSRegularExpression(
            pattern: "^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$"
        )
        let range = NSRange(string.startIndex..., in: string)
        return uuidRegex?.firstMatch(in: string, range: range) != nil
    }
}

// MARK: - SwiftUI Image Loading
extension PhotoManager {
    /// Load photo as SwiftUI Image
    func loadSwiftUIImage(id: String) -> Image? {
        guard let uiImage = loadPhoto(id: id) else { return nil }
        return Image(uiImage: uiImage)
    }
}
