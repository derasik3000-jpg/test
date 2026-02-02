import SwiftUI
import CoreData

@main
struct CRTheroadtocontrolApp: App {
    let degubaPersistence = DegubaPersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var evubewOnboardingViewModel = EhonohOnboardingViewModel()
    @State private var cuqavuIsOnboardingComplete = false
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            TemoraRootView()
                .environment(\.managedObjectContext, degubaPersistence.container.viewContext)
                .preferredColorScheme(.dark) // Закрепляем темную тему для всего приложения
        }
    }
}
// AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // НЕ запускаем AppsFlyer здесь - он будет запущен только после проверки даты
        // если дата прошла и это первый вход
        return true
    }
}
