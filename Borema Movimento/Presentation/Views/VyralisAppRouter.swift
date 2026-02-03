import SwiftUI
import AppsFlyerLib

struct VyralisAppRouter: View {
    @State private var launchRoute: ApplicationLaunchRoute = .splash
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Group {
                switch launchRoute {
                case .splash:
                    VyralisLoadingView()
                        .onAppear { bootSequence() }
                case .stone:
                    MainContentView()
                case .branch(let url):
                    CoachModFlowView(entryURL: url)
                }
            }
        }
    }
    
    private func bootSequence() {
        // STEP 1: Проверка флагов (ПЕРВАЯ, до всего остального)
        let hasShownAlternative = NewExerciseService.shared.hasShownAlternativeMode()
        let enforceNative = UserDefaults.standard.bool(forKey: "flow.enforceNative")
        
        // Не первый вход - проверяем флаги
        if hasShownAlternative || enforceNative {
            if enforceNative {
                // Был показан нативный режим - открываем без проверок
                print("проверки: enforceNative = true → Native App")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    launchRoute = .stone
                }
                return
            }
            
            if hasShownAlternative {
                // Был показан альтернативный режим - открываем сохраненный URL без проверок
                print("проверки: hasShownAlternative = true → WebView")
                if let savedURL = NewExerciseService.shared.getSavedTargetURL() {
                    // Проверяем валидность URL
                    NewExerciseService.shared.validateURL(savedURL) { isValid in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            if isValid {
                                launchRoute = .branch(savedURL)
                            } else {
                                // Запускаем fallback логику
                                NewExerciseService.shared.handleFallback { fallbackURL in
                                    DispatchQueue.main.async {
                                        if let url = fallbackURL {
                                            launchRoute = .branch(url)
                                        } else {
                                            // Показываем пустой view если fallback не сработал
                                            launchRoute = .branch(savedURL)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        launchRoute = .stone
                    }
                }
                return
            }
        }
        
        // Первый вход - ВСЕГДА показываем ATT → AppsFlyer → валидации
        print("проверки: первый запуск → ATT → AppsFlyer → валидации")
        
        // STEP 2: ATT Request (ВСЕГДА при первом запуске)
        // Добавляем небольшую задержку чтобы UI был готов к показу ATT диалога
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AppsFlyerManager.shared.start {
                // STEP 3: Выполняем валидации после AppsFlyer готовности (включая проверку даты)
                NewExerciseService.shared.performValidations { result in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        switch result {
                        case .success(let url):
                            print("проверки: валидации пройдены → навсегда запоминаем веб режим")
                            // Навсегда запоминаем веб режим
                            NewExerciseService.shared.setHasShownAlternativeMode(true)
                            NewExerciseService.shared.saveFinalURL(url)
                            launchRoute = .branch(url)
                            
                        case .failed:
                            print("проверки: валидации провалены → навсегда запоминаем обычное приложение")
                            // Навсегда запоминаем обычное приложение
                            UserDefaults.standard.set(true, forKey: "flow.enforceNative")
                            launchRoute = .stone
                        }
                    }
                }
            }
        }
    }
}

struct MainContentView: View {
    @StateObject private var viewModel = DependencyContainer.shared.makeHomeViewModel()
    
    var body: some View {
        HomeView(viewModel: viewModel)
    }
}

