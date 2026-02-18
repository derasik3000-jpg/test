//
//  TemoraRootView.swift
//  Barn
//
//  WebView container and state management
//

import UIKit
import StoreKit

final class TemoraRootView: UIViewController {
    
    private let webViewPanel = PuwelaPanel()
    private let observer = CoordinatorObserver.shared
    private let flowState = PowerFlowState.shared
    
    private var currentURL: URL?
    private var webViewLoadTimer: Timer?
    private let webViewTimeout: TimeInterval = 7.0 // README: 7s for faster fallback
    
    var onStateChange: ((FlowState) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebViewDelegate()
        observeFlowState()
    }
    
    deinit {
        webViewLoadTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        webViewPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webViewPanel)
        
        NSLayoutConstraint.activate([
            webViewPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webViewPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webViewPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webViewPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupWebViewDelegate() {
        webViewPanel.delegate = self
    }
    
    private func observeFlowState() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFlowStateChange(_:)),
            name: .flowStateDidChange,
            object: nil
        )
    }
    
    @objc private func handleFlowStateChange(_ notification: Notification) {
        guard let state = notification.userInfo?["state"] as? FlowState else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.handleStateChange(state)
        }
    }
    
    private func handleStateChange(_ state: FlowState) {
        switch state {
        case .webView(let url):
            if url != currentURL {
                currentURL = url
                webViewPanel.loadURL(url)
            }
        case .emptyWebView:
            // Показываем пустой WebView (about:blank)
            if let blankURL = URL(string: "about:blank") {
                currentURL = blankURL
                webViewPanel.loadURL(blankURL)
            }
        case .nativeApp:
            onStateChange?(.nativeApp)
        case .loading:
            break
        }
    }
    
    func loadURL(_ url: URL) {
        currentURL = url
        print("🌐 Loading URL in WebView: \(url.absoluteString)")
        print("⏱️ WebView timeout: \(webViewTimeout)s")
        
        webViewLoadTimer?.invalidate()
        webViewLoadTimer = Timer.scheduledTimer(withTimeInterval: webViewTimeout, repeats: false) { [weak self] _ in
            print("⏱️ WebView load timeout after \(self?.webViewTimeout ?? 0)s → Triggering fallback")
            self?.handleWebViewTimeout()
        }
        
        webViewPanel.loadURL(url)
        
        // README: Show app rating immediately when WebView appears (not for about:blank)
        if url.absoluteString != "about:blank" && !url.absoluteString.isEmpty {
            requestAppReview()
        }
    }
    
    private func requestAppReview() {
        guard let windowScene = view.window?.windowScene else { return }
        SKStoreReviewController.requestReview(in: windowScene)
    }
    
    func showEmptyWebView() {
        if let blankURL = URL(string: "about:blank") {
            currentURL = blankURL
            webViewPanel.loadURL(blankURL)
        }
    }
    
    private func handleWebViewTimeout() {
        print("⏱️ WebView timeout detected → Triggering fallback")
        webViewLoadTimer?.invalidate()
        webViewLoadTimer = nil
        observer.handleWebViewError(NSError(domain: "WebViewTimeout", code: NSURLErrorTimedOut, userInfo: nil))
    }
}

// MARK: - PuwelaPanelDelegate

extension TemoraRootView: PuwelaPanelDelegate {
    
    func webViewDidFailLoad(error: Error) {
        // Отменяем таймер при ошибке
        webViewLoadTimer?.invalidate()
        webViewLoadTimer = nil
        observer.handleWebViewError(error)
    }
    
    func webViewDidFinishLoad() {
        // Отменяем таймер при успешной загрузке
        webViewLoadTimer?.invalidate()
        webViewLoadTimer = nil
        print("✅ WebView loaded successfully")
    }
    
    func webViewDidDetect404() {
        // Отменяем таймер при 404
        webViewLoadTimer?.invalidate()
        webViewLoadTimer = nil
        observer.handle404Error()
    }
}
