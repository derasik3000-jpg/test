//
//  MoodPickerCard.swift
//  DAYTRACE
//
//  Mood picker component
//

import UIKit

final class MoodPickerCard: UIView {
    
    var onMoodSelected: ((MoodState) -> Void)?
    
    private var selectedMood: MoodState = .neutral
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "How's your day?"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var moodButtons: [MoodState: UIButton] = [:]
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = ColorPalette.surface
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(moodStack)
        
        createMoodButtons()
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 140),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            moodStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            moodStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            moodStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            moodStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func createMoodButtons() {
        let moods: [(MoodState, String)] = [
            (.low, "😔"),
            (.neutral, "😐"),
            (.high, "😊")
        ]
        
        for (mood, emoji) in moods {
            let button = UIButton(type: .system)
            button.setTitle(emoji, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 40)
            button.backgroundColor = ColorPalette.primary.withAlphaComponent(0.2)
            button.layer.cornerRadius = 12
            button.tag = mood.hashValue
            button.addTarget(self, action: #selector(moodTapped(_:)), for: .touchUpInside)
            
            moodButtons[mood] = button
            moodStack.addArrangedSubview(button)
        }
        
        updateSelection()
    }
    
    @objc private func moodTapped(_ sender: UIButton) {
        if let mood = moodButtons.first(where: { $0.value == sender })?.key {
            selectedMood = mood
            updateSelection()
            onMoodSelected?(mood)
            
            AnimationKit.springScale(view: sender, scale: 0.9)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    private func updateSelection() {
        for (mood, button) in moodButtons {
            if mood == selectedMood {
                button.backgroundColor = ColorPalette.primary
            } else {
                button.backgroundColor = ColorPalette.primary.withAlphaComponent(0.2)
            }
        }
    }
    
    func setMood(_ mood: MoodState) {
        selectedMood = mood
        updateSelection()
    }
}
