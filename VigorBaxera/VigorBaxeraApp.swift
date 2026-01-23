import SwiftUI
import Combine

@main
struct VigorBaxeraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            PeggiRootView()
        }
    }
}

final class ZyvorAppState: ObservableObject {
    @Published var onboardingCompleted: Bool = false
    
    private let stack = PyxeloCoreStack.shared
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        let repo = NylexSettingsRepoImpl(context: stack.qylexContext)
        let settings = repo.fyndexLoad()
        onboardingCompleted = settings.onboardingCompleted
        
        if onboardingCompleted {
            RyqexHapticsSound.shared.kyloxConfigure(haptics: settings.hapticsEnabled, sound: settings.endBeepEnabled)
        }
    }
}
