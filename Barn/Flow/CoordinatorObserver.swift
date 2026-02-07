//
//  CoordinatorObserver.swift
//  Barn
//
//  WebView error handling and fallback logic
//

import Foundation

class CoordinatorObserver {
    
    static let shared = CoordinatorObserver()
    
    private let flowState = PowerFlowState.shared
    
    private init() {}
    
    func handleWebViewError(_ error: Error) {
        print("❌ WebView error: \(error.localizedDescription)")
        
        // Check if it's a network error
        if isNetworkError(error) {
            print("🔄 Network error detected → Triggering fallback")
            flowState.handleWebViewError()
        } else {
            print("❌ Non-network error → Show Native App")
            CoachModExerciseService.shared.setEnforceNative(true)
            flowState.handleWebViewError()
        }
    }
    
    func handle404Error() {
        print("❌ 404 error detected → Triggering fallback")
        flowState.handleWebViewError()
    }
    
    private func isNetworkError(_ error: Error) -> Bool {
        let nsError = error as NSError
        let networkErrorCodes: [Int] = [
            NSURLErrorTimedOut,
            NSURLErrorNotConnectedToInternet,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorCannotConnectToHost,
            NSURLErrorCannotFindHost,
            NSURLErrorDNSLookupFailed
        ]
        
        return networkErrorCodes.contains(nsError.code)
    }
}
