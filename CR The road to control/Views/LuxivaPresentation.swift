import SwiftUI
import StoreKit
import AppsFlyerLib
import AdSupport

struct LuxivaLoadingView: View {
    @State private var jironuRotation: Double = 0
    @State private var puwenaScale: CGFloat = 1.0
    @State private var degubaPulseScale: CGFloat = 1.0
    @State private var cuqavuGlowOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Анимированная иконка приложения
                ZStack {
                    // Внешнее свечение
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(cuqavuGlowOpacity),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(degubaPulseScale)
                    
                    // Средний круг с градиентом
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                                    CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(degubaPulseScale * 0.9)
                    
                    // Внутренний спиннер
                    ZStack {
                        Circle()
                            .stroke(
                                CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                                lineWidth: 6
                            )
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: 0.75)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary,
                                        CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(jironuRotation))
                            .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.5), radius: 10, x: 0, y: 0)
                        
                        // Центральная иконка
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            .scaleEffect(puwenaScale)
                    }
                }
                .accessibilityLabel("Loading")
                
                Spacer()
            }
        }
        .onAppear {
            // Вращение спиннера
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                jironuRotation = 360
            }
            
            // Пульсация иконки
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                puwenaScale = 1.1
            }
            
            // Пульсация свечения
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                degubaPulseScale = 1.2
                cuqavuGlowOpacity = 0.8
            }
        }
    }
}

struct TemoraRootView: View {
    @State private var jikonuCurrentRoute: LuxivaRoute = .splash
    @StateObject private var evubewOnboardingViewModel = EhonohOnboardingViewModel()
    @State private var cuqavuIsOnboardingComplete = false
    @State private var appsFlyerInitialized = false
    
    var body: some View {
        Group {
            switch jikonuCurrentRoute {
            case .splash:
                LuxivaLoadingView()
                    .onAppear {
                        // Сначала проверяем дату, затем ждем ATT если нужно
                        checkDateAndProceed()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ATTStatusReceived"))) { _ in
                        // После получения ATT статуса ждем немного и продолжаем
                        print("✅ ATT статус получен, ждем инициализации AppsFlyer...")
                        waitForAppsFlyerReadyAfterATT()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppsFlyerInitialized"))) { _ in
                        if !appsFlyerInitialized {
                            appsFlyerInitialized = true
                            // После полной инициализации AppsFlyer продолжаем стандартный путь
                            continueWithWebViewChecks()
                        }
                    }
            case .stone:
                ZStack {
                    CuqavuMainTabView()
                        .onAppear {
                            cuqavuIsOnboardingComplete = true
                        }
                    
                    if !cuqavuIsOnboardingComplete && !evubewOnboardingViewModel.axemobIsOnboardingComplete() {
                        DegubaOnboardingView(cuqavuIsOnboardingComplete: $cuqavuIsOnboardingComplete)
                    }
                }
            case .branch(let url):
                PuwelaPanel(entry: url)
            }
        }
    }
    
    private func checkDateAndProceed() {
        // ШАГ 1: Проверка флагов (ПЕРВАЯ проверка, до всего остального)
        if CoachModExerciseService.instance.traineeModIsEnforceNative() {
            // enforceNative = true → показываем нативное приложение без проверок
            print("🔬 Флаги: enforceNative = true → нативное приложение")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.jikonuCurrentRoute = .stone
                let degubaCounter = (UserDefaults.standard.integer(forKey: "app.launchCount") + 1)
                self.coachModCheckRatingAlertEligibility(counter: degubaCounter)
            }
            return
        }
        
        if CoachModExerciseService.instance.coachModHasShownAlternativeMode() {
            // hasShownAlternative = true → показываем WebView с сохраненным URL без проверок
            print("🔬 Флаги: hasShownAlternative = true → WebView с сохраненным URL")
            initiateSequence()
            return
        }
        
        // ШАГ 2: Первый вход → ВСЕГДА делаем ATT запрос (без проверки даты!)
        if CoachModExerciseService.instance.traineeModIsFirstLaunch() {
            print("🔬 Первый вход: запускаем ATT запрос (без проверки даты)")
            AppsFlyerManager.shared.start {
                // Уведомляем о готовности через NotificationCenter
                NotificationCenter.default.post(name: NSNotification.Name("AppsFlyerInitialized"), object: nil)
            }
            // Ждем ATT и инициализации AppsFlyer перед проверками
            waitForAppsFlyerInitialization()
        } else {
            // Не первый вход - сразу переходим к стандартной логике
            initiateSequence()
        }
    }
    
    private func waitForAppsFlyerInitialization() {
        // Сначала проверяем, получен ли ATT статус
        guard AppsFlyerManager.shared.attStatusReceived else {
            print("⏳ Waiting for ATT status...")
            // Ждем уведомления о получении ATT статуса
            return
        }
        
        // Если ATT получен, проверяем инициализацию AppsFlyer
        if AppsFlyerManager.shared.isInitialized {
            appsFlyerInitialized = true
            continueWithWebViewChecks()
            return
        }
        
        // Если не инициализирован, ждем максимум 10 секунд
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if !self.appsFlyerInitialized {
                print("⚠️ AppsFlyer initialization timeout, proceeding anyway")
                self.appsFlyerInitialized = true
                self.continueWithWebViewChecks()
            }
        }
    }
    
    private func waitForAppsFlyerReadyAfterATT() {
        // После получения ATT статуса ждем немного, чтобы AppsFlyer успел получить UID и IDFA
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Проверяем, что у нас есть валидные данные
            let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
            let advertisingID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            
            print("📊 Проверка данных после ATT:")
            print("   AppsFlyer UID: \(appsFlyerUID.isEmpty ? "не доступен" : appsFlyerUID)")
            print("   Advertising ID: \(advertisingID)")
            
            // Проверяем, что IDFA не пустой (не 00000000-0000-0000-0000-000000000000)
            let isEmptyIDFA = advertisingID == "00000000-0000-0000-0000-000000000000"
            
            if isEmptyIDFA {
                print("⚠️ IDFA все еще пустой, ждем еще...")
            }
            
            // Если AppsFlyer уже инициализирован и IDFA валиден, продолжаем сразу
            if AppsFlyerManager.shared.isInitialized && !isEmptyIDFA && !appsFlyerUID.isEmpty {
                self.appsFlyerInitialized = true
                self.continueWithWebViewChecks()
                return
            }
            
            // Иначе ждем инициализации и валидных данных или таймаут
            var checkCount = 0
            let maxChecks = 20 // 20 проверок по 0.5 секунды = 10 секунд максимум
            
            func checkReady() {
                checkCount += 1
                
                let currentUID = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
                let currentIDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                let isReady = AppsFlyerManager.shared.isInitialized && 
                             currentIDFA != "00000000-0000-0000-0000-000000000000" &&
                             !currentUID.isEmpty
                
                if isReady {
                    print("✅ Данные готовы: UID=\(currentUID), IDFA=\(currentIDFA)")
                    self.appsFlyerInitialized = true
                    self.continueWithWebViewChecks()
                } else if checkCount < maxChecks {
                    if checkCount % 4 == 0 { // Логируем каждые 2 секунды
                        print("⏳ Ожидание данных... UID=\(currentUID.isEmpty ? "нет" : currentUID), IDFA=\(currentIDFA == "00000000-0000-0000-0000-000000000000" ? "нет" : currentIDFA)")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        checkReady()
                    }
                } else {
                    print("⚠️ AppsFlyer initialization timeout after ATT, proceeding anyway")
                    print("   Финальные данные: UID=\(currentUID.isEmpty ? "нет" : currentUID), IDFA=\(currentIDFA)")
                    self.appsFlyerInitialized = true
                    self.continueWithWebViewChecks()
                }
            }
            
            checkReady()
        }
    }
    
    private func continueWithWebViewChecks() {
        // После AppsFlyer инициализации выполняем проверки
        // ШАГ 1: Проверка даты (первая проверка после AppsFlyer)
        if !CoachModExerciseService.instance.coachModCheckDatePublic() {
            print("🔬 Проверка даты: Не прошла - показываем нативное приложение")
            UserDefaults.standard.set(true, forKey: "flow.enforceNative")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.jikonuCurrentRoute = .stone
                let degubaCounter = (UserDefaults.standard.integer(forKey: "app.launchCount") + 1)
                self.coachModCheckRatingAlertEligibility(counter: degubaCounter)
            }
            return
        }
        
        print("🔬 Проверка даты: Пройдена - продолжаем остальные проверки")
        
        // ШАГ 2: Остальные проверки (устройство, интернет, сервер)
        let axemobStartTime = Date()
        
        CoachModExerciseService.instance.coachModValidateFirstLaunch { [self] success, url in
            let elapsed = Date().timeIntervalSince(axemobStartTime)
            let wait = max(0, 3.0 - elapsed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                if success {
                    self.jikonuCurrentRoute = .branch(url)
                } else {
                    self.jikonuCurrentRoute = .stone
                }
                let degubaCounter = (UserDefaults.standard.integer(forKey: "app.launchCount") + 1)
                self.coachModCheckRatingAlertEligibility(counter: degubaCounter)
            }
        }
    }
    
    private func initiateSequence() {
        // Эта функция вызывается только при НЕ первом входе
        // Проверки НЕ выполняем, просто открываем сохраненный URL или нативное приложение
        
        let degubaCounter = (UserDefaults.standard.integer(forKey: "app.launchCount") + 1)
        UserDefaults.standard.set(degubaCounter, forKey: "app.launchCount")
        
        let axemobStartTime = Date()
        
        // Проверяем флаги без выполнения проверок
        if CoachModExerciseService.instance.traineeModIsEnforceNative() {
            // Был показан нативный режим - открываем его без проверок
            print("🔬 Не первый вход: enforceNative = true → нативное приложение")
            let elapsed = Date().timeIntervalSince(axemobStartTime)
            let wait = max(0, 2.0 - elapsed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                self.jikonuCurrentRoute = .stone
                self.coachModCheckRatingAlertEligibility(counter: degubaCounter)
            }
        } else if CoachModExerciseService.instance.coachModHasShownAlternativeMode() {
            // Был показан WebView - открываем сохраненный URL без проверок
            print("🔬 Не первый вход: hasShownAlternativeMode = true → WebView с сохраненным URL")
            CoachModExerciseService.instance.traineeModValidateSavedURL { [self] success, url in
                let elapsed = Date().timeIntervalSince(axemobStartTime)
                let wait = max(0, 2.0 - elapsed)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                    // Всегда показываем WebView, даже если URL невалиден (показываем пустой)
                    self.jikonuCurrentRoute = .branch(url)
                    self.coachModCheckRatingAlertEligibility(counter: degubaCounter)
                }
            }
        } else {
            // Не должно происходить, но на всякий случай - показываем нативное приложение
            print("⚠️ Не первый вход: нет флагов → нативное приложение (fallback)")
            let elapsed = Date().timeIntervalSince(axemobStartTime)
            let wait = max(0, 2.0 - elapsed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                self.jikonuCurrentRoute = .stone
                self.coachModCheckRatingAlertEligibility(counter: degubaCounter)
            }
        }
    }
    
    private func coachModCheckRatingAlertEligibility(counter: Int) {
        // Проверяем условия для показа алерта оценки
        let hasShownAlternative = CoachModExerciseService.instance.coachModHasShownAlternativeMode()
        let ratingAlertShown = UserDefaults.standard.bool(forKey: "CrabsRatingAlertShown")
        
        // Показываем алерт при втором запуске, если был показан альтернативный режим
        if hasShownAlternative && counter == 2 && !ratingAlertShown {
            coachModShowRatingAlert()
        }
    }
    
    private func coachModShowRatingAlert() {
        // Показываем нативный алерт оценки на английском языке
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            UserDefaults.standard.set(true, forKey: "CrabsRatingAlertShown")
        }
    }
}

