//
//  PeggiRootView.swift
//  VigorBaxera
//
//  Created on 21.01.2026
//

import SwiftUI

// MARK: - Peggi Root View
struct PeggiRootView: View {
    @StateObject private var coordinator = CoordinatorObserver.shared
    @StateObject private var appState = ZyvorAppState()
    
    var body: some View {
        ZStack {
            // Main content based on navigation state
            if coordinator.isValidating {
                // Show beautiful splash screen during validation
                SplashView()
                    .transition(.opacity)
            } else {
                switch coordinator.currentNavigationState {
                case .alternativeMode:
                    ResearchFlowView()
                        .transition(.opacity)
                    
                case .mainApp, .validating:
                    if appState.onboardingCompleted {
                        KyxorMainTabView()
                            .transition(.opacity)
                    } else {
                        NylorOnboardingFlow(completed: $appState.onboardingCompleted)
                            .transition(.opacity)
                    }
                }
            }
        }
        .onAppear {
            print("🎯 PeggiRootView: View appeared, starting validation")
            coordinator.startValidationChain()
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.isValidating)
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentNavigationState)
    }
}

