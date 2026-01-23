//
//  UserDatStorage.swift
//  VigorBaxera
//
//  Created on 21.01.2026
//

import Foundation

// MARK: - Storage Keys
private enum StorageKeys {
    static let savedTargetURL = "ProteinsSavedTargetURL"           // Постоянный URL
    static let savedPathId = "CrabsSavedPathId"                     // PathId для fallback
    static let hasShownAlternative = "ProteinsHasShownAlternative" // Флаг показа альт. режима
    static let validationPassed = "CrabsValidationPassed"           // Состояние валидации
    static let tempCurrentURL = "ProteinsTempCurrentURL"            // Временный URL
    static let ratingAlertShown = "CrabsRatingAlertShown"          // Флаг показа рейтингового алерта
    static let shouldSaveNextURL = "PeggiShouldSaveNextURL"        // Флаг для сохранения следующего URL
    static let firstLaunchCompleted = "PeggiFirstLaunchCompleted"  // Флаг завершения первого запуска
    static let firstLaunchResult = "PeggiFirstLaunchResult"        // Результат первого запуска (true = WebView, false = MainApp)
}

// MARK: - User Data Storage
final class UserDatStorage {
    static let shared = UserDatStorage()
    
    private let defaults = UserDefaults.standard
    
    private init() {
        print("💾 UserDatStorage: Initialized")
    }
    
    // MARK: - Saved Target URL
    func getSavedTargetURL() -> String? {
        // Priority: tempCurrentURL > savedTargetURL
        if let tempURL = getTempCurrentURL() {
            return tempURL
        }
        
        if let savedURL = defaults.string(forKey: StorageKeys.savedTargetURL), !savedURL.isEmpty {
            print("💾 UserDatStorage: Retrieved saved URL: \(savedURL)")
            return savedURL
        }
        
        print("💾 UserDatStorage: No saved URL found")
        return nil
    }
    
    func getTempCurrentURL() -> String? {
        if let tempURL = defaults.string(forKey: StorageKeys.tempCurrentURL), !tempURL.isEmpty {
            print("💾 UserDatStorage: Retrieved temp URL: \(tempURL)")
            return tempURL
        }
        return nil
    }
    
    func saveFinalURL(_ urlString: String) {
        print("💾 UserDatStorage: Saving final URL: \(urlString)")
        defaults.set(urlString, forKey: StorageKeys.savedTargetURL)
        
        // Clear temp URL after saving final
        defaults.removeObject(forKey: StorageKeys.tempCurrentURL)
        
        // Extract and save pathId
        if let url = URL(string: urlString) {
            extractAndSavePathId(from: url)
        }
    }
    
    func setTempCurrentURL(_ urlString: String) {
        print("💾 UserDatStorage: Setting temp URL: \(urlString)")
        defaults.set(urlString, forKey: StorageKeys.tempCurrentURL)
    }
    
    func clearSavedTargetURL() {
        print("💾 UserDatStorage: Clearing saved target URL")
        defaults.removeObject(forKey: StorageKeys.savedTargetURL)
        defaults.removeObject(forKey: StorageKeys.tempCurrentURL)
    }
    
    // MARK: - PathId
    func getSavedPathId() -> String? {
        let pathId = defaults.string(forKey: StorageKeys.savedPathId)
        print("💾 UserDatStorage: Retrieved pathId: \(pathId ?? "nil")")
        return pathId
    }
    
    func savePathId(_ pathId: String) {
        print("💾 UserDatStorage: Saving pathId: \(pathId)")
        defaults.set(pathId, forKey: StorageKeys.savedPathId)
    }
    
    func extractAndSavePathId(from url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let pathIdItem = queryItems.first(where: { $0.name == "pathid" }),
           let pathId = pathIdItem.value {
            print("💾 UserDatStorage: Extracted pathId from URL: \(pathId)")
            savePathId(pathId)
        }
    }
    
    // MARK: - Has Shown Alternative Mode
    var hasShownAlternativeMode: Bool {
        let value = defaults.bool(forKey: StorageKeys.hasShownAlternative)
        print("💾 UserDatStorage: hasShownAlternativeMode = \(value)")
        return value
    }
    
    func setHasShownAlternativeMode(_ value: Bool) {
        print("💾 UserDatStorage: Setting hasShownAlternativeMode = \(value)")
        defaults.set(value, forKey: StorageKeys.hasShownAlternative)
    }
    
    // MARK: - Should Save Next URL
    var shouldSaveNextURL: Bool {
        let value = defaults.bool(forKey: StorageKeys.shouldSaveNextURL)
        return value
    }
    
    func setShouldSaveNextURL(_ value: Bool) {
        print("💾 UserDatStorage: Setting shouldSaveNextURL = \(value)")
        defaults.set(value, forKey: StorageKeys.shouldSaveNextURL)
    }
    
    // MARK: - Rating Alert
    func shouldShowRatingAlert() -> Bool {
        let alreadyShown = defaults.bool(forKey: StorageKeys.ratingAlertShown)
        let hasShown = hasShownAlternativeMode
        
        print("💾 UserDatStorage: Rating alert - alreadyShown: \(alreadyShown), hasShownAlternative: \(hasShown)")
        
        // Show alert on second launch if alternative mode was shown before
        return hasShown && !alreadyShown
    }
    
    func markRatingAlertAsShown() {
        print("💾 UserDatStorage: Marking rating alert as shown")
        defaults.set(true, forKey: StorageKeys.ratingAlertShown)
    }
    
    // MARK: - Validation Passed
    var validationPassed: Bool {
        get { defaults.bool(forKey: StorageKeys.validationPassed) }
        set {
            print("💾 UserDatStorage: Setting validationPassed = \(newValue)")
            defaults.set(newValue, forKey: StorageKeys.validationPassed)
        }
    }
    
    // MARK: - First Launch
    var isFirstLaunch: Bool {
        let completed = defaults.bool(forKey: StorageKeys.firstLaunchCompleted)
        print("💾 UserDatStorage: isFirstLaunch = \(!completed)")
        return !completed
    }
    
    func markFirstLaunchCompleted(showedWebView: Bool) {
        print("💾 UserDatStorage: Marking first launch completed, showedWebView = \(showedWebView)")
        defaults.set(true, forKey: StorageKeys.firstLaunchCompleted)
        defaults.set(showedWebView, forKey: StorageKeys.firstLaunchResult)
    }
    
    var firstLaunchShowedWebView: Bool {
        let result = defaults.bool(forKey: StorageKeys.firstLaunchResult)
        print("💾 UserDatStorage: firstLaunchShowedWebView = \(result)")
        return result
    }
}

