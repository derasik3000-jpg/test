
import UIKit

final class SpiceRackSettingsViewController: UIViewController {

    // ── Coordinator ──────────────────────────

    weak var coordinatorDelegate: KitchenNavigable?

    // ── Data ─────────────────────────────────

    private let vault = CellarVault.shared
    private var config: KitchenConfig {
        vault.config
    }

    // ── UI ───────────────────────────────────

    private let scrollBowl = UIScrollView()
    private let contentStack = UIStackView()

    // Avatar section
    private let avatarButton = UIButton(type: .system)
    private let avatarLabel = UILabel()

    // Stats button
    private let statsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = SaffronPalette.brioche
        btn.layer.cornerRadius = PlatingCorner.biscuit
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 64).isActive = true
        return btn
    }()

    // Share button
    private let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = SaffronPalette.brioche
        btn.layer.cornerRadius = PlatingCorner.biscuit
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 64).isActive = true
        return btn
    }()

    // Meal types
    private var mealTypeSwitches: [UISwitch] = []

    // Servings
    private let servingsStepper = UIStepper()
    private let servingsLabel = UILabel()

    // Rounding
    private let roundingSwitch = UISwitch()
    private let roundingLabel = UILabel()

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Lifecycle
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = SaffronPalette.crust
        navigationItem.largeTitleDisplayMode = .always

        setupLayout()
        loadSettings()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Layout
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func setupLayout() {
        scrollBowl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollBowl)

        contentStack.axis = .vertical
        contentStack.spacing = KitchenSpacing.banquet
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollBowl.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollBowl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollBowl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollBowl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollBowl.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollBowl.topAnchor, constant: KitchenSpacing.platter),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.plate),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.plate),
            contentStack.bottomAnchor.constraint(equalTo: scrollBowl.bottomAnchor, constant: -KitchenSpacing.banquet),
            contentStack.widthAnchor.constraint(equalTo: scrollBowl.widthAnchor, constant: -KitchenSpacing.plate * 2),
        ])

        // Avatar section
        setupAvatarSection()

        // Gamification buttons
        setupGamificationButtons()

        // Meal types
        setupMealTypesSection()

        // Servings
        setupServingsSection()

        // Rounding
        setupRoundingSection()
    }

    private func setupAvatarSection() {
        let container = UIView()
        container.backgroundColor = SaffronPalette.brioche
        container.layer.cornerRadius = PlatingCorner.biscuit
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Your Avatar"
        titleLabel.font = TypographyRecipe.sectionRoast()
        titleLabel.textColor = SaffronPalette.flour
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        avatarButton.titleLabel?.font = .systemFont(ofSize: 48)
        avatarButton.addTarget(self, action: #selector(avatarTap), for: .touchUpInside)
        avatarButton.translatesAutoresizingMaskIntoConstraints = false

        avatarLabel.text = "Tap to change"
        avatarLabel.font = TypographyRecipe.croutonCaption()
        avatarLabel.textColor = SaffronPalette.steamGrey
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)
        container.addSubview(avatarButton)
        container.addSubview(avatarLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: KitchenSpacing.plate),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            avatarButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            avatarButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            avatarButton.widthAnchor.constraint(equalToConstant: 80),
            avatarButton.heightAnchor.constraint(equalToConstant: 80),

            avatarLabel.topAnchor.constraint(equalTo: avatarButton.bottomAnchor, constant: KitchenSpacing.crumb),
            avatarLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            avatarLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.plate),
        ])

        contentStack.addArrangedSubview(container)
    }

    private func setupGamificationButtons() {
        // Stats button
        let statsStack = UIStackView()
        statsStack.axis = .horizontal
        statsStack.spacing = KitchenSpacing.napkin
        statsStack.alignment = .center
        statsStack.isUserInteractionEnabled = false

        let statsIcon = UIImageView(image: UIImage(systemName: "chart.bar.fill"))
        statsIcon.tintColor = SaffronPalette.honeyComb
        statsIcon.translatesAutoresizingMaskIntoConstraints = false
        statsIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        statsIcon.heightAnchor.constraint(equalToConstant: 24).isActive = true
        statsIcon.isUserInteractionEnabled = false

        let statsText = UILabel()
        statsText.text = "Statistics"
        statsText.font = TypographyRecipe.cardLabel()
        statsText.textColor = SaffronPalette.flour
        statsText.isUserInteractionEnabled = false

        statsStack.addArrangedSubview(statsIcon)
        statsStack.addArrangedSubview(statsText)
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        statsButton.addSubview(statsStack)
        statsButton.addTarget(self, action: #selector(statsTap), for: .touchUpInside)

        NSLayoutConstraint.activate([
            statsStack.centerXAnchor.constraint(equalTo: statsButton.centerXAnchor),
            statsStack.centerYAnchor.constraint(equalTo: statsButton.centerYAnchor),
        ])

        // Share button
        let shareStack = UIStackView()
        shareStack.axis = .horizontal
        shareStack.spacing = KitchenSpacing.napkin
        shareStack.alignment = .center
        shareStack.isUserInteractionEnabled = false

        let shareIcon = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
        shareIcon.tintColor = SaffronPalette.honeyComb
        shareIcon.translatesAutoresizingMaskIntoConstraints = false
        shareIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        shareIcon.heightAnchor.constraint(equalToConstant: 24).isActive = true
        shareIcon.isUserInteractionEnabled = false

        let shareText = UILabel()
        shareText.text = "Share Data"
        shareText.font = TypographyRecipe.cardLabel()
        shareText.textColor = SaffronPalette.flour
        shareText.isUserInteractionEnabled = false

        shareStack.addArrangedSubview(shareIcon)
        shareStack.addArrangedSubview(shareText)
        shareStack.translatesAutoresizingMaskIntoConstraints = false

        shareButton.addSubview(shareStack)
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)

        NSLayoutConstraint.activate([
            shareStack.centerXAnchor.constraint(equalTo: shareButton.centerXAnchor),
            shareStack.centerYAnchor.constraint(equalTo: shareButton.centerYAnchor),
        ])

        contentStack.addArrangedSubview(statsButton)
        contentStack.addArrangedSubview(shareButton)
    }

    private func setupMealTypesSection() {
        let container = buildSection(title: "Meal Types")
        let titleLabel = container.subviews.first as! UILabel
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = KitchenSpacing.napkin
        stack.translatesAutoresizingMaskIntoConstraints = false

        for kind in CourseKind.allCases {
            let row = buildMealTypeRow(kind)
            stack.addArrangedSubview(row)
        }

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.plate),
        ])

        contentStack.addArrangedSubview(container)
    }

    private func buildMealTypeRow(_ kind: CourseKind) -> UIView {
        let row = UIView()
        row.backgroundColor = SaffronPalette.meringue
        row.layer.cornerRadius = PlatingCorner.biscuit
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let icon = UIImageView(image: UIImage(systemName: kind.sfIcon))
        icon.tintColor = kind.tintColor
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = kind.displayLabel
        label.font = TypographyRecipe.servingBody()
        label.textColor = SaffronPalette.flour
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        let toggle = UISwitch()
        toggle.tag = kind.rawValue
        toggle.addTarget(self, action: #selector(mealTypeToggled(_:)), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        mealTypeSwitches.append(toggle)

        row.addSubview(icon)
        row.addSubview(label)
        row.addSubview(toggle)

        NSLayoutConstraint.activate([
            // Icon
            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: KitchenSpacing.plate),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),
            
            // Label
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: KitchenSpacing.napkin),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -KitchenSpacing.plate),
            
            // Toggle
            toggle.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -KitchenSpacing.plate),
            toggle.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])

        return row
    }

    private func setupServingsSection() {
        let container = buildSection(title: "Default Servings")
        let titleLabel = container.subviews.first as! UILabel
        
        let rowContainer = UIView()
        rowContainer.backgroundColor = SaffronPalette.meringue
        rowContainer.layer.cornerRadius = PlatingCorner.biscuit
        rowContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = KitchenSpacing.plate
        row.alignment = .center
        row.distribution = .fill
        row.translatesAutoresizingMaskIntoConstraints = false

        servingsLabel.font = TypographyRecipe.servingBody()
        servingsLabel.textColor = SaffronPalette.flour
        servingsLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        servingsStepper.minimumValue = 1
        servingsStepper.maximumValue = 8
        servingsStepper.stepValue = 1
        servingsStepper.addTarget(self, action: #selector(servingsChanged), for: .valueChanged)
        servingsStepper.setContentHuggingPriority(.required, for: .horizontal)

        row.addArrangedSubview(servingsLabel)
        row.addArrangedSubview(servingsStepper)

        rowContainer.addSubview(row)
        container.addSubview(rowContainer)
        
        NSLayoutConstraint.activate([
            rowContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            rowContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            rowContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),
            rowContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.plate),
            rowContainer.heightAnchor.constraint(equalToConstant: 56),
            
            row.topAnchor.constraint(equalTo: rowContainer.topAnchor),
            row.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor, constant: KitchenSpacing.plate),
            row.trailingAnchor.constraint(equalTo: rowContainer.trailingAnchor, constant: -KitchenSpacing.plate),
            row.bottomAnchor.constraint(equalTo: rowContainer.bottomAnchor),
        ])

        contentStack.addArrangedSubview(container)
    }

    private func setupRoundingSection() {
        let container = buildSection(title: "Rounding")
        let titleLabel = container.subviews.first as! UILabel
        
        let rowContainer = UIView()
        rowContainer.backgroundColor = SaffronPalette.meringue
        rowContainer.layer.cornerRadius = PlatingCorner.biscuit
        rowContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = KitchenSpacing.plate
        row.alignment = .center
        row.distribution = .fill
        row.translatesAutoresizingMaskIntoConstraints = false

        roundingLabel.font = TypographyRecipe.servingBody()
        roundingLabel.textColor = SaffronPalette.flour
        roundingLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        roundingSwitch.addTarget(self, action: #selector(roundingToggled), for: .valueChanged)
        roundingSwitch.setContentHuggingPriority(.required, for: .horizontal)

        row.addArrangedSubview(roundingLabel)
        row.addArrangedSubview(roundingSwitch)

        rowContainer.addSubview(row)
        container.addSubview(rowContainer)
        
        NSLayoutConstraint.activate([
            rowContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            rowContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            rowContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),
            rowContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.plate),
            rowContainer.heightAnchor.constraint(equalToConstant: 56),
            
            row.topAnchor.constraint(equalTo: rowContainer.topAnchor),
            row.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor, constant: KitchenSpacing.plate),
            row.trailingAnchor.constraint(equalTo: rowContainer.trailingAnchor, constant: -KitchenSpacing.plate),
            row.bottomAnchor.constraint(equalTo: rowContainer.bottomAnchor),
        ])

        contentStack.addArrangedSubview(container)
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

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Data Loading
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func loadSettings() {
        // Avatar
        avatarButton.setTitle(config.avatarEmoji, for: .normal)

        // Meal types
        for toggle in mealTypeSwitches {
            guard let kind = CourseKind(rawValue: toggle.tag) else { continue }
            toggle.isOn = config.enabledCourses.contains(kind)
        }

        // Servings
        servingsStepper.value = Double(config.defaultServings)
        servingsLabel.text = "Default servings: \(config.defaultServings)"

        // Rounding
        roundingSwitch.isOn = config.roundingEnabled
        roundingLabel.text = "Round to convenient values"
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Actions
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @objc private func avatarTap() {
        let alert = UIAlertController(title: "Choose Avatar", message: "Pick an emoji", preferredStyle: .alert)

        let emojis = ["🧑‍🍳", "👨‍🍳", "👩‍🍳", "🍳", "🥘", "🍲", "🍱", "🍝", "🍕", "🌮", "🥗", "🍰"]
        let emojiRows = stride(from: 0, to: emojis.count, by: 4).map { start in
            Array(emojis[start..<min(start + 4, emojis.count)])
        }

        for row in emojiRows {
            let rowAction = UIAlertAction(title: row.joined(separator: "  "), style: .default) { [weak self] action in
                // Extract emoji from title
                if let title = action.title, let emoji = row.first {
                    self?.setAvatar(emoji)
                }
            }
            alert.addAction(rowAction)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func setAvatar(_ emoji: String) {
        vault.stir { ledger in
            ledger.config.avatarEmoji = emoji
            ledger.config.refreshedAt = Date()
        }
        avatarButton.setTitle(emoji, for: .normal)

        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }

    @objc private func statsTap() {
        coordinatorDelegate?.requestOpenStats()
    }

    @objc private func shareTap() {
        let score = vault.computeTasteScore()
        let text = """
        My Menu of 12 Dishes Stats:
        
        📅 Weeks planned: \(score.totalWeeksPlanned)
        🍽 Total meals: \(score.totalSlotsGenerated)
        🎯 Unique dishes: \(score.uniqueDishesUsed)
        ✅ Completed lists: \(score.shoppingListsCompleted)
        🔥 Current streak: \(score.currentStreak)
        
        Badges earned: \(score.earnedBadges.count)
        """

        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = shareButton
        }
        present(activityVC, animated: true)
    }

    @objc private func mealTypeToggled(_ sender: UISwitch) {
        guard let kind = CourseKind(rawValue: sender.tag) else { return }
        vault.stir { ledger in
            if sender.isOn {
                ledger.config.enabledCoursesMask |= kind.bitmask
            } else {
                ledger.config.enabledCoursesMask &= ~kind.bitmask
            }
            ledger.config.refreshedAt = Date()
        }
    }

    @objc private func servingsChanged() {
        let servings = Int(servingsStepper.value)
        servingsLabel.text = "Default servings: \(servings)"
        vault.stir { ledger in
            ledger.config.defaultServings = servings
            ledger.config.refreshedAt = Date()
        }
    }

    @objc private func roundingToggled() {
        vault.stir { ledger in
            ledger.config.roundingEnabled = self.roundingSwitch.isOn
            ledger.config.refreshedAt = Date()
        }
    }
}
