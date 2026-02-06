//
//  DayDetailScreen.swift
//  PULSE
//
//  Day Detail Screen - Full screen view for a single day's beats
//

import UIKit

class DayDetailScreen: UIViewController {
    
    private let record: DailyPulseRecord
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let headerView = UIView()
    private let dateLabel = UILabel()
    private let beatCountLabel = UILabel()
    private let moodIndicatorView = UIView()
    
    private let beatsSection = UIStackView()
    
    init(record: DailyPulseRecord) {
        self.record = record
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pulseBackground
        
        setupNavigationBar()
        setupScrollView()
        setupHeader()
        setupBeatsSection()
        loadBeats()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        closeButton.tintColor = .pulseTextSecondary
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.alignment = .fill
        
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func setupHeader() {
        headerView.backgroundColor = .pulseSurface
        headerView.layer.cornerRadius = 20
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor.pulsePrimary.withAlphaComponent(0.2).cgColor
        
        // Date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        dateLabel.text = formatter.string(from: record.date)
        dateLabel.font = .systemFont(ofSize: 28, weight: .bold)
        dateLabel.textColor = .pulsePrimary
        dateLabel.numberOfLines = 0
        
        // Beat count and total amount
        let totalAmount = record.totalAmount
        beatCountLabel.text = String(format: "$%.2f • %d expenses", totalAmount, record.beats.count)
        beatCountLabel.font = .systemFont(ofSize: 17, weight: .medium)
        beatCountLabel.textColor = .pulseTextSecondary
        
        // Mood indicator (large circle)
        moodIndicatorView.backgroundColor = getMoodColor()
        moodIndicatorView.layer.cornerRadius = 40
        
        // Mood breakdown
        let moodBreakdownStack = createMoodBreakdown()
        
        headerView.addSubview(moodIndicatorView)
        headerView.addSubview(dateLabel)
        headerView.addSubview(beatCountLabel)
        headerView.addSubview(moodBreakdownStack)
        
        moodIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        beatCountLabel.translatesAutoresizingMaskIntoConstraints = false
        moodBreakdownStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            moodIndicatorView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            moodIndicatorView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            moodIndicatorView.widthAnchor.constraint(equalToConstant: 80),
            moodIndicatorView.heightAnchor.constraint(equalToConstant: 80),
            
            dateLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            dateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            dateLabel.trailingAnchor.constraint(equalTo: moodIndicatorView.leadingAnchor, constant: -20),
            
            beatCountLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            beatCountLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            beatCountLabel.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            
            moodBreakdownStack.topAnchor.constraint(equalTo: moodIndicatorView.bottomAnchor, constant: 20),
            moodBreakdownStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            moodBreakdownStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            moodBreakdownStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24)
        ])
        
        contentStack.addArrangedSubview(headerView)
    }
    
    private func createMoodBreakdown() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        
        let cheapCount = record.beats.filter { $0.mood == .cheap }.count
        let normalCount = record.beats.filter { $0.mood == .normal }.count
        let expensiveCount = record.beats.filter { $0.mood == .expensive }.count
        
        stack.addArrangedSubview(createMoodPill(emoji: "💵", label: "Cheap", count: cheapCount, color: .pulseCalm))
        stack.addArrangedSubview(createMoodPill(emoji: "💰", label: "Normal", count: normalCount, color: .pulseSurface))
        stack.addArrangedSubview(createMoodPill(emoji: "💸", label: "Expensive", count: expensiveCount, color: .pulseIntense))
        
        return stack
    }
    
    private func createMoodPill(emoji: String, label: String, count: Int, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.15)
        container.layer.cornerRadius = 12
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.textAlignment = .center
        
        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = .systemFont(ofSize: 20, weight: .bold)
        countLabel.textColor = .pulsePrimary
        countLabel.textAlignment = .center
        
        let nameLabel = UILabel()
        nameLabel.text = label
        nameLabel.font = .systemFont(ofSize: 11, weight: .medium)
        nameLabel.textColor = .pulseTextSecondary
        nameLabel.textAlignment = .center
        
        container.addSubview(emojiLabel)
        container.addSubview(countLabel)
        container.addSubview(nameLabel)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            emojiLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            countLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 4),
            countLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 2),
            nameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func setupBeatsSection() {
        let titleLabel = UILabel()
        titleLabel.text = "All Expenses"
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        beatsSection.axis = .vertical
        beatsSection.spacing = 12
        beatsSection.alignment = .fill
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(beatsSection)
    }
    
    private func loadBeats() {
        // Сортируем beats по времени (новые сверху)
        let sortedBeats = record.beats.sorted { $0.timestamp > $1.timestamp }
        
        if sortedBeats.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No beats recorded this day"
            emptyLabel.font = .systemFont(ofSize: 15, weight: .regular)
            emptyLabel.textColor = .pulseTextSecondary
            emptyLabel.textAlignment = .center
            beatsSection.addArrangedSubview(emptyLabel)
        } else {
            for beat in sortedBeats {
                let beatCard = createBeatCard(beat: beat)
                beatsSection.addArrangedSubview(beatCard)
            }
        }
    }
    
    private func createBeatCard(beat: Beat) -> UIView {
        let card = PulseSurface(style: .card)
        
        // Category emoji (left side, large)
        let categoryLabel = UILabel()
        categoryLabel.text = beat.category.emoji
        categoryLabel.font = .systemFont(ofSize: 40)
        
        // Amount (top right, large and bold)
        let amountLabel = UILabel()
        amountLabel.text = String(format: "$%.2f", beat.amount)
        amountLabel.font = .systemFont(ofSize: 24, weight: .bold)
        amountLabel.textColor = .pulsePrimary
        
        // Category name
        let categoryNameLabel = UILabel()
        categoryNameLabel.text = beat.category.displayName
        categoryNameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        categoryNameLabel.textColor = .pulsePrimary
        
        // Time
        let timeLabel = UILabel()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: beat.timestamp)
        timeLabel.font = .systemFont(ofSize: 13, weight: .regular)
        timeLabel.textColor = .pulseTextSecondary
        
        // Mood indicator (small, on the right)
        let moodLabel = UILabel()
        moodLabel.text = "\(beat.mood.emoji) \(beat.mood.displayName)"
        moodLabel.font = .systemFont(ofSize: 13, weight: .medium)
        moodLabel.textColor = .pulseTextSecondary
        
        card.addSubview(categoryLabel)
        card.addSubview(amountLabel)
        card.addSubview(categoryNameLabel)
        card.addSubview(timeLabel)
        card.addSubview(moodLabel)
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Category emoji on the left
            categoryLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            categoryLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            categoryLabel.widthAnchor.constraint(equalToConstant: 50),
            categoryLabel.heightAnchor.constraint(equalToConstant: 50),
            
            // Amount on the top right
            amountLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: categoryLabel.trailingAnchor, constant: 12),
            
            // Category name below emoji
            categoryNameLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            categoryNameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            categoryNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -20),
            
            // Time next to category name
            timeLabel.firstBaselineAnchor.constraint(equalTo: categoryNameLabel.firstBaselineAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: categoryNameLabel.trailingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -20),
            
            // Mood indicator below amount
            moodLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 6),
            moodLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])
        
        // Note if exists
        if let note = beat.note, !note.isEmpty {
            let noteLabel = UILabel()
            noteLabel.text = "💭 \"\(note)\""
            noteLabel.font = .systemFont(ofSize: 14, weight: .regular)
            noteLabel.textColor = .pulsePrimary
            noteLabel.numberOfLines = 0
            
            let noteContainer = UIView()
            noteContainer.backgroundColor = .pulsePrimaryLight
            noteContainer.layer.cornerRadius = 12
            
            noteContainer.addSubview(noteLabel)
            card.addSubview(noteContainer)
            
            noteLabel.translatesAutoresizingMaskIntoConstraints = false
            noteContainer.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                // Position note container below the lower of categoryNameLabel or moodLabel
                noteContainer.topAnchor.constraint(greaterThanOrEqualTo: categoryNameLabel.bottomAnchor, constant: 12),
                noteContainer.topAnchor.constraint(greaterThanOrEqualTo: moodLabel.bottomAnchor, constant: 12),
                noteContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
                noteContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
                noteContainer.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
                
                noteLabel.topAnchor.constraint(equalTo: noteContainer.topAnchor, constant: 10),
                noteLabel.leadingAnchor.constraint(equalTo: noteContainer.leadingAnchor, constant: 12),
                noteLabel.trailingAnchor.constraint(equalTo: noteContainer.trailingAnchor, constant: -12),
                noteLabel.bottomAnchor.constraint(equalTo: noteContainer.bottomAnchor, constant: -10)
            ])
        } else {
            // If no note, create a spacer view to ensure proper bottom padding
            let spacerView = UIView()
            card.addSubview(spacerView)
            spacerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                spacerView.topAnchor.constraint(greaterThanOrEqualTo: categoryNameLabel.bottomAnchor, constant: 8),
                spacerView.topAnchor.constraint(greaterThanOrEqualTo: moodLabel.bottomAnchor, constant: 8),
                spacerView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
                spacerView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
                spacerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
                spacerView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
            ])
        }
        
        return card
    }
    
    private func getMoodColor() -> UIColor {
        guard !record.beats.isEmpty else { return .pulseSurface }
        
        let moodCounts = record.beats.reduce(into: [Mood: Int]()) { counts, beat in
            counts[beat.mood, default: 0] += 1
        }
        
        let dominantMood = moodCounts.max(by: { $0.value < $1.value })?.key ?? .normal
        
        switch dominantMood {
        case .cheap: return .pulseCalm
        case .normal: return .pulseSurface
        case .expensive: return .pulseIntense
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        PulseHaptics.medium()
        dismiss(animated: true)
    }
}
