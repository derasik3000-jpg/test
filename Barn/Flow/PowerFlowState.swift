//
//  PowerFlowState.swift
//  Barn
//
//  Main flow controller managing state transitions
//

import Foundation
import UIKit

enum FlowState {
    case loading
    case nativeApp
    case webView(URL)
    case emptyWebView // Пустой WebView когда fallback не удался
}

extension Notification.Name {
    static let flowStateDidChange = Notification.Name("flowStateDidChange")
}

class PowerFlowState {
    
    static let shared = PowerFlowState()
    
    private let service = CoachModExerciseService.shared
    private let appsFlyerManager = AppsFlyerManager.shared
    
    var currentState: FlowState = .loading
    
    private init() {}
    
    // MARK: - Main Flow
    
    func startFlow() {
        print("🚀 ===== STARTING FLOW =====")
        
        // STEP 1: First launch choice check FIRST (README: if set → always WebView, never Native)
        if let firstChoice = service.getFirstLaunchChoice() {
            print("📋 firstLaunchChoice = \(firstChoice) → Always show WebView (saved URL → fallback → empty)")
            if let savedURL = service.getSavedURL() {
                print("📍 Saved URL: \(savedURL.absoluteString) → Show WebView")
                transitionToWebView(url: savedURL)
            } else {
                print("🔄 No saved URL → Try fallback with pathId")
                service.coachModTryFallbackURL { [weak self] success, url in
                    if success, let url = url {
                        self?.transitionToWebView(url: url)
                    } else {
                        self?.transitionToEmptyWebView()
                    }
                }
            }
            return
        }
        
        // No choice set → First launch → Proceed with ATT
        print("🆕 First launch detected → Starting ATT request")
        startFirstLaunchFlow()
    }
    
    // MARK: - First Launch Flow
    
    private func startFirstLaunchFlow() {
        print("🔔 ===== ATT REQUEST PHASE =====")
        print("⏳ Loading screen stays visible until ATT response received...")
        
        // Убеждаемся что состояние loading
        currentState = .loading
        
        // STEP 2: ATT Request (FIRST STEP ON FIRST LAUNCH)
        // ATT запрос показывается во время экрана загрузки
        // Экран загрузки остается видимым до получения ответа
        appsFlyerManager.start(
            attCompletion: { [weak self] in
                print("✅ ATT response received → Proceeding to AppsFlyer initialization")
                print("⏳ Loading screen stays visible until AppsFlyer initialized...")
                // STEP 3: Initialize AppsFlyer (after ATT)
                self?.waitForAppsFlyerInitialization()
            },
            appsFlyerCompletion: nil
        )
    }
    
    private func waitForAppsFlyerInitialization() {
        print("⏳ ===== APPSFLYER INITIALIZATION PHASE =====")
        print("⏳ Waiting for AppsFlyer data (sub1 & sub2)...")
        print("⏳ Loading screen stays visible until AppsFlyer data ready...")
        
        // Убеждаемся что состояние loading
        currentState = .loading
        
        appsFlyerManager.waitForDataReady(timeout: 5.0) { [weak self] ready in
            if ready {
                print("✅ AppsFlyer data ready → Proceeding to conversion data wait")
            } else {
                print("⚠️ AppsFlyer data timeout → Proceeding anyway")
            }
            
            // STEP 4: Wait for conversion data (up to 8s, README)
            print("⏳ Waiting for conversion data (up to 8s)...")
            self?.appsFlyerManager.waitForConversionData(forceWait: true) { [weak self] conversionData in
                print("✅ Conversion data ready or timeout → Proceeding to validations")
                self?.runValidations(conversionData: conversionData)
            }
        }
    }
    
    // MARK: - Validations (README: date, device, internet, server; set firstLaunchChoice)
    
    private func runValidations(conversionData: [AnyHashable: Any]?) {
        print("🔍 ===== VALIDATIONS PHASE =====")
        currentState = .loading
        
        // 4.1 Date Check
        if !service.coachModCheckDatePublic() {
            print("❌ Date check FAILED → firstLaunchChoice = nativeApp")
            service.setFirstLaunchChoice("nativeApp")
            transitionToNativeApp()
            return
        }
        
        // 4.2 Device Check
        if service.isIPad() {
            print("❌ iPad detected → firstLaunchChoice = nativeApp")
            service.setFirstLaunchChoice("nativeApp")
            transitionToNativeApp()
            return
        }
        
        // 4.3 Internet Check (timeout 2s per README)
        print("🌐 Checking internet connection...")
        service.checkInternetConnection(timeout: 2.0) { [weak self] hasInternet in
            guard let self = self else { return }
            
            if !hasInternet {
                print("❌ No internet → firstLaunchChoice = nativeApp")
                self.service.setFirstLaunchChoice("nativeApp")
                self.transitionToNativeApp()
                return
            }
            
            print("🌐 Internet available → Making server request...")
            self.makeServerRequest(conversionData: conversionData)
        }
    }
    
    private func makeServerRequest(conversionData: [AnyHashable: Any]?) {
        print("📡 ===== MAKING SERVER REQUEST =====")
        currentState = .loading
        
        let baseURL = service.getPrimaryServerURL()
        let url = appsFlyerManager.getCustomLink(baseURL: baseURL, conversionData: conversionData)
        
        print("🌐 Base URL: \(baseURL)")
        print("🌐 Request URL: \(url)")
        
        service.coachModRequestServerURL(startURL: url) { [weak self] success, finalURL in
            guard let self = self else { return }
            
            if success, let url = finalURL {
                print("✅ Server request SUCCESS → firstLaunchChoice = webView")
                self.service.setFirstLaunchChoice("webView")
                self.transitionToWebView(url: url)
            } else {
                print("❌ Server request FAILED → firstLaunchChoice = nativeApp")
                self.service.setFirstLaunchChoice("nativeApp")
                self.transitionToNativeApp()
            }
        }
    }
    
    // MARK: - State Transitions
    
    private func transitionToNativeApp() {
        currentState = .nativeApp
        NotificationCenter.default.post(name: .flowStateDidChange, object: nil, userInfo: ["state": FlowState.nativeApp])
    }
    
    private func transitionToWebView(url: URL) {
        currentState = .webView(url)
        NotificationCenter.default.post(name: .flowStateDidChange, object: nil, userInfo: ["state": FlowState.webView(url)])
    }
    
    // MARK: - Handle WebView Errors
    
    func handleWebViewError() {
        print("🔄 ===== WEBVIEW ERROR DETECTED =====")
        print("🔄 Trying fallback logic...")
        
        // Логируем текущие сохраненные данные
        if let savedURL = service.getSavedURL() {
            print("📦 Current saved URL: \(savedURL.absoluteString)")
        }
        if let pathId = service.getSavedPathId() {
            print("📦 Current saved pathId: \(pathId)")
        }
        
        service.coachModTryFallbackURL { [weak self] success, url in
            if success, let url = url {
                print("✅ Fallback URL success → Loading WebView")
                self?.transitionToWebView(url: url)
            } else {
                print("❌ Fallback failed → Show empty WebView")
                self?.transitionToEmptyWebView()
            }
        }
    }
    
    // MARK: - Empty WebView Transition
    
    private func transitionToEmptyWebView() {
        currentState = .emptyWebView
        NotificationCenter.default.post(name: .flowStateDidChange, object: nil, userInfo: ["state": FlowState.emptyWebView])
    }
}
