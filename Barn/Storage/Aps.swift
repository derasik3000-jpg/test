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
    private var conversionData: [AnyHashable: Any]?
    private var conversionDataReceived = false
    
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
                
                // Minimal delay so UI is ready (README: 0.1s for maximum speed)
                print("⏳ Waiting 0.1s before showing ATT dialog (ensuring UI is ready)...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
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
    
    // README: wait for AppsFlyer sub1 & sub2, timeout 5s, check interval 0.2s
    func waitForDataReady(timeout: TimeInterval = 5.0, completion: @escaping (Bool) -> Void) {
        let startTime = Date()
        let checkInterval: TimeInterval = 0.2
        print("⏳ Waiting for AppsFlyer initialization (timeout: \(timeout)s, check every \(checkInterval)s)...")
        
        func checkDataReady() {
            let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
            let advertisingID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            
            let hasValidIDFA = advertisingID != "00000000-0000-0000-0000-000000000000"
            let hasAppsFlyerUID = !appsFlyerUID.isEmpty
            
            let isReady = (isInitialized || (hasValidIDFA && hasAppsFlyerUID))
            let elapsed = Date().timeIntervalSince(startTime)
            
            if isReady {
                print("✅ AppsFlyer data ready!")
                print("📊 AppsFlyer UID (sub1): \(appsFlyerUID)")
                print("📱 Advertising ID (sub2): \(advertisingID)")
                completion(true)
            } else if elapsed >= timeout {
                print("⚠️ AppsFlyer data timeout after \(timeout)s")
                completion(false)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + checkInterval) {
                    checkDataReady()
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + checkInterval) {
            checkDataReady()
        }
    }
    
    /// Wait for conversion data up to 8 seconds (README). Used only once at first login — not persisted.
    func waitForConversionData(forceWait: Bool = false, completion: @escaping ([AnyHashable: Any]?) -> Void) {
        if !forceWait && conversionDataReceived, let data = conversionData {
            completion(data)
            return
        }
        
        let deadline = Date().timeIntervalSince1970 + 8.0
        func waitLoop() {
            if conversionDataReceived, let data = conversionData {
                completion(data)
                return
            }
            if Date().timeIntervalSince1970 >= deadline {
                completion(nil)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { waitLoop() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { waitLoop() }
    }
    
    /// README: baseURL + sub1 + sub2 + all conversion data params (dynamic)
    func getCustomLink(baseURL: String, conversionData: [AnyHashable: Any]? = nil) -> String {
        guard var urlComponents = URLComponents(string: baseURL) else { return baseURL }
        var queryItems = urlComponents.queryItems ?? []
        
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
        let advertisingID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        queryItems.append(URLQueryItem(name: "sub1", value: appsFlyerUID))
        queryItems.append(URLQueryItem(name: "sub2", value: advertisingID))
        
        if let conversionData = conversionData {
            for (key, value) in conversionData {
                let keyStr = String(describing: key)
                let valueStr = convertValueToString(value)
                if !keyStr.isEmpty && !valueStr.isEmpty {
                    queryItems.append(URLQueryItem(name: keyStr, value: valueStr))
                }
            }
        }
        
        urlComponents.queryItems = queryItems
        let customLink = urlComponents.url?.absoluteString ?? baseURL
        
        print("🔗 Custom Link: \(customLink)")
        print("📊 AppsFlyer UID (sub1): \(appsFlyerUID)")
        print("📱 Advertising ID (sub2): \(advertisingID)")
        if let conversionData = conversionData {
            print("📦 Conversion Data parameters: \(conversionData.count) items")
        }
        return customLink
    }
    
    private func convertValueToString(_ value: Any) -> String {
        if let s = value as? String { return s }
        if let n = value as? NSNumber { return n.stringValue }
        return String(describing: value)
    }
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("✅ ===== APPSFLYER CONVERSION DATA SUCCESS =====")
        print("LOG : \(conversionInfo)")
        conversionData = conversionInfo
        conversionDataReceived = true
        isInitialized = true
        // Conversion data used only once at first login — not persisted
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

