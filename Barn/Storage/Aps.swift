//
//  AppsFlyerManager.swift
//  Barn
//
//  AppsFlyer integration with ATT support
//

import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport
import UIKit

class AppsFlyerManager: NSObject, AppsFlyerLibDelegate {
    
    static let shared = AppsFlyerManager()
    
    private var isInitialized = false
    private var attStatusReceived = false
    private var attCompletion: (() -> Void)?
    private var appsFlyerCompletion: ((Bool) -> Void)?
    
    private override init() {
        super.init()
        setupAppsFlyer()
    }
    
    // Настройка AppsFlyer
    private func setupAppsFlyer() {
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = "vyrf3pF5euT6wxJbqfz2PK"
        appsFlyer.appleAppID = "6758735246"
        appsFlyer.waitForATTUserAuthorization(timeoutInterval: 60)
        appsFlyer.delegate = self
    }
    
    // Запрос ATT и инициализация AppsFlyer с колбэками
    func start(attCompletion: (() -> Void)? = nil, appsFlyerCompletion: ((Bool) -> Void)? = nil) {
        self.attCompletion = attCompletion
        self.appsFlyerCompletion = appsFlyerCompletion
        
        print("🔔 ===== ATT REQUEST STARTING =====")
        
        DispatchQueue.main.async { [weak self] in
            if #available(iOS 14, *) {
                // Проверяем текущий статус ATT перед запросом
                let currentStatus = ATTrackingManager.trackingAuthorizationStatus
                print("📊 Current ATT status: \(self?.attStatusString(currentStatus) ?? "unknown") (\(currentStatus.rawValue))")
                
                // Если статус уже определен (не notDetermined), не показываем диалог
                if currentStatus != .notDetermined {
                    print("ℹ️ ATT status already determined → Skipping dialog")
                    print("✅ ATT Status: \(self?.attStatusString(currentStatus) ?? "unknown")")
                    print("ℹ️ User previously \(currentStatus == .authorized ? "authorized" : "denied") tracking")
                    self?.attStatusReceived = true
                    self?.attCompletion?()
                    print("🚀 Starting AppsFlyer SDK...")
                    AppsFlyerLib.shared().start()
                    return
                }
                
                // Проверяем что мы на главном потоке
                assert(Thread.isMainThread, "ATT request must be on main thread")
                print("✅ On main thread: \(Thread.isMainThread)")
                
                // Добавляем небольшую задержку чтобы пользователь успел увидеть экран загрузки
                // и чтобы UI был полностью готов
                print("⏳ Waiting 1.0s before showing ATT dialog (ensuring UI is ready)...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    // Проверяем что окно видимо
                    if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                       window.isHidden == false {
                        print("✅ Window is visible and ready")
                    } else {
                        print("⚠️ Window might not be ready, but proceeding anyway")
                    }
                    
                    print("🔔 Calling ATTrackingManager.requestTrackingAuthorization()...")
                    print("🔔 ATT dialog should appear now!")
                    
                    ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                        print("✅ ===== ATT RESPONSE RECEIVED =====")
                        print("✅ ATT Status: \(self?.attStatusString(status) ?? "unknown") (\(status.rawValue))")
                        
                        if status == .authorized {
                            print("✅ User authorized tracking")
                        } else if status == .denied {
                            print("❌ User denied tracking")
                        } else if status == .restricted {
                            print("⚠️ Tracking restricted")
                        }
                        
                        self?.attStatusReceived = true
                        // Вызываем колбэк ATT
                        self?.attCompletion?()
                        // Затем запускаем AppsFlyer
                        print("🚀 Starting AppsFlyer SDK...")
                        AppsFlyerLib.shared().start()
                    }
                }
            } else {
                // iOS < 14: No ATT needed
                print("ℹ️ iOS < 14: ATT not needed")
                self?.attStatusReceived = true
                attCompletion?()
                print("🚀 Starting AppsFlyer SDK...")
                AppsFlyerLib.shared().start()
            }
        }
    }
    
    @available(iOS 14, *)
    private func attStatusString(_ status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorized:
            return "authorized"
        @unknown default:
            return "unknown"
        }
    }
    
    // Ожидание готовности данных AppsFlyer (sub1 & sub2)
    func waitForDataReady(timeout: TimeInterval = 10.0, completion: @escaping (Bool) -> Void) {
        let startTime = Date()
        print("⏳ Waiting for AppsFlyer initialization (timeout: \(timeout)s)...")
        
        func checkDataReady() {
            let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
            let advertisingID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            
            let hasValidIDFA = advertisingID != "00000000-0000-0000-0000-000000000000"
            let hasAppsFlyerUID = !appsFlyerUID.isEmpty
            
            // Проверяем готовность: AppsFlyer инициализирован ИЛИ есть данные
            let isReady = (isInitialized || (hasValidIDFA && hasAppsFlyerUID))
            
            let elapsed = Date().timeIntervalSince(startTime)
            
            print("🔍 AppsFlyer check: initialized=\(isInitialized), UID=\(appsFlyerUID.isEmpty ? "empty" : appsFlyerUID), IDFA=\(hasValidIDFA ? advertisingID : "invalid"), elapsed=\(String(format: "%.1f", elapsed))s")
            
            if isReady {
                print("✅ AppsFlyer data ready!")
                print("📊 AppsFlyer UID (sub1): \(appsFlyerUID)")
                print("📱 Advertising ID (sub2): \(advertisingID)")
                completion(true)
            } else if elapsed >= timeout {
                print("⚠️ AppsFlyer data timeout after \(timeout)s")
                print("📊 AppsFlyer UID (sub1): \(appsFlyerUID.isEmpty ? "empty" : appsFlyerUID)")
                print("📱 Advertising ID (sub2): \(advertisingID)")
                print("⚠️ Proceeding anyway...")
                completion(false)
            } else {
                // Проверяем снова через 0.5 секунды
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    checkDataReady()
                }
            }
        }
        
        // Начинаем проверку через небольшую задержку, чтобы AppsFlyer успел запуститься
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            checkDataReady()
        }
    }
    
    // Получение кастомной ссылки с параметрами AppsFlyer
    func getCustomLink(baseURL: String) -> String {
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
        let advertisingID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        let customLink = "\(baseURL)?sub1=\(appsFlyerUID)&sub2=\(advertisingID)"
        
        // Логирование для тестирования
        print("🔗 Custom Link: \(customLink)")
        print("📊 AppsFlyer UID (sub1): \(appsFlyerUID)")
        print("📱 Advertising ID (sub2): \(advertisingID)")
        
        return customLink
    }
    
    // Callback с данными атрибуции
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("✅ ===== APPSFLYER CONVERSION DATA SUCCESS =====")
        print("LOG : \(conversionInfo)")
        isInitialized = true
        print("✅ AppsFlyer marked as initialized")
        
        // Логируем текущие данные
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
        let advertisingID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        print("📊 AppsFlyer UID (sub1): \(appsFlyerUID)")
        print("📱 Advertising ID (sub2): \(advertisingID)")
        
        appsFlyerCompletion?(true)
    }
    
    func onConversionDataFail(_ error: Error) {
        print("❌ ===== APPSFLYER CONVERSION DATA FAIL =====")
        print("❌ AppsFlyer Conversion Data Error: \(error.localizedDescription)")
        isInitialized = true // Помечаем как инициализирован, даже при ошибке
        print("⚠️ AppsFlyer marked as initialized despite error")
        appsFlyerCompletion?(false)
    }
    
    // Отправка кастомного ивента
    func logEvent(_ eventName: String, withValues values: [String: Any]? = nil) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: values)
        print("📊 Event sent: \(eventName)")
    }
}

