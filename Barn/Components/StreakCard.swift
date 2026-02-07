//
//  StreakCard.swift
//  DAYTRACE
//
//  Streak counter card with flame animation
//

import UIKit

final class StreakCard: UIView {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0).cgColor,  // Orange-Red
            UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0).cgColor   // Orange
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 16
        return gradient
    }()
    
    private let flameIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        let iv = UIImageView()
        iv.image = UIImage(systemName: "flame.fill", withConfiguration: config)
        iv.tintColor = ColorPalette.background
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .heavy)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Day Streak"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.addSubview(flameIcon)
        containerView.addSubview(countLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            flameIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            flameIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            flameIcon.widthAnchor.constraint(equalToConstant: 28),
            flameIcon.heightAnchor.constraint(equalToConstant: 28),
            
            countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            countLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 0),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(streak: Int) {
        countLabel.text = "\(streak)"
        
        // Update flame color based on streak
        if streak >= 7 {
            flameIcon.tintColor = UIColor.systemOrange
            animateFlame(intense: true)
        } else if streak >= 3 {
            flameIcon.tintColor = ColorPalette.background
            animateFlame(intense: false)
        } else if streak > 0 {
            flameIcon.tintColor = ColorPalette.background.withAlphaComponent(0.6)
            flameIcon.layer.removeAllAnimations()
        } else {
            flameIcon.tintColor = .white.withAlphaComponent(0.3)
            flameIcon.layer.removeAllAnimations()
        }
    }
    
    private func animateFlame(intense: Bool) {
        flameIcon.layer.removeAllAnimations()
        
        let duration = intense ? 0.3 : 0.5
        let scale: CGFloat = intense ? 1.15 : 1.08
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: {
                self.flameIcon.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        )
    }
}
