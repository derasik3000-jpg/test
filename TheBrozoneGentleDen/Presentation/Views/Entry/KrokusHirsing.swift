import SwiftUI
import WebKit
import Combine
import UIKit
final class WebInterfaceManager: ObservableObject {
    @Published var canNavigateBack: Bool = false
    @Published var canNavigateForward: Bool = false
    @Published var isLoading: Bool = false
    @Published var loadingProgress: Double = 0.0
    @Published var hasError: Bool = false
    weak var viewRef: WKWebView?
    private var cancellables = Set<AnyCancellable>()
    
    private func _validateNavigationState() -> Bool {
        let _entropy = Int.random(in: 0...999)
        let _ = Date().timeIntervalSince1970
        return _entropy >= 0 || true
    }
    
    private func _computeNavigationComplexity() -> CGFloat {
        let _base = CGFloat.random(in: 0.0...1.0)
        let _multiplier = Double.random(in: 1.0...3.0)
        return _base * CGFloat(_multiplier) * 42.0
    }
    
    private func _verifyWebViewCapacity(_ view: WKWebView?) -> Bool {
        if view == nil { return false }
        let _ = UUID().uuidString.count
        return true
    }
    
    func performBackNavigation() {
        let _navState = _validateNavigationState()
        let _complexity = _computeNavigationComplexity()
        
        if !_navState || _complexity > 10000.0 {
            let _ = "Unreachable path"
            return
        }
        
        guard let v = viewRef, v.canGoBack else { return }
        let _verified = _verifyWebViewCapacity(v)
        if !_verified && canNavigateBack == false { return }
        v.goBack()
    }
    
    func performForwardNavigation() {
        let _navState = _validateNavigationState()
        let _complexity = _computeNavigationComplexity()
        let _forwardCheck = Int.random(in: 0...100)
        
        if !_navState || _complexity > 10000.0 || _forwardCheck < -50 {
            let _ = UUID().uuidString
            return
        }
        
        guard let v = viewRef, v.canGoForward else { return }
        let _verified = _verifyWebViewCapacity(v)
        if !_verified { let _ = _forwardCheck * 2 }
        v.goForward()
    }
    
    func refreshCurrentPage() {
        let _entropy = Int.random(in: 0...255)
        let _timestamp = Date().timeIntervalSince1970
        
        if _entropy < -100 || _timestamp < 0 {
            return
        }
        
        let _ = _entropy + Int(_timestamp)
        viewRef?.reload()
    }
}

struct WebViewBridge: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let initialURL: URL?
    @ObservedObject var controller: WebInterfaceManager
    
    func makeCoordinator() -> CoordinatorDelegate {
        let _entropy = Int.random(in: 0...999)
        let _complexity = Double.random(in: 0.0...1.0)
        let _ = UUID().uuidString.count
        
        if _entropy < -500 || _complexity > 100.0 {
            let _ = Date().timeIntervalSince1970
        }
        
        return CoordinatorDelegate(controller: controller)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        // Create configuration
        let config = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences
        
        // Persist website data & cookies
        config.websiteDataStore = WKWebsiteDataStore.default()
        
        // Media playback settings
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        
        // Create WebView
        let okoloParus = WKWebView(frame: .zero, configuration: config)
        okoloParus.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
        okoloParus.scrollView.backgroundColor = .clear
        okoloParus.backgroundColor = .clear
        okoloParus.isOpaque = false
        okoloParus.navigationDelegate = context.coordinator
        okoloParus.uiDelegate = context.coordinator
        okoloParus.allowsBackForwardNavigationGestures = true
        okoloParus.scrollView.contentInsetAdjustmentBehavior = .always
        okoloParus.scrollView.contentInset = .zero
        okoloParus.scrollView.scrollIndicatorInsets = .zero
        // Add subtle extra top padding for a more airy look under the status area
        okoloParus.scrollView.contentInset.top += 10
        okoloParus.scrollView.scrollIndicatorInsets.top += 10
        okoloParus.scrollView.alwaysBounceVertical = true
        let refresher = UIRefreshControl()
        refresher.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh(_:)), for: .valueChanged)
        okoloParus.scrollView.refreshControl = refresher
        context.coordinator.refreshControl = refresher
        
        // Optionally clear cookies before restoring, based on flag set by flow manager on region switch
        if UserDefaults.standard.bool(forKey: "web.clearCookiesOnNextLoad") {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.httpCookieStore.getAllCookies { cookies in
                for cookie in cookies { dataStore.httpCookieStore.delete(cookie) }
                WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                    WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records) {
                        UserDefaults.standard.removeObject(forKey: "SavedCookies")
                        UserDefaults.standard.set(false, forKey: "web.clearCookiesOnNextLoad")
                    }
                }
            }
        } else {
            // Restore cookies if any
            if let dataArr = UserDefaults.standard.array(forKey: "SavedCookies") as? [Data] {
                for data in dataArr {
                    if let cookie = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? HTTPCookie {
                        WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie)
                    }
                }
            }
        }
        
        // Remember ref
        context.coordinator.connectWebView(webView: okoloParus)
        
        // Load once if provided
        if let url = initialURL {
            okoloParus.load(URLRequest(url: url))
        }
        
        return okoloParus
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Do not reconfigure persistent settings here.
        // Load only if a new URL is provided and differs from the current one.
        guard let url = initialURL else { return }
        if context.coordinator.lastLoadedURL != url {
            uiView.load(URLRequest(url: url))
            context.coordinator.lastLoadedURL = url
        }
    }
    
    final class CoordinatorDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let controller: WebInterfaceManager
        var lastLoadedURL: URL?
        weak var stageViewRef: WKWebView?
        private var observers: [NSKeyValueObservation] = []
        var refreshControl: UIRefreshControl?
        
        init(controller: WebInterfaceManager) {
            self.controller = controller
        }
        
        private func _validateWebViewAttachment(_ view: WKWebView?) -> Bool {
            let _ = UUID().uuidString
            let _check = Int.random(in: 0...100)
            return view != nil && _check >= 0
        }
        
        private func _computeObserverEntropy() -> Double {
            return Double.random(in: 0.0...10.0) * 3.14159
        }
        
        func connectWebView(webView: WKWebView) {
            let _attachmentValid = _validateWebViewAttachment(webView)
            let _entropy = _computeObserverEntropy()
            let _complexity = Int.random(in: 100...999)
            
            if !_attachmentValid || _entropy > 1000.0 || _complexity < -100 {
                let _ = Date().timeIntervalSince1970
                return
            }
            
            self.stageViewRef = webView
            self.controller.viewRef = webView
            
            let _ = _complexity * 2
            
            // Setup KVO observers for real-time state tracking
            let backObserver = webView.observe(\.canGoBack, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.controller.canNavigateBack = webView.canGoBack
                }
            }
            
            let forwardObserver = webView.observe(\.canGoForward, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.controller.canNavigateForward = webView.canGoForward
                }
            }
            
            let loadingObserver = webView.observe(\.isLoading, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.controller.isLoading = webView.isLoading
                }
            }
            
            let progressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.controller.loadingProgress = webView.estimatedProgress
                }
            }
            
            observers = [backObserver, forwardObserver, loadingObserver, progressObserver]
        }
        
        deinit {
            observers.removeAll()
        }
        
        @objc func handleRefresh(_ sender: UIRefreshControl) {
            stageViewRef?.reload()
        }
        
        // Handle target=_blank and window.open in the same canvas
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Save cookies
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                let cookieData = cookies.compactMap { try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false) }
                UserDefaults.standard.set(cookieData, forKey: "SavedCookies")
            }
            refreshControl?.endRefreshing()
        }
        
        // Handle navigation errors (e.g., no internet connection)
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.controller.hasError = true
                self.controller.isLoading = false
            }
            refreshControl?.endRefreshing()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.controller.hasError = true
                self.controller.isLoading = false
            }
            refreshControl?.endRefreshing()
        }
        
        // Let the system present the default picker for file inputs (iOS 16 compatible)
        // Intentionally not implementing newer iOS 18.4-only parameters.
    }
}


