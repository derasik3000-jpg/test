//
//  TemoraRootView.swift
//  PowerSession
//
//  Главный view для WebView с темным фоном
//

import SwiftUI

struct TemoraRootView: View {
    let url: URL
    @State private var currentURL: URL
    @State private var fallbackAttempts = 0
    
    init(url: URL) {
        self.url = url
        _currentURL = State(initialValue: url)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            PuwelaPanel(
                url: currentURL,
                onError: { error in
                    handleError(error)
                },
                on404Detected: {
                    handle404()
                }
            )
        }
    }
    
    private func handleError(_ error: Error) {
        // Предотвращаем множественные попытки fallback
        guard fallbackAttempts == 0 else {
            print("⚠️ Fallback already attempted, ignoring error")
            return
        }
        
        fallbackAttempts += 1
        print("🔴 WebView error, attempting fallback (attempt \(fallbackAttempts))")
        
        CoordinatorObserver.shared.handleWebViewError(error) { success, url in
            if success, let url = url {
                print("✅ Fallback URL loaded, updating WebView")
                currentURL = url
                // Сбрасываем счетчик для нового URL
                fallbackAttempts = 0
            } else {
                print("❌ Fallback URL failed, WebView will show error")
                // Не переключаемся на нативное приложение, просто оставляем WebView с ошибкой
            }
        }
    }
    
    private func handle404() {
        // Предотвращаем множественные попытки fallback
        guard fallbackAttempts == 0 else {
            print("⚠️ Fallback already attempted, ignoring 404")
            return
        }
        
        fallbackAttempts += 1
        print("🔴 404 detected, attempting fallback (attempt \(fallbackAttempts))")
        
        CoordinatorObserver.shared.handle404Error { success, url in
            if success, let url = url {
                print("✅ Fallback URL loaded, updating WebView")
                currentURL = url
                // Сбрасываем счетчик для нового URL
                fallbackAttempts = 0
            } else {
                print("❌ Fallback URL failed, WebView will show error")
                // Не переключаемся на нативное приложение, просто оставляем WebView с ошибкой
            }
        }
    }
}
