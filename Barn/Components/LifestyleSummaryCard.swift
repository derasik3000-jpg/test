//
//  LifestyleSummaryCard.swift
//  DAYTRACE
//
//  Lifestyle summary component
//

import UIKit

final class LifestyleSummaryCard: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Patterns"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mostActiveDayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commonMoodLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        addSubview(mostActiveDayLabel)
        addSubview(commonMoodLabel)
        addSubview(streakLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            mostActiveDayLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            mostActiveDayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mostActiveDayLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            commonMoodLabel.topAnchor.constraint(equalTo: mostActiveDayLabel.bottomAnchor, constant: 8),
            commonMoodLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            commonMoodLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            streakLabel.topAnchor.constraint(equalTo: commonMoodLabel.bottomAnchor, constant: 8),
            streakLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            streakLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            streakLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func updateWithTraces(_ traces: [DailyTrace]) {
        if traces.isEmpty {
            mostActiveDayLabel.text = "📊 No data yet"
            commonMoodLabel.text = "😊 Start tracking to see patterns"
            streakLabel.text = "🔥 Streak: 0 days"
            return
        }
        
        // Most active day
        let sortedByActions = traces.sorted { $0.actions.count > $1.actions.count }
        if let mostActive = sortedByActions.first {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            mostActiveDayLabel.text = "📊 Most active: \(formatter.string(from: mostActive.date)) (\(mostActive.actions.count) actions)"
        }
        
        // Common mood
        let moodCounts = traces.reduce(into: [MoodState: Int]()) { counts, trace in
            counts[trace.mood, default: 0] += 1
        }
        if let commonMood = moodCounts.max(by: { $0.value < $1.value })?.key {
            let emoji: String
            switch commonMood {
            case .low: emoji = "😔"
            case .neutral: emoji = "😐"
            case .high: emoji = "😊"
            }
            commonMoodLabel.text = "😊 Common mood: \(emoji)"
        }
        
        // Streak calculation
        let streak = calculateStreak(traces: traces)
        streakLabel.text = "🔥 Current streak: \(streak) days"
    }
    
    private func calculateStreak(traces: [DailyTrace]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        for _ in 0..<30 {
            if traces.contains(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}
