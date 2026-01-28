//
//  AppsFlyerManager.swift
//  ApsTest
//
//  Простая инициализация AppsFlyer
//

import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import UIKit
import AdSupport

class AppsFlyerManager: NSObject, AppsFlyerLibDelegate {
    
    static let shared = AppsFlyerManager()
    
    // Базовый URL Keitaro
    private let keitaroBaseURL = "https://olivehvsv.com/qkpJHTCk"
    
    // Флаги готовности
    private(set) var isInitialized = false
    private(set) var attStatusReceived = false
    
    // Callback для уведомления о готовности
    private var initializationCompletion: (() -> Void)?
    
    private override init() {
        super.init()
        setupAppsFlyer()
    }
    
    // Настройка AppsFlyer
    private func setupAppsFlyer() {
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = "HytqxK9vTnV5ihxpK5rhh9"
        appsFlyer.appleAppID = "6755447559"
        appsFlyer.waitForATTUserAuthorization(timeoutInterval: 60)
        appsFlyer.delegate = self
    }
    
    // Запрос разрешения и старт
    func start(completion: @escaping () -> Void) {
        initializationCompletion = completion
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                    guard let self = self else { return }
                    print("ATT Status: \(status.rawValue)")
                    self.attStatusReceived = true
                    AppsFlyerLib.shared().start()
                    
                    // Уведомляем о получении ATT статуса
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("ATTStatusReceived"), object: nil)
                    }
                }
            } else {
                self.attStatusReceived = true
                AppsFlyerLib.shared().start()
                
                // Уведомляем о получении ATT статуса (для iOS < 14)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("ATTStatusReceived"), object: nil)
                }
            }
        }
    }
    
    // Получение кастомной ссылки с параметрами sub1 и sub2
    func getCustomLink() -> String {
        // Получаем AppsFlyer UID (может быть пустым до инициализации)
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
        
        // Получаем Advertising ID (IDFA)
        let advertisingID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        // Проверяем, что ATT статус получен и данные валидны
        if !attStatusReceived {
            print("⚠️ ATT статус еще не получен! sub2 может быть пустым")
        }
        
        // Проверяем, что IDFA не пустой (не 00000000-0000-0000-0000-000000000000)
        if advertisingID == "00000000-0000-0000-0000-000000000000" {
            print("⚠️ IDFA пустой (00000000-0000-0000-0000-000000000000) - возможно ATT еще не обработан")
        }
        
        // Формируем кастомную ссылку
        let customLink = "\(keitaroBaseURL)?sub1=\(appsFlyerUID)&sub2=\(advertisingID)"
        
        // Логирование для тестировщика
        print("🔗 Custom Link: \(customLink)")
        print("📊 AppsFlyer UID (sub1): \(appsFlyerUID.isEmpty ? "not available yet" : appsFlyerUID)")
        print("📱 Advertising ID (sub2): \(advertisingID)")
        print("📋 ATT Status Received: \(attStatusReceived)")
        
        return customLink
    }
    
    // Callback с данными атрибуции
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("LOG : \(conversionInfo)")
        print("✅ Conversion Data Success:")
        for (key, value) in conversionInfo {
            print("  \(key): \(value)")
        }
        
        // Помечаем как инициализированный после получения данных конверсии
        if !isInitialized {
            isInitialized = true
            initializationCompletion?()
            initializationCompletion = nil
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("❌ Conversion Data Error: \(error.localizedDescription)")
        
        // Даже при ошибке помечаем как инициализированный после таймаута
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.isInitialized {
                self.isInitialized = true
                self.initializationCompletion?()
                self.initializationCompletion = nil
            }
        }
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

