//
//  OnboardingPage.swift
//  DAYTRACE
//
//  Single onboarding page with animations
//

import UIKit

final class OnboardingPage: UIView {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 80)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.surface.withAlphaComponent(0.5)
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Floating particles
    private var particles: [UIView] = []
    
    init(emoji: String, title: String, description: String, pageIndex: Int) {
        super.init(frame: .zero)
        emojiLabel.text = emoji
        titleLabel.text = title
        descriptionLabel.text = description
        setupUI()
        startAnimation(delay: Double(pageIndex) * 0.15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            emojiLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40)
        ])
        
        // Create floating particles
        createParticles()
    }
    
    private func createParticles() {
        for i in 0..<8 {
            let particle = UIView()
            particle.backgroundColor = ColorPalette.primary.withAlphaComponent(0.3)
            particle.layer.cornerRadius = CGFloat.random(in: 3...8)
            particle.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(particle)
            sendSubviewToBack(particle)
            particles.append(particle)
            
            let size = CGFloat.random(in: 6...16)
            NSLayoutConstraint.activate([
                particle.widthAnchor.constraint(equalToConstant: size),
                particle.heightAnchor.constraint(equalToConstant: size)
            ])
            
            // Random position
            particle.center = CGPoint(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 200)
            )
        }
    }
    
    private func startAnimation(delay: TimeInterval) {
        // Initial state
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: 50)
        emojiLabel.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        titleLabel.alpha = 0
        descriptionLabel.alpha = 0
        
        // Container animation
        UIView.animate(
            withDuration: 0.8,
            delay: delay,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.3,
            options: [],
            animations: {
                self.containerView.alpha = 1
                self.containerView.transform = .identity
            }
        )
        
        // Emoji animation
        UIView.animate(
            withDuration: 0.6,
            delay: delay + 0.2,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: [],
            animations: {
                self.emojiLabel.transform = .identity
            }
        )
        
        // Title animation
        UIView.animate(
            withDuration: 0.5,
            delay: delay + 0.4,
            options: [.curveEaseOut],
            animations: {
                self.titleLabel.alpha = 1
            }
        )
        
        // Description animation
        UIView.animate(
            withDuration: 0.5,
            delay: delay + 0.6,
            options: [.curveEaseOut],
            animations: {
                self.descriptionLabel.alpha = 1
            }
        )
        
        // Animate particles
        animateParticles(delay: delay)
        
        // Continuous emoji pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 1.0) {
            self.startEmojiPulse()
        }
    }
    
    private func animateParticles(delay: TimeInterval) {
        for (index, particle) in particles.enumerated() {
            particle.alpha = 0
            
            UIView.animate(
                withDuration: 1.5,
                delay: delay + Double(index) * 0.1,
                options: [.repeat, .autoreverse],
                animations: {
                    particle.alpha = 0.6
                    particle.transform = CGAffineTransform(translationX: CGFloat.random(in: -30...30), y: CGFloat.random(in: -50...50))
                }
            )
        }
    }
    
    private func startEmojiPulse() {
        UIView.animate(
            withDuration: 1.5,
            delay: 0,
            options: [.repeat, .autoreverse, .allowUserInteraction],
            animations: {
                self.emojiLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        )
    }
}
