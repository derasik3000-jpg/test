//
//  EnhancedMoodPickerCard.swift
//  DAYTRACE
//
//  Interactive mood picker with visual feedback
//

import UIKit

final class EnhancedMoodPickerCard: UIView {
    
    var onMoodSelected: ((MoodState) -> Void)?
    
    private var selectedMood: MoodState = .neutral
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.surface
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Daily Energy Check"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Track your energy to find your best times"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.6)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var moodButtons: [MoodButton] = []
    
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
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(moodStack)
        
        // Create mood buttons with better labels
        let moods: [(MoodState, String, String, String)] = [
            (.low, "😴", "Low", "Tired"),
            (.neutral, "😊", "Okay", "Normal"),
            (.high, "⚡️", "High", "Energized")
        ]
        
        for (mood, emoji, label, description) in moods {
            let button = MoodButton()
            button.configure(emoji: emoji, label: label, description: description, mood: mood)
            button.addTarget(self, action: #selector(moodTapped(_:)), for: .touchUpInside)
            moodButtons.append(button)
            moodStack.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            moodStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            moodStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            moodStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            heightAnchor.constraint(equalToConstant: 190)
        ])
    }
    
    // MARK: - Configuration
    
    func setMood(_ mood: MoodState) {
        selectedMood = mood
        
        for button in moodButtons {
            button.setSelected(button.mood == mood)
        }
    }
    
    // MARK: - Actions
    
    @objc private func moodTapped(_ sender: MoodButton) {
        guard let mood = sender.mood else { return }
        
        setMood(mood)
        onMoodSelected?(mood)
        
        // Animate the selected button
        AnimationKit.springScale(view: sender, scale: 0.9)
    }
}

// MARK: - MoodButton

final class MoodButton: UIButton {
    
    var mood: MoodState?
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false  // Pass touches through
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false  // Pass touches through
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 9, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false  // Pass touches through
        return label
    }()
    
    private let selectionRing: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 36
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.clear.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false  // Pass touches through
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Make entire button area tappable including all subviews
        return bounds.contains(point)
    }
    
    private func setupUI() {
        addSubview(selectionRing)
        addSubview(emojiLabel)
        addSubview(textLabel)
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            selectionRing.topAnchor.constraint(equalTo: topAnchor),
            selectionRing.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionRing.widthAnchor.constraint(equalToConstant: 72),
            selectionRing.heightAnchor.constraint(equalToConstant: 72),
            
            emojiLabel.centerXAnchor.constraint(equalTo: selectionRing.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: selectionRing.centerYAnchor),
            
            textLabel.topAnchor.constraint(equalTo: selectionRing.bottomAnchor, constant: 6),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            
            descriptionLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            widthAnchor.constraint(equalToConstant: 105),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 110)
        ])
    }
    
    func configure(emoji: String, label: String, description: String, mood: MoodState) {
        self.mood = mood
        emojiLabel.text = emoji
        textLabel.text = label
        descriptionLabel.text = description
    }
    
    func setSelected(_ isSelected: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            if isSelected {
                self.selectionRing.layer.borderColor = ColorPalette.primary.cgColor
                self.selectionRing.backgroundColor = ColorPalette.primary.withAlphaComponent(0.15)
                self.textLabel.textColor = ColorPalette.primary
                self.descriptionLabel.textColor = ColorPalette.primary.withAlphaComponent(0.8)
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            } else {
                self.selectionRing.layer.borderColor = UIColor.clear.cgColor
                self.selectionRing.backgroundColor = .clear
                self.textLabel.textColor = .white.withAlphaComponent(0.7)
                self.descriptionLabel.textColor = .white.withAlphaComponent(0.5)
                self.transform = .identity
            }
        }
    }
}
