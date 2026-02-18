
import UIKit

final class PantryGridViewController: UIViewController {

    // ── Coordinator ──────────────────────────

    weak var coordinatorDelegate: KitchenNavigable?

    // ── Data ─────────────────────────────────

    private var allEntrees: [Entree] = []

    // ── UI ───────────────────────────────────

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = SaffronPalette.crust
        tv.separatorStyle = .none
        tv.dataSource = self
        tv.delegate = self
        tv.register(SimpleDishCell.self, forCellReuseIdentifier: SimpleDishCell.reuseTag)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 60
        return tv
    }()

    // ── Observer ─────────────────────────────

    private var ledgerToken: NSObjectProtocol?

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Lifecycle
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My 12"
        view.backgroundColor = SaffronPalette.crust
        navigationItem.largeTitleDisplayMode = .always

        configureNavBar()
        layoutSubviews()
        reloadPantry()
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
        let helpVC = PantryHelpViewController()
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
        reloadPantry()
    }

    deinit {
        if let tok = ledgerToken { NotificationCenter.default.removeObserver(tok) }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Layout
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func layoutSubviews() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: KitchenSpacing.plate),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.plate),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.plate),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Data
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func reloadPantry() {
        allEntrees = CellarVault.shared.entrees // sorted 0…11
        tableView.reloadData()
    }

    private func observeLedger() {
        ledgerToken = NotificationCenter.default.addObserver(
            forName: CellarVault.ledgerDidUpdate,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.reloadPantry()
        }
    }

}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - UITableView DataSource
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension PantryGridViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12 // Always show 12 slots
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SimpleDishCell.reuseTag, for: indexPath
        ) as? SimpleDishCell else {
            return UITableViewCell()
        }

        // Get entree for this slot, or create empty one
        let slotIndex = indexPath.row
        let entree = allEntrees.first { $0.slotIndex == slotIndex }
            ?? Entree.emptyPlate(at: slotIndex)

        cell.configure(with: entree)

        // Set up callbacks
        cell.onDeleteTapped = { [weak self] in
            self?.confirmClearSlot(slotIndex)
        }

        cell.onEditTapped = { [weak self] in
            if entree.isReadyToServe {
                self?.coordinatorDelegate?.requestEditEntree(entree)
            } else {
                self?.coordinatorDelegate?.requestCreateEntree(atSlot: slotIndex)
            }
        }

        cell.onFavoriteTapped = { [weak self] in
            if entree.isReadyToServe {
                self?.toggleFavorite(entree)
            }
        }

        return cell
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - UITableView Delegate
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension PantryGridViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let verticalPadding = KitchenSpacing.napkin * 2 // top + bottom
        return 60 + verticalPadding // 60 (content) + 12 (top) + 12 (bottom) = 84
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let slotIndex = indexPath.row
        let entree = allEntrees.first { $0.slotIndex == slotIndex }
            ?? Entree.emptyPlate(at: slotIndex)

        if entree.isReadyToServe {
            coordinatorDelegate?.requestOpenEntreeDetail(entree)
        } else {
            coordinatorDelegate?.requestCreateEntree(atSlot: slotIndex)
        }
    }

    // ── Actions ──────────────────────────────

    private func toggleFavorite(_ entree: Entree) {
        var updated = entree
        updated.isFavorite.toggle()
        updated.refreshedAt = Date()
        CellarVault.shared.updateEntree(updated)

        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(updated.isFavorite ? .success : .warning)
        
        // Reload pantry to get updated data
        reloadPantry()
    }

    private func confirmClearSlot(_ index: Int) {
        let alert = UIAlertController(
            title: "Clear this slot?",
            message: "The dish will be removed from your set of 12.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            CellarVault.shared.clearSlot(at: index)
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
            self?.reloadPantry()
        })
        present(alert, animated: true)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🩺 Health Banner View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Shows "9/12 ready · 7 have ingredients" indicator.
final class HealthBannerView: UIView {

    private let readyBadge = UILabel()
    private let ingredientBadge = UILabel()
    private let progressLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = SaffronPalette.brioche
        layer.cornerRadius = PlatingCorner.biscuit

        let stack = UIStackView(arrangedSubviews: [readyBadge, ingredientBadge])
        stack.axis = .horizontal
        stack.spacing = KitchenSpacing.plate
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -KitchenSpacing.plate),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: KitchenSpacing.garnish),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -KitchenSpacing.garnish),
        ])

        readyBadge.font = TypographyRecipe.croutonCaption()
        ingredientBadge.font = TypographyRecipe.croutonCaption()
        ingredientBadge.textColor = SaffronPalette.steamGrey

        // Progress arc (behind text)
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = SaffronPalette.honeyComb.withAlphaComponent(0.15).cgColor
        progressLayer.lineWidth = 3
        layer.insertSublayer(progressLayer, at: 0)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(ready: Int, withIngredients: Int) {
        let full = ready == 12

        readyBadge.text = full ? "✅ 12/12 ready" : "🍽 \(ready)/12 ready"
        readyBadge.textColor = full ? SaffronPalette.mintGarnish : SaffronPalette.honeyComb

        ingredientBadge.text = "🧅 \(withIngredients) have ingredients"

        // Animate subtle glow if full
        if full {
            layer.borderWidth = 1
            layer.borderColor = SaffronPalette.mintGarnish.withAlphaComponent(0.3).cgColor
        } else {
            layer.borderWidth = 0
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🏷 Filter Ribbon View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Horizontal scrolling tag chips: All · Breakfast · Lunch · Dinner · Snack.
final class FilterRibbonView: UIView {

    var onFilterChanged: ((CourseKind?) -> Void)?
    private var selectedKind: CourseKind?
    private var chipButtons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildChips()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildChips() {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = KitchenSpacing.garnish
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: topAnchor),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: KitchenSpacing.plate),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -KitchenSpacing.plate),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scroll.heightAnchor),
        ])

        // "All" chip
        let allBtn = makeChip(title: "All", tag: -1)
        stack.addArrangedSubview(allBtn)
        chipButtons.append(allBtn)

        // Course chips
        for kind in CourseKind.allCases {
            let btn = makeChip(title: kind.displayLabel, tag: kind.rawValue)
            stack.addArrangedSubview(btn)
            chipButtons.append(btn)
        }

        styleChips(selectedTag: -1)
    }

    private func makeChip(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = TypographyRecipe.servingBody()
        btn.tag = tag
        btn.layer.cornerRadius = PlatingCorner.biscuit
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        return btn
    }

    @objc private func chipTapped(_ sender: UIButton) {
        let kind: CourseKind? = sender.tag >= 0 ? CourseKind(rawValue: sender.tag) : nil
        selectedKind = kind
        styleChips(selectedTag: sender.tag)
        onFilterChanged?(kind)
    }

    private func styleChips(selectedTag: Int) {
        for btn in chipButtons {
            let active = btn.tag == selectedTag
            UIView.animate(withDuration: 0.2) {
                btn.backgroundColor = active
                    ? SaffronPalette.honeyComb.withAlphaComponent(0.2)
                    : SaffronPalette.brioche
                btn.setTitleColor(
                    active ? SaffronPalette.honeyComb : SaffronPalette.steamGrey,
                    for: .normal
                )
                btn.layer.borderWidth = active ? 2 : 0
                btn.layer.borderColor = active ? UIColor.white.cgColor : UIColor.clear.cgColor
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Help Modal View Controller
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class PantryHelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "How to Use My 12"
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

        // Help items - updated for simplified design
        let helpItems = [
            ("➕", "Add New Dish", "Tap on an empty slot (with +) to create a new dish. Fill in the name, meal types, ingredients, and cooking steps."),
            ("✏️", "Edit Dish", "Tap the edit button (pencil icon) on any filled slot to view or edit the dish details."),
            ("🗑️", "Delete Dish", "Tap the delete button (trash icon) to remove a dish from your list of 12."),
            ("⭐", "Favorite", "Tap the star button to mark a dish as favorite. Filled star means it's favorited."),
            ("📋", "List of 12", "You have exactly 12 slots for dishes. Fill them all to have a complete meal plan!")
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
