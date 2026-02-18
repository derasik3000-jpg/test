// ──────────────────────────────────────────────
// SousChefCoordinator.swift
// с8 – "Menu of 12 Dishes"
//
// Root coordinator. Decides the flow:
//   Splash ➜ Onboarding (first run)
//          ➜ Main Tab Bar (returning user)
// Owns child coordinators for each tab.
// ──────────────────────────────────────────────

import UIKit
import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🧑‍🍳 SousChefCoordinator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class SousChefCoordinator {

    // ── Dependencies ─────────────────────────

    private let window: UIWindow
    private let vault: CellarVault

    // ── State ────────────────────────────────

    private var tabBarController: BistroTabBarController?

    // ── Init ─────────────────────────────────

    init(window: UIWindow, vault: CellarVault = .shared) {
        self.window = window
        self.vault = vault
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Public: Start
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Entry point called from SceneDelegate.
    func openKitchen() {
        showSplash()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Splash
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func showSplash() {
        let splashVC = FlambeSplashViewController()
        splashVC.onFlameOut = { [weak self] in
            self?.decidePath()
        }
        window.rootViewController = splashVC
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Decision
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func decidePath() {
        if vault.hasCompletedOnboarding {
            transitionToMainKitchen()
        } else {
            showOnboarding()
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Onboarding
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func showOnboarding() {
        let onboardVC = TastingOnboardViewController()
        onboardVC.onTastingComplete = { [weak self] in
            self?.vault.markOnboardingDone()
            self?.transitionToMainKitchen()
        }
        crossfadeTransition(to: onboardVC)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Main Tab Bar
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func transitionToMainKitchen() {
        let tabBar = buildTabBar()
        self.tabBarController = tabBar
        crossfadeTransition(to: tabBar)
    }

    private func buildTabBar() -> BistroTabBarController {
        // ── Tab 1: 12 Dishes ("Pantry") ──────
        let pantryVC = PantryGridViewController()
        pantryVC.coordinatorDelegate = self
        let pantryNav = seasonedNav(
            root: pantryVC,
            title: "My 12",
            icon: "square.grid.2x2.fill",
            tag: 0
        )

        // ── Tab 2: Week Plan ─────────────────
        let weekVC = BanquetWeekViewController()
        weekVC.coordinatorDelegate = self
        let weekNav = seasonedNav(
            root: weekVC,
            title: "Week",
            icon: "calendar",
            tag: 1
        )

        // ── Tab 3: Shopping ──────────────────
        let viewModel = ShoppingListViewModel()
        viewModel.coordinatorDelegate = self
        viewModel.onShowHelp = { [weak self] in
            self?.showShoppingHelp()
        }
        viewModel.onOpenStoreMode = { [weak self] roll in
            self?.requestStoreMode(roll: roll)
        }
        let shoppingView = ShoppingListView(viewModel: viewModel)
        let shopVC = UIHostingController(rootView: shoppingView)
        shopVC.view.backgroundColor = SaffronPalette.crust
        let shopNav = seasonedNav(
            root: shopVC,
            title: "Shopping",
            icon: "cart.fill",
            tag: 2
        )

        let tabBar = BistroTabBarController()
        tabBar.viewControllers = [pantryNav, weekNav, shopNav]
        tabBar.selectedIndex = 0

        return tabBar
    }

    /// Creates a UINavigationController with dark styling.
    private func seasonedNav(
        root: UIViewController,
        title: String,
        icon: String,
        tag: Int
    ) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        let tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: icon)
        )
        tabBarItem.tag = tag
        nav.tabBarItem = tabBarItem
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Navigation Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Smooth crossfade when changing root view controller.
    private func crossfadeTransition(to vc: UIViewController) {
        let duration: TimeInterval = FrostBox.shouldReduceMotion ? 0.1 : 0.45

        UIView.transition(
            with: window,
            duration: duration,
            options: [.transitionCrossDissolve, .curveEaseInOut],
            animations: {
                let old = self.window.rootViewController
                self.window.rootViewController = vc
                old?.dismiss(animated: false)
            }
        )
    }

    /// Active navigation controller for the currently visible tab.
    private var activeNav: UINavigationController? {
        tabBarController?.selectedViewController as? UINavigationController
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍽 KitchenNavigable Protocol
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Protocol that view controllers use to request navigation.
protocol KitchenNavigable: AnyObject {
    // Pantry
    func requestOpenEntreeDetail(_ entree: Entree)
    func requestCreateEntree(atSlot index: Int)
    func requestEditEntree(_ entree: Entree)

    // Week
    func requestOpenDayDetail(date: Date, week: FeastWeek)
    func requestSwapSlot(_ slot: ServingSlot, inWeek: FeastWeek)
    func requestOpenRulesEditor()
    func requestOpenWeekHistory()

    // Shopping
    func requestOpenTicketDetail(_ ticket: GroceryTicket)
    func requestStoreMode(roll: GroceryRoll)

    // Settings / Stats
    func requestOpenSettings()
    func requestOpenStats()

    // Cross-tab
    func requestSwitchToWeekTab()
    func requestSwitchToShoppingTab()
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - KitchenNavigable Implementation
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension SousChefCoordinator: KitchenNavigable {

    // ── Pantry / Dishes ──────────────────────

    func requestOpenEntreeDetail(_ entree: Entree) {
        let detailVC = RecipeForgeViewController(mode: .view(entree))
        detailVC.coordinatorDelegate = self
        activeNav?.pushViewController(detailVC, animated: true)
    }

    func requestCreateEntree(atSlot index: Int) {
        let createVC = RecipeForgeViewController(mode: .create(slotIndex: index))
        createVC.coordinatorDelegate = self
        let modalNav = UINavigationController(rootViewController: createVC)
        modalNav.modalPresentationStyle = .pageSheet
        if let sheet = modalNav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        activeNav?.present(modalNav, animated: true)
    }

    func requestEditEntree(_ entree: Entree) {
        let editVC = RecipeForgeViewController(mode: .edit(entree))
        editVC.coordinatorDelegate = self
        let modalNav = UINavigationController(rootViewController: editVC)
        modalNav.modalPresentationStyle = .pageSheet
        if let sheet = modalNav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        activeNav?.present(modalNav, animated: true)
    }

    // ── Week ─────────────────────────────────

    func requestOpenDayDetail(date: Date, week: FeastWeek) {
        // Day detail is handled inline by BanquetWeekViewController
        // for now via expansion — placeholder for future push screen
    }

    func requestSwapSlot(_ slot: ServingSlot, inWeek week: FeastWeek) {
        let broth = MenuGenerationBroth(vault: vault)
        let candidates = broth.swapCandidates(for: slot, inWeek: week)

        let swapVC = SwapPickerSheet(
            slot: slot,
            candidates: candidates
        )
        swapVC.onDishChosen = { [weak self] chosenEntree in
            // Caller (BanquetWeekVC) handles the actual slot update
            NotificationCenter.default.post(
                name: .init("SwapSlotChosen"),
                object: nil,
                userInfo: [
                    "slotID": slot.id,
                    "entreeID": chosenEntree.id
                ]
            )
        }

        let modalNav = UINavigationController(rootViewController: swapVC)
        modalNav.modalPresentationStyle = .pageSheet
        if let sheet = modalNav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        activeNav?.present(modalNav, animated: true)
    }

    func requestOpenRulesEditor() {
        let rulesVC = RulesForgeSheet()
        let modalNav = UINavigationController(rootViewController: rulesVC)
        modalNav.modalPresentationStyle = .pageSheet
        if let sheet = modalNav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        activeNav?.present(modalNav, animated: true)
    }

    func requestOpenWeekHistory() {
        // Future: push a week history list
    }

    // ── Shopping ─────────────────────────────

    func requestOpenTicketDetail(_ ticket: GroceryTicket) {
        // Future: push ticket detail
    }

    func showShoppingHelp() {
        let helpVC = ShoppingHelpViewController()
        let nav = UINavigationController(rootViewController: helpVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        activeNav?.present(nav, animated: true)
    }
    
    func requestStoreMode(roll: GroceryRoll) {
        let storeModeVC = StoreModeViewController(roll: roll)
        storeModeVC.modalPresentationStyle = .fullScreen
        activeNav?.present(storeModeVC, animated: true)
    }

    // ── Settings / Stats ─────────────────────

    func requestOpenSettings() {
        let settingsVC = SpiceRackSettingsViewController()
        settingsVC.coordinatorDelegate = self
        activeNav?.pushViewController(settingsVC, animated: true)
    }

    func requestOpenStats() {
        let statsVC = EmberStatsViewController()
        activeNav?.pushViewController(statsVC, animated: true)
    }

    // ── Cross-Tab ────────────────────────────

    func requestSwitchToWeekTab() {
        tabBarController?.selectedIndex = 1
    }

    func requestSwitchToShoppingTab() {
        tabBarController?.selectedIndex = 2
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🔀 Swap Picker Sheet (lightweight)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Bottom-sheet for choosing a replacement dish for a slot.
final class SwapPickerSheet: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let slot: ServingSlot
    let candidates: [Entree]
    var onDishChosen: ((Entree) -> Void)?

    private let plateTable = UITableView(frame: .zero, style: .insetGrouped)
    private let reuseTag = "SwapMorsel"

    init(slot: ServingSlot, candidates: [Entree]) {
        self.slot = slot
        self.candidates = candidates
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Swap \(slot.course.displayLabel)"
        view.backgroundColor = SaffronPalette.crust
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closeTap)
        )

        plateTable.dataSource = self
        plateTable.delegate = self
        plateTable.register(UITableViewCell.self, forCellReuseIdentifier: reuseTag)
        plateTable.backgroundColor = .clear
        plateTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plateTable)

        NSLayoutConstraint.activate([
            plateTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            plateTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            plateTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            plateTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func closeTap() {
        dismiss(animated: true)
    }

    // ── Table Data Source ────────────────────

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        candidates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseTag, for: indexPath)
        let entree = candidates[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = entree.title
        config.textProperties.color = SaffronPalette.flour
        config.textProperties.font = TypographyRecipe.cardLabel()

        let tags = entree.courseTags.map { $0.displayLabel }.joined(separator: ", ")
        config.secondaryText = tags + (entree.isFavorite ? "  ⭐️" : "")
        config.secondaryTextProperties.color = SaffronPalette.steamGrey
        config.secondaryTextProperties.font = TypographyRecipe.croutonCaption()

        cell.contentConfiguration = config
        cell.backgroundColor = SaffronPalette.brioche
        cell.accessoryType = .disclosureIndicator

        let selectedBG = UIView()
        selectedBG.backgroundColor = SaffronPalette.honeyComb.withAlphaComponent(0.15)
        cell.selectedBackgroundView = selectedBG

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chosen = candidates[indexPath.row]
        onDishChosen?(chosen)
        dismiss(animated: true)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - ⚙️ Rules Forge Sheet (lightweight)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Bottom-sheet for editing generation rules.
final class RulesForgeSheet: UIViewController {

    private let vault = CellarVault.shared
    private let scrollBowl = UIScrollView()
    private let stackPlate = UIStackView()

    // Switches
    private let noConsecutiveSwitch = UISwitch()
    private let noSameDaySwitch = UISwitch()
    private let heavyDinnerSwitch = UISwitch()
    private let crossTagSwitch = UISwitch()

    // Stepper
    private let maxRepeatsStepper = UIStepper()
    private let maxRepeatsLabel = UILabel()

    // Slider
    private let favWeightSlider = UISlider()
    private let favWeightLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Generation Rules"
        view.backgroundColor = SaffronPalette.crust
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closeTap)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", style: .done, target: self, action: #selector(saveTap)
        )

        setupLayout()
        loadCurrentRules()
    }

    private func setupLayout() {
        scrollBowl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollBowl)

        stackPlate.axis = .vertical
        stackPlate.spacing = KitchenSpacing.banquet
        stackPlate.translatesAutoresizingMaskIntoConstraints = false
        scrollBowl.addSubview(stackPlate)

        NSLayoutConstraint.activate([
            scrollBowl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollBowl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollBowl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollBowl.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackPlate.topAnchor.constraint(equalTo: scrollBowl.topAnchor, constant: KitchenSpacing.platter),
            stackPlate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.plate),
            stackPlate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.plate),
            stackPlate.bottomAnchor.constraint(equalTo: scrollBowl.bottomAnchor, constant: -KitchenSpacing.banquet),
            stackPlate.widthAnchor.constraint(equalTo: scrollBowl.widthAnchor, constant: -KitchenSpacing.plate * 2),
        ])

        // Build sections
        setupRulesSection()
        setupLimitsSection()
        setupFavoritesSection()
    }

    private func setupRulesSection() {
        let container = buildSection(title: "Generation Rules")
        let titleLabel = container.subviews.first as! UILabel
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = KitchenSpacing.napkin
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(buildRuleRow(
            icon: "arrow.triangle.2.circlepath",
            title: "No consecutive repeats",
            toggle: noConsecutiveSwitch
        ))
        stack.addArrangedSubview(buildRuleRow(
            icon: "calendar.badge.exclamationmark",
            title: "No same dish same day",
            toggle: noSameDaySwitch
        ))
        stack.addArrangedSubview(buildRuleRow(
            icon: "moon.fill",
            title: "Avoid heavy dinners in a row",
            toggle: heavyDinnerSwitch
        ))
        stack.addArrangedSubview(buildRuleRow(
            icon: "tag.fill",
            title: "Allow cross-tag fallback",
            toggle: crossTagSwitch
        ))

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.plate),
        ])

        stackPlate.addArrangedSubview(container)
    }

    private func setupLimitsSection() {
        let container = buildSection(title: "Limits")
        let titleLabel = container.subviews.first as! UILabel
        
        let rowContainer = UIView()
        rowContainer.backgroundColor = SaffronPalette.meringue
        rowContainer.layer.cornerRadius = PlatingCorner.biscuit
        rowContainer.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "repeat"))
        icon.tintColor = SaffronPalette.honeyComb
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        maxRepeatsLabel.font = TypographyRecipe.servingBody()
        maxRepeatsLabel.textColor = SaffronPalette.flour
        maxRepeatsLabel.translatesAutoresizingMaskIntoConstraints = false

        maxRepeatsStepper.minimumValue = 1
        maxRepeatsStepper.maximumValue = 5
        maxRepeatsStepper.stepValue = 1
        maxRepeatsStepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        maxRepeatsStepper.translatesAutoresizingMaskIntoConstraints = false

        rowContainer.addSubview(icon)
        rowContainer.addSubview(maxRepeatsLabel)
        rowContainer.addSubview(maxRepeatsStepper)

        container.addSubview(rowContainer)
        
        NSLayoutConstraint.activate([
            rowContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            rowContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            rowContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),
            rowContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.plate),
            rowContainer.heightAnchor.constraint(equalToConstant: 56),

            icon.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor, constant: KitchenSpacing.plate),
            icon.centerYAnchor.constraint(equalTo: rowContainer.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),

            maxRepeatsLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: KitchenSpacing.napkin),
            maxRepeatsLabel.centerYAnchor.constraint(equalTo: rowContainer.centerYAnchor),
            maxRepeatsLabel.trailingAnchor.constraint(lessThanOrEqualTo: maxRepeatsStepper.leadingAnchor, constant: -KitchenSpacing.plate),

            maxRepeatsStepper.trailingAnchor.constraint(equalTo: rowContainer.trailingAnchor, constant: -KitchenSpacing.plate),
            maxRepeatsStepper.centerYAnchor.constraint(equalTo: rowContainer.centerYAnchor),
        ])

        stackPlate.addArrangedSubview(container)
    }

    private func setupFavoritesSection() {
        let container = buildSection(title: "Favorites")
        let titleLabel = container.subviews.first as! UILabel
        
        let rowContainer = UIView()
        rowContainer.backgroundColor = SaffronPalette.meringue
        rowContainer.layer.cornerRadius = PlatingCorner.biscuit
        rowContainer.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "star.fill"))
        icon.tintColor = SaffronPalette.honeyComb
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        favWeightLabel.font = TypographyRecipe.servingBody()
        favWeightLabel.textColor = SaffronPalette.flour
        favWeightLabel.translatesAutoresizingMaskIntoConstraints = false

        favWeightSlider.minimumValue = 0
        favWeightSlider.maximumValue = 100
        favWeightSlider.minimumTrackTintColor = SaffronPalette.honeyComb
        favWeightSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        favWeightSlider.translatesAutoresizingMaskIntoConstraints = false

        let sliderStack = UIStackView(arrangedSubviews: [favWeightLabel, favWeightSlider])
        sliderStack.axis = .vertical
        sliderStack.spacing = KitchenSpacing.garnish
        sliderStack.translatesAutoresizingMaskIntoConstraints = false

        rowContainer.addSubview(icon)
        rowContainer.addSubview(sliderStack)

        container.addSubview(rowContainer)
        
        NSLayoutConstraint.activate([
            rowContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            rowContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            rowContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),
            rowContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.plate),

            icon.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor, constant: KitchenSpacing.plate),
            icon.topAnchor.constraint(equalTo: rowContainer.topAnchor, constant: KitchenSpacing.plate),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),

            sliderStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: KitchenSpacing.napkin),
            sliderStack.trailingAnchor.constraint(equalTo: rowContainer.trailingAnchor, constant: -KitchenSpacing.plate),
            sliderStack.topAnchor.constraint(equalTo: rowContainer.topAnchor, constant: KitchenSpacing.plate),
            sliderStack.bottomAnchor.constraint(equalTo: rowContainer.bottomAnchor, constant: -KitchenSpacing.plate),
        ])

        stackPlate.addArrangedSubview(container)
    }

    private func buildSection(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = SaffronPalette.brioche
        container.layer.cornerRadius = PlatingCorner.biscuit
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = TypographyRecipe.sectionRoast()
        titleLabel.textColor = SaffronPalette.flour
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: KitchenSpacing.plate),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),
        ])

        return container
    }

    private func loadCurrentRules() {
        let rules = vault.config.rules
        noConsecutiveSwitch.isOn = rules.noConsecutiveSameInCourse
        noSameDaySwitch.isOn = rules.noSameDishSameDay
        heavyDinnerSwitch.isOn = rules.avoidHeavyDinnersInRow
        crossTagSwitch.isOn = rules.allowCrossTagFallback
        maxRepeatsStepper.value = Double(rules.maxRepeatsPerWeek)
        maxRepeatsLabel.text = "Max repeats/week: \(rules.maxRepeatsPerWeek)"
        favWeightSlider.value = Float(rules.favoritesWeightPercent)
        favWeightLabel.text = "Favorites boost: \(rules.favoritesWeightPercent)%"
    }

    @objc private func closeTap() { dismiss(animated: true) }

    @objc private func saveTap() {
        vault.stir { ledger in
            ledger.config.rules.noConsecutiveSameInCourse = self.noConsecutiveSwitch.isOn
            ledger.config.rules.noSameDishSameDay = self.noSameDaySwitch.isOn
            ledger.config.rules.avoidHeavyDinnersInRow = self.heavyDinnerSwitch.isOn
            ledger.config.rules.allowCrossTagFallback = self.crossTagSwitch.isOn
            ledger.config.rules.maxRepeatsPerWeek = Int(self.maxRepeatsStepper.value)
            ledger.config.rules.favoritesWeightPercent = Int(self.favWeightSlider.value)
            ledger.config.rules.refreshedAt = Date()
        }
        dismiss(animated: true)
    }

    // ── Row Builders ─────────────────────────

    private func buildRuleRow(icon: String, title: String, toggle: UISwitch) -> UIView {
        let row = UIView()
        row.backgroundColor = SaffronPalette.meringue
        row.layer.cornerRadius = PlatingCorner.biscuit
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = SaffronPalette.honeyComb
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = TypographyRecipe.servingBody()
        label.textColor = SaffronPalette.flour
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.setContentHuggingPriority(.required, for: .horizontal)

        row.addSubview(iconView)
        row.addSubview(label)
        row.addSubview(toggle)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: KitchenSpacing.plate),
            iconView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: KitchenSpacing.napkin),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -KitchenSpacing.plate),

            toggle.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -KitchenSpacing.plate),
            toggle.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])

        return row
    }

    @objc private func stepperChanged() {
        maxRepeatsLabel.text = "Max repeats/week: \(Int(maxRepeatsStepper.value))"
    }

    @objc private func sliderChanged() {
        favWeightLabel.text = "Favorites boost: \(Int(favWeightSlider.value))%"
    }
}
