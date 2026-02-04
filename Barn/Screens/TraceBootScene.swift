//
//  TraceBootScene.swift
//  DAYTRACE
//
//  Enhanced animated loading screen with multiple elements and animations
//

import UIKit

final class TraceBootScene: UIViewController {
    
    var onComplete: (() -> Void)?
    
    // MARK: - Background Elements
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            ColorPalette.background.cgColor,
            ColorPalette.background.withAlphaComponent(0.8).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }()
    
    // MARK: - Main Logo Elements
    
    private let logoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let centerCircle: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primary
        view.layer.cornerRadius = 60
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let innerCircle: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.background
        view.layer.cornerRadius = 40
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Orbiting Elements
    
    private var orbitingDots: [UIView] = []
    private let numberOfDots = 8
    
    // MARK: - App Name
    
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "DAYTRACE"
        label.font = .systemFont(ofSize: 36, weight: .heavy)
        label.textColor = ColorPalette.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.text = "Track your journey"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = ColorPalette.primary.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    // MARK: - Particle Effects
    
    private var particles: [UIView] = []
    private let numberOfParticles = 20
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.background
        setupGradient()
        setupUI()
        startAnimations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup
    
    private func setupGradient() {
        view.layer.insertSublayer(gradientLayer, at: 0)
        animateGradient()
    }
    
    private func setupUI() {
        // Add main elements
        view.addSubview(logoContainer)
        logoContainer.addSubview(centerCircle)
        logoContainer.addSubview(innerCircle)
        view.addSubview(appNameLabel)
        view.addSubview(taglineLabel)
        
        // Setup orbiting dots
        setupOrbitingDots()
        
        // Setup particles
        setupParticles()
        
        // Constraints
        NSLayoutConstraint.activate([
            logoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            logoContainer.widthAnchor.constraint(equalToConstant: 200),
            logoContainer.heightAnchor.constraint(equalToConstant: 200),
            
            centerCircle.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            centerCircle.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            centerCircle.widthAnchor.constraint(equalToConstant: 120),
            centerCircle.heightAnchor.constraint(equalToConstant: 120),
            
            innerCircle.centerXAnchor.constraint(equalTo: centerCircle.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: centerCircle.centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: 80),
            innerCircle.heightAnchor.constraint(equalToConstant: 80),
            
            appNameLabel.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: 40),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            taglineLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 8),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupOrbitingDots() {
        for _ in 0..<numberOfDots {
            let dot = UIView()
            dot.backgroundColor = ColorPalette.primary
            dot.layer.cornerRadius = 6
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.alpha = 0
            
            logoContainer.addSubview(dot)
            orbitingDots.append(dot)
            
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 12),
                dot.heightAnchor.constraint(equalToConstant: 12),
                dot.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
                dot.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor)
            ])
        }
    }
    
    private func setupParticles() {
        for _ in 0..<numberOfParticles {
            let particle = UIView()
            particle.backgroundColor = ColorPalette.primary.withAlphaComponent(0.3)
            particle.layer.cornerRadius = 2
            particle.translatesAutoresizingMaskIntoConstraints = false
            particle.alpha = 0
            
            let size = CGFloat.random(in: 4...8)
            view.insertSubview(particle, at: 1)
            particles.append(particle)
            
            let x = CGFloat.random(in: 0...view.bounds.width)
            let y = CGFloat.random(in: 0...view.bounds.height)
            
            NSLayoutConstraint.activate([
                particle.widthAnchor.constraint(equalToConstant: size),
                particle.heightAnchor.constraint(equalToConstant: size),
                particle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: x),
                particle.topAnchor.constraint(equalTo: view.topAnchor, constant: y)
            ])
        }
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        animateCenterCircle()
        animateInnerCircle()
        animateOrbitingDots()
        animateAppName()
        animateParticles()
        
        // Complete after all animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.fadeOutAndComplete()
        }
    }
    
    private func animateGradient() {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = gradientLayer.colors
        animation.toValue = [
            ColorPalette.background.withAlphaComponent(0.8).cgColor,
            ColorPalette.background.cgColor
        ]
        animation.duration = 2.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "gradientAnimation")
    }
    
    private func animateCenterCircle() {
        // Pulse animation
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut],
            animations: { [weak self] in
                self?.centerCircle.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        )
        
        // Rotation animation
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 3.0
        rotation.repeatCount = .infinity
        centerCircle.layer.add(rotation, forKey: "rotation")
    }
    
    private func animateInnerCircle() {
        // Counter-rotation
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = -CGFloat.pi * 2
        rotation.duration = 2.0
        rotation.repeatCount = .infinity
        innerCircle.layer.add(rotation, forKey: "counterRotation")
        
        // Pulse
        UIView.animate(
            withDuration: 0.8,
            delay: 0.2,
            options: [.repeat, .autoreverse, .curveEaseInOut],
            animations: { [weak self] in
                self?.innerCircle.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        )
    }
    
    private func animateOrbitingDots() {
        let radius: CGFloat = 100
        
        for (index, dot) in orbitingDots.enumerated() {
            let angle = (CGFloat(index) / CGFloat(numberOfDots)) * 2 * .pi
            let delay = Double(index) * 0.1
            
            // Fade in
            UIView.animate(withDuration: 0.3, delay: delay) {
                dot.alpha = 1.0
            }
            
            // Orbit animation
            let orbit = CAKeyframeAnimation(keyPath: "position")
            let path = UIBezierPath()
            
            for i in 0...360 {
                let currentAngle = angle + (CGFloat(i) * .pi / 180)
                let x = logoContainer.bounds.midX + radius * cos(currentAngle)
                let y = logoContainer.bounds.midY + radius * sin(currentAngle)
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            orbit.path = path.cgPath
            orbit.duration = 4.0
            orbit.repeatCount = .infinity
            orbit.calculationMode = .linear
            dot.layer.add(orbit, forKey: "orbit")
        }
    }
    
    private func animateAppName() {
        // Fade in app name
        UIView.animate(
            withDuration: 0.8,
            delay: 0.5,
            options: .curveEaseOut,
            animations: { [weak self] in
                self?.appNameLabel.alpha = 1.0
                self?.appNameLabel.transform = CGAffineTransform(translationX: 0, y: -10)
            }
        )
        
        // Fade in tagline
        UIView.animate(
            withDuration: 0.8,
            delay: 0.8,
            options: .curveEaseOut,
            animations: { [weak self] in
                self?.taglineLabel.alpha = 1.0
            }
        )
        
        // Subtle pulse on app name
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                options: [.repeat, .autoreverse, .curveEaseInOut],
                animations: {
                    self?.appNameLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                }
            )
        }
    }
    
    private func animateParticles() {
        for (index, particle) in particles.enumerated() {
            let delay = Double.random(in: 0...1.0)
            let duration = Double.random(in: 2.0...4.0)
            
            // Fade in
            UIView.animate(withDuration: 0.5, delay: delay) {
                particle.alpha = 1.0
            }
            
            // Float animation
            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: [.repeat, .autoreverse, .curveEaseInOut],
                animations: {
                    let randomY = CGFloat.random(in: -30...30)
                    let randomX = CGFloat.random(in: -20...20)
                    particle.transform = CGAffineTransform(translationX: randomX, y: randomY)
                }
            )
            
            // Rotation
            let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.fromValue = 0
            rotation.toValue = CGFloat.pi * 2
            rotation.duration = Double.random(in: 3.0...6.0)
            rotation.repeatCount = .infinity
            particle.layer.add(rotation, forKey: "particleRotation\(index)")
        }
    }
    
    private func fadeOutAndComplete() {
        // Stop all animations
        view.layer.removeAllAnimations()
        gradientLayer.removeAllAnimations()
        
        // Fade out everything
        UIView.animate(
            withDuration: 0.5,
            animations: { [weak self] in
                self?.view.alpha = 0
            },
            completion: { [weak self] _ in
                self?.triggerHaptic()
                self?.onComplete?()
            }
        )
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
