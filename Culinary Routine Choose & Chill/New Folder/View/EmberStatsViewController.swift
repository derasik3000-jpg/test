// ──────────────────────────────────────────────
// EmberStatsViewController.swift
// с8 – "Menu of 12 Dishes"
//
// Statistics screen with charts: donut for meal
// type distribution, bar chart for top dishes,
// timeline for weekly activity. Shows badges,
// streaks, and insights. Gamification-focused.
// ──────────────────────────────────────────────

import UIKit

final class EmberStatsViewController: UIViewController {

    // ── Data ─────────────────────────────────

    private let vault = CellarVault.shared
    private var tasteScore: TasteScore = .empty

    // ── UI ───────────────────────────────────

    private let scrollBowl = UIScrollView()
    private let contentStack = UIStackView()

    // Header with avatar and score
    private let headerView = StatsHeaderView()

    // Badges section
    private let badgesView = BadgesCollectionView()

    // Charts
    private let mealTypeDonut = SimpleDonutChart()
    private let topDishesList = TopDishesListView()

    // Stats cards
    private var statCards: [StatCardView] = []

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Lifecycle
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Statistics"
        view.backgroundColor = SaffronPalette.crust
        navigationItem.largeTitleDisplayMode = .always

        setupLayout()
        loadStats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStats()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Layout
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func setupLayout() {
        scrollBowl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollBowl)

        contentStack.axis = .vertical
        contentStack.spacing = KitchenSpacing.tray
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

        // Header
        contentStack.addArrangedSubview(headerView)

        // Badges
        contentStack.addArrangedSubview(badgesView)

        // Meal Type Distribution section
        let mealTypeContainer = buildChartSection(title: "Meal Type Distribution", chart: mealTypeDonut)
        mealTypeDonut.heightAnchor.constraint(equalToConstant: 200).isActive = true
        contentStack.addArrangedSubview(mealTypeContainer)

        // Top Dishes section
        let topDishesContainer = buildChartSection(title: "Top Dishes", chart: topDishesList)
        topDishesList.translatesAutoresizingMaskIntoConstraints = false
        topDishesList.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        contentStack.addArrangedSubview(topDishesContainer)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Data Loading
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func loadStats() {
        tasteScore = vault.computeTasteScore()

        // Update header
        headerView.configure(score: tasteScore, avatar: vault.config.avatarEmoji)

        // Update badges
        badgesView.configure(badges: tasteScore.earnedBadges)

        // Build charts
        buildMealTypeChart()
        buildTopDishesChart()

        // Build stat cards
        buildStatCards()
    }

    private func buildMealTypeChart() {
        let events = vault.allSauteEvents
        var counts: [CourseKind: Int] = [:]

        for event in events {
            counts[event.course, default: 0] += 1
        }

        let total = counts.values.reduce(0, +)
        guard total > 0 else {
            mealTypeDonut.isHidden = true
            return
        }

        var slices: [(CourseKind, Double)] = []
        for kind in CourseKind.allCases {
            let count = counts[kind, default: 0]
            if count > 0 {
                slices.append((kind, Double(count) / Double(total)))
            }
        }

        mealTypeDonut.configure(slices: slices)
        mealTypeDonut.isHidden = false
    }

    private func buildTopDishesChart() {
        let events = vault.allSauteEvents
        var dishCounts: [UUID: Int] = [:]

        for event in events {
            dishCounts[event.entreeID, default: 0] += 1
        }

        let sorted = dishCounts.sorted { $0.value > $1.value }.prefix(5)
        guard !sorted.isEmpty else {
            topDishesList.isHidden = true
            return
        }

        let entrees = vault.entrees
        var dishes: [(String, Int)] = []

        for (id, count) in sorted {
            if let entree = entrees.first(where: { $0.id == id }) {
                dishes.append((entree.title, count))
            }
        }

        topDishesList.configure(dishes: dishes)
        topDishesList.isHidden = false
    }

    private func buildStatCards() {
        statCards.forEach { $0.removeFromSuperview() }
        statCards.removeAll()

        let cards = [
            ("Weeks Planned", "\(tasteScore.totalWeeksPlanned)", "calendar"),
            ("Total Meals", "\(tasteScore.totalSlotsGenerated)", "fork.knife"),
            ("Unique Dishes", "\(tasteScore.uniqueDishesUsed)", "star.fill"),
            ("Completed Lists", "\(tasteScore.shoppingListsCompleted)", "checkmark.circle.fill"),
            ("Current Streak", "\(tasteScore.currentStreak)", "flame.fill"),
        ]

        for (title, value, icon) in cards {
            let card = StatCardView(title: title, value: value, icon: icon)
            contentStack.addArrangedSubview(card)
            statCards.append(card)
        }
    }

    private func buildChartSection(title: String, chart: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = TypographyRecipe.sectionRoast()
        titleLabel.textColor = SaffronPalette.flour
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        chart.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(chart)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: KitchenSpacing.plate),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: KitchenSpacing.plate),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -KitchenSpacing.plate),

            chart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            chart.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            chart.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -KitchenSpacing.plate),
        ])

        return container
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Stats Header View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class StatsHeaderView: UIView {

    private let avatarLabel = UILabel()
    private let scoreLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupHeader() {
        backgroundColor = SaffronPalette.brioche
        layer.cornerRadius = PlatingCorner.biscuit
        applySeasoning(ShadowSeasoning.softGlow)

        avatarLabel.font = .systemFont(ofSize: 64)
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false

        scoreLabel.font = TypographyRecipe.chefTitle()
        scoreLabel.textColor = SaffronPalette.flour
        scoreLabel.textAlignment = .center
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = TypographyRecipe.sideNote()
        subtitleLabel.textColor = SaffronPalette.steamGrey
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(avatarLabel)
        addSubview(scoreLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            avatarLabel.topAnchor.constraint(equalTo: topAnchor, constant: KitchenSpacing.platter),
            avatarLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            scoreLabel.topAnchor.constraint(equalTo: avatarLabel.bottomAnchor, constant: KitchenSpacing.plate),
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: KitchenSpacing.plate),
            scoreLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -KitchenSpacing.plate),

            subtitleLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: KitchenSpacing.garnish),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KitchenSpacing.plate),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -KitchenSpacing.platter),
        ])
    }

    func configure(score: TasteScore, avatar: String) {
        avatarLabel.text = avatar
        scoreLabel.text = "Your Progress"
        subtitleLabel.text = "\(score.totalWeeksPlanned) weeks planned • \(score.currentStreak) week streak"
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Badges Collection View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class BadgesCollectionView: UIView {

    private let titleLabel = UILabel()
    private let badgesStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBadges()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupBadges() {
        backgroundColor = SaffronPalette.brioche
        layer.cornerRadius = PlatingCorner.biscuit

        titleLabel.text = "Badges Earned"
        titleLabel.font = TypographyRecipe.sectionRoast()
        titleLabel.textColor = SaffronPalette.flour
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        badgesStack.axis = .horizontal
        badgesStack.spacing = KitchenSpacing.plate
        badgesStack.distribution = .fillEqually
        badgesStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgesStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: KitchenSpacing.plate),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            badgesStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.plate),
            badgesStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            badgesStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KitchenSpacing.plate),
            badgesStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -KitchenSpacing.plate),
            badgesStack.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    func configure(badges: [String]) {
        badgesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if badges.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Complete challenges to earn badges!"
            emptyLabel.font = TypographyRecipe.croutonCaption()
            emptyLabel.textColor = SaffronPalette.steamGrey
            emptyLabel.textAlignment = .center
            badgesStack.addArrangedSubview(emptyLabel)
            return
        }

        for iconName in badges.prefix(4) {
            let badgeView = UIView()
            badgeView.backgroundColor = SaffronPalette.meringue
            badgeView.layer.cornerRadius = 30

            let icon = UIImageView(image: UIImage(systemName: iconName))
            icon.tintColor = SaffronPalette.honeyComb
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            badgeView.addSubview(icon)

            NSLayoutConstraint.activate([
                icon.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 32),
                icon.heightAnchor.constraint(equalToConstant: 32),
            ])

            badgesStack.addArrangedSubview(badgeView)
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Simple Donut Chart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class SimpleDonutChart: UIView {

    private var slices: [(CourseKind, Double)] = []
    private let legendStack = UIStackView()
    private var legendConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLegend()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLegend()
    }

    private func setupLegend() {
        legendStack.axis = .vertical
        legendStack.spacing = KitchenSpacing.napkin
        legendStack.distribution = .fillEqually
        legendStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(legendStack)
    }

    override func draw(_ rect: CGRect) {
        guard !slices.isEmpty else { return }

        // Chart on the right side
        let chartSize = min(rect.height * 0.7, 120)
        let chartX = rect.maxX - chartSize - 20
        let chartY = rect.midY - chartSize / 2
        let center = CGPoint(x: chartX + chartSize / 2, y: chartY + chartSize / 2)
        let radius = chartSize * 0.4
        let innerRadius = radius * 0.55

        var startAngle: CGFloat = -.pi / 2

        for (kind, percentage) in slices {
            let endAngle = startAngle + CGFloat(percentage * 2 * .pi)

            let path = UIBezierPath()
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.addArc(withCenter: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
            path.close()

            kind.tintColor.setFill()
            path.fill()

            // Add percentage label on slice
            let midAngle = (startAngle + endAngle) / 2
            let labelRadius = (radius + innerRadius) / 2
            let labelX = center.x + cos(midAngle) * labelRadius
            let labelY = center.y + sin(midAngle) * labelRadius
            
            let percentageText = "\(Int(percentage * 100))%"
            let textAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let textSize = percentageText.size(withAttributes: textAttrs)
            percentageText.draw(at: CGPoint(x: labelX - textSize.width / 2, y: labelY - textSize.height / 2), withAttributes: textAttrs)

            startAngle = endAngle
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLegendLayout()
    }

    private func updateLegendLayout() {
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        NSLayoutConstraint.deactivate(legendConstraints)
        legendConstraints.removeAll()

        guard !slices.isEmpty else { return }

        for (kind, percentage) in slices {
            let row = UIView()
            row.translatesAutoresizingMaskIntoConstraints = false

            let indicator = UIView()
            indicator.backgroundColor = kind.tintColor
            indicator.layer.cornerRadius = 6
            indicator.translatesAutoresizingMaskIntoConstraints = false

            let emojiLabel = UILabel()
            emojiLabel.text = kind.emoji
            emojiLabel.font = .systemFont(ofSize: 16)
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false

            let nameLabel = UILabel()
            nameLabel.text = kind.displayLabel
            nameLabel.font = TypographyRecipe.servingBody()
            nameLabel.textColor = SaffronPalette.flour
            nameLabel.translatesAutoresizingMaskIntoConstraints = false

            let percentageLabel = UILabel()
            percentageLabel.text = "\(Int(percentage * 100))%"
            percentageLabel.font = TypographyRecipe.servingBody()
            percentageLabel.textColor = SaffronPalette.honeyComb
            percentageLabel.textAlignment = .right
            percentageLabel.translatesAutoresizingMaskIntoConstraints = false

            row.addSubview(indicator)
            row.addSubview(emojiLabel)
            row.addSubview(nameLabel)
            row.addSubview(percentageLabel)

            NSLayoutConstraint.activate([
                row.heightAnchor.constraint(equalToConstant: 32),

                indicator.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                indicator.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                indicator.widthAnchor.constraint(equalToConstant: 12),
                indicator.heightAnchor.constraint(equalToConstant: 12),

                emojiLabel.leadingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: KitchenSpacing.napkin),
                emojiLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                emojiLabel.widthAnchor.constraint(equalToConstant: 20),

                nameLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: KitchenSpacing.crumb),
                nameLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

                percentageLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                percentageLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                percentageLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: KitchenSpacing.crumb),
            ])

            legendStack.addArrangedSubview(row)
        }

        legendConstraints = [
            legendStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            legendStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            legendStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -140),
        ]
        NSLayoutConstraint.activate(legendConstraints)
    }

    func configure(slices: [(CourseKind, Double)]) {
        self.slices = slices
        setNeedsDisplay()
        setNeedsLayout()
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Top Dishes List View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class TopDishesListView: UIView {

    private let dishesStack = UIStackView()
    private var dishes: [(String, Int)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupList()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupList()
    }

    private func setupList() {
        dishesStack.axis = .vertical
        dishesStack.spacing = KitchenSpacing.napkin
        dishesStack.distribution = .fillEqually
        dishesStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dishesStack)

        NSLayoutConstraint.activate([
            dishesStack.topAnchor.constraint(equalTo: topAnchor, constant: KitchenSpacing.plate),
            dishesStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            dishesStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KitchenSpacing.plate),
            dishesStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -KitchenSpacing.plate),
        ])
    }

    func configure(dishes: [(String, Int)]) {
        self.dishes = dishes
        dishesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard !dishes.isEmpty else { return }

        for (index, (name, count)) in dishes.enumerated() {
            let row = buildDishRow(position: index + 1, name: name, count: count)
            dishesStack.addArrangedSubview(row)
        }
    }

    private func buildDishRow(position: Int, name: String, count: Int) -> UIView {
        let row = UIView()
        row.backgroundColor = SaffronPalette.meringue
        row.layer.cornerRadius = PlatingCorner.biscuit
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 56).isActive = true

        // Position badge
        let positionLabel = UILabel()
        positionLabel.text = "\(position)"
        positionLabel.font = TypographyRecipe.ovenDigit()
        positionLabel.textColor = SaffronPalette.honeyComb
        positionLabel.textAlignment = .left
        positionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Dish name
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = TypographyRecipe.servingBody()
        nameLabel.textColor = SaffronPalette.flour
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Count badge
        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = TypographyRecipe.servingBody()
        countLabel.textColor = SaffronPalette.flour
        countLabel.textAlignment = .right
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(positionLabel)
        row.addSubview(nameLabel)
        row.addSubview(countLabel)

        NSLayoutConstraint.activate([
            positionLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: KitchenSpacing.plate),
            positionLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: positionLabel.trailingAnchor, constant: KitchenSpacing.plate),
            nameLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -KitchenSpacing.plate),

            countLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -KitchenSpacing.plate),
            countLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])

        return row
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Stat Card View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class StatCardView: UIView {

    init(title: String, value: String, icon: String) {
        super.init(frame: .zero)
        setupCard(title: title, value: value, icon: icon)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupCard(title: String, value: String, icon: String) {
        backgroundColor = SaffronPalette.brioche
        layer.cornerRadius = PlatingCorner.biscuit
        applySeasoning(ShadowSeasoning.softGlow)

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = SaffronPalette.honeyComb
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = TypographyRecipe.servingBody()
        titleLabel.textColor = SaffronPalette.steamGrey
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = TypographyRecipe.ovenDigit()
        valueLabel.textColor = SaffronPalette.flour
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KitchenSpacing.plate),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: KitchenSpacing.plate),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -KitchenSpacing.plate),

            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KitchenSpacing.plate),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: KitchenSpacing.plate),

            heightAnchor.constraint(equalToConstant: 64),
        ])
    }
}
