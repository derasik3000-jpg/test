

import UIKit

final class MarketBasketViewController: UIViewController {

    // ── Coordinator ──────────────────────────

    weak var coordinatorDelegate: KitchenNavigable?

    // ── Data ─────────────────────────────────

    private var currentRoll: GroceryRoll?
    private var groupedItems: [AisleGroup] = []
    private var showOnlyUnchecked = false

    // ── UI ───────────────────────────────────

    private let weekNavBar = WeekNavigationBar()
    private let filterToggle = UISwitch()
    private let filterLabel = UILabel()
    private let filterSubtitle = UILabel()
    private let storeModeButton = SaffronPalette.brewSecondaryButton(titled: "Store Mode")
    private let storeModeSubtitle = UILabel()

    private let scrollBowl = UIScrollView()
    private let itemsStack = UIStackView()

    private let emptyStateLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "No shopping list yet\n\nGo to 'Week Plan' and generate a week to automatically create your shopping list from the meal ingredients."
        lbl.font = TypographyRecipe.servingBody()
        lbl.textColor = SaffronPalette.steamGrey
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // ── Services ───────────────────────────────

    private let vault = CellarVault.shared
    private var currentWeekStart: Date = Date().startOfFeastWeek()

    // ── Observer ──────────────────────────────

    private var ledgerToken: NSObjectProtocol?

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Lifecycle
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shopping"
        view.backgroundColor = SaffronPalette.crust
        navigationItem.largeTitleDisplayMode = .always

        configureNavBar()
        setupLayout()
        loadShoppingList()
        observeLedger()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Nav Bar
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func configureNavBar() {
        let helpImage = UIImage(systemName: "questionmark.circle")
        let helpBtn = UIBarButtonItem(image: helpImage, style: .plain,
                                      target: self, action: #selector(helpTapped))
        navigationItem.leftBarButtonItem = helpBtn
    }

    @objc private func helpTapped() {
        showHelpModal()
    }

    private func showHelpModal() {
        let helpVC = ShoppingHelpViewController()
        let nav = UINavigationController(rootViewController: helpVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadShoppingList()
    }

    deinit {
        if let tok = ledgerToken {
            NotificationCenter.default.removeObserver(tok)
        }
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

        // Filter toggle
        filterLabel.text = "Show only unchecked"
        filterLabel.font = TypographyRecipe.servingBody()
        filterLabel.textColor = SaffronPalette.flour
        filterLabel.translatesAutoresizingMaskIntoConstraints = false

        filterToggle.addTarget(self, action: #selector(filterToggled), for: .valueChanged)
        filterToggle.translatesAutoresizingMaskIntoConstraints = false

        let filterRow = UIStackView(arrangedSubviews: [filterLabel, filterToggle])
        filterRow.axis = .horizontal
        filterRow.spacing = KitchenSpacing.garnish
        filterRow.alignment = .center
        filterRow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterRow)
        
        // Filter subtitle
        filterSubtitle.text = "Hide items you've checked or marked as owned"
        filterSubtitle.font = TypographyRecipe.croutonCaption()
        filterSubtitle.textColor = SaffronPalette.steamGrey
        filterSubtitle.numberOfLines = 0
        filterSubtitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterSubtitle)

        // Store mode button
        storeModeButton.addTarget(self, action: #selector(storeModeTap), for: .touchUpInside)
        storeModeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(storeModeButton)
        
        // Subtitle for store mode button
        storeModeSubtitle.text = "Full-screen optimized view for shopping"
        storeModeSubtitle.font = TypographyRecipe.croutonCaption()
        storeModeSubtitle.textColor = SaffronPalette.steamGrey
        storeModeSubtitle.textAlignment = .center
        storeModeSubtitle.numberOfLines = 0
        storeModeSubtitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(storeModeSubtitle)

        // Scroll container
        scrollBowl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollBowl)

        itemsStack.axis = .vertical
        itemsStack.spacing = KitchenSpacing.tray
        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        scrollBowl.addSubview(itemsStack)

        NSLayoutConstraint.activate([
            weekNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weekNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            filterRow.topAnchor.constraint(equalTo: weekNavBar.bottomAnchor, constant: KitchenSpacing.plate),
            filterRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.plate),
            filterRow.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -KitchenSpacing.plate),

            filterSubtitle.topAnchor.constraint(equalTo: filterRow.bottomAnchor, constant: KitchenSpacing.crumb),
            filterSubtitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.plate),
            filterSubtitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.plate),

            storeModeButton.topAnchor.constraint(equalTo: filterSubtitle.bottomAnchor, constant: KitchenSpacing.plate),
            storeModeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.platter),
            storeModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.platter),

            storeModeSubtitle.topAnchor.constraint(equalTo: storeModeButton.bottomAnchor, constant: KitchenSpacing.crumb),
            storeModeSubtitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.platter),
            storeModeSubtitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.platter),

            scrollBowl.topAnchor.constraint(equalTo: storeModeSubtitle.bottomAnchor, constant: KitchenSpacing.plate),
            scrollBowl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollBowl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollBowl.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            itemsStack.topAnchor.constraint(equalTo: scrollBowl.topAnchor, constant: KitchenSpacing.plate),
            itemsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.plate),
            itemsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.plate),
            itemsStack.bottomAnchor.constraint(equalTo: scrollBowl.bottomAnchor, constant: -KitchenSpacing.banquet),
            itemsStack.widthAnchor.constraint(equalTo: scrollBowl.widthAnchor, constant: -KitchenSpacing.plate * 2),
        ])
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Data Loading
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func loadShoppingList() {
        // Preserve filter toggle state
        let savedFilterState = showOnlyUnchecked
        
        guard let week = vault.currentFeastWeek(),
              Calendar.current.isDate(week.weekStartDate, inSameDayAs: currentWeekStart) else {
            // Try to find week for currentWeekStart
            if let foundWeek = vault.feastWeekHistory.first(where: { week in
                Calendar.current.isDate(week.weekStartDate, inSameDayAs: currentWeekStart)
            }) {
                currentRoll = vault.groceryRoll(forWeek: foundWeek.id)
                if currentRoll == nil {
                    // Auto-generate shopping list if it doesn't exist
                    let aggregator = BasketAggregator()
                    let roll = aggregator.harvestBasket(for: foundWeek)
                    vault.saveGroceryRoll(roll)
                    currentRoll = roll
                }
            } else {
                currentRoll = nil
            }
            // Restore filter toggle state
            showOnlyUnchecked = savedFilterState
            filterToggle.isOn = savedFilterState
            rebuildItems()
            return
        }

        currentRoll = vault.groceryRoll(forWeek: week.id)
        if currentRoll == nil {
            // Auto-generate shopping list if it doesn't exist
            let aggregator = BasketAggregator()
            let roll = aggregator.harvestBasket(for: week)
            vault.saveGroceryRoll(roll)
            currentRoll = roll
        }

        updateWeekNavBar()
        // Restore filter toggle state
        showOnlyUnchecked = savedFilterState
        filterToggle.isOn = savedFilterState
        rebuildItems()
    }

    private func updateWeekNavBar() {
        weekNavBar.configure(weekStart: currentWeekStart)
    }

    private func rebuildItems() {
        itemsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let roll = currentRoll, !roll.items.isEmpty else {
            itemsStack.addArrangedSubview(emptyStateLabel)
            return
        }

        // Filter out empty items (ingredients with no name)
        let validItems = roll.items.filter { !$0.displayName.trimmingCharacters(in: .whitespaces).isEmpty }

        // Group by aisle
        let aisles = vault.aisles
        var groups: [AisleGroup] = []

        for aisle in aisles {
            let items = validItems.filter { $0.aisleID == aisle.id }
            if !items.isEmpty {
                groups.append(AisleGroup(aisle: aisle, items: items))
            }
        }

        // Other category
        let otherItems = validItems.filter { $0.aisleID == nil }
        if !otherItems.isEmpty {
            let otherAisle = AisleCategory(
                id: UUID(),
                title: "Other",
                sortRank: 999,
                isHidden: false,
                bakedAt: Date(),
                refreshedAt: Date()
            )
            groups.append(AisleGroup(aisle: otherAisle, items: otherItems))
        }

        groupedItems = groups

        // Build UI
        for group in groups {
            let sectionView = AisleSectionView(group: group, showOnlyUnchecked: showOnlyUnchecked)
            sectionView.onItemToggled = { [weak self] ticket in
                // Always get the latest ticket from currentRoll to ensure we have the most up-to-date state
                guard let self = self,
                      let currentRoll = self.currentRoll,
                      let currentTicket = currentRoll.items.first(where: { $0.id == ticket.id }) else {
                    return
                }
                // Use the ticket from currentRoll, not from the closure parameter
                self.toggleItem(currentTicket)
            }
            sectionView.onOwnedToggled = { [weak self] ticket in
                // Always get the latest ticket from currentRoll to ensure we have the most up-to-date state
                guard let self = self,
                      let currentRoll = self.currentRoll,
                      let currentTicket = currentRoll.items.first(where: { $0.id == ticket.id }) else {
                    return
                }
                // Use the ticket from currentRoll, not from the closure parameter
                self.toggleOwned(currentTicket)
            }
            itemsStack.addArrangedSubview(sectionView)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Actions
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func moveWeek(by offset: Int) {
        guard let newDate = Calendar.current.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart) else { return }
        currentWeekStart = newDate.startOfFeastWeek()
        loadShoppingList()
    }

    @objc private func filterToggled() {
        // Update state from toggle
        showOnlyUnchecked = filterToggle.isOn
        rebuildItems()
    }

    @objc private func storeModeTap() {
        guard let roll = currentRoll else {
            let alert = UIAlertController(
                title: "No Shopping List",
                message: "Generate a week plan first to create a shopping list.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        coordinatorDelegate?.requestStoreMode(roll: roll)
    }

    private func toggleItem(_ ticket: GroceryTicket) {
        guard var roll = currentRoll else { return }

        guard let idx = roll.items.firstIndex(where: { $0.id == ticket.id }) else {
            return
        }
        
        // If item is empty (no name), remove it instead of toggling
        let isEmpty = roll.items[idx].displayName.trimmingCharacters(in: .whitespaces).isEmpty
        if isEmpty {
            roll.items.remove(at: idx)
        } else {
            // Toggle the checked state - use the current state from roll, not from ticket parameter
            let currentCheckedState = roll.items[idx].isChecked
            roll.items[idx].isChecked = !currentCheckedState
            roll.items[idx].refreshedAt = Date()
        }
        roll.refreshedAt = Date()
        vault.saveGroceryRoll(roll)
        
        // Update currentRoll BEFORE rebuildItems to ensure we use the latest data
        currentRoll = roll

        // Rebuild UI with updated data - this will create new views with fresh data
        rebuildItems()

        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }

    private func toggleOwned(_ ticket: GroceryTicket) {
        guard var roll = currentRoll else { return }

        guard let idx = roll.items.firstIndex(where: { $0.id == ticket.id }) else {
            return
        }
        
        let currentTicket = roll.items[idx]
        roll.items[idx].isOwned.toggle()
        roll.items[idx].refreshedAt = Date()
        roll.refreshedAt = Date()
        vault.saveGroceryRoll(roll)
        currentRoll = roll

        // Also update pantry
        if roll.items[idx].isOwned {
            vault.markAsOwned(
                normalizedName: currentTicket.normalizedName,
                displayName: currentTicket.displayName,
                aisleID: currentTicket.aisleID
            )
        } else {
            vault.removeFromPantry(normalizedName: currentTicket.normalizedName)
        }

        // Rebuild UI with updated data
        rebuildItems()
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
            // When dishes are updated, regenerate shopping list if week plan exists
            self?.updateShoppingListIfNeeded()
        }
    }
    
    private func updateShoppingListIfNeeded() {
        // Preserve filter toggle state
        let savedFilterState = showOnlyUnchecked
        
        guard let week = vault.currentFeastWeek(),
              Calendar.current.isDate(week.weekStartDate, inSameDayAs: currentWeekStart) else {
            // Try to find week for currentWeekStart
            if let foundWeek = vault.feastWeekHistory.first(where: { week in
                Calendar.current.isDate(week.weekStartDate, inSameDayAs: currentWeekStart)
            }) {
                // Regenerate shopping list when dishes are updated
                let aggregator = BasketAggregator()
                let roll = aggregator.harvestBasket(for: foundWeek)
                vault.saveGroceryRoll(roll)
                currentRoll = roll
                // Restore filter toggle state
                showOnlyUnchecked = savedFilterState
                filterToggle.isOn = savedFilterState
                rebuildItems()
            }
            return
        }
        
        // Regenerate shopping list when dishes are updated
        let aggregator = BasketAggregator()
        let roll = aggregator.harvestBasket(for: week)
        vault.saveGroceryRoll(roll)
        currentRoll = roll
        // Restore filter toggle state
        showOnlyUnchecked = savedFilterState
        filterToggle.isOn = savedFilterState
        rebuildItems()
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Aisle Group
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct AisleGroup {
    let aisle: AisleCategory
    let items: [GroceryTicket]
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Aisle Section View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class AisleSectionView: UIView {

    var onItemToggled: ((GroceryTicket) -> Void)?
    var onOwnedToggled: ((GroceryTicket) -> Void)?

    private var group: AisleGroup
    private let showOnlyUnchecked: Bool

    init(group: AisleGroup, showOnlyUnchecked: Bool) {
        self.group = group
        self.showOnlyUnchecked = showOnlyUnchecked
        super.init(frame: .zero)
        setupSection()
    }
    
    func updateGroup(_ newGroup: AisleGroup) {
        self.group = newGroup
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupSection() {
        backgroundColor = SaffronPalette.brioche
        layer.cornerRadius = PlatingCorner.biscuit
        applySeasoning(ShadowSeasoning.softGlow)

        let titleLabel = UILabel()
        titleLabel.text = group.aisle.title
        titleLabel.font = TypographyRecipe.sectionRoast()
        titleLabel.textColor = SaffronPalette.flour
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        let itemsStack = UIStackView()
        itemsStack.axis = .vertical
        itemsStack.spacing = KitchenSpacing.garnish
        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(itemsStack)

        // Filter out empty items and apply unchecked filter if needed
        let validItems = group.items.filter { !$0.displayName.trimmingCharacters(in: .whitespaces).isEmpty }
        
        let displayItems = showOnlyUnchecked
            ? validItems.filter { !$0.isChecked && !$0.isOwned }
            : validItems

        for ticket in displayItems {
            let ticketID = ticket.id // Capture ID to avoid closure issues
            let row = GroceryItemRow(ticket: ticket)
            row.onToggled = { [weak self] in
                // Pass the ticket ID, the callback will find the current ticket from roll
                self?.onItemToggled?(ticket)
            }
            row.onOwnedToggled = { [weak self] in
                // Pass the ticket ID, the callback will find the current ticket from roll
                self?.onOwnedToggled?(ticket)
            }
            itemsStack.addArrangedSubview(row)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: KitchenSpacing.plate),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KitchenSpacing.plate),

            itemsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.garnish),
            itemsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            itemsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KitchenSpacing.plate),
            itemsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -KitchenSpacing.plate),
        ])
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Grocery Item Row
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class GroceryItemRow: UIView {

    var onToggled: (() -> Void)?
    var onOwnedToggled: (() -> Void)?

    private let ticket: GroceryTicket
    private let checkBox = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let amountLabel = UILabel()
    private let ownedButton = UIButton(type: .system)

    init(ticket: GroceryTicket) {
        self.ticket = ticket
        super.init(frame: .zero)
        setupRow()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupRow() {
        checkBox.setImage(
            UIImage(systemName: ticket.isChecked ? "checkmark.circle.fill" : "circle"),
            for: .normal
        )
        checkBox.tintColor = ticket.isChecked ? SaffronPalette.mintGarnish : SaffronPalette.steamGrey
        checkBox.addTarget(self, action: #selector(checkTapped), for: .touchUpInside)
        checkBox.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.text = ticket.displayName
        nameLabel.font = TypographyRecipe.servingBody()
        nameLabel.textColor = ticket.isChecked || ticket.isOwned
            ? SaffronPalette.ashDust
            : SaffronPalette.flour
        nameLabel.numberOfLines = 1
        
        // Always set attributed text to ensure strikethrough works correctly
        let attr = NSMutableAttributedString(string: ticket.displayName)
        if ticket.isChecked || ticket.isOwned {
            attr.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attr.length))
        }
        nameLabel.attributedText = attr
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        amountLabel.text = "\(ticket.amount) \(ticket.unit.shortLabel)"
        amountLabel.font = TypographyRecipe.croutonCaption()
        amountLabel.textColor = SaffronPalette.steamGrey
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        ownedButton.setImage(
            UIImage(systemName: ticket.isOwned ? "house.fill" : "house"),
            for: .normal
        )
        ownedButton.tintColor = ticket.isOwned ? SaffronPalette.mintGarnish : SaffronPalette.steamGrey
        ownedButton.addTarget(self, action: #selector(ownedTapped), for: .touchUpInside)
        ownedButton.accessibilityLabel = "Mark as have at home"
        ownedButton.accessibilityHint = "Tap to mark this item as already owned at home"
        ownedButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(checkBox)
        addSubview(nameLabel)
        addSubview(amountLabel)
        addSubview(ownedButton)

        NSLayoutConstraint.activate([
            checkBox.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkBox.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkBox.widthAnchor.constraint(equalToConstant: 32),
            checkBox.heightAnchor.constraint(equalToConstant: 32),

            nameLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: KitchenSpacing.garnish),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -KitchenSpacing.garnish),

            amountLabel.trailingAnchor.constraint(equalTo: ownedButton.leadingAnchor, constant: -KitchenSpacing.garnish),
            amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            ownedButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            ownedButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            ownedButton.widthAnchor.constraint(equalToConstant: 32),
            ownedButton.heightAnchor.constraint(equalToConstant: 32),

            heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @objc private func checkTapped() {
        onToggled?()
    }

    @objc private func ownedTapped() {
        onOwnedToggled?()
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Shopping Help Modal
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class ShoppingHelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "How to Use Shopping"
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
            ("📋", "How Products Appear", "Products are automatically generated from your week plan. When you generate a week in 'Week Plan', all ingredients from the dishes are collected and grouped by store aisles."),
            ("🔄", "Updating Shopping List", "The shopping list automatically updates when you regenerate a week in 'Week Plan'. After tapping 'Regenerate Unlocked' in Week Plan, your shopping list will refresh with the new ingredients from the updated meals."),
            ("➕", "Adding Products", "You cannot add products manually. They are automatically created from the ingredients in your dishes. To add more products, add ingredients to your dishes in 'My 12'."),
            ("✅", "Check Off Items", "Tap the circle icon to check off items you've already bought. Checked items will be crossed out."),
            ("🏠", "Mark as 'Have at Home'", "Tap the house icon to mark items you already have at home. These items will be removed from your shopping list and saved to your pantry."),
            ("🔍", "Filter Unchecked", "Toggle 'Show only unchecked' to hide items you've already checked or marked as owned. This helps focus on what you still need to buy."),
            ("📅", "Week Navigation", "Use arrows to switch between weeks. Each week has its own shopping list based on the meals planned for that week."),
            ("🏪", "Store Mode", "Tap 'Store Mode' to open a full-screen optimized view for shopping. Large buttons make it easy to check off items while shopping. Items are organized by store aisles.")
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Store Mode View Controller
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class StoreModeViewController: UIViewController {

    private let roll: GroceryRoll
    private let vault = CellarVault.shared
    private var currentRoll: GroceryRoll
    private var groupedItems: [AisleGroup] = []

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private var itemViews: [StoreModeItemView] = []

    init(roll: GroceryRoll) {
        self.roll = roll
        self.currentRoll = roll
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SaffronPalette.crust
        
        setupLayout()
        loadItems()
    }

    private func setupLayout() {
        // Header
        let headerView = UIView()
        headerView.backgroundColor = SaffronPalette.brioche
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Store Mode"
        titleLabel.font = TypographyRecipe.chefTitle()
        titleLabel.textColor = SaffronPalette.flour
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Done", for: .normal)
        closeButton.titleLabel?.font = TypographyRecipe.cardLabel()
        closeButton.setTitleColor(SaffronPalette.honeyComb, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        view.addSubview(headerView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = KitchenSpacing.tray
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: KitchenSpacing.plate),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -KitchenSpacing.plate),
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
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

    private func loadItems() {
        // Filter out checked, owned, and empty items
        let activeItems = currentRoll.items.filter { 
            !$0.isChecked && !$0.isOwned && !$0.displayName.trimmingCharacters(in: .whitespaces).isEmpty
        }
        
        guard !activeItems.isEmpty else {
            let emptyLabel = UILabel()
            emptyLabel.text = "All items are checked or marked as owned!"
            emptyLabel.font = TypographyRecipe.sectionRoast()
            emptyLabel.textColor = SaffronPalette.steamGrey
            emptyLabel.textAlignment = .center
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            contentStack.addArrangedSubview(emptyLabel)
            return
        }

        // Group by aisle
        let aisles = vault.aisles.sorted { $0.sortRank < $1.sortRank }
        var groups: [AisleGroup] = []

        for aisle in aisles {
            let items = activeItems.filter { $0.aisleID == aisle.id }
            if !items.isEmpty {
                groups.append(AisleGroup(aisle: aisle, items: items))
            }
        }

        // Other category
        let otherItems = activeItems.filter { $0.aisleID == nil }
        if !otherItems.isEmpty {
            let otherAisle = AisleCategory(
                id: UUID(),
                title: "Other",
                sortRank: 999,
                isHidden: false,
                bakedAt: Date(),
                refreshedAt: Date()
            )
            groups.append(AisleGroup(aisle: otherAisle, items: otherItems))
        }

        groupedItems = groups

        // Build UI - large touchable items
        for group in groups {
            let sectionView = buildAisleSection(group: group)
            contentStack.addArrangedSubview(sectionView)
        }
    }

    private func buildAisleSection(group: AisleGroup) -> UIView {
        let container = UIView()
        container.backgroundColor = SaffronPalette.brioche
        container.layer.cornerRadius = PlatingCorner.biscuit
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = group.aisle.title
        titleLabel.font = TypographyRecipe.sectionRoast()
        titleLabel.textColor = SaffronPalette.flour
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        let itemsStack = UIStackView()
        itemsStack.axis = .vertical
        itemsStack.spacing = KitchenSpacing.napkin
        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(itemsStack)

        for ticket in group.items {
            let itemView = StoreModeItemView(ticket: ticket)
            itemView.onToggled = { [weak self] in
                self?.toggleItem(ticket)
            }
            itemView.onOwnedToggled = { [weak self] in
                self?.toggleOwned(ticket)
            }
            itemsStack.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: KitchenSpacing.plate),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),

            itemsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            itemsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            itemsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),
            itemsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.plate),
        ])

        return container
    }

    private func toggleItem(_ ticket: GroceryTicket) {
        if let idx = currentRoll.items.firstIndex(where: { $0.id == ticket.id }) {
            currentRoll.items[idx].isChecked.toggle()
            currentRoll.items[idx].refreshedAt = Date()
            currentRoll.refreshedAt = Date()
            vault.saveGroceryRoll(currentRoll)
            
            // Update view
            if let itemView = itemViews.first(where: { $0.ticket.id == ticket.id }) {
                itemView.updateState(ticket: currentRoll.items[idx])
            }
            
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
        }
    }

    private func toggleOwned(_ ticket: GroceryTicket) {
        if let idx = currentRoll.items.firstIndex(where: { $0.id == ticket.id }) {
            currentRoll.items[idx].isOwned.toggle()
            currentRoll.items[idx].refreshedAt = Date()
            currentRoll.refreshedAt = Date()
            vault.saveGroceryRoll(currentRoll)
            
            // Update pantry
            if currentRoll.items[idx].isOwned {
                vault.markAsOwned(
                    normalizedName: ticket.normalizedName,
                    displayName: ticket.displayName,
                    aisleID: ticket.aisleID
                )
            } else {
                vault.removeFromPantry(normalizedName: ticket.normalizedName)
            }
            
            // Reload to remove owned items
            contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            itemViews.removeAll()
            loadItems()
            
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
        }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Store Mode Item View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class StoreModeItemView: UIView {

    var onToggled: (() -> Void)?
    var onOwnedToggled: (() -> Void)?

    private(set) var ticket: GroceryTicket
    private let checkButton = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let amountLabel = UILabel()
    private let ownedButton = UIButton(type: .system)

    init(ticket: GroceryTicket) {
        self.ticket = ticket
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {
        backgroundColor = SaffronPalette.meringue
        layer.cornerRadius = PlatingCorner.biscuit
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 72).isActive = true

        // Large check button
        checkButton.setImage(
            UIImage(systemName: ticket.isChecked ? "checkmark.circle.fill" : "circle"),
            for: .normal
        )
        checkButton.tintColor = ticket.isChecked ? SaffronPalette.mintGarnish : SaffronPalette.steamGrey
        checkButton.addTarget(self, action: #selector(checkTapped), for: .touchUpInside)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        checkButton.imageView?.contentMode = .scaleAspectFit

        nameLabel.text = ticket.displayName
        nameLabel.font = TypographyRecipe.cardLabel()
        nameLabel.textColor = SaffronPalette.flour
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        amountLabel.text = "\(ticket.amount) \(ticket.unit.shortLabel)"
        amountLabel.font = TypographyRecipe.servingBody()
        amountLabel.textColor = SaffronPalette.honeyComb
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        ownedButton.setImage(
            UIImage(systemName: ticket.isOwned ? "house.fill" : "house"),
            for: .normal
        )
        ownedButton.tintColor = ticket.isOwned ? SaffronPalette.mintGarnish : SaffronPalette.steamGrey
        ownedButton.addTarget(self, action: #selector(ownedTapped), for: .touchUpInside)
        ownedButton.translatesAutoresizingMaskIntoConstraints = false
        ownedButton.accessibilityLabel = "Mark as have at home"

        addSubview(checkButton)
        addSubview(nameLabel)
        addSubview(amountLabel)
        addSubview(ownedButton)

        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            checkButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: 44),
            checkButton.heightAnchor.constraint(equalToConstant: 44),

            nameLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: KitchenSpacing.plate),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: KitchenSpacing.plate),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: ownedButton.leadingAnchor, constant: -KitchenSpacing.plate),

            amountLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            amountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: KitchenSpacing.crumb),
            amountLabel.trailingAnchor.constraint(lessThanOrEqualTo: ownedButton.leadingAnchor, constant: -KitchenSpacing.plate),

            ownedButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KitchenSpacing.plate),
            ownedButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            ownedButton.widthAnchor.constraint(equalToConstant: 44),
            ownedButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    func updateState(ticket: GroceryTicket) {
        self.ticket = ticket
        
        checkButton.setImage(
            UIImage(systemName: ticket.isChecked ? "checkmark.circle.fill" : "circle"),
            for: .normal
        )
        checkButton.tintColor = ticket.isChecked ? SaffronPalette.mintGarnish : SaffronPalette.steamGrey
        
        ownedButton.setImage(
            UIImage(systemName: ticket.isOwned ? "house.fill" : "house"),
            for: .normal
        )
        ownedButton.tintColor = ticket.isOwned ? SaffronPalette.mintGarnish : SaffronPalette.steamGrey
        
        if ticket.isChecked {
            nameLabel.textColor = SaffronPalette.ashDust
            let attr = NSMutableAttributedString(string: ticket.displayName)
            attr.addAttribute(.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attr.length))
            nameLabel.attributedText = attr
        } else {
            nameLabel.textColor = SaffronPalette.flour
            nameLabel.attributedText = nil
            nameLabel.text = ticket.displayName
        }
    }

    @objc private func checkTapped() {
        onToggled?()
    }

    @objc private func ownedTapped() {
        onOwnedToggled?()
    }
}
