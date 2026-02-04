//
//  ActionCell.swift
//  DAYTRACE
//
//  Enhanced action cell with clear state button and visual feedback
//

import UIKit

final class ActionCell: UITableViewCell {
    
    static let identifier = "ActionCell"
    
    var onStateChanged: ((ActionState) -> Void)?
    
    private var currentState: ActionState = .pending
    private var currentAction: TraceAction?
    
    // MARK: - UI Components
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primary
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Category indicator
    private let categoryDot: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let actionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let metaStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .black.withAlphaComponent(0.7)
        return label
    }()
    
    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .black.withAlphaComponent(0.7)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .black.withAlphaComponent(0.5)
        return label
    }()
    
    // Large state button
    private let stateButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 20
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        return btn
    }()
    
    // Hint label (shows on first use)
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "👆 Tap to complete"
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.alpha = 0
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(categoryDot)
        cardView.addSubview(actionLabel)
        cardView.addSubview(metaStack)
        cardView.addSubview(stateButton)
        cardView.addSubview(hintLabel)
        
        metaStack.addArrangedSubview(categoryLabel)
        metaStack.addArrangedSubview(priorityLabel)
        metaStack.addArrangedSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            categoryDot.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            categoryDot.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            categoryDot.widthAnchor.constraint(equalToConstant: 8),
            categoryDot.heightAnchor.constraint(equalToConstant: 8),
            
            actionLabel.leadingAnchor.constraint(equalTo: categoryDot.trailingAnchor, constant: 12),
            actionLabel.trailingAnchor.constraint(equalTo: stateButton.leadingAnchor, constant: -12),
            actionLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            
            metaStack.leadingAnchor.constraint(equalTo: actionLabel.leadingAnchor),
            metaStack.topAnchor.constraint(equalTo: actionLabel.bottomAnchor, constant: 6),
            metaStack.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -14),
            
            stateButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            stateButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            stateButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            stateButton.heightAnchor.constraint(equalToConstant: 40),
            
            hintLabel.topAnchor.constraint(equalTo: stateButton.bottomAnchor, constant: 4),
            hintLabel.centerXAnchor.constraint(equalTo: stateButton.centerXAnchor)
        ])
        
        stateButton.addTarget(self, action: #selector(stateButtonTapped), for: .touchUpInside)
        
        // Show hint on first action
        showHintIfNeeded()
    }
    
    private func resetUI() {
        actionLabel.attributedText = nil
        hintLabel.alpha = 0
    }
    
    private func showHintIfNeeded() {
        // Show hint for first 3 pending actions
        let hasSeenHint = UserDefaults.standard.bool(forKey: "hasSeenActionHint")
        if !hasSeenHint {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.animate(withDuration: 0.3) {
                    self.hintLabel.alpha = 1.0
                }
                
                // Auto-hide after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    UIView.animate(withDuration: 0.3) {
                        self.hintLabel.alpha = 0
                    }
                    UserDefaults.standard.set(true, forKey: "hasSeenActionHint")
                }
            }
        }
    }
    
    // MARK: - Configuration
    
    func configure(with action: TraceAction) {
        currentAction = action
        currentState = action.state
        
        actionLabel.text = action.text
        
        // Category
        categoryLabel.text = "\(action.category.emoji) \(action.category.rawValue)"
        categoryDot.backgroundColor = UIColor(hexString: action.category.color)
        
        // Priority
        priorityLabel.text = action.priority.emoji
        priorityLabel.textColor = {
            switch action.priority {
            case .high: return UIColor.systemRed
            case .medium: return UIColor.systemYellow
            case .low: return UIColor.systemGreen
            }
        }()
        
        // Time
        if let minutes = action.estimatedMinutes {
            timeLabel.text = "⏱ \(minutes)m"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            timeLabel.text = formatter.string(from: action.createdAt)
        }
        
        updateStateUI(animated: false)
    }
    
    private func updateStateUI(animated: Bool) {
        let updates = {
            switch self.currentState {
            case .pending:
                // Button - черная с черным текстом
                self.stateButton.setTitle("Mark Done", for: .normal)
                self.stateButton.backgroundColor = .black.withAlphaComponent(0.3)
                self.stateButton.setTitleColor(.black, for: .normal)
                self.stateButton.layer.borderWidth = 2
                self.stateButton.layer.borderColor = UIColor.black.cgColor
                
                // Text - черный
                self.actionLabel.alpha = 1.0
                self.actionLabel.textColor = .black
                self.actionLabel.attributedText = NSAttributedString(string: self.actionLabel.text ?? "")
                
                // Card
                self.cardView.alpha = 1.0
                
            case .done:
                // Button - черная заливка с желтым текстом
                self.stateButton.setTitle("✓ Done", for: .normal)
                self.stateButton.backgroundColor = .black
                self.stateButton.setTitleColor(ColorPalette.primary, for: .normal)
                self.stateButton.layer.borderWidth = 0
                
                // Text with strikethrough - черный полупрозрачный
                self.actionLabel.alpha = 0.5
                self.actionLabel.textColor = .black
                if let text = self.actionLabel.text {
                    let attributedString = NSMutableAttributedString(string: text)
                    attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
                    attributedString.addAttribute(.foregroundColor, value: UIColor.black.withAlphaComponent(0.5), range: NSRange(location: 0, length: text.count))
                    self.actionLabel.attributedText = attributedString
                }
                
                // Card
                self.cardView.alpha = 0.7
                
            case .skipped:
                // Button - серая
                self.stateButton.setTitle("⏭ Skipped", for: .normal)
                self.stateButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                self.stateButton.setTitleColor(.black.withAlphaComponent(0.6), for: .normal)
                self.stateButton.layer.borderWidth = 1
                self.stateButton.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
                
                // Text - черный полупрозрачный
                self.actionLabel.alpha = 0.4
                self.actionLabel.textColor = .black
                self.actionLabel.attributedText = NSAttributedString(string: self.actionLabel.text ?? "")
                
                // Card
                self.cardView.alpha = 0.6
            }
            
            // Hide hint when state changes
            self.hintLabel.alpha = 0
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, animations: updates)
        } else {
            updates()
        }
    }
    
    // MARK: - Actions
    
    @objc private func stateButtonTapped() {
        // Cycle through states: pending -> done -> pending
        // Long press for skip is still available via swipe actions
        let newState: ActionState = currentState == .done ? .pending : .done
        currentState = newState
        
        updateStateUI(animated: true)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animate button
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.stateButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
                    self.stateButton.transform = .identity
                }
            }
        )
        
        onStateChanged?(newState)
    }
}

// MARK: - UIColor Extension

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
