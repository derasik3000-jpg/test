// ──────────────────────────────────────────────
// BanquetWeekViewController.swift
// с8 – "Menu of 12 Dishes"
//
// Tab 2 — "Week Plan": Shows 7 days with meal
// slots. Features: generate week, lock/unlock
// slots, swap dishes, regenerate unlocked,
// week navigation. Animated slot updates.
// ──────────────────────────────────────────────

import UIKit

final class BanquetWeekViewController: UIViewController {

    // ── Coordinator ──────────────────────────

    weak var coordinatorDelegate: KitchenNavigable?

    // ── Data ─────────────────────────────────

    private var currentWeek: FeastWeek?
    private var currentWeekStart: Date {
        didSet {
            loadWeek()
        }
    }

    // ── UI ───────────────────────────────────

    private let weekNavBar = WeekNavigationBar()
    private let modeSelector = UISegmentedControl(items: ["Random", "Smart Rules"])
    private let generateButton = SaffronPalette.brewPrimaryButton(titled: "Generate Week")
    private let regenerateButton = SaffronPalette.brewSecondaryButton(titled: "Regenerate Unlocked")
    private let generateSubtitleLabel = UILabel()
    private let regenerateSubtitleLabel = UILabel()

    private let scrollBowl = UIScrollView()
    private let daysStack = UIStackView()

    private var dayViews: [DayCardView] = []

    // ── Services ───────────────────────────────

    private let broth = MenuGenerationBroth()
    private let vault = CellarVault.shared

    // ── Observer ──────────────────────────────

    private var ledgerToken: NSObjectProtocol?

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Init
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    init() {
        self.currentWeekStart = Date().startOfFeastWeek()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Lifecycle
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Week Plan"
        view.backgroundColor = SaffronPalette.crust
        navigationItem.largeTitleDisplayMode = .always

        configureNavBar()
        setupLayout()
        loadWeek()
        observeLedger()
        observeSwapNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWeek()
    }

    deinit {
        if let tok = ledgerToken {
            NotificationCenter.default.removeObserver(tok)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Nav Bar
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func configureNavBar() {
        let helpImage = UIImage(systemName: "questionmark.circle")
        let helpBtn = UIBarButtonItem(image: helpImage, style: .plain,
                                      target: self, action: #selector(helpTapped))
        navigationItem.leftBarButtonItem = helpBtn
        
        let rulesBtn = UIBarButtonItem(
            title: "Rules",
            style: .plain,
            target: self,
            action: #selector(rulesTap)
        )
        navigationItem.rightBarButtonItem = rulesBtn
    }

    @objc private func helpTapped() {
        showHelpModal()
    }

    @objc private func rulesTap() {
        coordinatorDelegate?.requestOpenRulesEditor()
    }

    private func showHelpModal() {
        let helpVC = WeekPlanHelpViewController()
        let nav = UINavigationController(rootViewController: helpVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Layout
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func setupLayout() {
        // Week navigation
        weekNavBar.onPrevious = { [weak self] in
            self?.moveWeek(by: -1)
        }
        weekNavBar.onNext = { [weak self] in
            self?.moveWeek(by: 1)
        }
        weekNavBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(weekNavBar)

        // Mode selector
        modeSelector.selectedSegmentIndex = vault.config.defaultBlendMode.rawValue
        modeSelector.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        modeSelector.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modeSelector)

        // Generate button
        generateButton.addTarget(self, action: #selector(generateTap), for: .touchUpInside)
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(generateButton)

        // Regenerate button
        regenerateButton.addTarget(self, action: #selector(regenerateTap), for: .touchUpInside)
        regenerateButton.translatesAutoresizingMaskIntoConstraints = false
        regenerateButton.isHidden = true
        view.addSubview(regenerateButton)
        
        // Subtitle labels
        generateSubtitleLabel.text = "Creates a new meal plan for the week"
        generateSubtitleLabel.font = TypographyRecipe.croutonCaption()
        generateSubtitleLabel.textColor = SaffronPalette.steamGrey
        generateSubtitleLabel.textAlignment = .center
        generateSubtitleLabel.numberOfLines = 0
        generateSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(generateSubtitleLabel)
        
        regenerateSubtitleLabel.text = "Regenerates only unlocked slots, keeps locked ones"
        regenerateSubtitleLabel.font = TypographyRecipe.croutonCaption()
        regenerateSubtitleLabel.textColor = SaffronPalette.steamGrey
        regenerateSubtitleLabel.textAlignment = .center
        regenerateSubtitleLabel.numberOfLines = 0
        regenerateSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        regenerateSubtitleLabel.isHidden = true
        view.addSubview(regenerateSubtitleLabel)

        // Scroll container
        scrollBowl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollBowl)

        daysStack.axis = .vertical
        daysStack.spacing = KitchenSpacing.plate
        daysStack.translatesAutoresizingMaskIntoConstraints = false
        scrollBowl.addSubview(daysStack)

        NSLayoutConstraint.activate([
            weekNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weekNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            modeSelector.topAnchor.constraint(equalTo: weekNavBar.bottomAnchor, constant: KitchenSpacing.plate),
            modeSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.plate),
            modeSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.plate),

            generateButton.topAnchor.constraint(equalTo: modeSelector.bottomAnchor, constant: KitchenSpacing.plate),
            generateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.platter),
            generateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.platter),

            generateSubtitleLabel.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: KitchenSpacing.crumb),
            generateSubtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.platter),
            generateSubtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.platter),

            regenerateButton.topAnchor.constraint(equalTo: generateSubtitleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            regenerateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.platter),
            regenerateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.platter),

            regenerateSubtitleLabel.topAnchor.constraint(equalTo: regenerateButton.bottomAnchor, constant: KitchenSpacing.crumb),
            regenerateSubtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.platter),
            regenerateSubtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.platter),

            scrollBowl.topAnchor.constraint(equalTo: regenerateSubtitleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            scrollBowl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollBowl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollBowl.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            daysStack.topAnchor.constraint(equalTo: scrollBowl.topAnchor, constant: KitchenSpacing.plate),
            daysStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.plate),
            daysStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.plate),
            daysStack.bottomAnchor.constraint(equalTo: scrollBowl.bottomAnchor, constant: -KitchenSpacing.banquet),
            daysStack.widthAnchor.constraint(equalTo: scrollBowl.widthAnchor, constant: -KitchenSpacing.plate * 2),
        ])
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Data Loading
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func loadWeek() {
        currentWeek = vault.currentFeastWeek()
        if currentWeek == nil || !Calendar.current.isDate(currentWeek!.weekStartDate, inSameDayAs: currentWeekStart) {
            currentWeek = vault.feastWeekHistory.first { week in
                Calendar.current.isDate(week.weekStartDate, inSameDayAs: currentWeekStart)
            }
        }

        updateWeekNavBar()
        rebuildDayViews()
        updateButtons()
    }

    private func updateWeekNavBar() {
        weekNavBar.configure(weekStart: currentWeekStart)
    }

    private func rebuildDayViews() {
        dayViews.forEach { $0.removeFromSuperview() }
        dayViews.removeAll()
        
        // Clear all arranged subviews from stack
        daysStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let week = currentWeek else {
            // Empty state
            let emptyLabel = UILabel()
            emptyLabel.text = "Generate your first week plan!"
            emptyLabel.font = TypographyRecipe.sectionRoast()
            emptyLabel.textColor = SaffronPalette.steamGrey
            emptyLabel.textAlignment = .center
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            daysStack.addArrangedSubview(emptyLabel)
            return
        }

        let days = week.calendarDays
        let entrees = vault.entrees

        for day in days {
            let slots = week.slotsForDay(day)
            let dayView = DayCardView(day: day, slots: slots, entrees: entrees)
            dayView.onSlotTap = { [weak self] slot in
                self?.handleSlotTap(slot)
            }
            dayView.onLockToggle = { [weak self] slot in
                self?.toggleLock(slot)
            }
            dayView.onSwapTap = { [weak self] slot in
                self?.requestSwap(slot)
            }
            daysStack.addArrangedSubview(dayView)
            dayViews.append(dayView)
        }
    }

    private func updateButtons() {
        let hasWeek = currentWeek != nil
        regenerateButton.isHidden = !hasWeek
        regenerateSubtitleLabel.isHidden = !hasWeek
        generateButton.setTitle(hasWeek ? "Regenerate Week" : "Generate Week", for: .normal)
        generateSubtitleLabel.text = hasWeek 
            ? "Replaces all slots with a new random plan"
            : "Creates a new meal plan for the week"
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Actions
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @objc private func modeChanged() {
        let mode = BlendMode(rawValue: modeSelector.selectedSegmentIndex) ?? .randomShuffle
        vault.stir { $0.config.defaultBlendMode = mode }
    }

    @objc private func generateTap() {
        guard vault.readyEntreeCount >= 12 else {
            showAlert(title: "Not Ready", message: "Please fill all 12 dishes first.")
            return
        }

        let mode = BlendMode(rawValue: modeSelector.selectedSegmentIndex) ?? .randomShuffle
        let result = broth.cookWeek(
            weekStart: currentWeekStart,
            mode: mode,
            newSeed: true,
            existingWeek: currentWeek
        )

        vault.saveFeastWeek(result.feastWeek)
        currentWeek = result.feastWeek

        // Build shopping list
        let aggregator = BasketAggregator()
        let roll = aggregator.harvestBasket(for: result.feastWeek)
        vault.saveGroceryRoll(roll)

        // Record events
        vault.recordSauteEvents(from: result.feastWeek)

        // Animate update
        animateWeekUpdate()
        updateButtons()

        // Haptic feedback
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
    }

    @objc private func regenerateTap() {
        guard var week = currentWeek else { return }

        let result = broth.reheatUnlocked(existing: week)
        week = result.feastWeek

        vault.saveFeastWeek(week)
        currentWeek = week

        // Rebuild shopping list
        let aggregator = BasketAggregator()
        let roll = aggregator.harvestBasket(for: week)
        vault.saveGroceryRoll(roll)

        animateWeekUpdate()
    }

    private func moveWeek(by offset: Int) {
        guard let newDate = Calendar.current.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart) else { return }
        currentWeekStart = newDate.startOfFeastWeek()
    }

    private func handleSlotTap(_ slot: ServingSlot) {
        guard let entreeID = slot.entreeID,
              let entree = vault.entrees.first(where: { $0.id == entreeID }) else { return }
        coordinatorDelegate?.requestOpenEntreeDetail(entree)
    }

    private func toggleLock(_ slot: ServingSlot) {
        guard var week = currentWeek else { return }

        if let idx = week.slots.firstIndex(where: { $0.id == slot.id }) {
            week.slots[idx].isLocked.toggle()
            week.slots[idx].refreshedAt = Date()
            week.refreshedAt = Date()
            vault.saveFeastWeek(week)
            currentWeek = week
            rebuildDayViews()

            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
        }
    }

    private func requestSwap(_ slot: ServingSlot) {
        guard let week = currentWeek else { return }
        coordinatorDelegate?.requestSwapSlot(slot, inWeek: week)
    }

    private func observeSwapNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSwapNotification(_:)),
            name: NSNotification.Name("SwapSlotChosen"),
            object: nil
        )
    }

    @objc private func handleSwapNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let slotID = userInfo["slotID"] as? UUID,
              let entreeID = userInfo["entreeID"] as? UUID,
              var week = currentWeek else { return }

        if let idx = week.slots.firstIndex(where: { $0.id == slotID }) {
            week.slots[idx].entreeID = entreeID
            week.slots[idx].refreshedAt = Date()
            week.refreshedAt = Date()
            vault.saveFeastWeek(week)
            currentWeek = week

            // Rebuild shopping list
            let aggregator = BasketAggregator()
            let roll = aggregator.harvestBasket(for: week)
            vault.saveGroceryRoll(roll)

            animateWeekUpdate()
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Animation
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func animateWeekUpdate() {
        guard !FrostBox.shouldReduceMotion else {
            rebuildDayViews()
            return
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.daysStack.alpha = 0.5
        }) { _ in
            self.rebuildDayViews()
            UIView.animate(withDuration: 0.3) {
                self.daysStack.alpha = 1.0
            }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Observer
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func observeLedger() {
        ledgerToken = NotificationCenter.default.addObserver(
            forName: CellarVault.ledgerDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadWeek()
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Week Navigation Bar
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class WeekNavigationBar: UIView {

    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?

    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let weekLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBar()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupBar() {
        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevButton.tintColor = SaffronPalette.honeyComb
        prevButton.addTarget(self, action: #selector(prevTap), for: .touchUpInside)
        prevButton.translatesAutoresizingMaskIntoConstraints = false

        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.tintColor = SaffronPalette.honeyComb
        nextButton.addTarget(self, action: #selector(nextTap), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        weekLabel.font = TypographyRecipe.sectionRoast()
        weekLabel.textColor = SaffronPalette.flour
        weekLabel.textAlignment = .center
        weekLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(prevButton)
        addSubview(nextButton)
        addSubview(weekLabel)

        NSLayoutConstraint.activate([
            prevButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            prevButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            prevButton.widthAnchor.constraint(equalToConstant: 44),
            prevButton.heightAnchor.constraint(equalToConstant: 44),

            weekLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            weekLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KitchenSpacing.plate),
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 44),
            nextButton.heightAnchor.constraint(equalToConstant: 44),

            heightAnchor.constraint(equalToConstant: 56),
        ])
    }

    func configure(weekStart: Date) {
        weekLabel.text = weekStart.weekRangeLabel()
    }

    @objc private func prevTap() {
        onPrevious?()
    }

    @objc private func nextTap() {
        onNext?()
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Day Card View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class DayCardView: UIView {

    var onSlotTap: ((ServingSlot) -> Void)?
    var onLockToggle: ((ServingSlot) -> Void)?
    var onSwapTap: ((ServingSlot) -> Void)?

    private let dayLabel = UILabel()
    private let slotsStack = UIStackView()
    private var slotViews: [SlotRowView] = []

    init(day: Date, slots: [ServingSlot], entrees: [Entree]) {
        super.init(frame: .zero)
        setupCard(day: day, slots: slots, entrees: entrees)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupCard(day: Date, slots: [ServingSlot], entrees: [Entree]) {
        backgroundColor = SaffronPalette.brioche
        layer.cornerRadius = PlatingCorner.biscuit
        applySeasoning(ShadowSeasoning.softGlow)

        let df = DateFormatter()
        df.dateFormat = "EEEE, MMM d"
        dayLabel.text = df.string(from: day)
        dayLabel.font = TypographyRecipe.cardLabel()
        dayLabel.textColor = SaffronPalette.flour
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dayLabel)

        slotsStack.axis = .vertical
        slotsStack.spacing = KitchenSpacing.garnish
        slotsStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slotsStack)

        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: topAnchor, constant: KitchenSpacing.plate),
            dayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            dayLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KitchenSpacing.plate),

            slotsStack.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: KitchenSpacing.garnish),
            slotsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            slotsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KitchenSpacing.plate),
            slotsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -KitchenSpacing.plate),
        ])

        for slot in slots {
            let entree = slot.entreeID.flatMap { id in entrees.first(where: { $0.id == id }) }
            let row = SlotRowView(slot: slot, entree: entree)
            row.onTap = { [weak self] in
                self?.onSlotTap?(slot)
            }
            row.onLockTap = { [weak self] in
                self?.onLockToggle?(slot)
            }
            row.onSwapTap = { [weak self] in
                self?.onSwapTap?(slot)
            }
            slotsStack.addArrangedSubview(row)
            slotViews.append(row)
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Slot Row View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class SlotRowView: UIView {

    var onTap: (() -> Void)?
    var onLockTap: (() -> Void)?
    var onSwapTap: (() -> Void)?

    private let courseLabel = UILabel()
    private let dishLabel = UILabel()
    private let lockButton = UIButton(type: .system)
    private let swapButton = UIButton(type: .system)

    init(slot: ServingSlot, entree: Entree?) {
        super.init(frame: .zero)
        setupRow(slot: slot, entree: entree)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupRow(slot: ServingSlot, entree: Entree?) {
        let isEmpty = entree == nil
        
        // Style for empty slots
        if isEmpty {
            backgroundColor = SaffronPalette.meringue.withAlphaComponent(0.5)
            layer.borderWidth = 1
            layer.borderColor = SaffronPalette.steamGrey.withAlphaComponent(0.3).cgColor
            layer.cornerRadius = PlatingCorner.biscuit
        }
        
        courseLabel.text = slot.course.displayLabel
        courseLabel.font = TypographyRecipe.sprinkleTag()
        courseLabel.textColor = slot.course.tintColor
        courseLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(courseLabel)

        if let entree = entree {
            dishLabel.text = entree.title
            dishLabel.font = TypographyRecipe.servingBody()
            dishLabel.textColor = SaffronPalette.flour
        } else {
            dishLabel.text = "Empty - Generate week to fill"
            dishLabel.font = TypographyRecipe.croutonCaption()
            dishLabel.textColor = SaffronPalette.steamGrey
        }
        dishLabel.translatesAutoresizingMaskIntoConstraints = false
        dishLabel.numberOfLines = 1
        dishLabel.lineBreakMode = .byTruncatingTail
        dishLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        dishLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        addSubview(dishLabel)

        lockButton.setImage(UIImage(systemName: slot.isLocked ? "lock.fill" : "lock.open"), for: .normal)
        lockButton.tintColor = slot.isLocked ? SaffronPalette.frozenBerry : SaffronPalette.steamGrey
        lockButton.addTarget(self, action: #selector(lockTap), for: .touchUpInside)
        lockButton.translatesAutoresizingMaskIntoConstraints = false
        lockButton.isHidden = isEmpty
        lockButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        lockButton.setContentHuggingPriority(.required, for: .horizontal)

        swapButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        swapButton.tintColor = SaffronPalette.honeyComb
        swapButton.addTarget(self, action: #selector(swapTap), for: .touchUpInside)
        swapButton.translatesAutoresizingMaskIntoConstraints = false
        swapButton.isHidden = isEmpty
        swapButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        swapButton.setContentHuggingPriority(.required, for: .horizontal)

        let buttonStack = UIStackView(arrangedSubviews: [lockButton, swapButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = KitchenSpacing.garnish
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        buttonStack.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(buttonStack)

        // Add padding for empty slots to prevent text overlapping border
        let leftPadding: CGFloat = isEmpty ? KitchenSpacing.garnish : 0
        
        NSLayoutConstraint.activate([
            courseLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftPadding),
            courseLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            courseLabel.widthAnchor.constraint(equalToConstant: 80),

            dishLabel.leadingAnchor.constraint(equalTo: courseLabel.trailingAnchor, constant: KitchenSpacing.garnish),
            dishLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dishLabel.trailingAnchor.constraint(lessThanOrEqualTo: buttonStack.leadingAnchor, constant: -KitchenSpacing.plate),

            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: isEmpty ? -KitchenSpacing.garnish : 0),
            buttonStack.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightAnchor.constraint(equalToConstant: 44),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(rowTap))
        addGestureRecognizer(tap)
    }

    @objc private func rowTap() {
        onTap?()
    }

    @objc private func lockTap() {
        onLockTap?()
    }

    @objc private func swapTap() {
        onSwapTap?()
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Week Plan Help Modal
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class WeekPlanHelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "How to Use Week Plan"
        view.backgroundColor = SaffronPalette.crust
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )

        setupHelpContent()
    }

    @objc private func doneTapped() {
        dismiss(animated: true)
    }

    private func setupHelpContent() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = KitchenSpacing.tray
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        let helpItems = [
            ("📅", "Week Navigation", "Use arrows to switch between weeks. The current week is shown at the top."),
            ("🎲", "Generate Week", "Tap 'Generate Week' to create a meal plan. Make sure you have at least 12 dishes ready in 'My 12' first."),
            ("🔄", "Regenerate Unlocked", "After generating, tap this to regenerate only unlocked slots. Locked slots stay the same."),
            ("🔒", "Lock Slots", "Tap the lock icon on any meal slot to lock it. Locked slots won't change when regenerating."),
            ("🔄", "Swap Dish", "Tap the swap icon to replace a dish with another one from your collection."),
            ("📋", "Empty Slots", "Empty slots appear when you haven't generated a week yet. Generate a week to fill them."),
            ("⚙️", "Mode Selector", "Choose 'Random' for random selection or 'Smart Rules' to use your generation rules.")
        ]

        for (icon, title, description) in helpItems {
            let itemView = createHelpItem(icon: icon, title: title, description: description)
            contentStack.addArrangedSubview(itemView)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: KitchenSpacing.platter),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.plate),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.plate),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -KitchenSpacing.banquet),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -KitchenSpacing.plate * 2),
        ])
    }

    private func createHelpItem(icon: String, title: String, description: String) -> UIView {
        let container = UIView()
        container.backgroundColor = SaffronPalette.brioche
        container.layer.cornerRadius = PlatingCorner.biscuit
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 32)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = TypographyRecipe.sectionRoast()
        titleLabel.textColor = SaffronPalette.flour
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = TypographyRecipe.servingBody()
        descLabel.textColor = SaffronPalette.steamGrey
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconLabel)
        container.addSubview(titleLabel)
        container.addSubview(descLabel)

        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            iconLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: KitchenSpacing.plate),
            iconLabel.widthAnchor.constraint(equalToConstant: 40),
            iconLabel.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: KitchenSpacing.plate),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: KitchenSpacing.plate),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),

            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.garnish),
            descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),
            descLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.plate),
        ])

        return container
    }
}
