import SwiftUI
import Foundation

final class PowerFlowState: ObservableObject {
    @Published var showSplash: Bool = true
    @Published var showWebView: Bool = false
    @Published var webViewURL: URL?
    @Published var showMainApp: Bool = false

    var currentState: AppState {
        if showSplash { return .splash }
        if showWebView { return .webView }
        return .main
    }

    enum AppState {
        case splash, webView, main
    }

    private var startTime: Date?
    private let service = CoachModExerciseService.shared
    private var validationsStarted = false

    func startFlow() {
        startTime = Date()
        
        // Check flags for non-first launch (before ATT)
        if service.shouldEnforceNative() {
            print("ℹ️ enforceNative flag is true - showing native app")
            showMainAppAfterSplash()
            return
        }
        
        if service.hasShownAlternative(), let savedURLString = service.getSavedURL(), let savedURL = URL(string: savedURLString) {
            print("ℹ️ hasShownAlternative flag is true - showing WebView with saved URL")
            webViewURL = savedURL
            showWebViewAfterSplash()
            return
        }
        
        // First launch - start with ATT request
        requestATT()
    }
    
    private func requestATT() {
        print("🔐 Starting ATT request")
        
        // Запрашиваем ATT, после получения ответа запускаем AppsFlyer
        AppsFlyerManager.shared.start(
            attCompletion: { [weak self] in
                guard let self = self else { return }
                print("✅ ATT response received - initializing AppsFlyer")
                self.initializeAppsFlyer()
            },
            appsFlyerCompletion: nil
        )
    }
    
    private func initializeAppsFlyer() {
        print("🚀 Initializing AppsFlyer")
        
        // Ждем инициализации AppsFlyer
        AppsFlyerManager.shared.waitForDataReady { [weak self] ready in
            guard let self = self else { return }
            
            if ready {
                print("✅ AppsFlyer initialized and data ready")
            } else {
                print("⚠️ AppsFlyer data not ready, proceeding anyway")
            }
            
            // После инициализации AppsFlyer делаем проверки
            self.proceedWithValidations()
        }
    }
    
    private func proceedWithValidations() {
        guard !validationsStarted else { return }
        validationsStarted = true
        
        // STEP 1: Date Check
        if !service.coachModCheckDatePublic() {
            print("❌ Date check failed - showing native app")
            showMainAppAfterSplash()
            return
        }
        
        // STEP 2: Device Check
        if !service.checkDevice() {
            print("❌ Device check failed (iPad) - showing native app")
            showMainAppAfterSplash()
            return
        }
        
        // STEP 3: Internet Check
        service.checkInternetConnection { [weak self] isConnected in
            guard let self = self else { return }
            
            if !isConnected {
                print("❌ Internet check failed - showing native app")
                self.showMainAppAfterSplash()
                return
            }
            
            // STEP 4: Server Request
            self.service.coachModRequestServerURL { [weak self] success, url in
                guard let self = self else { return }
                
                if success, let url = url {
                    print("✅ All validations passed - showing WebView")
                    self.webViewURL = url
                    self.showWebViewAfterSplash()
                } else {
                    print("❌ Server request failed - showing native app")
                    self.showMainAppAfterSplash()
                }
            }
        }
    }
    
    private func showWebViewAfterSplash() {
        let elapsed = Date().timeIntervalSince(self.startTime ?? Date())
        let minimumSplashTime: TimeInterval = 3.0
        let remaining = max(0, minimumSplashTime - elapsed)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
            withAnimation(.easeInOut(duration: 0.4)) {
                self.showSplash = false
                self.showWebView = true
            }
        }
    }
    
    private func showMainAppAfterSplash() {
        let elapsed = Date().timeIntervalSince(self.startTime ?? Date())
        let minimumSplashTime: TimeInterval = 3.0
        let remaining = max(0, minimumSplashTime - elapsed)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
            withAnimation(.easeInOut(duration: 0.4)) {
                self.showSplash = false
                self.showMainApp = true
            }
        }
    }
}
