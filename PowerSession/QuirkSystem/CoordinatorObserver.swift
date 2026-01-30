//
//  CoordinatorObserver.swift
//  PowerSession
//
//  Обработчик ошибок WebView и fallback логика
//

import Foundation

final class CoordinatorObserver {
    static let shared = CoordinatorObserver()
    
    private init() {}
    
    func handleWebViewError(_ error: Error, completion: @escaping (Bool, URL?) -> Void) {
        print("🔴 WebView error detected: \(error.localizedDescription)")
        
        // Try fallback URL
        CoachModExerciseService.shared.coachModTryFallbackURL { success, url in
            if success, let url = url {
                print("✅ Fallback URL successful: \(url.absoluteString)")
                completion(true, url)
            } else {
                print("❌ Fallback URL failed")
                completion(false, nil)
            }
        }
    }
    
    func handle404Error(completion: @escaping (Bool, URL?) -> Void) {
        print("🔴 404 error detected")
        handleWebViewError(NSError(domain: "WebView", code: 404, userInfo: [NSLocalizedDescriptionKey: "404 Not Found"]), completion: completion)
    }
}
