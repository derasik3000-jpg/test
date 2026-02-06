//
//  EchoVaultScreen.swift
//  Travel Budget Tracker
//
//  Tab 3 - Statistics Screen
//

import UIKit

class EchoVaultScreen: UIViewController {
    
    private var avatar: AvatarGlyph
    private var streak: Int = 0
    private var totalBeats: Int = 0
    private var records: [DailyPulseRecord] = []
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    // Hero Section
    private let heroCard = UIView()
    private let avatarView = AvatarComposerView()
    private let streakLabel = UILabel()
    private let totalBeatsLabel = UILabel()
    
    // Stats Grid
    private let statsGrid = UIStackView()
    
    // Insights Section
    private let insightsStack = UIStackView()
    
    init() {
        self.avatar = PulseStorage.shared.loadAvatar()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pulseBackground
        
        setupScrollView()
        setupHeroSection()
        setupStatsGrid()
        setupInsightsSection()
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        refreshAll()
    }
    
    // MARK: - Setup
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .fill
        
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func setupHeroSection() {
        heroCard.backgroundColor = .pulseSurface
        heroCard.layer.cornerRadius = 24
        heroCard.layer.borderWidth = 1
        heroCard.layer.borderColor = UIColor.pulsePrimary.withAlphaComponent(0.3).cgColor
        
        // Share button
        let shareButton = UIButton(type: .system)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .pulsePrimary
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        view.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shareButton.widthAnchor.constraint(equalToConstant: 44),
            shareButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Avatar
        avatarView.delegate = self
        avatarView.configure(with: avatar)
        
        // Streak
        streakLabel.font = .systemFont(ofSize: 48, weight: .bold)
        streakLabel.textColor = .pulsePrimary
        streakLabel.textAlignment = .center
        
        let streakTitleLabel = UILabel()
        streakTitleLabel.text = "Day Streak"
        streakTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        streakTitleLabel.textColor = .pulseTextSecondary
        streakTitleLabel.textAlignment = .center
        
        // Total Spent
        totalBeatsLabel.font = .systemFont(ofSize: 32, weight: .bold)
        totalBeatsLabel.textColor = .pulsePrimary
        totalBeatsLabel.textAlignment = .center
        totalBeatsLabel.adjustsFontSizeToFitWidth = true
        totalBeatsLabel.minimumScaleFactor = 0.5
        totalBeatsLabel.numberOfLines = 1
        
        let beatsTitleLabel = UILabel()
        beatsTitleLabel.text = "Total Spent"
        beatsTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        beatsTitleLabel.textColor = .pulseTextSecondary
        beatsTitleLabel.textAlignment = .center
        
        // Layout - вертикальный стек для лучшего отображения
        let statsStack = UIStackView()
        statsStack.axis = .vertical
        statsStack.spacing = 24
        statsStack.alignment = .fill
        
        // Total Spent Container (главная метрика)
        let spentContainer = UIView()
        spentContainer.addSubview(totalBeatsLabel)
        spentContainer.addSubview(beatsTitleLabel)
        
        totalBeatsLabel.translatesAutoresizingMaskIntoConstraints = false
        beatsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            totalBeatsLabel.topAnchor.constraint(equalTo: spentContainer.topAnchor),
            totalBeatsLabel.leadingAnchor.constraint(equalTo: spentContainer.leadingAnchor, constant: 20),
            totalBeatsLabel.trailingAnchor.constraint(equalTo: spentContainer.trailingAnchor, constant: -20),
            
            beatsTitleLabel.topAnchor.constraint(equalTo: totalBeatsLabel.bottomAnchor, constant: 4),
            beatsTitleLabel.centerXAnchor.constraint(equalTo: spentContainer.centerXAnchor),
            beatsTitleLabel.bottomAnchor.constraint(equalTo: spentContainer.bottomAnchor)
        ])
        
        // Streak Container (вторичная метрика)
        let streakContainer = UIView()
        streakContainer.backgroundColor = .pulsePrimaryLight
        streakContainer.layer.cornerRadius = 16
        
        streakContainer.addSubview(streakLabel)
        streakContainer.addSubview(streakTitleLabel)
        
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        streakTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            streakLabel.topAnchor.constraint(equalTo: streakContainer.topAnchor, constant: 16),
            streakLabel.centerXAnchor.constraint(equalTo: streakContainer.centerXAnchor),
            
            streakTitleLabel.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 4),
            streakTitleLabel.centerXAnchor.constraint(equalTo: streakContainer.centerXAnchor),
            streakTitleLabel.bottomAnchor.constraint(equalTo: streakContainer.bottomAnchor, constant: -16)
        ])
        
        statsStack.addArrangedSubview(spentContainer)
        statsStack.addArrangedSubview(streakContainer)
        
        heroCard.addSubview(avatarView)
        heroCard.addSubview(statsStack)
        
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 32),
            avatarView.centerXAnchor.constraint(equalTo: heroCard.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 120),
            avatarView.heightAnchor.constraint(equalToConstant: 120),
            
            statsStack.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 24),
            statsStack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -20),
            statsStack.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -24)
        ])
        
        contentStack.addArrangedSubview(heroCard)
    }
    
    private func setupStatsGrid() {
        let titleLabel = UILabel()
        titleLabel.text = "Your Patterns"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .pulsePrimary
        
        statsGrid.axis = .vertical
        statsGrid.spacing = 16
        statsGrid.alignment = .fill
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(statsGrid)
    }
    
    private func setupInsightsSection() {
        let titleLabel = UILabel()
        titleLabel.text = "Insights"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .pulsePrimary
        
        insightsStack.axis = .vertical
        insightsStack.spacing = 12
        insightsStack.alignment = .fill
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(insightsStack)
    }
    
    // MARK: - Data
    
    private func loadData() {
        records = PulseStorage.shared.loadAllRecords()
        streak = PulseStorage.shared.calculateStreak()
        totalBeats = records.reduce(0) { $0 + $1.beats.count }
        avatar = PulseStorage.shared.loadAvatar()
    }
    
    private var totalSpent: Double {
        return records.reduce(0) { $0 + $1.totalAmount }
    }
    
    private func refreshAll() {
        avatarView.configure(with: avatar)
        streakLabel.text = "\(streak)"
        
        // Форматируем сумму: если копейки = 0, показываем без них
        if totalSpent.truncatingRemainder(dividingBy: 1) == 0 {
            totalBeatsLabel.text = String(format: "$%.0f", totalSpent)
        } else {
            totalBeatsLabel.text = String(format: "$%.2f", totalSpent)
        }
        
        refreshStatsGrid()
        refreshInsights()
    }
    
    private func refreshStatsGrid() {
        statsGrid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Row 1: Energy Pattern + Mood Balance
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 16
        row1.distribution = .fillEqually
        
        row1.addArrangedSubview(createEnergyPatternCard())
        row1.addArrangedSubview(createMoodBalanceCard())
        
        // Row 2: Best Day + Consistency
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 16
        row2.distribution = .fillEqually
        
        row2.addArrangedSubview(createBestDayCard())
        row2.addArrangedSubview(createConsistencyCard())
        
        statsGrid.addArrangedSubview(row1)
        statsGrid.addArrangedSubview(row2)
    }
    
    private func createEnergyPatternCard() -> UIView {
        let card = PulseSurface(style: .card)
        
        let iconLabel = UILabel()
        iconLabel.text = "⚡️"
        iconLabel.font = .systemFont(ofSize: 40)
        
        let titleLabel = UILabel()
        titleLabel.text = "Energy Pattern"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        let archetype = ResourceSignature.detectArchetype(from: records)
        let valueLabel = UILabel()
        valueLabel.text = archetype.displayName
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = .pulsePrimary
        valueLabel.numberOfLines = 0
        
        card.addSubview(iconLabel)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            valueLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(energyPatternTapped))
        card.addGestureRecognizer(tapGesture)
        
        return card
    }
    
    private func createMoodBalanceCard() -> UIView {
        let card = PulseSurface(style: .card)
        
        let iconLabel = UILabel()
        iconLabel.text = "🎭"
        iconLabel.font = .systemFont(ofSize: 40)
        
        let titleLabel = UILabel()
        titleLabel.text = "Mood Balance"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        // Calculate dominant feeling
        let allBeats = records.flatMap { $0.beats }
        let cheapCount = allBeats.filter { $0.mood == .cheap }.count
        let normalCount = allBeats.filter { $0.mood == .normal }.count
        let expensiveCount = allBeats.filter { $0.mood == .expensive }.count
        
        var dominantMood = "Balanced"
        if cheapCount > normalCount && cheapCount > expensiveCount {
            dominantMood = "💵 Cheap"
        } else if expensiveCount > normalCount && expensiveCount > cheapCount {
            dominantMood = "💸 Expensive"
        } else if normalCount > cheapCount && normalCount > expensiveCount {
            dominantMood = "💰 Normal"
        }
        
        let valueLabel = UILabel()
        valueLabel.text = dominantMood
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = .pulsePrimary
        
        card.addSubview(iconLabel)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            valueLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(moodBalanceTapped))
        card.addGestureRecognizer(tapGesture)
        
        return card
    }
    
    private func createBestDayCard() -> UIView {
        let card = PulseSurface(style: .card)
        
        let iconLabel = UILabel()
        iconLabel.text = "⭐️"
        iconLabel.font = .systemFont(ofSize: 40)
        
        let titleLabel = UILabel()
        titleLabel.text = "Best Day"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        let bestDay = records.max(by: { $0.beats.count < $1.beats.count })
        let valueLabel = UILabel()
        if let day = bestDay {
            valueLabel.text = "\(day.beats.count) beats"
        } else {
            valueLabel.text = "No data"
        }
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = .pulsePrimary
        
        card.addSubview(iconLabel)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            valueLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bestDayTapped))
        card.addGestureRecognizer(tapGesture)
        
        return card
    }
    
    private func createConsistencyCard() -> UIView {
        let card = PulseSurface(style: .card)
        
        let iconLabel = UILabel()
        iconLabel.text = "📊"
        iconLabel.font = .systemFont(ofSize: 40)
        
        let titleLabel = UILabel()
        titleLabel.text = "Consistency"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        let activeDays = records.filter { !$0.beats.isEmpty }.count
        let totalDays = records.count
        let percentage = totalDays > 0 ? Int((Double(activeDays) / Double(totalDays)) * 100) : 0
        
        let valueLabel = UILabel()
        valueLabel.text = "\(percentage)%"
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = .pulsePrimary
        
        card.addSubview(iconLabel)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            valueLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(consistencyTapped))
        card.addGestureRecognizer(tapGesture)
        
        return card
    }
    
    private func refreshInsights() {
        insightsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Trip Budget Card
        insightsStack.addArrangedSubview(createBudgetCard())
        
        // Quiet Wins
        let wins = detectQuietWins()
        if !wins.isEmpty {
            for win in wins.prefix(3) {
                insightsStack.addArrangedSubview(createInsightCard(
                    icon: win.type.emoji,
                    title: win.title,
                    subtitle: formatDate(win.date)
                ))
            }
        }
        
        // Average daily spending
        let avgDaily = totalSpent / Double(max(records.filter { !$0.beats.isEmpty }.count, 1))
        insightsStack.addArrangedSubview(createInsightCard(
            icon: "📈",
            title: "Daily Average",
            subtitle: String(format: "$%.2f per day", avgDaily)
        ))
    }
    
    private func detectQuietWins() -> [QuietWin] {
        var wins: [QuietWin] = []
        
        for (index, record) in records.enumerated() {
            if index > 0 {
                let prevRecord = records[index - 1]
                if record.beats.count > prevRecord.beats.count + 3 {
                wins.append(QuietWin(title: "Big jump in activity", type: .consistency))
                }
            }
            
            if record.beats.count >= 10 {
                wins.append(QuietWin(title: "High engagement day", type: .consistency))
            }
            
            let cheapBeats = record.beats.filter { $0.mood == .cheap }.count
            if cheapBeats > record.beats.count / 2 && record.beats.count >= 5 {
                wins.append(QuietWin(title: "Great deals day", type: .calmStreak))
            }
        }
        
        return Array(wins.sorted { $0.date > $1.date }.prefix(5))
    }
    
    private func createInsightCard(icon: String, title: String, subtitle: String) -> UIView {
        let card = PulseSurface(style: .card)
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 28)
        iconLabel.setContentHuggingPriority(.required, for: .horizontal)
        iconLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .pulseTextSecondary
        
        card.addSubview(iconLabel)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        
        return card
    }
    
    private func createBudgetCard() -> UIView {
        let card = PulseSurface(style: .card)
        
        guard let budget = PulseStorage.shared.loadTripBudget() else {
            // Нет бюджета - показываем кнопку установки
            let iconLabel = UILabel()
            iconLabel.text = "💰"
            iconLabel.font = .systemFont(ofSize: 28)
            iconLabel.setContentHuggingPriority(.required, for: .horizontal)
            iconLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            let titleLabel = UILabel()
            titleLabel.text = "Set Trip Budget"
            titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            titleLabel.textColor = .pulsePrimary
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = "Track your spending against a budget"
            subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
            subtitleLabel.textColor = .pulseTextSecondary
            
            card.addSubview(iconLabel)
            card.addSubview(titleLabel)
            card.addSubview(subtitleLabel)
            
            iconLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                
                titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
                titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                subtitleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
            ])
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(budgetCardTapped))
            card.addGestureRecognizer(tapGesture)
            
            return card
        }
        
        // Есть бюджет - показываем прогресс
        let remaining = budget.totalAmount - totalSpent
        let progress = min(totalSpent / budget.totalAmount, 1.0)
        let spentPercent = Int(progress * 100)
        
        let iconLabel = UILabel()
        iconLabel.text = "💰"
        iconLabel.font = .systemFont(ofSize: 28)
        iconLabel.setContentHuggingPriority(.required, for: .horizontal)
        iconLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let titleLabel = UILabel()
        titleLabel.text = budget.tripName
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        titleLabel.numberOfLines = 1
        
        let amountLabel = UILabel()
        if remaining >= 0 {
            amountLabel.text = String(format: "$%.0f left", remaining)
            amountLabel.textColor = remaining < budget.totalAmount * 0.2 ? UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1.0) : .pulsePrimary
        } else {
            amountLabel.text = String(format: "$%.0f over!", abs(remaining))
            amountLabel.textColor = .pulseIntense
        }
        amountLabel.font = .systemFont(ofSize: 14, weight: .bold)
        amountLabel.numberOfLines = 1
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = String(format: "Spent: $%.0f / $%.0f (%d%%)", totalSpent, budget.totalAmount, spentPercent)
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .pulseTextSecondary
        subtitleLabel.numberOfLines = 1
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.8
        
        // Progress bar
        let progressView = UIProgressView()
        progressView.progress = Float(progress)
        progressView.progressTintColor = remaining < 0 ? .pulseIntense : (remaining < budget.totalAmount * 0.2 ? UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1.0) : .pulsePrimary)
        progressView.trackTintColor = .pulsePrimaryLight
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        card.addSubview(iconLabel)
        card.addSubview(titleLabel)
        card.addSubview(amountLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(progressView)
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            amountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            amountLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            progressView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            progressView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            progressView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(budgetCardTapped))
        card.addGestureRecognizer(tapGesture)
        
        return card
    }
    
    @objc private func budgetCardTapped() {
        PulseHaptics.selection()
        
        let currentBudget = PulseStorage.shared.loadTripBudget()
        
        let alert = UIAlertController(
            title: currentBudget == nil ? "Set Trip Budget" : "Edit Trip Budget",
            message: "Enter your total budget for this trip",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Amount (e.g., 1000)"
            textField.keyboardType = .decimalPad
            if let budget = currentBudget {
                textField.text = String(format: "%.0f", budget.totalAmount)
            }
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Trip name (optional)"
            textField.autocapitalizationType = .words
            if let budget = currentBudget {
                textField.text = budget.tripName
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if currentBudget != nil {
            alert.addAction(UIAlertAction(title: "Start New Trip", style: .default) { _ in
                self.showStartNewTripConfirmation()
            })
            
            alert.addAction(UIAlertAction(title: "Delete Budget", style: .destructive) { _ in
                PulseStorage.shared.deleteTripBudget()
                self.refreshInsights()
                PulseHaptics.success()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let amountText = alert.textFields?[0].text,
                  let amount = Double(amountText),
                  amount > 0 else {
                let errorAlert = UIAlertController(
                    title: "Invalid Amount",
                    message: "Please enter a valid budget amount",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }
            
            let tripName = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces) ?? "My Trip"
            let budget = TripBudget(totalAmount: amount, tripName: tripName.isEmpty ? "My Trip" : tripName)
            PulseStorage.shared.saveTripBudget(budget)
            self.refreshInsights()
            PulseHaptics.success()
        })
        
        present(alert, animated: true)
    }
    
    private func showStartNewTripConfirmation() {
        let alert = UIAlertController(
            title: "Start New Trip?",
            message: "This will clear all expenses and start fresh. Your old data will be permanently deleted. This cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Start New Trip", style: .destructive) { _ in
            self.startNewTrip()
        })
        
        present(alert, animated: true)
    }
    
    private func startNewTrip() {
        // Удаляем все записи о тратах
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordsURL = documentsURL.appendingPathComponent("pulse_records.json")
        
        try? fileManager.removeItem(at: recordsURL)
        
        // Перезагружаем данные
        loadData()
        refreshAll()
        
        PulseHaptics.success()
        
        let successAlert = UIAlertController(
            title: "New Trip Started!",
            message: "All expenses cleared. Ready to track your new adventure!",
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(successAlert, animated: true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // MARK: - Actions
    
    @objc private func shareTapped() {
        PulseHaptics.selection()
        
        // Create share text
        let archetype = ResourceSignature.detectArchetype(from: records)
        let allBeats = records.flatMap { $0.beats }
        let cheapCount = allBeats.filter { $0.mood == .cheap }.count
        let normalCount = allBeats.filter { $0.mood == .normal }.count
        let expensiveCount = allBeats.filter { $0.mood == .expensive }.count
        
        var dominantMood = "Balanced"
        if cheapCount > normalCount && cheapCount > expensiveCount {
            dominantMood = "Cheap 💵"
        } else if expensiveCount > normalCount && expensiveCount > cheapCount {
            dominantMood = "Expensive 💸"
        } else if normalCount > cheapCount && normalCount > expensiveCount {
            dominantMood = "Normal 💰"
        }
        
        let activeDays = records.filter { !$0.beats.isEmpty }.count
        let totalDays = records.count
        let consistency = totalDays > 0 ? Int((Double(activeDays) / Double(totalDays)) * 100) : 0
        
        let shareText = """
        My PULSE Stats ✨
        
        🔥 Streak: \(streak) days
        📊 Total Beats: \(totalBeats)
        ⚡️ Energy Pattern: \(archetype.displayName)
        🎭 Mood Balance: \(dominantMood)
        📈 Consistency: \(consistency)%
        
        Track your energy with PULSE
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
    
    @objc private func energyPatternTapped() {
        PulseHaptics.selection()
        
        let archetype = ResourceSignature.detectArchetype(from: records)
        
        let alert = UIAlertController(
            title: archetype.displayName,
            message: "\(archetype.description)\n\n💡 \(archetype.insight)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func moodBalanceTapped() {
        PulseHaptics.selection()
        
        let allBeats = records.flatMap { $0.beats }
        let cheapCount = allBeats.filter { $0.mood == .cheap }.count
        let normalCount = allBeats.filter { $0.mood == .normal }.count
        let expensiveCount = allBeats.filter { $0.mood == .expensive }.count
        let total = allBeats.count
        
        guard total > 0 else {
            let alert = UIAlertController(
                title: "Feeling Balance",
                message: "Start tracking expenses to see your feeling balance",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let cheapPercent = Int((Double(cheapCount) / Double(total)) * 100)
        let normalPercent = Int((Double(normalCount) / Double(total)) * 100)
        let expensivePercent = Int((Double(expensiveCount) / Double(total)) * 100)
        
        let message = """
        Your price perception:
        
        💵 Cheap: \(cheapPercent)% (\(cheapCount) expenses)
        💰 Normal: \(normalPercent)% (\(normalCount) expenses)
        💸 Expensive: \(expensivePercent)% (\(expensiveCount) expenses)
        
        Total: \(total) expenses tracked
        """
        
        let alert = UIAlertController(
            title: "Feeling Balance",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func bestDayTapped() {
        PulseHaptics.selection()
        
        guard let bestDay = records.max(by: { $0.beats.count < $1.beats.count }), !bestDay.beats.isEmpty else {
            let alert = UIAlertController(
                title: "Best Day",
                message: "Start tracking beats to see your best day",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: bestDay.date)
        
        let cheapCount = bestDay.beats.filter { $0.mood == .cheap }.count
        let normalCount = bestDay.beats.filter { $0.mood == .normal }.count
        let expensiveCount = bestDay.beats.filter { $0.mood == .expensive }.count
        
        let message = """
        Your biggest spending day was \(dateStr)
        
        Total: $\(String(format: "%.2f", bestDay.totalAmount)) (\(bestDay.beats.count) expenses)
        💵 Cheap: \(cheapCount)
        💰 Normal: \(normalCount)
        💸 Expensive: \(expensiveCount)
        """
        
        let alert = UIAlertController(
            title: "Best Day",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "View Day", style: .default) { _ in
            // Open day detail
            let detailVC = DayDetailScreen(record: bestDay)
            let navController = UINavigationController(rootViewController: detailVC)
            navController.modalPresentationStyle = .pageSheet
            
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(navController, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func consistencyTapped() {
        PulseHaptics.selection()
        
        let activeDays = records.filter { !$0.beats.isEmpty }.count
        let totalDays = records.count
        
        guard totalDays > 0 else {
            let alert = UIAlertController(
                title: "Consistency",
                message: "Start tracking beats to see your consistency",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let percentage = Int((Double(activeDays) / Double(totalDays)) * 100)
        let inactiveDays = totalDays - activeDays
        
        var insight = ""
        if percentage >= 80 {
            insight = "🌟 Excellent! You're very consistent"
        } else if percentage >= 60 {
            insight = "👍 Good consistency, keep it up!"
        } else if percentage >= 40 {
            insight = "💪 Building momentum, stay focused"
        } else {
            insight = "🌱 Every journey starts somewhere"
        }
        
        let message = """
        You've been active \(activeDays) out of \(totalDays) days
        
        Active days: \(activeDays)
        Inactive days: \(inactiveDays)
        Consistency rate: \(percentage)%
        
        \(insight)
        """
        
        let alert = UIAlertController(
            title: "Consistency",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }
    
}

// MARK: - AvatarComposerDelegate

extension EchoVaultScreen: AvatarComposerDelegate {
    func avatarDidChange(_ newAvatar: AvatarGlyph) {
        avatar = newAvatar
        PulseStorage.shared.saveAvatar(newAvatar)
        PulseHaptics.success()
    }
}
