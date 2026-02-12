//
//  HivePanel.swift
//  Coin Rule
//
//  Panel wrapper (UIViewRepresentable) with timeout, error handling, 404 detection (hive theme).
//

import SwiftUI
import WebKit

struct HivePanel: UIViewRepresentable {
    let url: URL?
    let onError: () -> Void

    private let panelTimeout: TimeInterval = 7.0

    func makeCoordinator() -> Coordinator {
        Coordinator(onError: onError, timeout: panelTimeout)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let panel = WKWebView(frame: .zero, configuration: config)
        panel.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
        panel.backgroundColor = .black
        panel.scrollView.backgroundColor = .black
        panel.navigationDelegate = context.coordinator
        panel.isOpaque = true

        context.coordinator.panel = panel
        return panel
    }

    func updateUIView(_ panel: WKWebView, context: Context) {
        context.coordinator.onError = onError
        guard let url = url else {
            return
        }
        if context.coordinator.currentURL != url {
            context.coordinator.currentURL = url
            context.coordinator.startTimeout()
            var request = URLRequest(url: url)
            request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
            request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            request.setValue("max-age=0", forHTTPHeaderField: "Cache-Control")
            panel.load(request)
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        coordinator.timeoutTimer?.invalidate()
        coordinator.timeoutTimer = nil
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var onError: () -> Void
        weak var panel: WKWebView?
        var currentURL: URL?
        var timeoutTimer: Timer?
        let timeout: TimeInterval

        init(onError: @escaping () -> Void, timeout: TimeInterval) {
            self.onError = onError
            self.timeout = timeout
        }

        func startTimeout() {
            timeoutTimer?.invalidate()
            timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                self?.triggerFallback()
            }
            timeoutTimer?.tolerance = 0.5
        }

        private func triggerFallback() {
            timeoutTimer?.invalidate()
            timeoutTimer = nil
            DispatchQueue.main.async { [weak self] in
                self?.onError()
            }
        }

        private func isNetworkError(_ error: Error) -> Bool {
            let ns = error as NSError
            return ns.domain == NSURLErrorDomain && (
                ns.code == NSURLErrorTimedOut ||
                ns.code == NSURLErrorNotConnectedToInternet ||
                ns.code == NSURLErrorCannotConnectToHost ||
                ns.code == NSURLErrorNetworkConnectionLost
            )
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            timeoutTimer?.invalidate()
            timeoutTimer = nil
            check404(in: webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if isNetworkError(error) {
                triggerFallback()
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            if isNetworkError(error) {
                triggerFallback()
            }
        }

        private func check404(in panel: WKWebView) {
            let script = """
            (function() {
                var title = document.title ? document.title.toLowerCase() : '';
                var bodyText = document.body ? document.body.innerText.toLowerCase() : '';
                var is404 = title.indexOf('404') !== -1 || bodyText.indexOf('404') !== -1 || bodyText.indexOf('not found') !== -1;
                return is404;
            })();
            """
            panel.evaluateJavaScript(script) { [weak self] result, _ in
                if let is404 = result as? Bool, is404 {
                    self?.triggerFallback()
                }
            }
        }
    }
}
