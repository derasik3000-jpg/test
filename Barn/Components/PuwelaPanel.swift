//
//  PuwelaPanel.swift
//  Barn
//
//  WebView wrapper component
//

import UIKit
import WebKit

protocol PuwelaPanelDelegate: AnyObject {
    func webViewDidFailLoad(error: Error)
    func webViewDidFinishLoad()
    func webViewDidDetect404()
}

final class PuwelaPanel: UIView {
    
    weak var delegate: PuwelaPanelDelegate?
    
    private var webView: WKWebView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func loadURL(_ url: URL) {
        var request = URLRequest(url: url)
        
        // Browser-like headers
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("max-age=0", forHTTPHeaderField: "Cache-Control")
        request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        
        webView.load(request)
    }
    
    private func checkFor404() {
        let script = """
        (function() {
            var title = document.title.toLowerCase();
            var bodyText = document.body.innerText.toLowerCase();
            var is404 = title.includes('404') || 
                       bodyText.includes('404') || 
                       bodyText.includes('not found');
            return is404;
        })();
        """
        
        webView.evaluateJavaScript(script) { [weak self] result, error in
            if let is404 = result as? Bool, is404 {
                self?.delegate?.webViewDidDetect404()
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension PuwelaPanel: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webViewDidFinishLoad()
        checkFor404()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.webViewDidFailLoad(error: error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delegate?.webViewDidFailLoad(error: error)
    }
}
