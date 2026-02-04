//
//  DayProgressCard.swift
//  DAYTRACE
//
//  Circular progress card showing day completion
//

import UIKit

final class DayProgressCard: UIView {
    
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
            UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0).cgColor,  // Purple
            UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0).cgColor   // Blue
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 16
        return gradient
    }()
    
    private let progressRing: CircularProgressView = {
        let ring = CircularProgressView()
        ring.translatesAutoresizingMaskIntoConstraints = false
        return ring
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Progress"
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
        containerView.addSubview(progressRing)
        containerView.addSubview(progressLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            progressRing.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            progressRing.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            progressRing.widthAnchor.constraint(equalToConstant: 44),
            progressRing.heightAnchor.constraint(equalToConstant: 44),
            
            progressLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            progressLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 0),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(completed: Int, total: Int, hasMood: Bool) {
        // Calculate progress based only on actions (mood doesn't affect progress)
        let progress: CGFloat
        if total == 0 {
            progress = 0
            progressLabel.text = "0%"
        } else {
            progress = CGFloat(completed) / CGFloat(total)
            let percentage = Int(progress * 100)
            progressLabel.text = "\(percentage)%"
        }
        
        progressRing.setProgress(progress, animated: true)
    }
}

// MARK: - CircularProgressView

final class CircularProgressView: UIView {
    
    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    private var currentProgress: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePaths()
    }
    
    private func setupLayers() {
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backgroundLayer.lineWidth = 4
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = ColorPalette.background.cgColor
        progressLayer.lineWidth = 4
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    private func updatePaths() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 2
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * .pi
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        backgroundLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool) {
        let clampedProgress = min(max(progress, 0), 1)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = currentProgress
            animation.toValue = clampedProgress
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressAnimation")
        }
        
        progressLayer.strokeEnd = clampedProgress
        currentProgress = clampedProgress
    }
}
