//
//  FieldManagerViewController.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class FieldManagerViewController: UIViewController {
    
    private let storageManager = BarnStorageManager.shared
    private var plots: [IrrigationPlot] = []
    
    // MARK: - UI Elements
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = FarmSpacing.plotMargin
        layout.minimumLineSpacing = FarmSpacing.plotMargin
        layout.sectionInset = UIEdgeInsets(
            top: FarmSpacing.plotMargin,
            left: FarmSpacing.plotMargin,
            bottom: FarmSpacing.plotMargin,
            right: FarmSpacing.plotMargin
        )
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = FarmPalette.richSoil
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let addPlotButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🌱 Add New Field", for: .normal)
        button.titleLabel?.font = FarmTypography.harvest
        button.backgroundColor = FarmPalette.goldenHarvest
        button.setTitleColor(FarmPalette.richSoil, for: .normal)
        button.layer.cornerRadius = FarmRadius.barn
        button.layer.shadowColor = FarmPalette.cropShadow.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private let quickStatsView: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.darkCard
        view.layer.cornerRadius = FarmRadius.crop
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.crop
        label.textColor = FarmPalette.goldenHarvest
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fields"
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupUI()
        setupCollectionView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        loadData()
        collectionView.reloadData()
        updateStats()
        
        // Force layout update for all visible cells to apply gradients
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.layoutIfNeeded()
            for cell in self?.collectionView.visibleCells ?? [] {
                if let plotCell = cell as? PlotCell {
                    plotCell.setNeedsLayout()
                    plotCell.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = FarmPalette.richSoil
        
        view.addSubview(quickStatsView)
        quickStatsView.addSubview(statsLabel)
        view.addSubview(collectionView)
        view.addSubview(addPlotButton)
        
        addPlotButton.addTarget(self, action: #selector(addPlotTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            quickStatsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: FarmSpacing.plotMargin),
            quickStatsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FarmSpacing.plotMargin),
            quickStatsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FarmSpacing.plotMargin),
            quickStatsView.heightAnchor.constraint(equalToConstant: 60),
            
            statsLabel.topAnchor.constraint(equalTo: quickStatsView.topAnchor, constant: FarmSpacing.seedGap),
            statsLabel.leadingAnchor.constraint(equalTo: quickStatsView.leadingAnchor, constant: FarmSpacing.plotMargin),
            statsLabel.trailingAnchor.constraint(equalTo: quickStatsView.trailingAnchor, constant: -FarmSpacing.plotMargin),
            statsLabel.bottomAnchor.constraint(equalTo: quickStatsView.bottomAnchor, constant: -FarmSpacing.seedGap),
            
            collectionView.topAnchor.constraint(equalTo: quickStatsView.bottomAnchor, constant: FarmSpacing.plotMargin),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: addPlotButton.topAnchor, constant: -FarmSpacing.plotMargin),
            
            addPlotButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FarmSpacing.acreSpace),
            addPlotButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FarmSpacing.acreSpace),
            addPlotButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -FarmSpacing.plotMargin),
            addPlotButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PlotCell.self, forCellWithReuseIdentifier: "PlotCell")
    }
    
    private func loadData() {
        // Load all plots first to ensure old data is migrated
        let allPlots = storageManager.loadPlots()
        plots = allPlots.filter { !$0.isArchived }
        
        print("📊 Fields Debug:")
        print("Total plots: \(allPlots.count)")
        print("Active plots: \(plots.count)")
        print("Archived plots: \(allPlots.filter { $0.isArchived }.count)")
    }
    
    private func updateStats() {
        let totalPlots = plots.count
        let totalWater = storageManager.getTotalWaterUsed()
        statsLabel.text = "📊 \(totalPlots) Active Fields • 💧 \(Int(totalWater))L Total Water"
    }
    
    // MARK: - Actions
    
    @objc private func addPlotTapped() {
        let addVC = AddPlotViewController()
        addVC.onPlotAdded = { [weak self] in
            self?.loadData()
            self?.collectionView.reloadData()
            self?.updateStats()
        }
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension FieldManagerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plots.isEmpty ? 1 : plots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlotCell", for: indexPath) as? PlotCell else {
            return UICollectionViewCell()
        }
        
        if plots.isEmpty {
            cell.configureEmpty()
            cell.onArchiveTapped = nil
        } else {
            let plot = plots[indexPath.item]
            cell.configure(with: plot)
            cell.onArchiveTapped = { [weak self] in
                self?.showArchiveConfirmation(for: plot)
            }
        }
        
        // Force layout update to apply gradient
        DispatchQueue.main.async {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
        
        return cell
    }
    
    private func showArchiveConfirmation(for plot: IrrigationPlot) {
        let alert = UIAlertController(
            title: "🌾 Archive Field",
            message: "Archive '\(plot.plotName)'? This field will be moved to archive. You can restore it later.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Archive", style: .default) { [weak self] _ in
            self?.archivePlot(plot)
        })
        
        present(alert, animated: true)
    }
    
    private func archivePlot(_ plot: IrrigationPlot) {
        storageManager.archivePlot(id: plot.id)
        
        // Add experience points
        var profile = storageManager.loadFarmerProfile()
        profile.addExperience(15)
        storageManager.saveFarmerProfile(profile)
        
        loadData()
        collectionView.reloadData()
        updateStats()
        
        let alert = UIAlertController(title: "✅ Archived", message: "'\(plot.plotName)' has been archived.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension FieldManagerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !plots.isEmpty else { return }
        
        let plot = plots[indexPath.item]
        let detailVC = PlotDetailViewController(plot: plot)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FieldManagerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = FarmSpacing.plotMargin * 3
        let width = (collectionView.bounds.width - padding) / 2
        return CGSize(width: width, height: 180)
    }
}
