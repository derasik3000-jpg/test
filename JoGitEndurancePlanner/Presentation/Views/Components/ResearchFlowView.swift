import SwiftUI
import WebKit

struct ResearchFlowView: UIViewRepresentable {
    @Binding var canGoBack: Bool
    @Binding var isLoading: Bool
    
    let initialURL: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // JavaScript settings
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.suppressesIncrementalRendering = false
        configuration.allowsAirPlayForMediaPlayback = false
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // Set delegates
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Custom user agent
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
        
        // Scroll view optimizations
        webView.scrollView.keyboardDismissMode = .interactive
        webView.scrollView.delaysContentTouches = false
        webView.scrollView.canCancelContentTouches = true
        webView.scrollView.scrollsToTop = false
        
        // Navigation gestures
        webView.allowsLinkPreview = false
        webView.allowsBackForwardNavigationGestures = true
        
        // Security
        if #available(iOS 16.4, *) {
            webView.isInspectable = false
        }
        
        // Background color
        webView.backgroundColor = .black
        webView.isOpaque = true
        webView.scrollView.backgroundColor = .black
        
        // Load initial URL
        if let url = URL(string: initialURL) {
            print("🔬 ResearchFlow: Loading initial URL: \(initialURL)")
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        // Set coordinator reference
        context.coordinator.setWebView(webView)
        context.coordinator.canGoBackBinding = Binding(
            get: { self.canGoBack },
            set: { self.canGoBack = $0 }
        )
        context.coordinator.isLoadingBinding = Binding(
            get: { self.isLoading },
            set: { self.isLoading = $0 }
        )
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Always update coordinator reference
        context.coordinator.setWebView(uiView)
        
        let newCanGoBack = uiView.canGoBack
        let newIsLoading = uiView.isLoading
        
        // Update bindings
        DispatchQueue.main.async {
            self.canGoBack = newCanGoBack
            self.isLoading = newIsLoading
        }
    }
    
    func makeCoordinator() -> CoordinatorObserver {
        CoordinatorObserver()
    }
}

// MARK: - Alternative Mode Container

struct AlternativeModeView: View {
    @State private var canGoBack = false
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    
    private let service = NewExerciseService.shared
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // WebView only - no navigation bar, no loader
            if let urlString = service.getSavedTargetURL() {
                ResearchFlowView(
                    canGoBack: $canGoBack,
                    isLoading: $isLoading,
                    initialURL: urlString
                )
            }
        }
        .statusBarHidden(true)
        .navigationBarHidden(true)
    }
}
