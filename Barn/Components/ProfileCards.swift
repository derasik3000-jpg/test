//
//  ProfileCards.swift
//  DAYTRACE
//
//  Enhanced profile components with gradients and rich data
//

import UIKit

// MARK: - Profile Header Card

final class ProfileHeaderCard: UIView {
    
    var onAvatarTapped: (() -> Void)?
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1.0).cgColor,  // Purple
            UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0).cgColor   // Pink
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 20
        return gradient
    }()
    
    private let avatarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .systemFont(ofSize: 64)
        btn.backgroundColor = ColorPalette.background.withAlphaComponent(0.2)
        btn.layer.cornerRadius = 50
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Journey"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 20
        layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(avatarButton)
        addSubview(nameLabel)
        addSubview(daysLabel)
        
        avatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 200),
            
            avatarButton.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            avatarButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarButton.widthAnchor.constraint(equalToConstant: 100),
            avatarButton.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: avatarButton.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            daysLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            daysLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func configure(avatar: UserAvatar, totalDays: Int) {
        avatarButton.setTitle(avatar.emoji, for: .normal)
        daysLabel.text = "📅 \(totalDays) days tracked"
    }
    
    @objc private func avatarTapped() {
        AnimationKit.springScale(view: avatarButton)
        onAvatarTapped?()
    }
}

// MARK: - Stats Grid View

final class StatsGridView: UIView {
    
    private let gridStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let totalActionsCard = ProfileStatCard(title: "Total Actions", icon: "checkmark.circle.fill", gradientColors: [
        UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0).cgColor,
        UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0).cgColor
    ])
    
    private let completedCard = ProfileStatCard(title: "Completed", icon: "star.fill", gradientColors: [
        UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0).cgColor,
        UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 1.0).cgColor
    ])
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(gridStack)
        gridStack.addArrangedSubview(totalActionsCard)
        gridStack.addArrangedSubview(completedCard)
        
        NSLayoutConstraint.activate([
            gridStack.topAnchor.constraint(equalTo: topAnchor),
            gridStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            gridStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            gridStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            gridStack.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
    
    func updateWithTraces(_ traces: [DailyTrace]) {
        let totalActions = traces.reduce(0) { $0 + $1.actions.count }
        let completed = traces.reduce(0) { $0 + $1.actions.filter { $0.state == .done }.count }
        
        totalActionsCard.setValue("\(totalActions)")
        completedCard.setValue("\(completed)")
    }
}

// MARK: - Profile Stat Card

final class ProfileStatCard: UIView {
    
    private let gradientLayer: CAGradientLayer
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .heavy)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.9)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(title: String, icon: String, gradientColors: [CGColor]) {
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer.colors = gradientColors
        self.gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        self.gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.gradientLayer.cornerRadius = 16
        
        super.init(frame: .zero)
        
        titleLabel.text = title
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(iconView)
        addSubview(valueLabel)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            valueLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -2),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
        
        // Animate value change
        UIView.transition(with: valueLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.valueLabel.text = value
        }
    }
}

// MARK: - Category Breakdown Card

final class CategoryBreakdownCard: UIView {
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 16
        return gradient
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Categories"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoriesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(titleLabel)
        addSubview(categoriesStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            categoriesStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            categoriesStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            categoriesStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            categoriesStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func updateWithTraces(_ traces: [DailyTrace]) {
        categoriesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if traces.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No data yet"
            emptyLabel.font = .systemFont(ofSize: 14)
            emptyLabel.textColor = .white.withAlphaComponent(0.7)
            categoriesStack.addArrangedSubview(emptyLabel)
            return
        }
        
        // Count actions by category
        var categoryCounts: [ActionCategory: Int] = [:]
        for trace in traces {
            for action in trace.actions {
                categoryCounts[action.category, default: 0] += 1
            }
        }
        
        // Sort by count
        let sorted = categoryCounts.sorted { $0.value > $1.value }.prefix(5)
        
        for (category, count) in sorted {
            let row = CategoryRow()
            row.configure(category: category, count: count)
            categoriesStack.addArrangedSubview(row)
        }
    }
}

// MARK: - Category Row

final class CategoryRow: UIView {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let progressFill: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var progressWidthConstraint: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(emojiLabel)
        addSubview(nameLabel)
        addSubview(countLabel)
        addSubview(progressBar)
        progressBar.addSubview(progressFill)
        
        progressWidthConstraint = progressFill.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),
            
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            
            progressFill.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressBar.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBar.bottomAnchor),
            progressWidthConstraint
        ])
    }
    
    func configure(category: ActionCategory, count: Int, maxCount: Int = 100) {
        emojiLabel.text = category.emoji
        nameLabel.text = category.rawValue
        countLabel.text = "\(count)"
        
        let progress = min(CGFloat(count) / CGFloat(maxCount), 1.0)
        progressWidthConstraint.constant = progress * bounds.width
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Achievements Card

final class AchievementsCard: UIView {
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0).cgColor,
            UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 16
        return gradient
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🏆 Achievements"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let achievementsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(titleLabel)
        addSubview(achievementsStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            achievementsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            achievementsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            achievementsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            achievementsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func updateWithTraces(_ traces: [DailyTrace]) {
        achievementsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let totalActions = traces.reduce(0) { $0 + $1.actions.count }
        let completed = traces.reduce(0) { $0 + $1.actions.filter { $0.state == .done }.count }
        let streak = calculateStreak(traces: traces)
        
        // Achievement badges
        let achievements: [(String, String, Bool)] = [
            ("🌟", "First Action", totalActions >= 1),
            ("💪", "10 Actions", totalActions >= 10),
            ("🔥", "3 Day Streak", streak >= 3),
            ("⚡️", "7 Day Streak", streak >= 7),
            ("🏆", "50 Completed", completed >= 50)
        ]
        
        for (emoji, title, unlocked) in achievements {
            let badge = AchievementBadge()
            badge.configure(emoji: emoji, title: title, unlocked: unlocked)
            achievementsStack.addArrangedSubview(badge)
        }
    }
    
    private func calculateStreak(traces: [DailyTrace]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        for _ in 0..<30 {
            if traces.contains(where: { calendar.isDate($0.date, inSameDayAs: currentDate) && !$0.actions.isEmpty }) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Achievement Badge

final class AchievementBadge: UIView {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lockIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let iv = UIImageView()
        iv.image = UIImage(systemName: "lock.fill", withConfiguration: config)
        iv.tintColor = .white.withAlphaComponent(0.5)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white.withAlphaComponent(0.1)
        layer.cornerRadius = 12
        
        addSubview(emojiLabel)
        addSubview(titleLabel)
        addSubview(lockIcon)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
            
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            lockIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            lockIcon.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(emoji: String, title: String, unlocked: Bool) {
        emojiLabel.text = emoji
        titleLabel.text = title
        
        if unlocked {
            emojiLabel.alpha = 1.0
            titleLabel.alpha = 1.0
            lockIcon.isHidden = true
            backgroundColor = .white.withAlphaComponent(0.2)
        } else {
            emojiLabel.alpha = 0.3
            titleLabel.alpha = 0.5
            lockIcon.isHidden = false
            backgroundColor = .white.withAlphaComponent(0.05)
        }
    }
}

// MARK: - Insights Card

final class InsightsCard: UIView {
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 16
        return gradient
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "💡 Insights"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let insightsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(titleLabel)
        addSubview(insightsStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            insightsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            insightsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            insightsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            insightsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func updateWithTraces(_ traces: [DailyTrace]) {
        insightsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if traces.isEmpty {
            addInsight(icon: "✨", text: "Start tracking to see insights")
            return
        }
        
        // Calculate insights
        let totalActions = traces.reduce(0) { $0 + $1.actions.count }
        let completed = traces.reduce(0) { $0 + $1.actions.filter { $0.state == .done }.count }
        let completionRate = totalActions > 0 ? Int((Double(completed) / Double(totalActions)) * 100) : 0
        
        // Most productive day of week
        var dayOfWeekCounts: [Int: Int] = [:]
        for trace in traces {
            let dayOfWeek = Calendar.current.component(.weekday, from: trace.date)
            dayOfWeekCounts[dayOfWeek, default: 0] += trace.actions.filter { $0.state == .done }.count
        }
        
        if let mostProductiveDay = dayOfWeekCounts.max(by: { $0.value < $1.value }) {
            let dayName = Calendar.current.weekdaySymbols[mostProductiveDay.key - 1]
            addInsight(icon: "📅", text: "Most productive on \(dayName)s")
        }
        
        // Completion rate
        addInsight(icon: "✅", text: "You complete \(completionRate)% of your actions")
        
        // Most used category
        var categoryCounts: [ActionCategory: Int] = [:]
        for trace in traces {
            for action in trace.actions {
                categoryCounts[action.category, default: 0] += 1
            }
        }
        if let topCategory = categoryCounts.max(by: { $0.value < $1.value }) {
            addInsight(icon: topCategory.key.emoji, text: "You focus most on \(topCategory.key.rawValue)")
        }
    }
    
    private func addInsight(icon: String, text: String) {
        let row = InsightRow()
        row.configure(icon: icon, text: text)
        insightsStack.addArrangedSubview(row)
    }
}

// MARK: - Insight Row

final class InsightRow: UIView {
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconLabel)
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconLabel.topAnchor.constraint(equalTo: topAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 28),
            
            textLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(icon: String, text: String) {
        iconLabel.text = icon
        textLabel.text = text
    }
}
