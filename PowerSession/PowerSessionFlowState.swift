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
        
        // STEP 1: Date Check (FIRST, BEFORE ANYTHING ELSE)
        if !service.coachModCheckDatePublic() {
            // Date check failed -> enforceNative = true -> Show Native App
            print("❌ Date check failed - showing native app")
            showMainAppAfterSplash()
            return
        }
        
        // Check flags for non-first launch
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
        
        // First launch - proceed with validations
        handleFirstLaunch()
    }
    
    private func handleFirstLaunch() {
        print("🚀 First launch detected - starting validations")
        
        // Start AppsFlyer
        AppsFlyerManager.shared.start()
        
        // Wait for AppsFlyer data and then proceed
        AppsFlyerManager.shared.waitForDataReady { [weak self] ready in
            guard let self = self else { return }
            
            if ready {
                print("✅ AppsFlyer data ready")
            } else {
                print("⚠️ AppsFlyer data not ready, proceeding anyway")
            }
            
            self.proceedWithValidations()
        }
    }
    
    private func proceedWithValidations() {
        guard !validationsStarted else { return }
        validationsStarted = true
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
                    print("✅ Server request successful - showing WebView")
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
