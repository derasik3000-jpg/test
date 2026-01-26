import SwiftUI
import StoreKit
import WebKit
import Combine

struct ApplicationEntryPoint: View {
    @StateObject private var service = CambridgeServicer.shared
    
    var body: some View {
        Group {
            switch service.currentMode {
            case .loading:
                LoadingIndicatorPanel()
                    .onAppear {
                        service.bootstrap()
                    }
            case .standard:
                RootContainerView()
            case .alternative(let url):
                ResearchFlowView(initialURL: url)
                    .environmentObject(service)
            }
        }
        .onChange(of: service.shouldShowRating) { shouldShow in
            if shouldShow {
                showRatingAlert()
            }
        }
    }
    
    private func showRatingAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
}

// MARK: - 🎓 Research Flow View (Alternative Mode)
struct ResearchFlowView: View {
    let initialURL: URL?
    @StateObject private var coordinator = TeacherModCoordinator()
    @EnvironmentObject var service: CambridgeServicer
    @State private var appeared = false
    @State private var currentURL: URL?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // WebView
                TeacherModWebView(
                    url: currentURL ?? initialURL,
                    canGoBack: $coordinator.canGoBack,
                    isLoading: $coordinator.isLoading,
                    coordinator: coordinator
                )
                .ignoresSafeArea(.all, edges: .bottom)
                .id(currentURL?.absoluteString ?? "empty") // Force reload when URL changes
            }
        }
        .statusBarHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            appeared = true
            currentURL = initialURL
        }
        .onChange(of: service.currentMode) { newMode in
            // React to mode changes
            if case .alternative(let url) = newMode {
                if url != currentURL {
                    print("🔄 ResearchFlowView: URL changed to \(url?.absoluteString ?? "nil")")
                    currentURL = url
                }
            }
        }
    }
}

// MARK: - 🌐 WebView Wrapper
struct TeacherModWebView: UIViewRepresentable {
    let url: URL?
    @Binding var canGoBack: Bool
    @Binding var isLoading: Bool
    let coordinator: TeacherModCoordinator
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // JavaScript enabled
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.suppressesIncrementalRendering = false
        config.allowsAirPlayForMediaPlayback = false
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // Gesture navigation
        webView.allowsBackForwardNavigationGestures = true
        
        // Input optimizations
        webView.scrollView.keyboardDismissMode = .interactive
        webView.scrollView.delaysContentTouches = false
        webView.scrollView.canCancelContentTouches = true
        webView.scrollView.scrollsToTop = false
        webView.allowsLinkPreview = false
        
        // Security
        if #available(iOS 16.4, *) {
            webView.isInspectable = false
        }
        
        context.coordinator.setWebView(webView)
        
        // Load URL
        if let url = url ?? CambridgeServicer.shared.getCurrentTargetURL() {
            print("🌐 Loading URL: \(url.absoluteString)")
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
            webView.load(request)
        } else {
            print("⚠️ No URL to load - empty WebView")
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.setWebView(uiView)
        
        let newCanGoBack = uiView.canGoBack
        let newIsLoading = uiView.isLoading
        
        DispatchQueue.main.async {
            self.canGoBack = newCanGoBack
            self.isLoading = newIsLoading
        }
    }
    
    func makeCoordinator() -> TeacherModCoordinator {
        return coordinator
    }
}

// MARK: - 📱 Loading Indicator Panel
struct LoadingIndicatorPanel: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var pulseOpacity: Double = 0.3
    @State private var textOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Gradient background matching app theme
            LinearGradient(
                colors: [
                    ThemeColorsConfig.backgroundDeep,
                    ThemeColorsConfig.backgroundDeep.opacity(0.95),
                    Color(hex: "1A1B2E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Animated logo with multiple layers
                ZStack {
                    // Outer rotating ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ThemeColorsConfig.accentBright,
                                    ThemeColorsConfig.accentBright.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotation))
                    
                    // Pulsing glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ThemeColorsConfig.accentBright.opacity(pulseOpacity),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    // Inner circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ThemeColorsConfig.accentBright.opacity(0.8),
                                    ThemeColorsConfig.accentBright.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .scaleEffect(scale)
                    
                    // Icon
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(ThemeColorsConfig.backgroundDeep)
                        .scaleEffect(scale)
                }
                .shadow(color: ThemeColorsConfig.accentBright.opacity(0.5), radius: 20, x: 0, y: 10)
                
                // Loading text with fade-in animation
                VStack(spacing: 8) {
                    Text("IPYourTier")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                        .opacity(textOpacity)
                    
                    Text("Checking your health...")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(ThemeColorsConfig.neutralAxis)
                        .opacity(textOpacity)
                }
            }
        }
        .onAppear {
            // Rotation animation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Scale pulse animation
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
            
            // Opacity pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseOpacity = 0.6
            }
            
            // Text fade-in
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                textOpacity = 1
            }
        }
    }
}

// MARK: - 🎯 Coordinator
@MainActor
class TeacherModCoordinator: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
    @Published var canGoBack = false
    @Published var isLoading = false
    
    private weak var webView: WKWebView?
    private var lastLoadedURL: URL?
    private var stateUpdateTimer: Timer?
    
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
            self.canGoBack = webView.canGoBack
            self.isLoading = webView.isLoading
        }
    }
    
    deinit {
        stateUpdateTimer?.invalidate()
    }
    
    // MARK: - Navigation Delegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("🌐 Started loading: \(webView.url?.absoluteString ?? "nil")")
        isLoading = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        
        print("✅ Finished loading: \(url.absoluteString)")
        isLoading = false
        canGoBack = webView.canGoBack
        
        // Save final URL if needed
        if lastLoadedURL != url {
            lastLoadedURL = url
            CambridgeServicer.shared.saveWebViewFinalURL(url)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ Navigation failed: \(error.localizedDescription)")
        isLoading = false
        
        let nsError = error as NSError
        
        // Handle timeout and connection errors
        if nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorNotConnectedToInternet {
            print("🔶 Network error detected - triggering fallback")
            // Fallback will be handled by CambridgeServicer on next launch
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("❌ Provisional navigation failed: \(error.localizedDescription)")
        isLoading = false
        
        let nsError = error as NSError
        
        // Handle SSL errors with HTTP fallback
        if nsError.code == NSURLErrorServerCertificateUntrusted {
            if let failedURL = webView.url, failedURL.scheme == "https" {
                print("🔄 SSL error - trying HTTP fallback")
                var components = URLComponents(url: failedURL, resolvingAgainstBaseURL: false)
                components?.scheme = "http"
                if let httpURL = components?.url {
                    webView.load(URLRequest(url: httpURL))
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // SSL Challenge handling
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }
    
    // MARK: - UI Delegate (for popup windows)
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Open popups in the same webview
        if let url = navigationAction.request.url {
            print("🔗 Opening popup in same view: \(url.absoluteString)")
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}


