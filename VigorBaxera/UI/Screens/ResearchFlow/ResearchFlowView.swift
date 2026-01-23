//
//  ResearchFlowView.swift
//  VigorBaxera
//
//  Created on 21.01.2026
//

import SwiftUI
import WebKit

// MARK: - Research Flow View
struct ResearchFlowView: View {
    @StateObject private var coordinator = CoordinatorObserver.shared
    @State private var canGoBack: Bool = false
    @State private var isLoading: Bool = false
    @State private var lastLoadedURL: String = ""
    @State private var safeAreaColor: Color = .white
    
    var body: some View {
        PeggiWebViewRepresentable(
            canGoBackBinding: $canGoBack,
            isLoadingBinding: $isLoading,
            lastLoadedURLBinding: $lastLoadedURL,
            safeAreaColorBinding: $safeAreaColor
        )
        .edgesIgnoringSafeArea([])
        .statusBarHidden(false)
        .navigationBarHidden(true)
    }
}


// MARK: - WebView Representable
struct PeggiWebViewRepresentable: UIViewRepresentable {
    @Binding var canGoBackBinding: Bool
    @Binding var isLoadingBinding: Bool
    @Binding var lastLoadedURLBinding: String
    @Binding var safeAreaColorBinding: Color
    
    func makeUIView(context: Context) -> WKWebView {
        print("🌐 PeggiWebView: Creating WKWebView")
        
        let configuration = WKWebViewConfiguration()
        
        // JavaScript settings
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        // Media settings
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.suppressesIncrementalRendering = false
        configuration.allowsAirPlayForMediaPlayback = false
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // Set delegates
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Custom User Agent
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
        
        // Scroll view optimizations
        webView.scrollView.keyboardDismissMode = .interactive
        webView.scrollView.delaysContentTouches = false
        webView.scrollView.canCancelContentTouches = true
        webView.scrollView.scrollsToTop = false
        
        // Respect safe area
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        // Navigation gestures
        webView.allowsLinkPreview = false
        webView.allowsBackForwardNavigationGestures = true
        
        // Security
        if #available(iOS 16.4, *) {
            webView.isInspectable = false
        }
        
        // Background color
        webView.backgroundColor = .white
        webView.isOpaque = true
        webView.scrollView.backgroundColor = .white
        
        // Store reference in coordinator
        context.coordinator.setWebView(webView)
        context.coordinator.safeAreaColorBinding = $safeAreaColorBinding
        
        // Load URL from storage or temp
        loadInitialURL(webView: webView)
        
        // Setup notification observers
        context.coordinator.setupNotifications()
        
        return webView
    }
    
    private func loadInitialURL(webView: WKWebView) {
        // Try to get temp URL first (from validation), then saved URL
        if let tempURL = UserDatStorage.shared.getTempCurrentURL(),
           let url = URL(string: tempURL) {
            print("🌐 PeggiWebView: Loading temp URL: \(tempURL)")
            webView.load(URLRequest(url: url))
        } else if let savedURL = UserDatStorage.shared.getSavedTargetURL(),
                  let url = URL(string: savedURL) {
            print("🌐 PeggiWebView: Loading saved URL: \(savedURL)")
            webView.load(URLRequest(url: url))
        } else {
            print("🌐 PeggiWebView: ⚠️ No URL to load")
        }
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Always update coordinator reference
        context.coordinator.setWebView(uiView)
        
        let newCanGoBack = uiView.canGoBack
        let newIsLoading = uiView.isLoading
        
        // Update bindings
        DispatchQueue.main.async {
            self.canGoBackBinding = newCanGoBack
            self.isLoadingBinding = newIsLoading
        }
    }
    
    func makeCoordinator() -> PeggiWebViewCoordinator {
        PeggiWebViewCoordinator(
            canGoBackBinding: $canGoBackBinding,
            isLoadingBinding: $isLoadingBinding,
            lastLoadedURLBinding: $lastLoadedURLBinding,
            safeAreaColorBinding: $safeAreaColorBinding
        )
    }
}

// MARK: - WebView Coordinator
class PeggiWebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    @Binding var canGoBackBinding: Bool
    @Binding var isLoadingBinding: Bool
    @Binding var lastLoadedURLBinding: String
    var safeAreaColorBinding: Binding<Color>?
    
    private weak var webView: WKWebView?
    private var stateUpdateTimer: Timer?
    
    init(canGoBackBinding: Binding<Bool>, isLoadingBinding: Binding<Bool>, lastLoadedURLBinding: Binding<String>, safeAreaColorBinding: Binding<Color>) {
        self._canGoBackBinding = canGoBackBinding
        self._isLoadingBinding = isLoadingBinding
        self._lastLoadedURLBinding = lastLoadedURLBinding
        self.safeAreaColorBinding = safeAreaColorBinding
        super.init()
        
        print("🌐 PeggiWebViewCoordinator: Initialized")
    }
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
        startStateUpdateTimer()
    }
    
    // MARK: - State Update Timer
    private func startStateUpdateTimer() {
        stateUpdateTimer?.invalidate()
        stateUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateStateFromWebView()
        }
    }
    
    private func updateStateFromWebView() {
        guard let webView = webView else { return }
        
        DispatchQueue.main.async {
            self.canGoBackBinding = webView.canGoBack
            self.isLoadingBinding = webView.isLoading
        }
    }
    
    // MARK: - Notification Setup
    func setupNotifications() {
        // No notifications needed anymore
    }
    
    // MARK: - Detect Safe Area Color
    private func detectSafeAreaColor(webView: WKWebView) {
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
            if let colorString = result as? String {
                print("🌐 PeggiWebViewCoordinator: Detected background color: \(colorString)")
                
                // Parse RGB color
                if let color = self?.parseRGBColor(colorString) {
                    DispatchQueue.main.async {
                        self?.safeAreaColorBinding?.wrappedValue = color
                    }
                }
            }
        }
    }
    
    private func parseRGBColor(_ colorString: String) -> Color? {
        // Parse "rgb(r, g, b)" or "rgba(r, g, b, a)"
        let pattern = "rgba?\\((\\d+),\\s*(\\d+),\\s*(\\d+)"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: colorString, options: [], range: NSRange(colorString.startIndex..., in: colorString)),
           match.numberOfRanges >= 4 {
            
            let rRange = Range(match.range(at: 1), in: colorString)
            let gRange = Range(match.range(at: 2), in: colorString)
            let bRange = Range(match.range(at: 3), in: colorString)
            
            if let rRange = rRange, let gRange = gRange, let bRange = bRange,
               let r = Double(colorString[rRange]),
               let g = Double(colorString[gRange]),
               let b = Double(colorString[bRange]) {
                
                return Color(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
            }
        }
        
        return nil
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("🌐 PeggiWebViewCoordinator: Started loading")
        DispatchQueue.main.async {
            self.isLoadingBinding = true
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        let urlString = url.absoluteString
        
        print("🌐 PeggiWebViewCoordinator: Finished loading: \(urlString)")
        
        DispatchQueue.main.async {
            self.isLoadingBinding = false
            self.canGoBackBinding = webView.canGoBack
        }
        
        // Save URL if flag is set
        if UserDatStorage.shared.shouldSaveNextURL {
            print("🌐 PeggiWebViewCoordinator: 💾 Saving final URL: \(urlString)")
            UserDatStorage.shared.saveFinalURL(urlString)
            UserDatStorage.shared.setShouldSaveNextURL(false)
        }
        
        // Always extract pathId from any URL
        UserDatStorage.shared.extractAndSavePathId(from: url)
        
        // Update last loaded URL
        DispatchQueue.main.async {
            self.lastLoadedURLBinding = urlString
        }
        
        // Detect safe area color
        detectSafeAreaColor(webView: webView)
        
        // Check for 404 errors
        checkFor404Error(webView: webView)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("🌐 PeggiWebViewCoordinator: ❌ Navigation failed: \(error.localizedDescription)")
        
        DispatchQueue.main.async {
            self.isLoadingBinding = false
        }
        
        handleNavigationError(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("🌐 PeggiWebViewCoordinator: ❌ Provisional navigation failed: \(error.localizedDescription)")
        
        DispatchQueue.main.async {
            self.isLoadingBinding = false
        }
        
        handleNavigationError(error)
    }
    
    // MARK: - Error Handling
    private func handleNavigationError(_ error: Error) {
        let nsError = error as NSError
        
        // Check for timeout or connection errors
        if nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorCannotConnectToHost || nsError.code == NSURLErrorNotConnectedToInternet {
            print("🌐 PeggiWebViewCoordinator: 🔄 Network error detected, triggering fallback")
            
            // Only trigger fallback if user has seen alternative mode
            if UserDatStorage.shared.hasShownAlternativeMode {
                Task {
                    await triggerFallback()
                }
            }
        }
        
        // Try HTTP fallback for SSL errors
        if nsError.code == NSURLErrorServerCertificateUntrusted || nsError.code == NSURLErrorSecureConnectionFailed {
            print("🌐 PeggiWebViewCoordinator: 🔒 SSL error, trying HTTP fallback")
            tryHTTPFallback()
        }
    }
    
    private func triggerFallback() async {
        print("🌐 PeggiWebViewCoordinator: Starting fallback process")
        
        // Clear invalid URL
        UserDatStorage.shared.clearSavedTargetURL()
        
        // Try fallback
        let result = await FlowwowService.shared.fetchWithFallback()
        
        switch result {
        case .success(let newURL):
            print("🌐 PeggiWebViewCoordinator: ✅ Fallback successful: \(newURL)")
            UserDatStorage.shared.setShouldSaveNextURL(true)
            
            // Load new URL
            if let url = URL(string: newURL) {
                DispatchQueue.main.async {
                    self.webView?.load(URLRequest(url: url))
                }
            }
            
        case .failure(let error):
            print("🌐 PeggiWebViewCoordinator: ❌ Fallback failed: \(error)")
            // Keep showing empty WebView for returning users
        }
    }
    
    private func tryHTTPFallback() {
        guard let currentURL = webView?.url?.absoluteString else { return }
        
        if currentURL.hasPrefix("https://") {
            let httpURL = currentURL.replacingOccurrences(of: "https://", with: "http://")
            print("🌐 PeggiWebViewCoordinator: Trying HTTP: \(httpURL)")
            
            if let url = URL(string: httpURL) {
                DispatchQueue.main.async {
                    self.webView?.load(URLRequest(url: url))
                }
            }
        }
    }
    
    // MARK: - 404 Detection
    private func checkFor404Error(webView: WKWebView) {
        let script = """
        (function() {
            var title = document.title.toLowerCase();
            var body = document.body.innerText.toLowerCase();
            return title.includes('404') || title.includes('not found') || 
                   body.includes('404') || body.includes('page not found');
        })();
        """
        
        webView.evaluateJavaScript(script) { [weak self] result, error in
            if let is404 = result as? Bool, is404 {
                print("🌐 PeggiWebViewCoordinator: 🚫 404 page detected")
                
                if UserDatStorage.shared.hasShownAlternativeMode {
                    Task {
                        await self?.triggerFallback()
                    }
                }
            }
        }
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
    
    // MARK: - WKUIDelegate (for popup windows)
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("🌐 PeggiWebViewCoordinator: Popup window requested, loading in same view")
        
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        
        return nil
    }
    
    deinit {
        stateUpdateTimer?.invalidate()
        print("🌐 PeggiWebViewCoordinator: Deinitialized")
    }
}


