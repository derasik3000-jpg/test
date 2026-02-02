//
//  AppsFlyerManager.swift
//  PowerSession
//
//  AppsFlyer инициализация с поддержкой WebView flow
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
    private var initializationCallback: (() -> Void)?
    
    private override init() {
        super.init()
        setupAppsFlyer()
    }
    
    // Настройка AppsFlyer
    private func setupAppsFlyer() {
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = "VFbyWxPARUWfoH6dZryQEG"
        appsFlyer.appleAppID = "6755775383"
        appsFlyer.waitForATTUserAuthorization(timeoutInterval: 10)
        appsFlyer.delegate = self
    }
    
    // Запрос разрешения и старт с callback
    func start(attCompletion: @escaping () -> Void, appsFlyerCompletion: (() -> Void)? = nil) {
        initializationCallback = appsFlyerCompletion
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    print("ATT Status: \(status.rawValue)")
                    self.attStatusReceived = true
                    // Вызываем completion после получения ответа ATT
                    DispatchQueue.main.async {
                        attCompletion()
                    }
                    // Затем запускаем AppsFlyer
                    AppsFlyerLib.shared().start()
                    NotificationCenter.default.post(name: NSNotification.Name("ATTStatusReceived"), object: nil)
                }
            } else {
                self.attStatusReceived = true
                // Для iOS < 14 сразу вызываем completion
                DispatchQueue.main.async {
                    attCompletion()
                }
                AppsFlyerLib.shared().start()
            }
        }
    }
    
    // Callback с данными атрибуции
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("LOG : \(conversionInfo)")
        isInitialized = true
        NotificationCenter.default.post(name: NSNotification.Name("AppsFlyerInitialized"), object: nil)
        initializationCallback?()
        initializationCallback = nil
    }
    
    func onConversionDataFail(_ error: Error) {
        print("❌ AppsFlyer Error: \(error.localizedDescription)")
        isInitialized = true
        NotificationCenter.default.post(name: NSNotification.Name("AppsFlyerInitialized"), object: nil)
        initializationCallback?()
        initializationCallback = nil
    }
    
    // Получить AppsFlyer UID
    func getAppsFlyerUID() -> String? {
        return AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    // Получить IDFA
    func getIDFA() -> String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    // Проверка готовности данных
    func waitForDataReady(timeout: TimeInterval = 10.0, completion: @escaping (Bool) -> Void) {
        let startTime = Date()
        
        func checkReady() {
            let appsFlyerUID = getAppsFlyerUID() ?? ""
            let idfa = getIDFA()
            let isValidIDFA = idfa != "00000000-0000-0000-0000-000000000000"
            
            if isInitialized && !appsFlyerUID.isEmpty && isValidIDFA {
                print("📊 AppsFlyer UID (sub1): \(appsFlyerUID)")
                print("📱 Advertising ID (sub2): \(idfa)")
                completion(true)
            } else if Date().timeIntervalSince(startTime) >= timeout {
                print("⚠️ AppsFlyer data timeout")
                completion(false)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    checkReady()
                }
            }
        }
        
        checkReady()
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

