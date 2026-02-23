// ──────────────────────────────────────────────
// KitchenAffiliateManager.swift
// Culinary Routine Choose & Chill
//
// Manages AppsFlyer SDK, ATT request, and conversion
// data collection. Culinary-themed affiliate tracking.
// ──────────────────────────────────────────────

import Foundation
import UIKit
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍳 KitchenAffiliateManager
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class KitchenAffiliateManager: NSObject, AppsFlyerLibDelegate {

    static let shared = KitchenAffiliateManager()

    // ── Configuration ────────────────────────

    private let devKey = "83E3fo2cfDzTLpBR6d4ZTK"
    private let appleAppID = "6759327383"

    // ── State (in memory only) ────────────────

    private(set) var conversionData: [AnyHashable: Any]?
    private(set) var conversionDataReceived = false
    private(set) var isInitialized = false

    // ── Init ──────────────────────────────────

    private override init() {
        super.init()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Public: Start Flow
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Starts ATT request (first launch), then AppsFlyer.
    /// attCompletion called after ATT response received.
    func start(
        attCompletion: @escaping () -> Void,
        appsFlyerCompletion: (() -> Void)?
    ) {
        if #available(iOS 14, *) {
            let currentStatus = ATTrackingManager.trackingAuthorizationStatus
            if currentStatus != .notDetermined {
                attCompletion()
                setupAppsFlyer()
                AppsFlyerLib.shared().start()
                appsFlyerCompletion?()
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                ATTrackingManager.requestTrackingAuthorization { _ in
                    attCompletion()
                    self?.setupAppsFlyer()
                    AppsFlyerLib.shared().start()
                    appsFlyerCompletion?()
                }
            }
        } else {
            attCompletion()
            setupAppsFlyer()
            AppsFlyerLib.shared().start()
            appsFlyerCompletion?()
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Wait for Data Ready
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Waits for AppsFlyer UID (sub1) and IDFA (sub2) to be ready.
    /// Timeout: 5 seconds. Check interval: 0.1 seconds.
    func waitForDataReady(completion: @escaping (Bool) -> Void) {
        let startTime = Date()
        let timeout: TimeInterval = 5.0
        let checkInterval: TimeInterval = 0.1

        func check() {
            let uid = getAppsFlyerUID()
            let idfa = getIDFA()
            let ready = !uid.isEmpty && idfa != "00000000-0000-0000-0000-000000000000"

            if ready {
                completion(true)
            } else if Date().timeIntervalSince(startTime) >= timeout {
                completion(false)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + checkInterval) {
                    check()
                }
            }
        }
        check()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Wait for Conversion Data
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Waits for conversion data up to 15s + 5s grace (20s total).
    func waitForConversionData(forceWait: Bool = false, completion: @escaping ([AnyHashable: Any]?) -> Void) {
        if !forceWait && conversionDataReceived && isInitialized, let data = conversionData {
            completion(data)
            return
        }

        let startTime = Date()
        let timeout: TimeInterval = 15.0
        let gracePeriod: TimeInterval = 5.0

        func check() {
            if conversionDataReceived, let data = conversionData {
                completion(data)
            } else if Date().timeIntervalSince(startTime) >= timeout + gracePeriod {
                completion(nil)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    check()
                }
            }
        }
        check()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Custom Link Generation
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func getCustomLink(baseURL: String, conversionData: [AnyHashable: Any]? = nil) -> String {
        guard var urlComponents = URLComponents(string: baseURL) else { return baseURL }

        var queryItems = urlComponents.queryItems ?? []

        let uid = getAppsFlyerUID()
        let idfa = getIDFA()
        queryItems.append(URLQueryItem(name: "sub1", value: uid))
        queryItems.append(URLQueryItem(name: "sub2", value: idfa))

        if let data = conversionData {
            for (key, value) in data {
                let keyStr = String(describing: key)
                let valueStr = convertValueToString(value)
                if !valueStr.isEmpty && !keyStr.isEmpty {
                    queryItems.append(URLQueryItem(name: keyStr, value: valueStr))
                }
            }
        }

        urlComponents.queryItems = queryItems
        let result = urlComponents.url?.absoluteString ?? baseURL

        print("🔗 Custom Link: \(result)")
        print("📊 AppsFlyer UID (sub1): \(uid)")
        print("📱 Advertising ID (sub2): \(idfa)")
        if let data = conversionData {
            print("📦 Conversion Data parameters: \(data.count) items")
        }

        return result
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - AppsFlyerLibDelegate
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("LOG : \(conversionInfo)")
        print("✅ onConversionDataSuccess – Conversion Data received")

        conversionData = conversionInfo
        conversionDataReceived = true
        isInitialized = true

        for (key, value) in conversionInfo {
            print("   - \(key): \(value)")
        }
        print("📦 Conversion data stored in memory (\(conversionInfo.count) parameters)")
    }

    func onConversionDataFail(_ error: Error) {
        print("❌ onConversionDataFail: \(error)")
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Private
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func setupAppsFlyer() {
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = devKey
        appsFlyer.appleAppID = appleAppID
        appsFlyer.waitForATTUserAuthorization(timeoutInterval: 60)
        appsFlyer.delegate = self
    }

    private func getAppsFlyerUID() -> String {
        AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
    }

    private func getIDFA() -> String {
        if #available(iOS 14, *) {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    private func convertValueToString(_ value: Any) -> String {
        if let str = value as? String { return str }
        if let num = value as? NSNumber { return num.stringValue }
        return String(describing: value)
    }
}
