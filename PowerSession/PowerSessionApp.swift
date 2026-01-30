import SwiftUI

@main
struct PowerSessionApp: App {
    @AppStorage("murkyHasCompletedOnboarding") private var vexHasCompleted = false
    @StateObject private var flowState = PowerFlowState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        plinthSeedDataIfNeeded()
        quirkConfigureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if flowState.showSplash {
                    PowerSplashScreenView()
                        .transition(.opacity)
                } else if flowState.showWebView, let webViewURL = flowState.webViewURL {
                    TemoraRootView(url: webViewURL)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else if flowState.showMainApp {
                    if vexHasCompleted {
                        FizzMainTabView()
                    } else {
                        WharfOnboardingFlow()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.4), value: flowState.currentState)
            .onAppear {
                flowState.startFlow()
                // Устанавливаем черный фон для окна приложения
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.backgroundColor = UIColor.black
                }
            }
        }

    }

    private func plinthSeedDataIfNeeded() {
        let context = QuirkCoreDataStack.shared.fizzContext
        PlinthSampleDataSeeder.quirkSeedIfNeeded(context: context)
    }

    private func quirkConfigureAppearance() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(VexColorPalette.wharfTextPrimary)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(VexColorPalette.wharfTextPrimary)
        ]


        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(VexColorPalette.quellAccent)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(VexColorPalette.wharfTextSecondary.opacity(0.3))
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(VexColorPalette.quellAccent)
        ], for: .normal)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(VexColorPalette.brindleBrandDark)
        ], for: .selected)
    }
}
// AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // AppsFlyer будет запущен только после проверки даты в PowerFlowState
        // Не вызываем здесь, чтобы не запрашивать ATT если дата не прошла
        return true
    }
}
