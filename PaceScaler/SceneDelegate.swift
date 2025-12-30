import UIKit
import WebKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var dependencies: PqDependencyContainer?

    // Минимальное время показа Splash
    private let minimumSplashTime: TimeInterval = 3
    private var splashStartTime: Date?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        splashStartTime = Date()

        // Показываем Splash сразу
        window.rootViewController = PaceSplashViewController()
        window.makeKeyAndVisible()

        // Выполняем seed
        Task { @MainActor in
            do {
                try await PqPersistenceController.shared.pqExecuteInitialSeed()
            } catch {
                print("Seed error: \(error)")
            }
        }

        // Запуск проверки конфигурации
        startFlow()
    }


    // MARK: - Старт лендинга / pathId / main flow
    private func startFlow() {
        PaceLogicController.shared.resolveConfig { [weak self] success, pathId in
            guard let self = self else { return }

            let elapsed = Date().timeIntervalSince(self.splashStartTime ?? Date())
            let remaining = max(0, self.minimumSplashTime - elapsed)

            DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
                if success, let id = pathId {
                    self.showPath(with: id)
                } else {
                    self.launchFromOnboardingOrMain()
                }
            }
        }
    }


    // MARK: - PathId экран (WebView)
    private func showPath(with id: String) {
        let displayVC = PaceDisplayViewController(pathId: id)
        window?.rootViewController = displayVC
    }


    // MARK: - Onboarding / Main App
    private func launchFromOnboardingOrMain() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "PqHasCompletedOnboarding")

        if hasCompletedOnboarding {
            showMainApp()
        } else {
            showOnboarding()
        }
    }


    // MARK: - Onboarding
    @MainActor
    private func showOnboarding() {
        let onboardingVC = PqOnboardingViewController()
        onboardingVC.onComplete = { [weak self] in
            UserDefaults.standard.set(true, forKey: "PqHasCompletedOnboarding")
            Task { @MainActor in
                self?.showMainApp()
            }
        }

        window?.rootViewController = onboardingVC
    }


    // MARK: - Main App
    @MainActor
    private func showMainApp() {
        guard let window = window else { return }

        do {
            let deps = PqDependencyContainer()
            dependencies = deps

            let tabBar = PqTabBarController(dependencies: deps)
            window.rootViewController = tabBar

        } catch {
            fatalError("Failed to launch main app: \(error)")
        }
    }
}
