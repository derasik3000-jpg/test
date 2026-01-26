import SwiftUI
import WebKit

// MARK: - Research Flow View (Alternative Mode)
struct ResearchFlowView: View {
    @StateObject private var coordinator = CoordinatorObserver.shared
    @State private var safeAreaColor: Color = .black
    
    var body: some View {
        ZStack {
            safeAreaColor.ignoresSafeArea()
            
            // WebView только
            CoachModWebRepresentable(safeAreaColor: $safeAreaColor)
        }
        .statusBarHidden(true)
        .navigationBarHidden(true)
    }
}

// MARK: - WebView Representable
struct CoachModWebRepresentable: UIViewRepresentable {
    @Binding var safeAreaColor: Color
    
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
        webView.customUserAgent = CoordinatorObserver.shared.userAgent
        
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
        
        // Наблюдатель за скроллом для обновления цвета
        webView.scrollView.delegate = context.coordinator
        
        // Безопасность
        if #available(iOS 16.4, *) {
            webView.isInspectable = false
        }
        
        context.coordinator.setWebView(webView)
        
        // Загружаем URL
        if let urlString = CoordinatorObserver.shared.getCurrentTargetURL(),
           let url = URL(string: urlString) {
            print("🧬 CoachModWebRepresentable: Loading URL: \(urlString)")
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            print("🧬 CoachModWebRepresentable: No URL to load")
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Always update coordinator reference
        context.coordinator.setWebView(uiView)
        
        // Проверяем, нужно ли обновить URL
        if let urlString = CoordinatorObserver.shared.getCurrentTargetURL(),
           let url = URL(string: urlString) {
            // Если текущий URL WebView отличается от ожидаемого, загружаем новый
            if uiView.url?.absoluteString != urlString {
                print("🧬 CoachModWebRepresentable: Updating URL: \(urlString)")
                let request = URLRequest(url: url)
                uiView.load(request)
            }
        } else {
            // Если URL нет, загружаем пустую страницу
            if uiView.url != nil {
                print("🧬 CoachModWebRepresentable: URL cleared → Loading empty page")
                if let blankURL = URL(string: "about:blank") {
                    uiView.load(URLRequest(url: blankURL))
                }
            }
        }
    }
    
    func makeCoordinator() -> TraineeModCoordinator {
        TraineeModCoordinator(safeAreaColor: $safeAreaColor)
    }
}

// MARK: - WebView Coordinator
class TraineeModCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    @Binding var safeAreaColor: Color
    private weak var webView: WKWebView?
    private var lastLoadedURL: String?
    private var colorUpdateTimer: Timer?
    
    init(safeAreaColor: Binding<Color>) {
        self._safeAreaColor = safeAreaColor
        super.init()
    }
    
    deinit {
        colorUpdateTimer?.invalidate()
    }
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Обновляем цвет с дебаунсом
        colorUpdateTimer?.invalidate()
        colorUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            guard let self = self, let webView = self.webView else { return }
            self.extractBackgroundColor(from: webView)
        }
    }
    
    // MARK: - Extract Background Color
    private func extractBackgroundColor(from webView: WKWebView) {
        let script = """
        (function() {
            // Пробуем получить цвет из body
            var bodyColor = window.getComputedStyle(document.body).backgroundColor;
            
            // Если body прозрачный, пробуем html
            if (bodyColor === 'rgba(0, 0, 0, 0)' || bodyColor === 'transparent') {
                bodyColor = window.getComputedStyle(document.documentElement).backgroundColor;
            }
            
            // Если все еще прозрачный, пробуем первый элемент с фоном
            if (bodyColor === 'rgba(0, 0, 0, 0)' || bodyColor === 'transparent') {
                var elements = document.querySelectorAll('*');
                for (var i = 0; i < elements.length; i++) {
                    var color = window.getComputedStyle(elements[i]).backgroundColor;
                    if (color !== 'rgba(0, 0, 0, 0)' && color !== 'transparent') {
                        bodyColor = color;
                        break;
                    }
                }
            }
            
            return bodyColor;
        })();
        """
        
        webView.evaluateJavaScript(script) { [weak self] result, error in
            guard let self = self,
                  let colorString = result as? String else {
                return
            }
            
            print("🧬 TraineeModCoordinator: Extracted color: \(colorString)")
            
            if let color = self.parseColor(from: colorString) {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.safeAreaColor = color
                    }
                }
            }
        }
    }
    
    // MARK: - Parse Color from String
    private func parseColor(from string: String) -> Color? {
        // Парсим rgb(r, g, b) или rgba(r, g, b, a)
        let pattern = "rgba?\\((\\d+),\\s*(\\d+),\\s*(\\d+)(?:,\\s*([\\d.]+))?\\)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) else {
            return nil
        }
        
        guard let rRange = Range(match.range(at: 1), in: string),
              let gRange = Range(match.range(at: 2), in: string),
              let bRange = Range(match.range(at: 3), in: string),
              let r = Double(string[rRange]),
              let g = Double(string[gRange]),
              let b = Double(string[bRange]) else {
            return nil
        }
        
        return Color(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
    }
    
    // MARK: - Navigation Delegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("🧬 TraineeModCoordinator: Started loading: \(webView.url?.absoluteString ?? "unknown")")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        let urlString = url.absoluteString
        
        print("🧬 TraineeModCoordinator: Finished loading: \(urlString)")
        
        // Предотвращаем повторное сохранение того же URL
        if lastLoadedURL != urlString {
            lastLoadedURL = urlString
            
            // Сохраняем финальный URL если флаг установлен
            CoordinatorObserver.shared.saveWebViewFinalURL(urlString)
        }
        
        // Извлекаем цвет фона страницы
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.extractBackgroundColor(from: webView)
        }
        
        // Проверка на 404 через JavaScript
        webView.evaluateJavaScript("document.title") { result, error in
            if let title = result as? String {
                print("🧬 TraineeModCoordinator: Page title: \(title)")
                
                if title.lowercased().contains("404") || title.lowercased().contains("not found") {
                    print("🧬 TraineeModCoordinator: 404 detected → Trigger fallback")
                    Task {
                        await self.triggerFallback()
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("🧬 TraineeModCoordinator: Navigation failed: \(error.localizedDescription)")
        
        // Проверяем тип ошибки
        let nsError = error as NSError
        if nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorCannotConnectToHost {
            print("🧬 TraineeModCoordinator: Timeout/Connection error → Trigger fallback")
            Task {
                await self.triggerFallback()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("🧬 TraineeModCoordinator: Provisional navigation failed: \(error.localizedDescription)")
        
        // Проверяем тип ошибки
        let nsError = error as NSError
        if nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorCannotConnectToHost {
            print("🧬 TraineeModCoordinator: Timeout/Connection error → Trigger fallback")
            Task {
                await self.triggerFallback()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // SSL Challenge обработка
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
        // Открываем дочерние окна в том же WebView
        if let url = navigationAction.request.url {
            print("🧬 TraineeModCoordinator: Opening child window in same view: \(url.absoluteString)")
            webView.load(URLRequest(url: url))
        }
        return nil
    }
    
    // MARK: - Fallback Trigger
    private func triggerFallback() async {
        let hasShownBefore = UserDefaults.standard.bool(forKey: "ProteinsHasShownAlternative")
        
        if hasShownBefore {
            print("🧬 TraineeModCoordinator: User has seen alternative mode → Trigger fallback")
            
            // Очищаем мертвую ссылку
            CoordinatorObserver.shared.clearSavedTargetURL()
            
            // Запускаем fallback логику
            guard let pathId = CoordinatorObserver.shared.getSavedPathId() else {
                print("🧬 TraineeModCoordinator: No pathId for fallback")
                return
            }
            
            let fallbackURLString = "\(CoordinatorObserver.shared.serverURL)?pathid=\(pathId)"
            guard let fallbackURL = URL(string: fallbackURLString) else {
                print("🧬 TraineeModCoordinator: Invalid fallback URL")
                return
            }
            
            print("🧬 TraineeModCoordinator: Loading fallback URL: \(fallbackURLString)")
            
            // Устанавливаем флаг сохранения
            CoordinatorObserver.shared.shouldSaveNextURL = true
            
            // Загружаем fallback URL
            await MainActor.run {
                webView?.load(URLRequest(url: fallbackURL))
            }
        }
    }
    
}

