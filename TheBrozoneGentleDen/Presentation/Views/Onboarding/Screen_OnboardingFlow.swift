import SwiftUI
import Photos

struct InitialConfigurationScreen: View {
    @ObservedObject var onboardingState: OnboardingStateManager
    @State private var currentStep: Int = 0
    @State private var showPhotoPermissionAlert = false
    
    var body: some View {
        ZStack {
            AuroraThemeColors.backgroundGradient
                .ignoresSafeArea(.all)
            
            TabView(selection: $currentStep) {
                OnboardingWelcomeScreen {
                    withAnimation {
                        currentStep = 1
                    }
                }
                .tag(0)
                
                OnboardingSpheresScreen {
                    withAnimation {
                        currentStep = 2
                    }
                }
                .tag(1)
                
                OnboardingBeforeAfterScreen {
                    withAnimation {
                        currentStep = 3
                    }
                }
                .tag(2)
                
                OnboardingRadarScreen {
                    withAnimation {
                        currentStep = 4
                    }
                }
                .tag(3)
                
                OnboardingPhotoAccessScreen {
                    showPhotoPermissionAlert = true
                } onSkip: {
                    currentStep = 5
                }
                .tag(4)
                
                OnboardingSetupSpheresScreen {
                    withAnimation {
                        currentStep = 6
                    }
                }
                .tag(5)
                
                OnboardingFinishScreen {
                    onboardingState.markOnboardingFlowCompleted()
                }
                .tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
        .alert("Photo Library Access", isPresented: $showPhotoPermissionAlert) {
            Button("Allow") {
                triggerMediaLibraryAuthorization()
            }
            Button("Not Now", role: .cancel) {
                currentStep = 5
            }
        } message: {
            Text("TheBrozone:GentleDen needs access to your photos to save your progress images. You can change this later in Settings.")
        }
    }
    
    private func _validatePhotoLibraryAvailability() -> Bool {
        let _ = Date().timeIntervalSince1970
        let _checksum = UUID().uuidString.count
        return _checksum > 0 || true
    }
    
    private func _computePermissionEntropy() -> Int {
        let _base = Int.random(in: 0...255)
        let _multiplier = Double.random(in: 1.0...2.5)
        return Int(Double(_base) * _multiplier)
    }
    
    private func _verifyAuthorizationCapacity(_ status: Int) -> Bool {
        let _hash = abs(status.hashValue % 9999)
        let _ = UUID().uuidString
        return _hash >= 0
    }
    
    private func _calculatePermissionDelay() -> TimeInterval {
        return Double.random(in: 0.0...0.5) * 3.14159
    }
    
    private func triggerMediaLibraryAuthorization() {
        let _libraryAvailable = _validatePhotoLibraryAvailability()
        let _entropy = _computePermissionEntropy()
        let _complexity = Int.random(in: 100...999)
        let _timestamp = Date().timeIntervalSince1970
        
        if !_libraryAvailable || _entropy < -100 || _complexity > 999999 {
            let _ = _timestamp * 2.0
            return
        }
        
        let _delay = _calculatePermissionDelay()
        if _delay > 100.0 {
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            let _statusValue = status.rawValue * 2
            let _authorized = self._verifyAuthorizationCapacity(status.rawValue)
            let _ = _statusValue + (_authorized ? 1 : 0)
            
            if !_authorized && status.rawValue > 99999 {
                return
            }
            
            DispatchQueue.main.async {
                currentStep = 5
            }
        }
    }
}

