//
//  PlotDetailViewController.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class PlotDetailViewController: UIViewController {
    
    private let plot: IrrigationPlot
    private let storageManager = BarnStorageManager.shared
    private var sessions: [WateringSession] = []
    private var currentSoilCondition: SoilCondition = .moist
    
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
    
    private let headerCard: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.darkCard
        view.layer.cornerRadius = FarmRadius.barn
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.isScrollEnabled = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let statisticsCard: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.darkCard
        view.layer.cornerRadius = FarmRadius.crop
        view.layer.borderWidth = 1
        view.layer.borderColor = FarmPalette.goldenHarvest.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cropConditionCard: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.darkCard
        view.layer.cornerRadius = FarmRadius.crop
        view.layer.borderWidth = 1
        view.layer.borderColor = FarmPalette.goldenHarvest.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    init(plot: IrrigationPlot) {
        self.plot = plot
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = plot.plotName
        currentSoilCondition = plot.soilCondition
        setupUI()
        setupTableView()
        loadSessions()
        
        // Set content inset for navigation bar
        let navBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        scrollView.contentInset = UIEdgeInsets(top: navBarHeight + statusBarHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSessions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = plot.plotName
        view.backgroundColor = FarmPalette.richSoil
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        setupHeaderCard()
        setupStatisticsCard()
        setupCropConditionCard()
        
        let sessionsLabel = UILabel()
        sessionsLabel.text = "💧 Watering History"
        sessionsLabel.font = FarmTypography.barn
        sessionsLabel.textColor = FarmPalette.goldenHarvest
        
            contentStack.addArrangedSubview(headerCard)
        contentStack.addArrangedSubview(statisticsCard)
        contentStack.addArrangedSubview(cropConditionCard)
        contentStack.addArrangedSubview(sessionsLabel)
        contentStack.addArrangedSubview(tableView)
        
        // Initial height constraint for tableView
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 100)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: FarmSpacing.plotMargin),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: FarmSpacing.plotMargin),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -FarmSpacing.plotMargin),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -FarmSpacing.plotMargin),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -FarmSpacing.plotMargin * 2),
            
            headerCard.heightAnchor.constraint(equalToConstant: 150),
            statisticsCard.heightAnchor.constraint(equalToConstant: 140),
            cropConditionCard.heightAnchor.constraint(equalToConstant: 120),
            tableViewHeightConstraint!
        ])
    }
    
    private func setupStatisticsCard() {
        let titleLabel = UILabel()
        titleLabel.text = "📊 Statistics"
        titleLabel.font = FarmTypography.harvest
        titleLabel.textColor = FarmPalette.goldenHarvest
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let totalSessionsLabel = UILabel()
        totalSessionsLabel.text = "Total Sessions: \(sessions.count)"
        totalSessionsLabel.font = FarmTypography.crop
        totalSessionsLabel.textColor = FarmPalette.morningMist
        totalSessionsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let totalWaterLabel = UILabel()
        let totalWater = sessions.reduce(0) { $0 + $1.waterAmount }
        totalWaterLabel.text = "Total Water: \(Int(totalWater))L"
        totalWaterLabel.font = FarmTypography.crop
        totalWaterLabel.textColor = FarmPalette.morningMist
        totalWaterLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let avgDurationLabel = UILabel()
        let avgDuration = sessions.isEmpty ? 0 : sessions.reduce(0) { $0 + $1.durationMinutes } / sessions.count
        avgDurationLabel.text = "Avg Duration: \(avgDuration) min"
        avgDurationLabel.font = FarmTypography.crop
        avgDurationLabel.textColor = FarmPalette.morningMist
        avgDurationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let lastWateredLabel = UILabel()
        if let lastSession = sessions.first {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            lastWateredLabel.text = "Last: \(formatter.localizedString(for: lastSession.date, relativeTo: Date()))"
        } else {
            lastWateredLabel.text = "Last: Never"
        }
        lastWateredLabel.font = FarmTypography.crop
        lastWateredLabel.textColor = FarmPalette.morningMist
        lastWateredLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statisticsCard.addSubview(titleLabel)
        statisticsCard.addSubview(totalSessionsLabel)
        statisticsCard.addSubview(totalWaterLabel)
        statisticsCard.addSubview(avgDurationLabel)
        statisticsCard.addSubview(lastWateredLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: statisticsCard.topAnchor, constant: FarmSpacing.plotMargin),
            titleLabel.leadingAnchor.constraint(equalTo: statisticsCard.leadingAnchor, constant: FarmSpacing.plotMargin),
            
            totalSessionsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: FarmSpacing.rowSpacing),
            totalSessionsLabel.leadingAnchor.constraint(equalTo: statisticsCard.leadingAnchor, constant: FarmSpacing.plotMargin),
            totalSessionsLabel.trailingAnchor.constraint(equalTo: statisticsCard.centerXAnchor, constant: -FarmSpacing.seedGap),
            
            totalWaterLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: FarmSpacing.rowSpacing),
            totalWaterLabel.leadingAnchor.constraint(equalTo: statisticsCard.centerXAnchor, constant: FarmSpacing.seedGap),
            totalWaterLabel.trailingAnchor.constraint(equalTo: statisticsCard.trailingAnchor, constant: -FarmSpacing.plotMargin),
            
            avgDurationLabel.topAnchor.constraint(equalTo: totalSessionsLabel.bottomAnchor, constant: FarmSpacing.rowSpacing),
            avgDurationLabel.leadingAnchor.constraint(equalTo: statisticsCard.leadingAnchor, constant: FarmSpacing.plotMargin),
            avgDurationLabel.trailingAnchor.constraint(equalTo: statisticsCard.centerXAnchor, constant: -FarmSpacing.seedGap),
            
            lastWateredLabel.topAnchor.constraint(equalTo: totalWaterLabel.bottomAnchor, constant: FarmSpacing.rowSpacing),
            lastWateredLabel.leadingAnchor.constraint(equalTo: statisticsCard.centerXAnchor, constant: FarmSpacing.seedGap),
            lastWateredLabel.trailingAnchor.constraint(equalTo: statisticsCard.trailingAnchor, constant: -FarmSpacing.plotMargin)
        ])
    }
    
    private func setupCropConditionCard() {
        let titleLabel = UILabel()
        titleLabel.text = "🌾 Crop Condition"
        titleLabel.font = FarmTypography.harvest
        titleLabel.textColor = FarmPalette.goldenHarvest
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let conditionStack = UIStackView()
        conditionStack.axis = .horizontal
        conditionStack.distribution = .fillEqually
        conditionStack.spacing = FarmSpacing.seedGap
        conditionStack.translatesAutoresizingMaskIntoConstraints = false
        
        for condition in SoilCondition.allCases {
            let button = UIButton(type: .system)
            button.setTitle("\(condition.emoji)\n\(condition.rawValue)", for: .normal)
            button.titleLabel?.font = FarmTypography.seedling
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.setTitleColor(FarmPalette.richSoil, for: .normal)
            button.backgroundColor = currentSoilCondition == condition ? FarmPalette.goldenHarvest : FarmPalette.morningMist
            button.layer.cornerRadius = FarmRadius.crop
            button.layer.borderWidth = currentSoilCondition == condition ? 2 : 1
            button.layer.borderColor = currentSoilCondition == condition ? UIColor.white.cgColor : FarmPalette.goldenHarvest.withAlphaComponent(0.3).cgColor
            button.tag = SoilCondition.allCases.firstIndex(of: condition) ?? 0
            button.addTarget(self, action: #selector(conditionButtonTapped(_:)), for: .touchUpInside)
            conditionStack.addArrangedSubview(button)
        }
        
        cropConditionCard.addSubview(titleLabel)
        cropConditionCard.addSubview(conditionStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cropConditionCard.topAnchor, constant: FarmSpacing.plotMargin),
            titleLabel.leadingAnchor.constraint(equalTo: cropConditionCard.leadingAnchor, constant: FarmSpacing.plotMargin),
            
            conditionStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: FarmSpacing.rowSpacing),
            conditionStack.leadingAnchor.constraint(equalTo: cropConditionCard.leadingAnchor, constant: FarmSpacing.plotMargin),
            conditionStack.trailingAnchor.constraint(equalTo: cropConditionCard.trailingAnchor, constant: -FarmSpacing.plotMargin),
            conditionStack.bottomAnchor.constraint(equalTo: cropConditionCard.bottomAnchor, constant: -FarmSpacing.plotMargin),
            conditionStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func conditionButtonTapped(_ sender: UIButton) {
        currentSoilCondition = SoilCondition.allCases[sender.tag]
        
        // Update plot condition
        var updatedPlot = plot
        updatedPlot.soilCondition = currentSoilCondition
        storageManager.updatePlot(updatedPlot)
        
        // Refresh condition card
        cropConditionCard.subviews.forEach { $0.removeFromSuperview() }
        setupCropConditionCard()
        
        showSuccessMessage("Crop condition updated: \(currentSoilCondition.emoji) \(currentSoilCondition.rawValue)")
    }
    
    private func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(title: "✅ Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupHeaderCard() {
        let nameLabel = UILabel()
        nameLabel.text = plot.plotName
        nameLabel.font = FarmTypography.barn
        nameLabel.textColor = FarmPalette.goldenHarvest
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let cropLabel = UILabel()
        cropLabel.text = "🌾 \(plot.cropType)"
        cropLabel.font = FarmTypography.harvest
        cropLabel.textColor = FarmPalette.morningMist
        cropLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let typeLabel = UILabel()
        typeLabel.text = "\(plot.irrigationType.rawValue) Irrigation"
        typeLabel.font = FarmTypography.crop
        typeLabel.textColor = FarmPalette.morningMist
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let waterLabel = UILabel()
        waterLabel.text = "💧 \(Int(plot.totalWaterUsed))L used"
        waterLabel.font = FarmTypography.crop
        waterLabel.textColor = FarmPalette.morningMist
        waterLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let emojiLabel = UILabel()
        emojiLabel.text = plot.irrigationType.emoji
        emojiLabel.font = .systemFont(ofSize: 50)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerCard.addSubview(nameLabel)
        headerCard.addSubview(cropLabel)
        headerCard.addSubview(typeLabel)
        headerCard.addSubview(waterLabel)
        headerCard.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: FarmSpacing.plotMargin),
            nameLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: FarmSpacing.fieldPadding),
            nameLabel.trailingAnchor.constraint(equalTo: emojiLabel.leadingAnchor, constant: -FarmSpacing.plotMargin),
            
            cropLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: FarmSpacing.seedGap),
            cropLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: FarmSpacing.fieldPadding),
            
            typeLabel.topAnchor.constraint(equalTo: cropLabel.bottomAnchor, constant: FarmSpacing.furrow),
            typeLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: FarmSpacing.fieldPadding),
            
            waterLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: FarmSpacing.furrow),
            waterLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: FarmSpacing.fieldPadding),
            
            emojiLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -FarmSpacing.fieldPadding),
            emojiLabel.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WateringSessionCell.self, forCellReuseIdentifier: "WateringSessionCell")
    }
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private func loadSessions() {
        sessions = storageManager.sessionsForPlot(id: plot.id).sorted { $0.date > $1.date }
        
        // Debug
        print("🔍 Plot Detail Debug:")
        print("Plot ID: \(plot.id)")
        print("Plot Name: \(plot.plotName)")
        let allSessions = storageManager.loadSessions()
        print("All sessions count: \(allSessions.count)")
        print("All sessions plot IDs: \(allSessions.map { $0.plotId })")
        print("Filtered sessions count: \(sessions.count)")
        
        tableView.reloadData()
        
        // Force layout update for all visible cells
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.layoutIfNeeded()
            
            // Force all visible cells to update their layout
            for cell in self.tableView.visibleCells {
                if let sessionCell = cell as? WateringSessionCell {
                    sessionCell.setNeedsLayout()
                    sessionCell.layoutIfNeeded()
                }
            }
        }
        
        // Update statistics
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.statisticsCard.subviews.forEach { $0.removeFromSuperview() }
            self.setupStatisticsCard()
        }
        
        // Update table height constraint
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.layoutIfNeeded()
            let rowHeight: CGFloat = self.sessions.isEmpty ? 60 : 100
            let height = max(100, CGFloat(self.sessions.count) * rowHeight)
            
            // Remove old height constraint
            if let oldConstraint = self.tableViewHeightConstraint {
                oldConstraint.isActive = false
            }
            
            // Add new constraint
            let newConstraint = self.tableView.heightAnchor.constraint(equalToConstant: height)
            newConstraint.isActive = true
            self.tableViewHeightConstraint = newConstraint
            
            // Force another layout update after constraint change
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource

extension PlotDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.isEmpty ? 1 : sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sessions.isEmpty {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No watering sessions yet"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = FarmPalette.dustyField
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WateringSessionCell", for: indexPath) as? WateringSessionCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: sessions[indexPath.row], plot: plot)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PlotDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sessions.isEmpty ? 60 : 100
    }
}
