//
//  ShareSnapshotCard.swift
//  DAYTRACE
//
//  Share snapshot component
//

import UIKit

final class ShareSnapshotCard: UIView {
    
    var onShareTapped: (() -> Void)?
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1.0).cgColor,
            UIColor(red: 0.7, green: 0.2, blue: 0.8, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 16
        return gradient
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "📸 Share Today"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a beautiful snapshot of your day"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.9)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Generate & Share", for: .normal)
        btn.setTitleColor(ColorPalette.primary, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 14
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
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
        layer.cornerRadius = 16
        layer.insertSublayer(gradientLayer, at: 0)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(shareButton)
        
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 140),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            shareButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            shareButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            shareButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            shareButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func shareTapped() {
        AnimationKit.springScale(view: shareButton)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        onShareTapped?()
    }
}
