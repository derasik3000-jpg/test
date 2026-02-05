//
//  HarvestCalendarViewController.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class HarvestCalendarViewController: UIViewController {
    
    private let storageManager = BarnStorageManager.shared
    private var wateringSessions: [WateringSession] = []
    private var plots: [IrrigationPlot] = []
    private var selectedDate = Date()
    private var isFirstTime: Bool {
        return plots.isEmpty && wateringSessions.isEmpty
    }
    
    // MARK: - UI Elements
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.darkCard
        view.layer.shadowColor = FarmPalette.goldenHarvest.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.5
        view.layer.borderWidth = 2
        view.layer.borderColor = FarmPalette.goldenHarvest.withAlphaComponent(0.5).cgColor
        view.isHidden = false
        view.alpha = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerBottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.goldenHarvest
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        button.tintColor = FarmPalette.goldenHarvest
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.barn
        label.textColor = FarmPalette.goldenHarvest
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let previousMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = FarmPalette.goldenHarvest
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = FarmPalette.goldenHarvest
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = FarmPalette.richSoil
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let addSessionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("💧 Log Watering", for: .normal)
        button.titleLabel?.font = FarmTypography.harvest
        button.setTitleColor(FarmPalette.richSoil, for: .normal)
        button.backgroundColor = FarmPalette.goldenHarvest
        button.layer.cornerRadius = FarmRadius.barn
        button.layer.shadowColor = FarmPalette.goldenHarvest.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let weatherButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("☁️ Weather Note", for: .normal)
        button.titleLabel?.font = FarmTypography.harvest
        button.setTitleColor(FarmPalette.richSoil, for: .normal)
        button.backgroundColor = FarmPalette.morningMist
        button.layer.cornerRadius = FarmRadius.barn
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.shadowColor = UIColor.white.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let weatherIndicatorLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.seedling
        label.textColor = FarmPalette.dustyField
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyIconLabel: UILabel = {
        let label = UILabel()
        label.text = "🌾"
        label.font = .systemFont(ofSize: 80)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Harvest Guardian!"
        label.font = FarmTypography.silo
        label.textColor = FarmPalette.goldenHarvest
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Start your irrigation journey:\n\n1️⃣ Go to Fields tab and add your first field\n2️⃣ Come back and log your watering sessions\n3️⃣ Track your progress in Dashboard"
        label.font = FarmTypography.harvest
        label.textColor = FarmPalette.morningMist
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let goToFieldsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🌱 Go to Fields", for: .normal)
        button.titleLabel?.font = FarmTypography.harvest
        button.backgroundColor = FarmPalette.goldenHarvest
        button.setTitleColor(FarmPalette.richSoil, for: .normal)
        button.layer.cornerRadius = FarmRadius.barn
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let helpCard: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.darkCard
        view.layer.cornerRadius = FarmRadius.crop
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let helpTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "💡 How to use Calendar"
        label.font = FarmTypography.harvest
        label.textColor = FarmPalette.goldenHarvest
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let helpTextLabel: UILabel = {
        let label = UILabel()
        label.text = "• Switch months with arrows\n• Tap 'Log Watering' to record\n• Add weather notes for context\n• View all sessions below"
        label.font = FarmTypography.crop
        label.textColor = FarmPalette.morningMist
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dismissHelpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Got it!", for: .normal)
        button.titleLabel?.font = FarmTypography.crop
        button.setTitleColor(FarmPalette.goldenHarvest, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupUI()
        setupTableView()
        loadData()
        updateMonthLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        loadData()
        tableView.reloadData()
        updateWeatherIndicator()
        
        // Force layout update for all visible cells to apply gradients
        DispatchQueue.main.async { [weak self] in
            self?.tableView.layoutIfNeeded()
            for cell in self?.tableView.visibleCells ?? [] {
                if let sessionCell = cell as? WateringSessionCell {
                    sessionCell.setNeedsLayout()
                    sessionCell.layoutIfNeeded()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Add gradient layers after layout
        addGradientToButton(addSessionButton, colors: [
            FarmPalette.goldenHarvest.cgColor,
            UIColor(red: 255/255, green: 220/255, blue: 100/255, alpha: 1.0).cgColor
        ])
        
        addGradientToButton(weatherButton, colors: [
            UIColor(red: 240/255, green: 240/255, blue: 255/255, alpha: 1.0).cgColor,
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0).cgColor
        ])
    }
    
    private func addGradientToButton(_ button: UIButton, colors: [CGColor]) {
        // Remove existing gradient layers
        button.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = button.layer.cornerRadius
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateWeatherIndicator() {
        let weatherNotes = storageManager.loadWeatherNotes()
        let todayNotes = weatherNotes.filter { Calendar.current.isDateInToday($0.date) }
        
        if let todayNote = todayNotes.first {
            weatherIndicatorLabel.text = "Today: \(todayNote.condition.emoji) \(todayNote.condition.rawValue)"
        } else {
            let recentNotes = weatherNotes.sorted { $0.date > $1.date }
            if let recentNote = recentNotes.first {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                weatherIndicatorLabel.text = "Last: \(recentNote.condition.emoji) \(formatter.string(from: recentNote.date))"
            } else {
                weatherIndicatorLabel.text = "No weather notes yet"
            }
        }
    }
    
    
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = FarmPalette.richSoil
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(helpCard)
        view.addSubview(weatherButton)
        view.addSubview(weatherIndicatorLabel)
        view.addSubview(addSessionButton)
        view.addSubview(headerView)
        
        // Bring header to front
        view.bringSubviewToFront(headerView)
        
        headerView.addSubview(previousMonthButton)
        headerView.addSubview(monthLabel)
        headerView.addSubview(nextMonthButton)
        headerView.addSubview(settingsButton)
        headerView.addSubview(headerBottomLine)
        
        emptyStateView.addSubview(emptyIconLabel)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptyDescriptionLabel)
        emptyStateView.addSubview(goToFieldsButton)
        
        helpCard.addSubview(helpTitleLabel)
        helpCard.addSubview(helpTextLabel)
        helpCard.addSubview(dismissHelpButton)
        
        previousMonthButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        addSessionButton.addTarget(self, action: #selector(addSessionTapped), for: .touchUpInside)
        weatherButton.addTarget(self, action: #selector(addWeatherNote), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        goToFieldsButton.addTarget(self, action: #selector(goToFieldsTapped), for: .touchUpInside)
        dismissHelpButton.addTarget(self, action: #selector(dismissHelpTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            headerBottomLine.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerBottomLine.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerBottomLine.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            headerBottomLine.heightAnchor.constraint(equalToConstant: 2),
            
            previousMonthButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: FarmSpacing.plotMargin),
            previousMonthButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            previousMonthButton.widthAnchor.constraint(equalToConstant: 44),
            previousMonthButton.heightAnchor.constraint(equalToConstant: 44),
            
            monthLabel.leadingAnchor.constraint(equalTo: previousMonthButton.trailingAnchor, constant: FarmSpacing.seedGap),
            monthLabel.trailingAnchor.constraint(equalTo: nextMonthButton.leadingAnchor, constant: -FarmSpacing.seedGap),
            monthLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -FarmSpacing.seedGap),
            nextMonthButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            nextMonthButton.widthAnchor.constraint(equalToConstant: 44),
            nextMonthButton.heightAnchor.constraint(equalToConstant: 44),
            
            settingsButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -FarmSpacing.plotMargin),
            settingsButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: weatherIndicatorLabel.topAnchor, constant: -FarmSpacing.plotMargin),
            
            helpCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: FarmSpacing.plotMargin),
            
            weatherButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FarmSpacing.plotMargin),
            weatherButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -FarmSpacing.seedGap),
            weatherButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -FarmSpacing.plotMargin),
            weatherButton.heightAnchor.constraint(equalToConstant: 50),
            
            weatherIndicatorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FarmSpacing.plotMargin),
            weatherIndicatorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FarmSpacing.plotMargin),
            weatherIndicatorLabel.bottomAnchor.constraint(equalTo: weatherButton.topAnchor, constant: -FarmSpacing.furrow),
            
            addSessionButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: FarmSpacing.seedGap),
            addSessionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FarmSpacing.plotMargin),
            addSessionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -FarmSpacing.plotMargin),
            addSessionButton.heightAnchor.constraint(equalToConstant: 50),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FarmSpacing.acreSpace),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FarmSpacing.acreSpace),
            
            emptyIconLabel.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyIconLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            emptyTitleLabel.topAnchor.constraint(equalTo: emptyIconLabel.bottomAnchor, constant: FarmSpacing.plotMargin),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyDescriptionLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: FarmSpacing.plotMargin),
            emptyDescriptionLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyDescriptionLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            goToFieldsButton.topAnchor.constraint(equalTo: emptyDescriptionLabel.bottomAnchor, constant: FarmSpacing.barnGap),
            goToFieldsButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            goToFieldsButton.widthAnchor.constraint(equalToConstant: 200),
            goToFieldsButton.heightAnchor.constraint(equalToConstant: 50),
            goToFieldsButton.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            
            helpCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: FarmSpacing.plotMargin),
            helpCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FarmSpacing.plotMargin),
            helpCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FarmSpacing.plotMargin),
            
            helpTitleLabel.topAnchor.constraint(equalTo: helpCard.topAnchor, constant: FarmSpacing.plotMargin),
            helpTitleLabel.leadingAnchor.constraint(equalTo: helpCard.leadingAnchor, constant: FarmSpacing.plotMargin),
            helpTitleLabel.trailingAnchor.constraint(equalTo: helpCard.trailingAnchor, constant: -FarmSpacing.plotMargin),
            
            helpTextLabel.topAnchor.constraint(equalTo: helpTitleLabel.bottomAnchor, constant: FarmSpacing.rowSpacing),
            helpTextLabel.leadingAnchor.constraint(equalTo: helpCard.leadingAnchor, constant: FarmSpacing.plotMargin),
            helpTextLabel.trailingAnchor.constraint(equalTo: helpCard.trailingAnchor, constant: -FarmSpacing.plotMargin),
            
            dismissHelpButton.topAnchor.constraint(equalTo: helpTextLabel.bottomAnchor, constant: FarmSpacing.rowSpacing),
            dismissHelpButton.trailingAnchor.constraint(equalTo: helpCard.trailingAnchor, constant: -FarmSpacing.plotMargin),
            dismissHelpButton.bottomAnchor.constraint(equalTo: helpCard.bottomAnchor, constant: -FarmSpacing.rowSpacing)
        ])
        
        updateEmptyState()
        checkIfShouldShowHelp()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WateringSessionCell.self, forCellReuseIdentifier: "WateringSessionCell")
        
        // Ensure table view and cells have transparent backgrounds
        tableView.backgroundColor = FarmPalette.richSoil
        if #available(iOS 13.0, *) {
            tableView.backgroundView = nil
        }
    }
    
    private func loadData() {
        wateringSessions = storageManager.loadSessions().sorted { $0.date > $1.date }
        plots = storageManager.loadPlots()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !isFirstTime
        tableView.isHidden = isFirstTime
        addSessionButton.isEnabled = !plots.isEmpty
        weatherButton.isEnabled = !plots.isEmpty
        
        if plots.isEmpty {
            addSessionButton.alpha = 0.5
            weatherButton.alpha = 0.5
        } else {
            addSessionButton.alpha = 1.0
            weatherButton.alpha = 1.0
        }
    }
    
    private func checkIfShouldShowHelp() {
        let hasSeenHelp = UserDefaults.standard.bool(forKey: "hasSeenCalendarHelp")
        helpCard.isHidden = hasSeenHelp || isFirstTime
    }
    
    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: selectedDate)
    }
    
    // MARK: - Actions
    
    @objc private func previousMonthTapped() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
            updateMonthLabel()
            animateMonthTransition()
        }
    }
    
    @objc private func nextMonthTapped() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
            updateMonthLabel()
            animateMonthTransition()
        }
    }
    
    private func animateMonthTransition() {
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        } completion: { _ in
            // Force layout update for all visible cells to apply gradients
            DispatchQueue.main.async { [weak self] in
                self?.tableView.layoutIfNeeded()
                for cell in self?.tableView.visibleCells ?? [] {
                    if let sessionCell = cell as? WateringSessionCell {
                        sessionCell.setNeedsLayout()
                        sessionCell.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @objc private func addSessionTapped() {
        guard !plots.isEmpty else {
            showAlert(title: "No Fields Yet", message: "Please add a field first in the Fields tab before logging watering sessions.")
            return
        }
        
        let addVC = AddWateringSessionViewController()
        addVC.onSessionAdded = { [weak self] in
            self?.loadData()
            self?.tableView.reloadData()
            
            // Force layout update for all visible cells to apply gradients
            DispatchQueue.main.async {
                self?.tableView.layoutIfNeeded()
                for cell in self?.tableView.visibleCells ?? [] {
                    if let sessionCell = cell as? WateringSessionCell {
                        sessionCell.setNeedsLayout()
                        sessionCell.layoutIfNeeded()
                    }
                }
            }
        }
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }
    
    @objc private func addWeatherNote() {
        let alertController = UIAlertController(title: "☁️ Weather Note", message: "Record today's weather condition. This helps track irrigation patterns.", preferredStyle: .actionSheet)
        
        for condition in WeatherCondition.allCases {
            alertController.addAction(UIAlertAction(title: "\(condition.emoji) \(condition.rawValue)", style: .default) { [weak self] _ in
                let note = WeatherNote(condition: condition)
                self?.storageManager.addWeatherNote(note)
                self?.updateWeatherIndicator()
                self?.showSuccessMessage("Weather note added! \(condition.emoji)")
            })
        }
        
        // Show recent weather notes
        let weatherNotes = storageManager.loadWeatherNotes().sorted { $0.date > $1.date }
        if !weatherNotes.isEmpty {
            alertController.addAction(UIAlertAction(title: "📋 View All Notes", style: .default) { [weak self] _ in
                self?.showWeatherNotesList()
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = weatherButton
            popover.sourceRect = weatherButton.bounds
        }
        
        present(alertController, animated: true)
    }
    
    private func showWeatherNotesList() {
        let weatherNotes = storageManager.loadWeatherNotes().sorted { $0.date > $1.date }
        let alert = UIAlertController(title: "📋 Weather Notes", message: nil, preferredStyle: .alert)
        
        if weatherNotes.isEmpty {
            alert.message = "No weather notes yet"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            
            var message = ""
            for (index, note) in weatherNotes.prefix(10).enumerated() {
                message += "\(note.condition.emoji) \(formatter.string(from: note.date))\n"
            }
            if weatherNotes.count > 10 {
                message += "\n...and \(weatherNotes.count - 10) more"
            }
            alert.message = message
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    private func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(title: "✅ Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func goToFieldsTapped() {
        tabBarController?.selectedIndex = 1
    }
    
    @objc private func dismissHelpTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenCalendarHelp")
        UIView.animate(withDuration: 0.3) {
            self.helpCard.alpha = 0
        } completion: { _ in
            self.helpCard.isHidden = true
            self.helpCard.alpha = 1
        }
    }
}

// MARK: - UITableViewDataSource

extension HarvestCalendarViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filteredSessions = wateringSessions.filter {
            Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: .month)
        }
        return filteredSessions.isEmpty ? 1 : filteredSessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filteredSessions = wateringSessions.filter {
            Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: .month)
        }
        
        if filteredSessions.isEmpty {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No watering sessions this month"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = FarmPalette.dustyField
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WateringSessionCell", for: indexPath) as? WateringSessionCell else {
            let fallbackCell = UITableViewCell()
            fallbackCell.backgroundColor = .clear
            fallbackCell.contentView.backgroundColor = .clear
            return fallbackCell
        }
        
        let session = filteredSessions[indexPath.row]
        let plot = plots.first { $0.id == session.plotId }
        cell.configure(with: session, plot: plot)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HarvestCalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
