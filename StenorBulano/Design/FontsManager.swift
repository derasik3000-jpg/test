
import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport
import UIKit

class AppsFlyerManager: NSObject, AppsFlyerLibDelegate {
    
    static let shared = AppsFlyerManager()
    
    // Callback для уведомления о завершении инициализации
    var onInitializationComplete: (() -> Void)?
    
    private override init() {
        super.init()
        setupAppsFlyer()
    }
    
    // Настройка AppsFlyer
    private func setupAppsFlyer() {
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = "w3jaZVARK3cm9QZ3YFA6SM"
        appsFlyer.appleAppID = "6755245894"
        appsFlyer.waitForATTUserAuthorization(timeoutInterval: 60)
        appsFlyer.delegate = self
    }
    
    // Запрос разрешения и старт
    func start(completion: @escaping () -> Void) {
        self.onInitializationComplete = completion
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    print("🔬 ATT Status: \(status.rawValue)")
                    AppsFlyerLib.shared().start()
                    
                    // Даем время на инициализацию AppsFlyer
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        completion()
                    }
                }
            } else {
                AppsFlyerLib.shared().start()
                
                // Даем время на инициализацию AppsFlyer
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    completion()
                }
            }
        }
    }
    
    // Получение sub1 (AppsFlyer UID)
    func getSub1() -> String {
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        print("🔬 AppsFlyer UID (sub1): \(appsFlyerUID)")
        return appsFlyerUID
    }
    
    // Получение sub2 (IDFA)
    func getSub2() -> String {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        print("🔬 IDFA (sub2): \(idfa)")
        return idfa
    }
    
    // Callback с данными атрибуции
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("✅ Conversion Data:")
        print("LOG : \(conversionInfo)")
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

