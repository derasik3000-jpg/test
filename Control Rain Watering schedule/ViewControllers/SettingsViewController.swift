//
//  SettingsViewController.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    private let storageManager = BarnStorageManager.shared
    private var farmerProfile: FarmerProfile!
    
    private let avatarEmojis = ["👨‍🌾", "👩‍🌾", "🧑‍🌾", "🌾", "🚜", "🐄", "🐓", "🐷", "🌻", "🌽", "🥕", "🍅"]
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = FarmSpacing.barnGap
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let profileSection: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.darkCard
        view.layer.cornerRadius = FarmRadius.barn
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 60)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameTextField: UITextField = {
        let field = UITextField()
        field.font = FarmTypography.barn
        field.textColor = FarmPalette.richSoil
        field.textAlignment = .center
        field.backgroundColor = FarmPalette.morningMist
        field.layer.borderWidth = 1
        field.layer.borderColor = FarmPalette.goldenHarvest.cgColor
        field.layer.cornerRadius = FarmRadius.crop
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let statisticsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📊 View Detailed Statistics", for: .normal)
        button.titleLabel?.font = FarmTypography.harvest
        button.backgroundColor = FarmPalette.goldenHarvest
        button.setTitleColor(FarmPalette.richSoil, for: .normal)
        button.layer.cornerRadius = FarmRadius.crop
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let exportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📤 Export Data", for: .normal)
        button.titleLabel?.font = FarmTypography.harvest
        button.backgroundColor = FarmPalette.morningMist
        button.setTitleColor(FarmPalette.richSoil, for: .normal)
        button.layer.cornerRadius = FarmRadius.crop
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🗑️ Reset All Data", for: .normal)
        button.titleLabel?.font = FarmTypography.crop
        button.setTitleColor(FarmPalette.wilted, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Harvest Guardian v1.0"
        label.font = FarmTypography.seedling
        label.textColor = FarmPalette.dustyField
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setupUI()
        loadProfile()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveProfile()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = FarmPalette.richSoil
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        setupProfileSection()
        
        let sectionLabel1 = createSectionLabel("Profile")
        let sectionLabel2 = createSectionLabel("Actions")
        
        contentStack.addArrangedSubview(sectionLabel1)
        contentStack.addArrangedSubview(profileSection)
        contentStack.addArrangedSubview(sectionLabel2)
        contentStack.addArrangedSubview(statisticsButton)
        contentStack.addArrangedSubview(exportButton)
        contentStack.addArrangedSubview(resetButton)
        contentStack.addArrangedSubview(versionLabel)
        
        avatarButton.addTarget(self, action: #selector(changeAvatarTapped), for: .touchUpInside)
        statisticsButton.addTarget(self, action: #selector(viewStatisticsTapped), for: .touchUpInside)
        exportButton.addTarget(self, action: #selector(exportDataTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetDataTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: FarmSpacing.fieldPadding),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: FarmSpacing.fieldPadding),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -FarmSpacing.fieldPadding),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -FarmSpacing.fieldPadding),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -FarmSpacing.fieldPadding * 2),
            
            profileSection.heightAnchor.constraint(equalToConstant: 180),
            statisticsButton.heightAnchor.constraint(equalToConstant: 50),
            exportButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupProfileSection() {
        let changeAvatarLabel = UILabel()
        changeAvatarLabel.text = "Tap to change avatar"
        changeAvatarLabel.font = FarmTypography.seedling
        changeAvatarLabel.textColor = FarmPalette.morningMist
        changeAvatarLabel.textAlignment = .center
        changeAvatarLabel.translatesAutoresizingMaskIntoConstraints = false
        
        profileSection.addSubview(avatarButton)
        profileSection.addSubview(changeAvatarLabel)
        profileSection.addSubview(nameTextField)
        
        NSLayoutConstraint.activate([
            avatarButton.topAnchor.constraint(equalTo: profileSection.topAnchor, constant: FarmSpacing.plotMargin),
            avatarButton.centerXAnchor.constraint(equalTo: profileSection.centerXAnchor),
            avatarButton.widthAnchor.constraint(equalToConstant: 80),
            avatarButton.heightAnchor.constraint(equalToConstant: 80),
            
            changeAvatarLabel.topAnchor.constraint(equalTo: avatarButton.bottomAnchor, constant: FarmSpacing.furrow),
            changeAvatarLabel.centerXAnchor.constraint(equalTo: profileSection.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: changeAvatarLabel.bottomAnchor, constant: FarmSpacing.rowSpacing),
            nameTextField.leadingAnchor.constraint(equalTo: profileSection.leadingAnchor, constant: FarmSpacing.fieldPadding),
            nameTextField.trailingAnchor.constraint(equalTo: profileSection.trailingAnchor, constant: -FarmSpacing.fieldPadding),
            nameTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func createSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = FarmTypography.harvest
        label.textColor = FarmPalette.goldenHarvest
        return label
    }
    
    private func loadProfile() {
        farmerProfile = storageManager.loadFarmerProfile()
        avatarButton.setTitle(farmerProfile.avatarEmoji, for: .normal)
        nameTextField.text = farmerProfile.farmerName
    }
    
    private func saveProfile() {
        if let name = nameTextField.text, !name.isEmpty {
            farmerProfile.farmerName = name
        }
        storageManager.saveFarmerProfile(farmerProfile)
    }
    
    // MARK: - Actions
    
    @objc private func changeAvatarTapped() {
        let alert = UIAlertController(title: "Choose Avatar", message: nil, preferredStyle: .actionSheet)
        
        for emoji in avatarEmojis {
            alert.addAction(UIAlertAction(title: emoji, style: .default) { [weak self] _ in
                self?.farmerProfile.avatarEmoji = emoji
                self?.avatarButton.setTitle(emoji, for: .normal)
                self?.storageManager.saveFarmerProfile(self!.farmerProfile)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func viewStatisticsTapped() {
        let alert = UIAlertController(title: "📊 Statistics", message: generateStatisticsText(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func generateStatisticsText() -> String {
        let totalPlots = storageManager.getActivePlotsCount()
        let totalSessions = storageManager.getTotalSessions()
        let totalWater = storageManager.getTotalWaterUsed()
        let level = farmerProfile.level
        let xp = farmerProfile.experiencePoints
        let streak = farmerProfile.currentStreak
        let longestStreak = farmerProfile.longestStreak
        
        return """
        Level: \(level)
        Experience: \(xp) XP
        
        Fields: \(totalPlots)
        Sessions: \(totalSessions)
        Water Used: \(Int(totalWater))L
        
        Current Streak: \(streak) days
        Longest Streak: \(longestStreak) days
        """
    }
    
    @objc private func exportDataTapped() {
        let plots = storageManager.loadPlots()
        let sessions = storageManager.loadSessions()
        
        var csvText = "Date,Field,Crop,Duration (min),Water (L),Notes\n"
        
        for session in sessions {
            if let plot = plots.first(where: { $0.id == session.plotId }) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                let dateString = dateFormatter.string(from: session.date)
                let notes = session.notes ?? ""
                csvText += "\(dateString),\(plot.plotName),\(plot.cropType),\(session.durationMinutes),\(session.waterAmount),\(notes)\n"
            }
        }
        
        let activityVC = UIActivityViewController(activityItems: [csvText], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func resetDataTapped() {
        let alert = UIAlertController(
            title: "⚠️ Reset All Data",
            message: "This will delete all your fields, watering sessions, and progress. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.performReset()
        })
        
        present(alert, animated: true)
    }
    
    private func performReset() {
        storageManager.savePlots([])
        storageManager.saveSessions([])
        storageManager.saveWeatherNotes([])
        storageManager.saveFarmerProfile(FarmerProfile())
        
        let alert = UIAlertController(title: "✅ Reset Complete", message: "All data has been cleared.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
