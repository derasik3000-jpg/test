//
//  TraceDetailSheet.swift
//  DAYTRACE
//
//  Bottom sheet showing detailed view of a daily trace
//

import UIKit

final class TraceDetailSheet: UIViewController {
    
    private let trace: DailyTrace
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Header
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = ColorPalette.primary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = ColorPalette.primary.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Mood section
    private let moodCard: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.surface
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let moodEmoji: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mood"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moodDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Stats row
    private let statsRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Actions section
    private let actionsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Actions"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = ColorPalette.primary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let emptyActionsLabel: UILabel = {
        let label = UILabel()
        label.text = "No actions recorded"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = ColorPalette.primary.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    init(trace: DailyTrace) {
        self.trace = trace
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.background
        setupUI()
        configureData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        // Header
        headerView.addSubview(dateLabel)
        headerView.addSubview(dayOfWeekLabel)
        contentStack.addArrangedSubview(headerView)
        
        // Mood card
        moodCard.addSubview(moodEmoji)
        moodCard.addSubview(moodTitleLabel)
        moodCard.addSubview(moodDescriptionLabel)
        contentStack.addArrangedSubview(moodCard)
        
        // Stats
        contentStack.addArrangedSubview(statsRow)
        
        // Actions section
        contentStack.addArrangedSubview(actionsSectionLabel)
        contentStack.addArrangedSubview(actionsStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            
            // Header
            dateLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            
            dayOfWeekLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            dayOfWeekLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            dayOfWeekLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            // Mood card
            moodCard.heightAnchor.constraint(equalToConstant: 100),
            
            moodEmoji.leadingAnchor.constraint(equalTo: moodCard.leadingAnchor, constant: 20),
            moodEmoji.centerYAnchor.constraint(equalTo: moodCard.centerYAnchor),
            
            moodTitleLabel.leadingAnchor.constraint(equalTo: moodEmoji.trailingAnchor, constant: 16),
            moodTitleLabel.topAnchor.constraint(equalTo: moodCard.topAnchor, constant: 28),
            
            moodDescriptionLabel.leadingAnchor.constraint(equalTo: moodEmoji.trailingAnchor, constant: 16),
            moodDescriptionLabel.topAnchor.constraint(equalTo: moodTitleLabel.bottomAnchor, constant: 4),
            
            // Stats row
            statsRow.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func configureData() {
        // Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        dateLabel.text = formatter.string(from: trace.date)
        
        formatter.dateFormat = "EEEE"
        dayOfWeekLabel.text = formatter.string(from: trace.date)
        
        // Mood
        switch trace.mood {
        case .low:
            moodEmoji.text = "😔"
            moodDescriptionLabel.text = "Feeling Low"
        case .neutral:
            moodEmoji.text = "😊"
            moodDescriptionLabel.text = "Feeling Okay"
        case .high:
            moodEmoji.text = "🚀"
            moodDescriptionLabel.text = "Feeling Great!"
        }
        
        // Stats
        let total = trace.actions.count
        let completed = trace.actions.filter { $0.state == .done }.count
        let skipped = trace.actions.filter { $0.state == .skipped }.count
        
        let completedStat = DetailStatCard()
        completedStat.configure(value: "\(completed)", label: "Completed", color: ColorPalette.background)
        statsRow.addArrangedSubview(completedStat)
        
        let pendingStat = DetailStatCard()
        pendingStat.configure(value: "\(total - completed - skipped)", label: "Pending", color: ColorPalette.surface)
        statsRow.addArrangedSubview(pendingStat)
        
        let skippedStat = DetailStatCard()
        skippedStat.configure(value: "\(skipped)", label: "Skipped", color: ColorPalette.primary.withAlphaComponent(0.3))
        statsRow.addArrangedSubview(skippedStat)
        
        // Actions
        if trace.actions.isEmpty {
            actionsStack.addArrangedSubview(emptyActionsLabel)
        } else {
            for action in trace.actions {
                let actionRow = DetailActionRow()
                actionRow.configure(with: action)
                actionsStack.addArrangedSubview(actionRow)
            }
        }
    }
}

// MARK: - DetailStatCard

final class DetailStatCard: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.surface
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let indicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(indicator)
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            indicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            indicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 6),
            indicator.heightAnchor.constraint(equalToConstant: 6),
            
            valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(value: String, label: String, color: UIColor) {
        valueLabel.text = value
        titleLabel.text = label
        indicator.backgroundColor = color
    }
}

// MARK: - DetailActionRow

final class DetailActionRow: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.surface
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(statusIcon)
        containerView.addSubview(textLabel)
        containerView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            statusIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),
            
            textLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -12),
            textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            timeLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    func configure(with action: TraceAction) {
        textLabel.text = action.text
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeLabel.text = formatter.string(from: action.createdAt)
        
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        
        switch action.state {
        case .done:
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
            statusIcon.tintColor = ColorPalette.background
            textLabel.alpha = 0.7
            
            let attributedString = NSMutableAttributedString(string: action.text)
            attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: action.text.count))
            textLabel.attributedText = attributedString
            
        case .pending:
            statusIcon.image = UIImage(systemName: "circle", withConfiguration: config)
            statusIcon.tintColor = .white.withAlphaComponent(0.3)
            textLabel.alpha = 1
            textLabel.attributedText = nil
            textLabel.text = action.text
            
        case .skipped:
            statusIcon.image = UIImage(systemName: "arrow.uturn.right.circle", withConfiguration: config)
            statusIcon.tintColor = .white.withAlphaComponent(0.4)
            textLabel.alpha = 0.5
        }
    }
}
