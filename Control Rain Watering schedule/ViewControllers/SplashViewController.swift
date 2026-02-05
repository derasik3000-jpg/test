//
//  SplashViewController.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    
    var onComplete: (() -> Void)?
    
    // MARK: - UI Elements
    
    private let mainIconLabel: UILabel = {
        let label = UILabel()
        label.text = "🌾"
        label.font = .systemFont(ofSize: 80)
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Harvest Guardian"
        label.font = FarmTypography.windmill
        label.textColor = FarmPalette.goldenHarvest
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Smart Irrigation Management"
        label.font = FarmTypography.harvest
        label.textColor = FarmPalette.morningMist
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Preparing your fields..."
        label.font = FarmTypography.crop
        label.textColor = FarmPalette.goldenHarvest
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let waterDropsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimationSequence()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = FarmPalette.richSoil
        
        view.addSubview(mainIconLabel)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(loadingLabel)
        view.addSubview(waterDropsContainer)
        
        NSLayoutConstraint.activate([
            mainIconLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainIconLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            
            titleLabel.topAnchor.constraint(equalTo: mainIconLabel.bottomAnchor, constant: FarmSpacing.fieldPadding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FarmSpacing.fieldPadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FarmSpacing.fieldPadding),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: FarmSpacing.seedGap),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FarmSpacing.fieldPadding),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FarmSpacing.fieldPadding),
            
            loadingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -FarmSpacing.acreSpace),
            loadingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FarmSpacing.fieldPadding),
            loadingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FarmSpacing.fieldPadding),
            
            waterDropsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waterDropsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            waterDropsContainer.topAnchor.constraint(equalTo: view.topAnchor),
            waterDropsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Animations
    
    private func startAnimationSequence() {
        // Icon animation
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.mainIconLabel.alpha = 1
            self.mainIconLabel.transform = .identity
        }
        
        // Title animation
        UIView.animate(withDuration: 0.6, delay: 0.6) {
            self.titleLabel.alpha = 1
        }
        
        // Subtitle animation
        UIView.animate(withDuration: 0.6, delay: 0.9) {
            self.subtitleLabel.alpha = 1
        }
        
        // Loading text animation
        UIView.animate(withDuration: 0.5, delay: 1.2) {
            self.loadingLabel.alpha = 1
        }
        
        // Animated water drops
        animateWaterDrops()
        
        // Rotate icon slightly
        rotateIcon()
        
        // Complete after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.fadeOutAndComplete()
        }
    }
    
    private func animateWaterDrops() {
        for i in 0..<8 {
            let delay = Double(i) * 0.3
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.createFallingWaterDrop()
            }
        }
    }
    
    private func createFallingWaterDrop() {
        let dropLabel = UILabel()
        dropLabel.text = "💧"
        dropLabel.font = .systemFont(ofSize: 24)
        dropLabel.alpha = 0.7
        
        let randomX = CGFloat.random(in: 40...(view.bounds.width - 40))
        dropLabel.frame = CGRect(x: randomX, y: -30, width: 30, height: 30)
        
        waterDropsContainer.addSubview(dropLabel)
        
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseIn, animations: {
            dropLabel.frame.origin.y = self.view.bounds.height + 30
            dropLabel.alpha = 0
        }) { _ in
            dropLabel.removeFromSuperview()
        }
    }
    
    private func rotateIcon() {
        UIView.animate(withDuration: 2.0, delay: 1.0, options: [.repeat, .autoreverse]) {
            self.mainIconLabel.transform = CGAffineTransform(rotationAngle: .pi / 12)
        }
    }
    
    private func fadeOutAndComplete() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0
        }) { _ in
            self.onComplete?()
        }
    }
}
