import SwiftUI

@main
struct StenorBulanoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var coordinator = CoordinatorObserver.shared
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @State private var validationComplete = false
    
    init() {
        _ = CoreDataStack.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !validationComplete {
                    // Показываем splash screen во время валидации
                    SplashView()
                        .onAppear {
                            startValidation()
                        }
                } else if coordinator.shouldShowAlternativeMode {
                    // Показываем альтернативный режим (WebView)
                    ResearchFlowView()
                } else if showOnboarding {
                    // Показываем онбординг
                    OnboardingView(isPresented: $showOnboarding)
                } else {
                    // Показываем основное приложение
                    MainTabView()
                }
            }
        }
    }
    
    private func startValidation() {
        // Ждем полной инициализации AppsFlyer и ATT
        AppsFlyerManager.shared.start {
            print("🔬 App: AppsFlyer initialized, starting validation")
            // Теперь начинаем валидацию
            self.coordinator.startValidation {
                self.validationComplete = true
            }
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // AppsFlyer будет инициализирован в startValidation()
        // AppsFlyerManager.shared.start() - вызывается позже с callback
        //AppsFlyerManager.shared.logEvent()
        return true
    }
}
