class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🔬 AppDelegate: Application launched")
        // AppsFlyer will be started from CoordinatorObserver
        return true
    }
}



import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import UIKit
import AdSupport

class AppsFlyerManager: NSObject, AppsFlyerLibDelegate {
    
    static let shared = AppsFlyerManager()
    
    // Completion handler for initialization
    private var initializationCompletion: (() -> Void)?
    private var isInitialized = false
    
    private override init() {
        super.init()
        setupAppsFlyer()
    }
    
    // Настройка AppsFlyer
    private func setupAppsFlyer() {
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = "qgsnWxQrc6kxtXnHhdwcZ"
        appsFlyer.appleAppID = "6755589240"
        appsFlyer.waitForATTUserAuthorization(timeoutInterval: 60)
        appsFlyer.delegate = self
    }
    
    // Запрос разрешения и старт с callback
    func start(completion: (() -> Void)? = nil) {
        self.initializationCompletion = completion
        
        print("🔬 AppsFlyerManager: Starting initialization")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                    print("🔬 AppsFlyerManager: ATT Status: \(status.rawValue)")
                    
                    switch status {
                    case .authorized:
                        print("🔬 AppsFlyerManager: ✅ ATT Authorized")
                    case .denied:
                        print("🔬 AppsFlyerManager: ❌ ATT Denied")
                    case .restricted:
                        print("🔬 AppsFlyerManager: ⚠️ ATT Restricted")
                    case .notDetermined:
                        print("🔬 AppsFlyerManager: ⏳ ATT Not Determined")
                    @unknown default:
                        print("🔬 AppsFlyerManager: ❓ ATT Unknown Status")
                    }
                    
                    AppsFlyerLib.shared().start()
                    
                    // Wait a bit for AppsFlyer to fully initialize
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.markAsInitialized()
                    }
                }
            } else {
                AppsFlyerLib.shared().start()
                
                // Wait a bit for AppsFlyer to fully initialize
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.markAsInitialized()
                }
            }
        }
    }
    
    // Mark as initialized and call completion
    private func markAsInitialized() {
        print("🔬 AppsFlyerManager: ✅ Fully initialized")
        isInitialized = true
        
        // Log the IDs
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        print("🔬 AppsFlyerManager: AppsFlyer UID: \(appsFlyerUID)")
        
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        print("🔬 AppsFlyerManager: IDFA: \(idfa)")
        
        initializationCompletion?()
        initializationCompletion = nil
    }
    
    // Check if initialized
    func waitForInitialization(completion: @escaping () -> Void) {
        if isInitialized {
            print("🔬 AppsFlyerManager: Already initialized")
            completion()
        } else {
            print("🔬 AppsFlyerManager: Waiting for initialization...")
            initializationCompletion = completion
        }
    }
    
    // Callback с данными атрибуции
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("✅ Conversion Data:")
        print("LOG : \(conversionInfo)")
        
        // Print each parameter separately for clarity
        for (key, value) in conversionInfo {
            print("  - \(key): \(value)")
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("❌ Error: \(error.localizedDescription)")
    }
    
    // Отправка кастомного ивента
    func logEvent() {
        AppsFlyerLib.shared().logEvent("myTestEvent", withValues: nil)
        print("📊 Event sent: myTestEvent")
    }
    
    // Отправка ивента с параметрами (опционально)
    func logEventWithParams(params: [String: Any]) {
        AppsFlyerLib.shared().logEvent("myTestEvent", withValues: params)
        print("📊 Event sent: myTestEvent with params: \(params)")
    }
}

