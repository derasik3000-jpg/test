//
//  TimelineCell.swift
//  DAYTRACE
//
//  Timeline cell component
//

import UIKit

final class TimelineCell: UITableViewCell {
    
    private var isExpanded = false
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.surface
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alpha = 0
        stack.isHidden = true
        return stack
    }()
    
    private let streakIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primary
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(streakIndicator)
        cardView.addSubview(dateLabel)
        cardView.addSubview(moodLabel)
        cardView.addSubview(actionsCountLabel)
        cardView.addSubview(detailsStack)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            streakIndicator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            streakIndicator.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            streakIndicator.widthAnchor.constraint(equalToConstant: 6),
            streakIndicator.heightAnchor.constraint(equalToConstant: 30),
            
            dateLabel.leadingAnchor.constraint(equalTo: streakIndicator.trailingAnchor, constant: 12),
            dateLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            
            moodLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            moodLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            
            actionsCountLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            actionsCountLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            actionsCountLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            detailsStack.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            detailsStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            detailsStack.topAnchor.constraint(equalTo: actionsCountLabel.bottomAnchor, constant: 8),
            detailsStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with trace: DailyTrace) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = formatter.string(from: trace.date)
        
        switch trace.mood {
        case .low:
            moodLabel.text = "😔"
        case .neutral:
            moodLabel.text = "😐"
        case .high:
            moodLabel.text = "😊"
        }
        
        let doneCount = trace.actions.filter { $0.state == .done }.count
        actionsCountLabel.text = "\(doneCount)/\(trace.actions.count) completed"
        
        detailsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for action in trace.actions {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14)
            label.textColor = .white.withAlphaComponent(0.8)
            
            let stateEmoji: String
            switch action.state {
            case .done: stateEmoji = "✅"
            case .skipped: stateEmoji = "⏭️"
            case .pending: stateEmoji = "⏳"
            }
            
            label.text = "\(stateEmoji) \(action.text)"
            detailsStack.addArrangedSubview(label)
        }
        
        if Calendar.current.isDateInToday(trace.date) {
            cardView.alpha = 1.0
        } else {
            let daysSince = Calendar.current.dateComponents([.day], from: trace.date, to: Date()).day ?? 0
            cardView.alpha = max(0.5, 1.0 - Double(daysSince) * 0.05)
        }
    }
    
    func toggleExpansion() {
        isExpanded.toggle()
        
        UIView.animate(withDuration: 0.3) {
            self.detailsStack.alpha = self.isExpanded ? 1 : 0
            self.detailsStack.isHidden = !self.isExpanded
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
