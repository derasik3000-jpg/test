

import SwiftUI
import WebKit

struct PuwelaPanel: UIViewRepresentable {
    let url: URL
    var onError: ((Error) -> Void)?
    var on404Detected: (() -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.isOpaque = false
        webView.allowsBackForwardNavigationGestures = true
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        let refresher = UIRefreshControl()
        refresher.tintColor = .white
        refresher.addTarget(context.coordinator, action: #selector(Coordinator.refreshPage), for: .valueChanged)
        webView.scrollView.refreshControl = refresher
        
        context.coordinator.webView = webView
        context.coordinator.refreshControl = refresher
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Загружаем URL только при первом создании или если URL изменился извне (fallback)
        // Не перезагружаем при внутренних переходах WebView
        if context.coordinator.initialURL == nil {
            // Первая загрузка
            context.coordinator.initialURL = url
            print("🔄 Initial load: \(url.absoluteString)")
            var request = URLRequest(url: url)
            request.timeoutInterval = 10.0
            webView.load(request)
            
            // Устанавливаем таймаут для автоматического fallback если загрузка слишком долгая
            DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                if webView.isLoading {
                    print("⏱️ WebView loading timeout, triggering fallback")
                    context.coordinator.onError?(NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: [NSLocalizedDescriptionKey: "Request timeout"]))
                }
            }
        } else if context.coordinator.initialURL != url && !context.coordinator.isUserNavigation {
            // URL изменился извне (fallback), загружаем новый URL
            print("🔄 External URL change (fallback): \(url.absoluteString)")
            context.coordinator.initialURL = url
            var request = URLRequest(url: url)
            request.timeoutInterval = 10.0
            webView.load(request)
        }
        // Если URL не изменился или это пользовательская навигация - ничего не делаем
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onError: onError, on404Detected: on404Detected)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var webView: WKWebView?
        var refreshControl: UIRefreshControl?
        var onError: ((Error) -> Void)?
        var on404Detected: (() -> Void)?
        var initialURL: URL?
        var isUserNavigation = false
        
        init(onError: ((Error) -> Void)?, on404Detected: (() -> Void)?) {
            self.onError = onError
            self.on404Detected = on404Detected
        }
        
        @objc func refreshPage() {
            webView?.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.refreshControl?.endRefreshing()
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if let url = webView.url {
                print("🌐 WebView started loading: \(url.absoluteString)")
            } else if let request = webView.url?.absoluteString {
                print("🌐 WebView started loading (provisional): \(request)")
            }
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            if let url = webView.url {
                print("✅ WebView committe navigation: \(url.absoluteString)")
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            refreshControl?.endRefreshing()
            if let url = webView.url {
                print("✅ WebView finished loading: \(url.absoluteString)")
            }
            checkFor404(in: webView)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            refreshControl?.endRefreshing()
            let nsError = error as NSError
            print("❌ WebView navigation error: \(error.localizedDescription) (code: \(nsError.code))")
            
            // Сразу вызываем fallback только для критических сетевых ошибок
            // Не вызываем для обычных переходов между страницами
            if isNetworkError(error) && !isNavigationInProgress {
                print("🚨 Network error detected, triggering fallback immediately")
                DispatchQueue.main.async {
                    self.onError?(error)
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            refreshControl?.endRefreshing()
            let nsError = error as NSError
            print("❌ WebView provisional navigation error: \(error.localizedDescription) (code: \(nsError.code))")
            
            // Сразу вызываем fallback для любых сетевых ошибок (это происходит раньше, чем didFail)
            if isNetworkError(error) {
                print("🚨 Network error detected in provisional navigation, triggering fallback immediately")
                DispatchQueue.main.async {
                    self.onError?(error)
                }
            }
        }
        
        private var isNavigationInProgress = false
        
        private func isNetworkError(_ error: Error) -> Bool {
            let nsError = error as NSError
            return nsError.domain == NSURLErrorDomain && (
                nsError.code == NSURLErrorTimedOut ||
                nsError.code == NSURLErrorNotConnectedToInternet ||
                nsError.code == NSURLErrorNetworkConnectionLost ||
                nsError.code == NSURLErrorCannotFindHost ||
                nsError.code == NSURLErrorCannotConnectToHost ||
                nsError.code == NSURLErrorDNSLookupFailed ||
                nsError.code == NSURLErrorHTTPTooManyRedirects ||
                nsError.code == NSURLErrorResourceUnavailable ||
                nsError.code == NSURLErrorBadServerResponse
            )
        }
        
        private func checkFor404(in webView: WKWebView) {
            let script = """
            (function() {
                var title = document.title.toLowerCase();
                var bodyText = document.body ? document.body.innerText.toLowerCase() : '';
                var is404 = title.includes('404') || 
                           bodyText.includes('404') || 
                           bodyText.includes('not found') ||
                           bodyText.includes('page not found');
                return is404;
            })();
            """
            
            webView.evaluateJavaScript(script) { [weak self] result, error in
                if let is404 = result as? Bool, is404 {
                    print("⚠️ 404 detected in WebView")
                    self?.on404Detected?()
                }
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = action.request.url {
                // Игнорируем about:blank и другие служебные URL
                if url.absoluteString == "about:blank" {
                    decisionHandler(.allow)
                    return
                }
                
                print("🔗 WebView navigation decision: \(url.absoluteString)")
                
                // Помечаем как пользовательскую навигацию (внутренний переход)
                isUserNavigation = true
                isNavigationInProgress = true
                
                // Разрешаем все навигации
                decisionHandler(.allow)
                
                // Сбрасываем флаги через небольшую задержку
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isNavigationInProgress = false
                    self.isUserNavigation = false
                }
            } else {
                decisionHandler(.allow)
            }
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if action.targetFrame == nil {
                webView.load(action.request)
            }
            return nil
        }
    }
}
