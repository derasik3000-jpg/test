import SwiftUI
import WebKit

// MARK: - ResearchFlowView - Основной компонент WebView
struct TraineeModResearchFlowView: UIViewRepresentable {
    let entryURL: URL?
    @Binding var coachModCanGoBack: Bool
    @Binding var traineeModIsLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // Базовые настройки
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.suppressesIncrementalRendering = false
        configuration.allowsAirPlayForMediaPlayback = false
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // User Agent с анти-бот заголовками
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
        
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
        
        // Внешний вид
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.isOpaque = true
        
        // Делегаты
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Устанавливаем WebView в CoordinatorObserver
        TraineeModCoordinatorObserver.instance.coachModSetWebView(webView)
        context.coordinator.coachModSetWebView(webView)
        
        // Загружаем URL, если есть
        if let url = entryURL {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Always update coordinator reference
        context.coordinator.coachModSetWebView(uiView)
        
        let newCanGoBack = uiView.canGoBack
        let newIsLoading = uiView.isLoading
        
        // Update bindings
        DispatchQueue.main.async {
            self.coachModCanGoBack = newCanGoBack
            self.traineeModIsLoading = newIsLoading
        }
    }
    
    func makeCoordinator() -> CoachModCoordinator {
        CoachModCoordinator(canGoBackBinding: $coachModCanGoBack, isLoadingBinding: $traineeModIsLoading)
    }
    
    class CoachModCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        @Binding var coachModCanGoBack: Bool
        @Binding var traineeModIsLoading: Bool
        private var traineeModWebView: WKWebView?
        
        init(canGoBackBinding: Binding<Bool>, isLoadingBinding: Binding<Bool>) {
            _coachModCanGoBack = canGoBackBinding
            _traineeModIsLoading = isLoadingBinding
        }
        
        func coachModSetWebView(_ webView: WKWebView) {
            traineeModWebView = webView
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.traineeModIsLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let url = webView.url else { return }
            
            DispatchQueue.main.async {
                self.traineeModIsLoading = false
                self.coachModCanGoBack = webView.canGoBack
            }
            
            // Уведомляем CoordinatorObserver о завершении загрузки
            TraineeModCoordinatorObserver.instance.traineeModDidFinishLoading(url: url)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.traineeModIsLoading = false
            }
            
            TraineeModCoordinatorObserver.instance.coachModHandleNavigationError(error, for: webView.url)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.traineeModIsLoading = false
            }
            
            TraineeModCoordinatorObserver.instance.traineeModHandleWebViewError(error, url: webView.url)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Разрешаем все навигации
            decisionHandler(.allow)
        }
        
        // MARK: - SSL Challenge обработка
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
        
        // MARK: - WKUIDelegate
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Открываем дочерние окна в том же view
            if let targetURL = navigationAction.request.url {
                webView.load(URLRequest(url: targetURL))
            }
            return nil
        }
    }
}

// MARK: - PuwelaPanel - Обертка для WebView
struct PuwelaPanel: View {
    let entry: URL?
    @State private var coachModCanGoBack = false
    @State private var traineeModIsLoading = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            
            TraineeModResearchFlowView(
                entryURL: entry,
                coachModCanGoBack: $coachModCanGoBack,
                traineeModIsLoading: $traineeModIsLoading
            )
        }
        .statusBarHidden(true)
        .navigationBarHidden(true)
    }
}

