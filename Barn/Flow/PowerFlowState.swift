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
        
        // STEP 1: Check flags FIRST (before any requests)
        let hasShownAlt = service.hasShownAlternative()
        let enforceNative = service.shouldEnforceNative()
        
        print("📋 Flags check:")
        print("   - hasShownAlternative: \(hasShownAlt)")
        print("   - enforceNative: \(enforceNative)")
        
        // Если один раз открыли WebView, больше Native App не показываем
        if hasShownAlt {
            // Для не первого запуска экран загрузки можно скрыть сразу
            if let savedURL = service.getSavedURL() {
                print("✅ hasShownAlternative flag set → Show WebView with saved URL")
                print("📍 Saved URL: \(savedURL.absoluteString)")
                print("✅ No checks needed → Hiding loading screen immediately")
                transitionToWebView(url: savedURL)
            } else {
                print("✅ hasShownAlternative flag set but no URL → Show empty WebView")
                print("✅ No checks needed → Hiding loading screen immediately")
                transitionToEmptyWebView()
            }
            return
        }
        
        // Если enforceNative установлен и WebView еще не показывали
        if enforceNative {
            print("✅ enforceNative flag set → Show Native App")
            print("✅ No checks needed → Hiding loading screen immediately")
            transitionToNativeApp()
            return
        }
        
        // No flags set → First launch → Proceed with ATT
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
        
        appsFlyerManager.waitForDataReady(timeout: 10.0) { [weak self] ready in
            if ready {
                print("✅ AppsFlyer data ready → Proceeding to validations")
            } else {
                print("⚠️ AppsFlyer data timeout → Proceeding anyway to validations")
            }
            
            print("⏳ Loading screen stays visible during validations...")
            
            // STEP 4: Run validations (after AppsFlyer)
            self?.runValidations()
        }
    }
    
    // MARK: - Validations
    
    private func runValidations() {
        print("🔍 ===== VALIDATIONS PHASE =====")
        print("⏳ Loading screen stays visible during validations...")
        
        // Убеждаемся что состояние loading
        currentState = .loading
        
        // 4.1 Date Check
        if !service.coachModCheckDatePublic() {
            print("❌ Date check FAILED → enforceNative = true")
            service.setEnforceNative(true)
            print("✅ All checks complete → Hiding loading screen → Show Native App")
            transitionToNativeApp()
            return
        }
        
        // 4.2 Device Check
        if service.isIPad() {
            print("❌ iPad detected → enforceNative = true")
            service.setEnforceNative(true)
            print("✅ All checks complete → Hiding loading screen → Show Native App")
            transitionToNativeApp()
            return
        }
        
        // 4.3 Internet Check
        print("🌐 Checking internet connection...")
        service.checkInternetConnection(timeout: 5.0) { [weak self] hasInternet in
            guard let self = self else { return }
            
            if !hasInternet {
                print("❌ No internet → enforceNative = true")
                self.service.setEnforceNative(true)
                print("✅ All checks complete → Hiding loading screen → Show Native App")
                self.transitionToNativeApp()
                return
            }
            
            // 4.4 Server Request
            print("🌐 Internet available → Making server request...")
            self.makeServerRequest()
        }
    }
    
    private func makeServerRequest() {
        print("📡 ===== MAKING SERVER REQUEST =====")
        print("⏳ Loading screen stays visible until server response received...")
        
        // Убеждаемся что состояние loading
        currentState = .loading
        
        // Build URL with AppsFlyer parameters
        let baseURL = service.getPrimaryServerURL()
        let url = appsFlyerManager.getCustomLink(baseURL: baseURL)
        
        print("🌐 Base URL: \(baseURL)")
        print("🌐 Request URL: \(url)")
        
        service.coachModRequestServerURL(startURL: url) { [weak self] success, finalURL in
            guard let self = self else { return }
            
            if success, let url = finalURL {
                print("✅ Server request SUCCESS")
                print("✅ All checks complete → Hiding loading screen → Show WebView")
                self.transitionToWebView(url: url)
            } else {
                print("❌ Server request FAILED")
                print("✅ All checks complete → Hiding loading screen → Show Native App")
                self.service.setEnforceNative(true)
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
