//
//  WateringSessionCell.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class WateringSessionCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = FarmRadius.crop
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.shadowColor = FarmPalette.cropShadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var gradientLayer: CAGradientLayer?
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plotNameLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.harvest
        label.textColor = FarmPalette.richSoil
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.crop
        label.textColor = FarmPalette.richSoil
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.crop
        label.textColor = FarmPalette.richSoil
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let waterLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.crop
        label.textColor = FarmPalette.richSoil
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        backgroundView = nil
        
        // Set temporary golden background until gradient is applied
        containerView.backgroundColor = FarmPalette.goldenHarvest
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(plotNameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(durationLabel)
        containerView.addSubview(waterLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: FarmSpacing.seedGap),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: FarmSpacing.plotMargin),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -FarmSpacing.plotMargin),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -FarmSpacing.seedGap),
            
            iconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: FarmSpacing.plotMargin),
            iconLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 40),
            
            plotNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: FarmSpacing.rowSpacing),
            plotNameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: FarmSpacing.rowSpacing),
            plotNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -FarmSpacing.plotMargin),
            
            dateLabel.topAnchor.constraint(equalTo: plotNameLabel.bottomAnchor, constant: FarmSpacing.furrow),
            dateLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: FarmSpacing.rowSpacing),
            
            durationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: FarmSpacing.furrow),
            durationLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: FarmSpacing.rowSpacing),
            
            waterLabel.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor),
            waterLabel.leadingAnchor.constraint(equalTo: durationLabel.trailingAnchor, constant: FarmSpacing.plotMargin)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure backgrounds are clear
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundView = nil
        
        // Only add gradient if containerView has valid bounds
        guard containerView.bounds.width > 0 && containerView.bounds.height > 0 else {
            return
        }
        
        // Apply gradient - this will be called multiple times, but applyGradient handles cleanup
        applyGradient()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Clear gradient layers - they will be re-added in layoutSubviews
        containerView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundView = nil
        // Set temporary golden background until gradient is applied
        containerView.backgroundColor = FarmPalette.goldenHarvest
        gradientLayer = nil
    }
    
    // MARK: - Configuration
    
    func configure(with session: WateringSession, plot: IrrigationPlot?) {
        // Clear background to ensure gradient shows
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundView = nil
        
        // Set temporary golden background until gradient is applied
        containerView.backgroundColor = FarmPalette.goldenHarvest
        
        iconLabel.text = session.wasRainfall ? "🌧️" : "💧"
        plotNameLabel.text = plot?.plotName ?? "Unknown Field"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: session.date)
        
        durationLabel.text = "⏱️ \(session.durationMinutes) min"
        waterLabel.text = "💧 \(Int(session.waterAmount))L"
        
        // Force layout update to ensure gradient is applied
        setNeedsLayout()
        layoutIfNeeded()
        
        // Apply gradient after layout - use async to ensure bounds are set
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.containerView.bounds.width > 0 && self.containerView.bounds.height > 0 {
                self.applyGradient()
            } else {
                // If bounds still not available, try again after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.containerView.bounds.width > 0 && self.containerView.bounds.height > 0 {
                        self.applyGradient()
                    }
                }
            }
        }
    }
    
    private func applyGradient() {
        // Remove all existing gradient layers
        containerView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        // Ensure background is clear
        containerView.backgroundColor = .clear
        
        // Create new gradient layer
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
}
