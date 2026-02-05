//
//  BarnDashboardViewController.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class BarnDashboardViewController: UIViewController {
    
    private let storageManager = BarnStorageManager.shared
    private var farmerProfile: FarmerProfile!
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = FarmSpacing.plotMargin
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let profileCard: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.darkCard
        view.layer.cornerRadius = FarmRadius.barn
        view.layer.shadowColor = FarmPalette.cropShadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 60)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.barn
        label.textColor = FarmPalette.goldenHarvest
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.harvest
        label.textColor = FarmPalette.morningMist
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streakCard: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.darkCard
        view.layer.cornerRadius = FarmRadius.crop
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.silo
        label.textColor = FarmPalette.goldenHarvest
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streakDescLabel: UILabel = {
        let label = UILabel()
        label.text = "Day Streak 🔥"
        label.font = FarmTypography.crop
        label.textColor = FarmPalette.morningMist
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = FarmSpacing.rowSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let achievementsHeader: UILabel = {
        let label = UILabel()
        label.text = "🏆 Achievements"
        label.font = FarmTypography.barn
        label.textColor = FarmPalette.goldenHarvest
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let achievementsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = FarmSpacing.rowSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dashboard"
        navigationController?.setNavigationBarHidden(false, animated: false)
        loadData()
        setupUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        loadData()
        updateUI()
        updateAchievements()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = FarmPalette.richSoil
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        // Profile Card
        profileCard.addSubview(avatarLabel)
        profileCard.addSubview(nameLabel)
        profileCard.addSubview(levelLabel)
        
        NSLayoutConstraint.activate([
            avatarLabel.topAnchor.constraint(equalTo: profileCard.topAnchor, constant: FarmSpacing.fieldPadding),
            avatarLabel.centerXAnchor.constraint(equalTo: profileCard.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatarLabel.bottomAnchor, constant: FarmSpacing.rowSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: FarmSpacing.plotMargin),
            nameLabel.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -FarmSpacing.plotMargin),
            
            levelLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: FarmSpacing.seedGap),
            levelLabel.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: FarmSpacing.plotMargin),
            levelLabel.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -FarmSpacing.plotMargin),
            levelLabel.bottomAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: -FarmSpacing.fieldPadding),
            
            profileCard.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Streak Card
        streakCard.addSubview(streakLabel)
        streakCard.addSubview(streakDescLabel)
        
        NSLayoutConstraint.activate([
            streakLabel.topAnchor.constraint(equalTo: streakCard.topAnchor, constant: FarmSpacing.plotMargin),
            streakLabel.centerXAnchor.constraint(equalTo: streakCard.centerXAnchor),
            
            streakDescLabel.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: FarmSpacing.furrow),
            streakDescLabel.centerXAnchor.constraint(equalTo: streakCard.centerXAnchor),
            streakDescLabel.bottomAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: -FarmSpacing.plotMargin),
            
            streakCard.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Add to stack
        contentStack.addArrangedSubview(profileCard)
        contentStack.addArrangedSubview(streakCard)
        contentStack.addArrangedSubview(statsStack)
        contentStack.addArrangedSubview(achievementsHeader)
        contentStack.addArrangedSubview(achievementsStack)
        
        setupStatsCards()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: FarmSpacing.plotMargin),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: FarmSpacing.plotMargin),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -FarmSpacing.plotMargin),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -FarmSpacing.plotMargin),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -FarmSpacing.plotMargin * 2)
        ])
    }
    
    private func setupStatsCards() {
        let totalWater = createStatCard(emoji: "💧", value: "\(Int(storageManager.getTotalWaterUsed()))L", label: "Water Used")
        let totalSessions = createStatCard(emoji: "📅", value: "\(storageManager.getTotalSessions())", label: "Sessions")
        let activePlots = createStatCard(emoji: "🌾", value: "\(storageManager.getActivePlotsCount())", label: "Fields")
        
        statsStack.addArrangedSubview(totalWater)
        statsStack.addArrangedSubview(totalSessions)
        statsStack.addArrangedSubview(activePlots)
    }
    
    private func createStatCard(emoji: String, value: String, label: String) -> UIView {
        let card = UIView()
        card.backgroundColor = FarmPalette.darkCard
        card.layer.cornerRadius = FarmRadius.crop
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 30)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = FarmTypography.barn
        valueLabel.textColor = FarmPalette.goldenHarvest
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descLabel = UILabel()
        descLabel.text = label
        descLabel.font = FarmTypography.seedling
        descLabel.textColor = FarmPalette.morningMist
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(emojiLabel)
        card.addSubview(valueLabel)
        card.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: FarmSpacing.rowSpacing),
            emojiLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: FarmSpacing.seedGap),
            valueLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            
            descLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: FarmSpacing.furrow),
            descLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            descLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -FarmSpacing.rowSpacing),
            
            card.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return card
    }
    
    private func updateAchievements() {
        // Clear existing achievements
        achievementsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let totalSessions = storageManager.getTotalSessions()
        let totalWater = storageManager.getTotalWaterUsed()
        let activePlots = storageManager.getActivePlotsCount()
        let archivedPlots = storageManager.loadArchivedPlots().count
        
        let defaultAchievements = [
            Achievement(title: "First Harvest", description: "Log your first watering session", emoji: "🌱", isUnlocked: totalSessions > 0),
            Achievement(title: "Field Master", description: "Manage 5 irrigation plots", emoji: "🏆", isUnlocked: activePlots >= 5),
            Achievement(title: "Water Warrior", description: "Use 1000L of water", emoji: "💪", isUnlocked: totalWater >= 1000),
            Achievement(title: "Streak Champion", description: "Maintain a 7-day streak", emoji: "🔥", isUnlocked: farmerProfile.currentStreak >= 7),
            Achievement(title: "Dedicated Farmer", description: "Log 10 watering sessions", emoji: "📅", isUnlocked: totalSessions >= 10),
            Achievement(title: "Water Expert", description: "Use 5000L of water", emoji: "💧", isUnlocked: totalWater >= 5000),
            Achievement(title: "Field Collector", description: "Manage 10 irrigation plots", emoji: "🌾", isUnlocked: activePlots >= 10),
            Achievement(title: "Perfect Week", description: "Maintain a 7-day streak", emoji: "⭐", isUnlocked: farmerProfile.currentStreak >= 7),
            Achievement(title: "Harvest Complete", description: "Archive your first field", emoji: "✅", isUnlocked: archivedPlots > 0),
            Achievement(title: "Consistent Care", description: "Log 50 watering sessions", emoji: "🎯", isUnlocked: totalSessions >= 50),
            Achievement(title: "Water Master", description: "Use 10000L of water", emoji: "🌊", isUnlocked: totalWater >= 10000),
            Achievement(title: "Legendary Streak", description: "Maintain a 30-day streak", emoji: "👑", isUnlocked: farmerProfile.currentStreak >= 30)
        ]
        
        for achievement in defaultAchievements {
            let achievementView = createAchievementView(achievement)
            achievementsStack.addArrangedSubview(achievementView)
        }
    }
    
    private func createAchievementView(_ achievement: Achievement) -> UIView {
        let container = UIView()
        container.backgroundColor = achievement.isUnlocked ? FarmPalette.goldenHarvest : FarmPalette.darkCard
        container.layer.cornerRadius = FarmRadius.crop
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let emojiLabel = UILabel()
        emojiLabel.text = achievement.emoji
        emojiLabel.font = .systemFont(ofSize: 40)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = achievement.title
        titleLabel.font = FarmTypography.harvest
        titleLabel.textColor = achievement.isUnlocked ? FarmPalette.richSoil : FarmPalette.goldenHarvest
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descLabel = UILabel()
        descLabel.text = achievement.description
        descLabel.font = FarmTypography.crop
        descLabel.textColor = achievement.isUnlocked ? FarmPalette.richSoil : FarmPalette.morningMist
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let statusLabel = UILabel()
        statusLabel.text = achievement.isUnlocked ? "✅ Unlocked" : "🔒 Locked"
        statusLabel.font = FarmTypography.seedling
        statusLabel.textColor = achievement.isUnlocked ? FarmPalette.richSoil : FarmPalette.dustyField
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(emojiLabel)
        container.addSubview(titleLabel)
        container.addSubview(descLabel)
        container.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: FarmSpacing.plotMargin),
            emojiLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: FarmSpacing.rowSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: FarmSpacing.rowSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -FarmSpacing.seedGap),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: FarmSpacing.furrow),
            descLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: FarmSpacing.rowSpacing),
            descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -FarmSpacing.plotMargin),
            descLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -FarmSpacing.rowSpacing),
            
            statusLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -FarmSpacing.plotMargin),
            statusLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        return container
    }
    
    private func loadData() {
        farmerProfile = storageManager.loadFarmerProfile()
    }
    
    private func updateUI() {
        avatarLabel.text = farmerProfile.avatarEmoji
        nameLabel.text = farmerProfile.farmerName
        levelLabel.text = "Level \(farmerProfile.level) • \(farmerProfile.experiencePoints) XP"
        streakLabel.text = "\(farmerProfile.currentStreak)"
        
        // Update stats
        if let totalWaterStat = statsStack.arrangedSubviews.first as? UIView {
            updateStatCard(totalWaterStat, value: "\(Int(storageManager.getTotalWaterUsed()))L")
        }
        if statsStack.arrangedSubviews.count > 1, let sessionsStat = statsStack.arrangedSubviews[1] as? UIView {
            updateStatCard(sessionsStat, value: "\(storageManager.getTotalSessions())")
        }
        if statsStack.arrangedSubviews.count > 2, let plotsStat = statsStack.arrangedSubviews[2] as? UIView {
            updateStatCard(plotsStat, value: "\(storageManager.getActivePlotsCount())")
        }
    }
    
    private func updateStatCard(_ card: UIView, value: String) {
        for subview in card.subviews {
            if let label = subview as? UILabel, label.font == FarmTypography.barn {
                label.text = value
                break
            }
        }
    }
}
