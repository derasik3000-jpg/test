//
//  EnhancedTimelineCell.swift
//  DAYTRACE
//
//  Enhanced timeline cell with visual timeline connector and rich information
//

import UIKit

final class EnhancedTimelineCell: UITableViewCell {
    
    static let identifier = "EnhancedTimelineCell"
    
    // MARK: - UI Components
    
    private let timelineConnector: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primary.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timelineDot: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = ColorPalette.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dotInner: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.surface
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.6)
        return label
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let moodBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = ColorPalette.primary.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let moodLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let tasksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    private let progressView: MiniProgressView = {
        let view = MiniProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let chevronIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        iv.tintColor = .white.withAlphaComponent(0.3)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
        timelineConnector.alpha = 1
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(timelineConnector)
        contentView.addSubview(timelineDot)
        timelineDot.addSubview(dotInner)
        contentView.addSubview(cardView)
        
        cardView.addSubview(dateStack)
        dateStack.addArrangedSubview(dayLabel)
        dateStack.addArrangedSubview(weekdayLabel)
        
        cardView.addSubview(moodBadge)
        moodBadge.addSubview(moodLabel)
        
        cardView.addSubview(contentStack)
        contentStack.addArrangedSubview(tasksLabel)
        contentStack.addArrangedSubview(progressView)
        
        cardView.addSubview(chevronIcon)
        
        NSLayoutConstraint.activate([
            timelineConnector.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 7),
            timelineConnector.topAnchor.constraint(equalTo: contentView.topAnchor),
            timelineConnector.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            timelineConnector.widthAnchor.constraint(equalToConstant: 2),
            
            timelineDot.centerXAnchor.constraint(equalTo: timelineConnector.centerXAnchor),
            timelineDot.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            timelineDot.widthAnchor.constraint(equalToConstant: 16),
            timelineDot.heightAnchor.constraint(equalToConstant: 16),
            
            dotInner.centerXAnchor.constraint(equalTo: timelineDot.centerXAnchor),
            dotInner.centerYAnchor.constraint(equalTo: timelineDot.centerYAnchor),
            dotInner.widthAnchor.constraint(equalToConstant: 8),
            dotInner.heightAnchor.constraint(equalToConstant: 8),
            
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: timelineConnector.trailingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            dateStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            dateStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            dateStack.widthAnchor.constraint(equalToConstant: 44),
            
            moodBadge.leadingAnchor.constraint(equalTo: dateStack.trailingAnchor, constant: 12),
            moodBadge.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            moodBadge.widthAnchor.constraint(equalToConstant: 40),
            moodBadge.heightAnchor.constraint(equalToConstant: 40),
            
            moodLabel.centerXAnchor.constraint(equalTo: moodBadge.centerXAnchor),
            moodLabel.centerYAnchor.constraint(equalTo: moodBadge.centerYAnchor),
            
            contentStack.leadingAnchor.constraint(equalTo: moodBadge.trailingAnchor, constant: 14),
            contentStack.trailingAnchor.constraint(equalTo: chevronIcon.leadingAnchor, constant: -12),
            contentStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            progressView.heightAnchor.constraint(equalToConstant: 6),
            
            chevronIcon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevronIcon.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronIcon.widthAnchor.constraint(equalToConstant: 14),
            chevronIcon.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with trace: DailyTrace, isFirst: Bool, isLast: Bool) {
        // Date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: trace.date)
        dayLabel.text = "\(day)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        weekdayLabel.text = formatter.string(from: trace.date).uppercased()
        
        // Mood
        switch trace.mood {
        case .low:
            moodLabel.text = "😔"
        case .neutral:
            moodLabel.text = "😊"
        case .high:
            moodLabel.text = "🚀"
        }
        
        // Stats
        let total = trace.actions.count
        let completed = trace.actions.filter { $0.state == .done }.count
        
        if total == 0 {
            tasksLabel.text = "No tasks"
            progressView.setProgress(0)
        } else {
            tasksLabel.text = "\(completed)/\(total) completed"
            progressView.setProgress(CGFloat(completed) / CGFloat(total))
        }
        
        // Timeline dot color based on completion - всегда желтый
        if total > 0 && completed == total {
            timelineDot.backgroundColor = ColorPalette.primary
        } else if completed > 0 {
            timelineDot.backgroundColor = ColorPalette.primary.withAlphaComponent(0.7)
        } else {
            timelineDot.backgroundColor = ColorPalette.primary.withAlphaComponent(0.4)
        }
    }
    
    func highlight() {
        UIView.animate(withDuration: 0.2, animations: {
            self.cardView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            self.cardView.backgroundColor = ColorPalette.primary.withAlphaComponent(0.3)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.cardView.transform = .identity
                self.cardView.backgroundColor = ColorPalette.surface
            }
        }
    }
}

// MARK: - MiniProgressView

final class MiniProgressView: UIView {
    
    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primary.withAlphaComponent(0.2)
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let fillView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primary
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var fillWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(trackView)
        trackView.addSubview(fillView)
        
        fillWidthConstraint = fillView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.001)
        
        NSLayoutConstraint.activate([
            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            fillWidthConstraint
        ])
    }
    
    func setProgress(_ progress: CGFloat) {
        let safeProgress = min(max(progress, 0.001), 1)
        
        fillWidthConstraint.isActive = false
        fillWidthConstraint = fillView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: safeProgress)
        fillWidthConstraint.isActive = true
        
        layoutIfNeeded()
    }
}
