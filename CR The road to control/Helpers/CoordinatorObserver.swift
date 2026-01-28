import Foundation
import WebKit

/// Singleton менеджер для управления WebView и обработки ошибок
final class TraineeModCoordinatorObserver {
    static let instance = TraineeModCoordinatorObserver()
    
    private var coachModWebView: WKWebView?
    private var traineeModStateUpdateTimer: Timer?
    
    private init() {}
    
    /// Установка WebView для управления
    func coachModSetWebView(_ webView: WKWebView) {
        guard coachModWebView !== webView else { return }
        coachModWebView = webView
        traineeModStartStateUpdateTimer()
    }
    
    /// Обработка ошибок загрузки WebView
    func traineeModHandleWebViewError(_ error: Error, url: URL?) {
        let nsError = error as NSError
        let errorCode = nsError.code
        
        // Проверяем тип ошибки
        let isTimeout = errorCode == NSURLErrorTimedOut
        let isConnectionError = errorCode == NSURLErrorNotConnectedToInternet || 
                                errorCode == NSURLErrorNetworkConnectionLost ||
                                errorCode == NSURLErrorCannotConnectToHost
        
        if isTimeout || isConnectionError {
            coachModTriggerFallback()
        } else {
            // Для других ошибок также пробуем fallback
            coachModTriggerFallback()
        }
    }
    
    /// Обработка ошибки навигации
    func coachModHandleNavigationError(_ error: Error, for url: URL?) {
        traineeModHandleWebViewError(error, url: url)
    }
    
    /// Обработка завершения загрузки страницы
    func traineeModDidFinishLoading(url: URL?) {
        guard let url = url else { return }
        
        // Проверяем, нужно ли сохранять URL
        if CoachModExerciseService.instance.traineeModShouldSaveNextURL() {
            CoachModExerciseService.instance.traineeModSaveWebViewFinalURL(url)
        }
        
        // Устанавливаем последний загруженный URL
        CoachModExerciseService.instance.coachModSetLastLoadedURL(url)
        
        // Проверяем на 404 через JavaScript
        coachModCheckFor404()
    }
    
    /// Проверка на 404 ошибку через JavaScript
    private func coachModCheckFor404() {
        guard let webView = coachModWebView else { return }
        
        let script = """
        (function() {
            var title = document.title.toLowerCase();
            var bodyText = document.body ? document.body.innerText.toLowerCase() : '';
            var is404 = title.includes('404') || 
                       title.includes('not found') || 
                       bodyText.includes('404') || 
                       bodyText.includes('not found') ||
                       bodyText.includes('page not found');
            return is404;
        })();
        """
        
        webView.evaluateJavaScript(script) { [weak self] result, error in
            if let is404 = result as? Bool, is404 {
                self?.coachModTriggerFallback()
            }
        }
    }
    
    /// Запуск fallback логики
    private func coachModTriggerFallback() {
        CoachModExerciseService.instance.coachModTryFallbackURL { [weak self] success, url in
            guard let self = self else { return }
            
            if success, let fallbackURL = url {
                DispatchQueue.main.async {
                    self.coachModWebView?.load(URLRequest(url: fallbackURL))
                }
            }
        }
    }
    
    /// Загрузка URL в WebView
    func traineeModLoadURL(_ url: URL) {
        guard let webView = coachModWebView else {
            return
        }
        
        // Проверяем, не является ли это последним загруженным URL
        if CoachModExerciseService.instance.traineeModIsLastLoadedURL(url) {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    /// Обновление состояния WebView
    func coachModUpdateState() {
        guard let webView = coachModWebView else { return }
        
        let canGoBack = webView.canGoBack
        let isLoading = webView.isLoading
        
        // Можно добавить уведомления или другие действия при изменении состояния
        // print("🔬 TraineeModCoordinatorObserver: State - canGoBack: \(canGoBack), isLoading: \(isLoading)")
    }
    
    /// Запуск таймера обновления состояния
    private func traineeModStartStateUpdateTimer() {
        coachModStopStateUpdateTimer()
        
        traineeModStateUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.coachModUpdateState()
        }
    }
    
    /// Остановка таймера обновления состояния
    func coachModStopStateUpdateTimer() {
        traineeModStateUpdateTimer?.invalidate()
        traineeModStateUpdateTimer = nil
    }
    
    deinit {
        coachModStopStateUpdateTimer()
    }
}
