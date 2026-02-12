//
//  AppsFlyerManager.swift
//  Coin Rule
//
//  AppsFlyer SDK: ATT, initialization, conversion data, custom link.
//

import Foundation
import UIKit
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport

final class AppsFlyerManager: NSObject, AppsFlyerLibDelegate {
    
    static let shared = AppsFlyerManager()
    
    private var conversionData: [AnyHashable: Any]?
    private var conversionDataReceived = false
    private var isInitialized = false
    private let queue = DispatchQueue(label: "com.coinrule.appsflyer")
    
    private override init() {
        super.init()
        setupAppsFlyer()
    }
    
    private func setupAppsFlyer() {
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = "2Wi6iRa3jkS8D5iLuLbKBF"
        appsFlyer.appleAppID = "6758861946"
        appsFlyer.waitForATTUserAuthorization(timeoutInterval: 60)
        appsFlyer.delegate = self
    }
    
    /// Start with ATT first (iOS 14+), then call attCompletion and start AppsFlyer. ATT dialog is always requested when status is .notDetermined.
    func start(attCompletion: @escaping () -> Void, appsFlyerCompletion: (() -> Void)?) {
        if #available(iOS 14, *) {
            // Не пропускаем шаг: всегда вызываем requestTrackingAuthorization (диалог покажется только при .notDetermined).
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                    // 0=notDetermined, 1=restricted, 2=denied, 3=authorized
                    let statusNote = (status.rawValue == 3) ? " (authorized)" : (status.rawValue == 2) ? " (denied)" : ""
                    print("ATT Status: \(status.rawValue)\(statusNote)")
                    attCompletion()
                    AppsFlyerLib.shared().start()
                    self?.isInitialized = true
                    appsFlyerCompletion?()
                }
            }
        } else {
            attCompletion()
            AppsFlyerLib.shared().start()
            isInitialized = true
            appsFlyerCompletion?()
        }
    }
    
    /// Legacy start (no callback) for compatibility.
    func start() {
        start(attCompletion: {}, appsFlyerCompletion: nil)
    }
    
    /// Wait until AppsFlyer UID (sub1) and IDFA (sub2) are ready, or timeout.
    func waitForDataReady(timeout: TimeInterval = 5.0, completion: @escaping (Bool) -> Void) {
        let start = Date()
        let checkInterval: TimeInterval = 0.2
        func check() {
            let uid = getAppsFlyerUID()
            let idfa = getIDFA()
            let invalidIDFA = idfa == "00000000-0000-0000-0000-000000000000" || idfa.isEmpty
            let ready = !uid.isEmpty && !invalidIDFA
            if ready || Date().timeIntervalSince(start) >= timeout {
                DispatchQueue.main.async { completion(ready) }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + checkInterval, execute: check)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: check)
    }
    
    /// Wait for conversion data in-memory only (used once for link building; not persisted).
    func waitForConversionData(timeout: TimeInterval = 8.0, completion: @escaping ([AnyHashable: Any]?) -> Void) {
        if conversionDataReceived, let data = conversionData {
            completion(data)
            return
        }
        let deadline = Date().timeIntervalSince1970 + timeout
        func poll() {
            if conversionDataReceived, let data = conversionData {
                DispatchQueue.main.async { completion(data) }
                return
            }
            if Date().timeIntervalSince1970 >= deadline {
                DispatchQueue.main.async { completion(self.getConversionData()) }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: poll)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: poll)
    }
    
    func getConversionData() -> [AnyHashable: Any]? {
        queue.sync { conversionData }
    }
    
    func getAppsFlyerUID() -> String {
        AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
    }
    
    /// IDFA: читаем всегда с main thread (иначе при status=authorized может вернуться пусто на симуляторе/части устройств).
    func getIDFA() -> String {
        guard #available(iOS 14, *) else { return "" }
        if Thread.isMainThread {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        return DispatchQueue.main.sync {
            ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
    }
    
    /// IDFA для ссылки: всегда возвращаем значение (при отказе в ATT или симуляторе — нулевой UUID).
    private func idfaForLink() -> String {
        let idfa = getIDFA()
        if !idfa.isEmpty && idfa != "00000000-0000-0000-0000-000000000000" { return idfa }
        return "00000000-0000-0000-0000-000000000000"
    }
    
    /// Build URL: baseURL + sub1 + sub2 + all conversion data parameters. sub1, sub2 и conversion data всегда в ссылке.
    func getCustomLink(baseURL: String, conversionData conv: [AnyHashable: Any]?) -> String {
        guard var urlComponents = URLComponents(string: baseURL) else { return baseURL }
        var queryItems = urlComponents.queryItems ?? []
        
        let uid = getAppsFlyerUID()
        let sub1 = uid.isEmpty ? "" : uid
        let sub2 = idfaForLink()
        if !sub1.isEmpty { queryItems.append(URLQueryItem(name: "sub1", value: sub1)) }
        queryItems.append(URLQueryItem(name: "sub2", value: sub2))
        
        if let conv = conv {
            for (key, value) in conv {
                let keyString = String(describing: key)
                let valueString = convertValueToString(value)
                if !valueString.isEmpty, !keyString.isEmpty {
                    queryItems.append(URLQueryItem(name: keyString, value: valueString))
                }
            }
        }
        
        urlComponents.queryItems = queryItems
        let result = urlComponents.url?.absoluteString ?? baseURL
        print("📊 AppsFlyer UID (sub1): \(sub1)")
        let sub2Note = (sub2 == "00000000-0000-0000-0000-000000000000") ? " (на симуляторе или при отказе в ATT так и бывает)" : ""
        print("📱 Advertising ID (sub2): \(sub2)\(sub2Note)")
        if let c = conv { print("📦 Conversion Data parameters: \(c.count) items") }
        return result
    }
    
    private func convertValueToString(_ value: Any) -> String {
        if let s = value as? String { return s }
        if let n = value as? NSNumber { return n.stringValue }
        return String(describing: value)
    }
    
    // MARK: - AppsFlyerLibDelegate
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("✅ Conversion Data:")
        print(conversionInfo)
        print("LOG : \(conversionInfo)")
        queue.async { [weak self] in
            self?.conversionData = conversionInfo
            self?.conversionDataReceived = true
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("❌ Conversion data error: \(error.localizedDescription)")
    }
    
    // MARK: - Events
    
    func logEvent() {
        AppsFlyerLib.shared().logEvent("myTestEvent", withValues: nil)
        print("📊 Event sent: myTestEvent")
    }
    
    func logEventWithParams(params: [String: Any]) {
        AppsFlyerLib.shared().logEvent("myTestEvent", withValues: params)
        print("📊 Event sent: myTestEvent with params: \(params)")
    }
}
