// ──────────────────────────────────────────────
// RecipeViewPanel.swift
// Culinary Routine Choose & Chill
//
// WebView wrapper (UIViewControllerRepresentable) with
// error handling, 404 detection, 7s timeout, fallback.
// Supports all orientations (portrait, landscape).
// ──────────────────────────────────────────────

import SwiftUI
import WebKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍲 RecipeViewPanel (SwiftUI)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct RecipeViewPanel: UIViewControllerRepresentable {

    let url: URL
    var onError: (() -> Void)?
    var on404Detected: (() -> Void)?

    func makeUIViewController(context: Context) -> RecipeWebViewController {
        let vc = RecipeWebViewController(url: url)
        vc.onError = onError
        vc.on404Detected = on404Detected
        return vc
    }

    func updateUIViewController(_ uiViewController: RecipeWebViewController, context: Context) {
        if uiViewController.currentURL != url {
            uiViewController.loadURL(url)
            uiViewController.currentURL = url
            uiViewController.onError = onError
            uiViewController.on404Detected = on404Detected
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍳 RecipeWebViewController (UIKit)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class RecipeWebViewController: UIViewController {

    var currentURL: URL
    var onError: (() -> Void)?
    var on404Detected: (() -> Void)?

    private var webView: WKWebView!
    private var timeoutTimer: Timer?
    private let timeoutInterval: TimeInterval = 7.0
    private var hasTriggeredFallback = false

    init(url: URL) {
        self.currentURL = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true

        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadURL(currentURL)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let mask: UIInterfaceOrientationMask = [.portrait, .landscapeLeft, .landscapeRight]
        print("🔄 [Orientation] RecipeWebViewController.supportedInterfaceOrientations → \(mask)")
        return mask
    }

    override var shouldAutorotate: Bool { true }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyOrientationPreferences()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if view.window == nil {
            DispatchQueue.main.async { [weak self] in
                self?.applyOrientationPreferences()
            }
        }
    }

    private func applyOrientationPreferences() {
        print("🔄 [Orientation] RecipeWebViewController.applyOrientationPreferences | window=\(view.window != nil) | windowScene=\(view.window?.windowScene != nil)")
        if #available(iOS 16.0, *) {
            if let windowScene = view.window?.windowScene {
                let prefs = UIWindowScene.GeometryPreferences.iOS(
                    interfaceOrientations: [.portrait, .landscapeLeft, .landscapeRight]
                )
                windowScene.requestGeometryUpdate(prefs) { error in
                    print("🔄 [Orientation] requestGeometryUpdate completed | error=\(String(describing: error))")
                }
            } else {
                print("🔄 [Orientation] RecipeWebViewController: no windowScene yet")
            }
        }
    }

    func loadURL(_ url: URL) {
        hasTriggeredFallback = false
        timeoutTimer?.invalidate()

        var request = URLRequest(url: url)
        request.timeoutInterval = 7.0
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")

        webView.load(request)

        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false) { [weak self] _ in
            self?.triggerFallback()
        }
    }

    private func triggerFallback() {
        guard !hasTriggeredFallback else { return }
        hasTriggeredFallback = true
        timeoutTimer?.invalidate()
        onError?()
    }

    private func isNetworkError(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == NSURLErrorDomain && (
            nsError.code == NSURLErrorTimedOut ||
            nsError.code == NSURLErrorNotConnectedToInternet ||
            nsError.code == NSURLErrorCannotConnectToHost ||
            nsError.code == NSURLErrorNetworkConnectionLost
        )
    }

    private func check404ViaJavaScript() {
        let script = """
        (function() {
            var title = document.title.toLowerCase();
            var bodyText = document.body ? document.body.innerText.toLowerCase() : '';
            var is404 = title.includes('404') || bodyText.includes('404') || bodyText.includes('not found');
            return is404;
        })();
        """
        webView.evaluateJavaScript(script) { [weak self] result, _ in
            if let is404 = result as? Bool, is404 {
                self?.triggerFallback()
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - WKNavigationDelegate
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension RecipeWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if isNetworkError(error) {
            triggerFallback()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if isNetworkError(error) {
            triggerFallback()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        timeoutTimer?.invalidate()
        check404ViaJavaScript()
    }
}
