//
//  GreetingCard.swift
//  DAYTRACE
//
//  Time-based greeting card with user avatar
//

import UIKit

final class GreetingCard: UIView {
    
    var onAvatarTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let avatarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 28
        btn.backgroundColor = ColorPalette.primary.withAlphaComponent(0.1)
        btn.titleLabel?.font = .systemFont(ofSize: 32)
        return btn
    }()
    
    private let greetingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = ColorPalette.primary
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = ColorPalette.primary.withAlphaComponent(0.7)
        return label
    }()
    
    private let sunIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let iv = UIImageView()
        iv.image = UIImage(systemName: "sun.max.fill", withConfiguration: config)
        iv.tintColor = ColorPalette.primary
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
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
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(avatarButton)
        addSubview(greetingStack)
        addSubview(sunIcon)
        
        greetingStack.addArrangedSubview(greetingLabel)
        greetingStack.addArrangedSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            avatarButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarButton.widthAnchor.constraint(equalToConstant: 56),
            avatarButton.heightAnchor.constraint(equalToConstant: 56),
            
            greetingStack.leadingAnchor.constraint(equalTo: avatarButton.trailingAnchor, constant: 14),
            greetingStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            greetingStack.trailingAnchor.constraint(lessThanOrEqualTo: sunIcon.leadingAnchor, constant: -12),
            
            sunIcon.trailingAnchor.constraint(equalTo: trailingAnchor),
            sunIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            sunIcon.widthAnchor.constraint(equalToConstant: 28),
            sunIcon.heightAnchor.constraint(equalToConstant: 28),
            
            heightAnchor.constraint(equalToConstant: 70)
        ])
        
        avatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
        
        // Animate sun icon
        animateSunIcon()
    }
    
    // MARK: - Configuration
    
    func configure(avatar: String, date: Date) {
        avatarButton.setTitle(avatar, for: .normal)
        
        let greeting = getTimeBasedGreeting()
        greetingLabel.text = greeting.text
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        dateLabel.text = formatter.string(from: date)
        
        updateSunIcon(for: greeting.period)
    }
    
    // MARK: - Helpers
    
    private enum TimePeriod {
        case morning, afternoon, evening, night
    }
    
    private struct Greeting {
        let text: String
        let period: TimePeriod
    }
    
    private func getTimeBasedGreeting() -> Greeting {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return Greeting(text: "Good morning", period: .morning)
        case 12..<17:
            return Greeting(text: "Good afternoon", period: .afternoon)
        case 17..<21:
            return Greeting(text: "Good evening", period: .evening)
        default:
            return Greeting(text: "Good night", period: .night)
        }
    }
    
    private func updateSunIcon(for period: TimePeriod) {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        
        switch period {
        case .morning:
            sunIcon.image = UIImage(systemName: "sun.max.fill", withConfiguration: config)
            sunIcon.tintColor = ColorPalette.primary
        case .afternoon:
            sunIcon.image = UIImage(systemName: "sun.max.fill", withConfiguration: config)
            sunIcon.tintColor = ColorPalette.primary
        case .evening:
            sunIcon.image = UIImage(systemName: "sunset.fill", withConfiguration: config)
            sunIcon.tintColor = ColorPalette.primary.withAlphaComponent(0.8)
        case .night:
            sunIcon.image = UIImage(systemName: "moon.stars.fill", withConfiguration: config)
            sunIcon.tintColor = ColorPalette.primary.withAlphaComponent(0.6)
        }
    }
    
    private func animateSunIcon() {
        UIView.animate(
            withDuration: 2.0,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: {
                self.sunIcon.transform = CGAffineTransform(rotationAngle: .pi / 12)
            }
        )
    }
    
    @objc private func avatarTapped() {
        AnimationKit.springScale(view: avatarButton)
        onAvatarTapped?()
    }
}
