//
//  PlotCell.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class PlotCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = FarmRadius.barn
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.shadowColor = FarmPalette.cropShadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var gradientLayer: CAGradientLayer?
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 50)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.harvest
        label.textColor = FarmPalette.richSoil
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cropLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.crop
        label.textColor = FarmPalette.richSoil
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.seedling
        label.textColor = FarmPalette.richSoil
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let archiveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = FarmPalette.richSoil
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onArchiveTapped: (() -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(cropLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(archiveButton)
        
        archiveButton.addTarget(self, action: #selector(archiveButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: FarmSpacing.plotMargin),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: FarmSpacing.seedGap),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: FarmSpacing.seedGap),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -FarmSpacing.seedGap),
            
            cropLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: FarmSpacing.furrow),
            cropLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: FarmSpacing.seedGap),
            cropLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -FarmSpacing.seedGap),
            
            statusLabel.topAnchor.constraint(equalTo: cropLabel.bottomAnchor, constant: FarmSpacing.seedGap),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: FarmSpacing.seedGap),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -FarmSpacing.seedGap),
            statusLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -FarmSpacing.seedGap),
            
            archiveButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: FarmSpacing.seedGap),
            archiveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -FarmSpacing.seedGap),
            archiveButton.widthAnchor.constraint(equalToConstant: 30),
            archiveButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func archiveButtonTapped() {
        onArchiveTapped?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Only add gradient if containerView has valid bounds
        guard containerView.bounds.width > 0 && containerView.bounds.height > 0 else {
            return
        }
        
        // Check if we're in empty state - don't add gradient
        if containerView.backgroundColor == FarmPalette.darkCard {
            return
        }
        
        // Remove all existing gradient layers
        containerView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        // Create new gradient layer for this cell
        let newGradientLayer = CAGradientLayer()
        newGradientLayer.colors = [
            FarmPalette.goldenHarvest.cgColor,
            FarmPalette.goldenHarvest.withAlphaComponent(0.7).cgColor,
            UIColor(red: 255/255, green: 220/255, blue: 100/255, alpha: 1.0).cgColor
        ]
        newGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        newGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        newGradientLayer.frame = containerView.bounds
        newGradientLayer.cornerRadius = containerView.layer.cornerRadius
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        containerView.layer.insertSublayer(newGradientLayer, at: 0)
        CATransaction.commit()
        
        gradientLayer = newGradientLayer
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Clear gradient layers - they will be re-added in layoutSubviews
        containerView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        gradientLayer = nil
    }
    
    // MARK: - Configuration
    
    func configure(with plot: IrrigationPlot) {
        // Clear background to ensure gradient shows
        containerView.backgroundColor = .clear
        
        iconLabel.text = plot.irrigationType.emoji
        nameLabel.text = plot.plotName
        nameLabel.textColor = FarmPalette.richSoil
        cropLabel.text = "🌾 \(plot.cropType)"
        cropLabel.textColor = FarmPalette.richSoil
        
        if let lastWatered = plot.lastWateredDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            let relativeDate = formatter.localizedString(for: lastWatered, relativeTo: Date())
            statusLabel.text = "Last watered \(relativeDate)"
        } else {
            statusLabel.text = "Not watered yet"
        }
        statusLabel.textColor = FarmPalette.richSoil
        
        // Force layout update to apply gradient
        setNeedsLayout()
    }
    
    func configureEmpty() {
        // Remove gradient for empty state
        containerView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        containerView.backgroundColor = FarmPalette.darkCard
        iconLabel.text = "🌱"
        nameLabel.text = "No Fields Yet"
        nameLabel.textColor = FarmPalette.goldenHarvest
        cropLabel.text = "Add your first field"
        cropLabel.textColor = FarmPalette.morningMist
        statusLabel.text = ""
    }
}
