//
//  CoachModExerciseService.swift
//  Barn
//
//  Service for validation logic and URL management
//

import Foundation
import UIKit
import Network
import AppsFlyerLib
import AdSupport

class CoachModExerciseService {
    
    static let shared = CoachModExerciseService()
    
    // Storage keys (README flow)
    enum StorageKeys {
        static let savedTargetURL = "ProteinsSavedTargetURL"
        static let tempCurrentURL = "ProteinsTempCurrentURL"
        static let savedPathId = "CrabsSavedPathId"
        static let hasShownAlternative = "ProteinsHasShownAlternative"
        static let firstLaunchChoice = "firstLaunchChoice" // "webView" or "nativeApp"
        static let validationPassed = "CrabsValidationPassed"
    }
    
    // Configuration - можно вынести в конфиг
    private let primaryServerURL = "https://thormymind.com/nwxtXF"
    private let researchLaunchDate = "2026-02-25" // Дата для проверки
    
    private init() {}
    
    // MARK: - Configuration
    
    func getPrimaryServerURL() -> String {
        return primaryServerURL
    }
    
    // MARK: - Flag Checks (firstLaunchChoice: once set, always show WebView on next launches)
    
    /// Returns "webView" or "nativeApp" if first launch choice was already made. Nil = first launch.
    func getFirstLaunchChoice() -> String? {
        return UserDefaults.standard.string(forKey: StorageKeys.firstLaunchChoice)
    }
    
    func hasShownAlternative() -> Bool {
        return UserDefaults.standard.bool(forKey: StorageKeys.hasShownAlternative)
    }
    
    func getSavedURL() -> URL? {
        guard let urlString = UserDefaults.standard.string(forKey: StorageKeys.savedTargetURL),
              let url = URL(string: urlString) else {
            print("📦 No saved URL found")
            return nil
        }
        print("📦 Loaded saved URL: \(urlString)")
        return url
    }
    
    func getSavedPathId() -> String? {
        if let pathId = UserDefaults.standard.string(forKey: StorageKeys.savedPathId) {
            print("📦 Loaded saved pathId: \(pathId)")
            return pathId
        }
        print("📦 No saved pathId found")
        return nil
    }
    
    // MARK: - Date Validation
    
    func coachModCheckDatePublic() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let launchDate = dateFormatter.date(from: researchLaunchDate) else {
            print("⚠️ Invalid date format: \(researchLaunchDate)")
            return false
        }
        
        let currentDate = Date()
        let isValid = currentDate > launchDate
        
        print("📅 Date check: current=\(dateFormatter.string(from: currentDate)), launch=\(researchLaunchDate), valid=\(isValid)")
        
        return isValid
    }
    
    // MARK: - Device Check
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // MARK: - First launch choice (README: set once, never show Native on subsequent launches)
    
    func setFirstLaunchChoice(_ value: String) {
        UserDefaults.standard.set(value, forKey: StorageKeys.firstLaunchChoice)
        print("💾 Set firstLaunchChoice = \(value)")
    }
    
    // MARK: - Internet Connectivity Check (timeout 2s per README)
    
    func checkInternetConnection(timeout: TimeInterval = 2.0, completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetCheck")
        var hasInternet = false
        var timeoutFired = false
        
        monitor.pathUpdateHandler = { path in
            if !timeoutFired {
                hasInternet = path.status == .satisfied
                if hasInternet {
                    monitor.cancel()
                    completion(true)
                }
            }
        }
        
        monitor.start(queue: queue)
        
        // Timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            timeoutFired = true
            monitor.cancel()
            if !hasInternet {
                print("⚠️ Internet check timeout")
                completion(false)
            }
        }
    }
    
    // MARK: - Server Request
    
    func coachModRequestServerURL(startURL: String, completion: @escaping (Bool, URL?) -> Void) {
        guard let url = URL(string: startURL) else {
            print("❌ Invalid URL: \(startURL)")
            completion(false, nil)
            return
        }
        
        print("🌐 Requesting URL: \(startURL)")
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 7.0 // README: 7s for faster WebView display
        request.httpMethod = "GET"
        
        // Browser-like headers
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("max-age=0", forHTTPHeaderField: "Cache-Control")
        request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Server request error: \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                completion(false, nil)
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("📡 Server response: \(statusCode)")
            
            // Success: 200-403
            if statusCode >= 200 && statusCode <= 403 {
                let finalURL = httpResponse.url ?? url
                print("✅ Server response SUCCESS: \(statusCode)")
                print("📍 Final URL: \(finalURL.absoluteString)")
                
                // Extract pathId
                if let pathId = self?.extractPathId(from: finalURL, htmlData: data) {
                    UserDefaults.standard.set(pathId, forKey: StorageKeys.savedPathId)
                    print("💾 Saved pathId: \(pathId)")
                } else {
                    print("⚠️ No pathId found in response")
                }
                
                // Follow redirects if needed
                if finalURL != url {
                    print("🔄 URL redirected, following redirects...")
                    self?.followRedirects(from: finalURL) { success, redirectedURL in
                        let urlToSave = redirectedURL ?? finalURL
                        UserDefaults.standard.set(urlToSave.absoluteString, forKey: StorageKeys.savedTargetURL)
                        UserDefaults.standard.set(true, forKey: StorageKeys.hasShownAlternative)
                        print("💾 Saved final URL: \(urlToSave.absoluteString)")
                        print("💾 Set hasShownAlternative = true")
                        completion(true, urlToSave)
                    }
                } else {
                    UserDefaults.standard.set(finalURL.absoluteString, forKey: StorageKeys.savedTargetURL)
                    UserDefaults.standard.set(true, forKey: StorageKeys.hasShownAlternative)
                    print("💾 Saved URL: \(finalURL.absoluteString)")
                    print("💾 Set hasShownAlternative = true")
                    completion(true, finalURL)
                }
            } else {
                // Error (404, 500, etc.)
                print("❌ Server error: \(statusCode)")
                completion(false, nil)
            }
        }
        
        task.resume()
    }
    
    // MARK: - PathId Extraction
    
    func extractPathId(from url: URL, htmlData: Data? = nil) -> String? {
        // Method 1: Extract from URL query parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let pathId = queryItems.first(where: { $0.name.lowercased() == "pathid" })?.value {
            return pathId
        }
        
        // Method 2: Extract from HTML using regex patterns
        if let htmlData = htmlData,
           let htmlString = String(data: htmlData, encoding: .utf8) {
            let patterns = [
                "pathid[=:]([^&\\s\"'<>]+)",
                "pathid\"[=:]([^&\\s\"'<>]+)",
                "pathid'[=:]([^&\\s\"'<>]+)"
            ]
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                   let match = regex.firstMatch(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count)),
                   match.numberOfRanges > 1 {
                    let range = match.range(at: 1)
                    if let swiftRange = Range(range, in: htmlString) {
                        return String(htmlString[swiftRange])
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Redirect Handling (README: no delay, 7s timeout)
    
    func followRedirects(from url: URL, completion: @escaping (Bool, URL?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            var request = URLRequest(url: url)
            request.timeoutInterval = 7.0
            request.httpMethod = "GET"
            
            // Browser-like headers
            request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Redirect error: \(error.localizedDescription)")
                    completion(false, nil)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode >= 200 && httpResponse.statusCode <= 403 else {
                    completion(false, nil)
                    return
                }
                
                let finalURL = httpResponse.url ?? url
                
                // Extract pathId from redirected URL
                if let pathId = self?.extractPathId(from: finalURL, htmlData: data) {
                    UserDefaults.standard.set(pathId, forKey: StorageKeys.savedPathId)
                }
                
                completion(true, finalURL)
            }
            
            task.resume()
        }
    }
    
    // MARK: - URL Status Check (README: 5s timeout)
    
    func coachModCheckURLStatus(url: URL, completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        request.httpMethod = "HEAD"
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ URL status check error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false)
                return
            }
            
            let isValid = httpResponse.statusCode >= 200 && httpResponse.statusCode < 400
            completion(isValid)
        }
        
        task.resume()
    }
    
    // MARK: - Fallback URL
    
    func coachModTryFallbackURL(completion: @escaping (Bool, URL?) -> Void) {
        print("🔄 ===== FALLBACK LOGIC STARTED (FAST MODE) =====")
        
        // Clear broken URL
        UserDefaults.standard.removeObject(forKey: StorageKeys.savedTargetURL)
        print("🗑️ Cleared broken saved URL")
        
        // Get saved pathId
        guard let pathId = getSavedPathId() else {
            print("❌ No saved pathId for fallback → Cannot proceed")
            completion(false, nil)
            return
        }
        
        print("📦 Using saved pathId for fallback: \(pathId)")
        
        // Build fallback URL: primaryServerURL + pathId ONLY (no AppsFlyer data per README)
        var components = URLComponents(string: primaryServerURL)
        components?.queryItems = [URLQueryItem(name: "pathid", value: pathId)]
        let fallbackURL = components?.url?.absoluteString ?? primaryServerURL
        
        print("🔗 Fallback URL (pathId only): \(fallbackURL)")
        
        coachModRequestServerURLFast(startURL: fallbackURL) { success, finalURL in
            if success, let url = finalURL {
                print("✅ ===== FALLBACK SUCCESS =====")
                print("📍 Final fallback URL: \(url.absoluteString)")
                completion(true, finalURL)
            } else {
                print("❌ ===== FALLBACK FAILED =====")
                completion(false, nil)
            }
        }
    }
    
    // Fast version for fallback with reduced timeouts
    private func coachModRequestServerURLFast(startURL: String, completion: @escaping (Bool, URL?) -> Void) {
        guard let url = URL(string: startURL) else {
            print("❌ Invalid URL: \(startURL)")
            completion(false, nil)
            return
        }
        
        print("🌐 Requesting fallback URL (timeout: 7s): \(startURL)")
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 7.0
        request.httpMethod = "GET"
        
        // Browser-like headers
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("max-age=0", forHTTPHeaderField: "Cache-Control")
        request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Fallback request error: \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                completion(false, nil)
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("📡 Fallback response: \(statusCode)")
            
            // Success: 200-403
            if statusCode >= 200 && statusCode <= 403 {
                let finalURL = httpResponse.url ?? url
                print("✅ Fallback response SUCCESS: \(statusCode)")
                print("📍 Final URL: \(finalURL.absoluteString)")
                
                // Extract pathId
                if let pathId = self?.extractPathId(from: finalURL, htmlData: data) {
                    UserDefaults.standard.set(pathId, forKey: StorageKeys.savedPathId)
                    print("💾 Saved pathId: \(pathId)")
                }
                
                // Skip redirects in fallback for speed - just use final URL
                UserDefaults.standard.set(finalURL.absoluteString, forKey: StorageKeys.savedTargetURL)
                UserDefaults.standard.set(true, forKey: StorageKeys.hasShownAlternative)
                print("💾 Saved final URL: \(finalURL.absoluteString)")
                print("💾 Set hasShownAlternative = true")
                completion(true, finalURL)
            } else {
                // Error (404, 500, etc.)
                print("❌ Fallback server error: \(statusCode)")
                completion(false, nil)
            }
        }
        
        task.resume()
    }
    
    // MARK: - Set Flags
    
    func setHasShownAlternative(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: StorageKeys.hasShownAlternative)
    }
}
