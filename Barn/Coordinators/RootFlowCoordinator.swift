//
//  RootFlowCoordinator.swift
//  DAYTRACE
//
//  Root coordinator managing app flow
//

import UIKit

final class RootFlowCoordinator: FlowCoordinator {
    
    let navigationController: UINavigationController
    private let window: UIWindow
    private var childCoordinator: FlowCoordinator?
    
    private let flowState = PowerFlowState.shared
    private var splashScreen: TraceBootScene?
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // Start WebView flow with loading screen
        startWebViewFlow()
    }
    
    private func startWebViewFlow() {
        // Show loading screen immediately (используем существующий TraceBootScene)
        let splash = TraceBootScene()
        // Не устанавливаем onComplete - будем управлять переходом вручную через handleFlowStateChange
        splash.onComplete = nil // Убираем автоматическое завершение
        splashScreen = splash
        navigationController.setViewControllers([splash], animated: false)
        
        // Setup flow state observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFlowStateChange(_:)),
            name: .flowStateDidChange,
            object: nil
        )
        
        // Start the flow
        flowState.startFlow()
    }
    
    @objc private func handleFlowStateChange(_ notification: Notification) {
        guard let state = notification.userInfo?["state"] as? FlowState else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let currentVC = self.navigationController.topViewController
            
            switch state {
            case .loading:
                // Keep loading screen visible - не скрываем экран загрузки
                print("⏳ State: LOADING → Keeping splash screen visible")
                break
                
            case .nativeApp:
                // Transition to native app - скрываем экран загрузки
                print("✅ State: NATIVE APP → Hiding splash screen")
                print("📍 Current VC type: \(type(of: currentVC ?? UIViewController()))")
                
                if currentVC is TraceBootScene {
                    // From splash screen - все проверки завершены
                    print("✅ Transitioning from TraceBootScene to native app")
                    self.hideSplashAndShowNativeApp()
                } else if currentVC is TemoraRootView {
                    // From WebView (error/fallback failed)
                    print("✅ Transitioning from TemoraRootView to native app")
                    self.showBootScreen()
                } else {
                    print("⚠️ Unexpected view controller type, calling hideSplashAndShowNativeApp anyway")
                    self.hideSplashAndShowNativeApp()
                }
                
            case .webView(let url):
                // Transition to WebView - скрываем экран загрузки
                print("✅ State: WEBVIEW → Hiding splash screen")
                print("📍 WebView URL: \(url.absoluteString)")
                if currentVC is TraceBootScene {
                    // From splash screen - все проверки завершены
                    self.hideSplashAndShowWebView(url: url)
                } else if currentVC is TemoraRootView {
                    // From WebView (fallback URL)
                    // TemoraRootView will handle loading the new URL
                    break
                }
                
            case .emptyWebView:
                // Transition to empty WebView - скрываем экран загрузки
                print("✅ State: EMPTY WEBVIEW → Hiding splash screen")
                if currentVC is TraceBootScene {
                    // From splash screen - все проверки завершены
                    self.hideSplashAndShowWebView(url: URL(string: "about:blank")!)
                } else if currentVC is TemoraRootView {
                    // Already showing WebView → show empty
                    (currentVC as? TemoraRootView)?.showEmptyWebView()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func hideSplashAndShowNativeApp() {
        // Hide splash screen and continue to boot screen
        print("🔄 Transitioning from splash to native app...")
        print("📍 Current view controller: \(String(describing: navigationController.topViewController))")
        
        splashScreen = nil
        
        // Пропускаем повторный TraceBootScene и сразу переходим к проверке onboarding
        print("🔄 Calling checkOnboardingStatus()...")
        checkOnboardingStatus()
    }
    
    private func hideSplashAndShowWebView(url: URL) {
        // Hide splash screen and show WebView
        print("🔄 Transitioning from splash to WebView...")
        splashScreen = nil
        
        let webView = TemoraRootView()
        webView.loadURL(url)
        navigationController.setViewControllers([webView], animated: true)
    }
    
    private func showBootScreen() {
        // Этот метод используется только когда переход из WebView в Native App
        let bootScene = TraceBootScene()
        bootScene.onComplete = { [weak self] in
            self?.checkOnboardingStatus()
        }
        navigationController.setViewControllers([bootScene], animated: true)
    }
    
    private func checkOnboardingStatus() {
        print("🔍 Checking onboarding status...")
        let hasCompleted = TraceStorage.shared.hasCompletedOnboarding
        print("📋 Has completed onboarding: \(hasCompleted)")
        
        if hasCompleted {
            print("✅ Onboarding completed → Showing main flow")
            showMainFlow()
        } else {
            print("🆕 Onboarding not completed → Showing onboarding")
            showOnboarding()
        }
    }
    
    private func showOnboarding() {
        print("🟡 ===== SHOWING ONBOARDING =====")
        print("🟡 RootFlowCoordinator: Showing onboarding")
        print("📍 Navigation controller: \(navigationController)")
        print("📍 Current view controllers count: \(navigationController.viewControllers.count)")
        
        let coordinator = IntroTraceCoordinator(navigationController: navigationController)
        coordinator.onComplete = { [weak self] in
            print("🟡 RootFlowCoordinator: Onboarding completed, showing main flow")
            self?.childCoordinator = nil // Release onboarding coordinator
            self?.showMainFlow()
        }
        childCoordinator = coordinator // Keep strong reference
        coordinator.start()
        
        print("🟡 Onboarding coordinator started")
    }
    
    private func showMainFlow() {
        print("🟢 ===== SHOWING MAIN FLOW =====")
        print("🟢 RootFlowCoordinator: Showing main flow")
        print("📍 Navigation controller: \(navigationController)")
        print("📍 Current view controllers count: \(navigationController.viewControllers.count)")
        
        let coordinator = MainTabCoordinator(navigationController: navigationController)
        childCoordinator = coordinator // Keep strong reference
        coordinator.start()
        
        print("🟢 Main flow coordinator started")
        print("📍 View controllers count after start: \(navigationController.viewControllers.count)")
    }
}
