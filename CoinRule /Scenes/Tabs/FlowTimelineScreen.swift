//
//  FlowTimelineScreen.swift
//  Travel Budget Tracker
//
//  Tab 2 - Expense History Screen
//

import UIKit

class FlowTimelineScreen: UIViewController {
    
    private var records: [DailyPulseRecord] = []
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    
    private let weekCalendarCard = PulseSurface(style: .card)
    private let weekCalendarView = CalendarWeekView()
    
    private let moodFlowCard = PulseSurface(style: .card)
    private let moodFlowView = MoodFlowView()
    
    private let weekSummaryCard = PulseSurface(style: .card)
    private let weekSummaryLabel = UILabel()
    
    private let memoryAnchorCard = PulseSurface(style: .card)
    private let memoryAnchorLabel = UILabel()
    
    private let recentExpensesCard = PulseSurface(style: .card)
    private let recentExpensesStack = UIStackView()
    
    private let timelineTitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pulseBackground
        
        loadRecords()
        setupTitle()
        setupScrollView()
        setupCards()
        setupTimeline()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTimeline()
    }
    
    // MARK: - Setup
    
    private func setupTitle() {
        titleLabel.text = "History"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .pulsePrimary
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
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
    
    private func loadRecords() {
        records = PulseStorage.shared.loadAllRecords()
    }
    
    private func setupCards() {
        setupRecentExpensesCard()
        setupWeekCalendarCard()
        setupMoodFlowCard()
        setupWeekSummaryCard()
        setupMemoryAnchorCard()
        
        contentStack.addArrangedSubview(recentExpensesCard)
        contentStack.addArrangedSubview(weekCalendarCard)
        contentStack.addArrangedSubview(moodFlowCard)
        contentStack.addArrangedSubview(weekSummaryCard)
        contentStack.addArrangedSubview(memoryAnchorCard)
        
        // Timeline title
        timelineTitleLabel.text = "Daily Records"
        timelineTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        timelineTitleLabel.textColor = .pulsePrimary
        contentStack.addArrangedSubview(timelineTitleLabel)
        contentStack.setCustomSpacing(12, after: memoryAnchorCard)
    }
    
    private func setupRecentExpensesCard() {
        let titleLabel = UILabel()
        titleLabel.text = "Recent Expenses"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        recentExpensesStack.axis = .vertical
        recentExpensesStack.spacing = 8
        recentExpensesStack.alignment = .fill
        
        recentExpensesCard.addSubview(titleLabel)
        recentExpensesCard.addSubview(recentExpensesStack)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        recentExpensesStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: recentExpensesCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: recentExpensesCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: recentExpensesCard.trailingAnchor, constant: -20),
            
            recentExpensesStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            recentExpensesStack.leadingAnchor.constraint(equalTo: recentExpensesCard.leadingAnchor, constant: 20),
            recentExpensesStack.trailingAnchor.constraint(equalTo: recentExpensesCard.trailingAnchor, constant: -20),
            recentExpensesStack.bottomAnchor.constraint(equalTo: recentExpensesCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupWeekCalendarCard() {
        let titleLabel = UILabel()
        titleLabel.text = "This Week"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        weekCalendarCard.addSubview(titleLabel)
        weekCalendarCard.addSubview(weekCalendarView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        weekCalendarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: weekCalendarCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: weekCalendarCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: weekCalendarCard.trailingAnchor, constant: -20),
            
            weekCalendarView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            weekCalendarView.leadingAnchor.constraint(equalTo: weekCalendarCard.leadingAnchor, constant: 20),
            weekCalendarView.trailingAnchor.constraint(equalTo: weekCalendarCard.trailingAnchor, constant: -20),
            weekCalendarView.heightAnchor.constraint(equalToConstant: 100),
            weekCalendarView.bottomAnchor.constraint(equalTo: weekCalendarCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupMoodFlowCard() {
        let titleLabel = UILabel()
        titleLabel.text = "Mood Flow"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Last 14 days"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .pulseTextSecondary
        
        moodFlowCard.addSubview(titleLabel)
        moodFlowCard.addSubview(subtitleLabel)
        moodFlowCard.addSubview(moodFlowView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        moodFlowView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: moodFlowCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: moodFlowCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: moodFlowCard.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: moodFlowCard.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: moodFlowCard.trailingAnchor, constant: -20),
            
            moodFlowView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            moodFlowView.leadingAnchor.constraint(equalTo: moodFlowCard.leadingAnchor, constant: 20),
            moodFlowView.trailingAnchor.constraint(equalTo: moodFlowCard.trailingAnchor, constant: -20),
            moodFlowView.heightAnchor.constraint(equalToConstant: 150),
            moodFlowView.bottomAnchor.constraint(equalTo: moodFlowCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupWeekSummaryCard() {
        let titleLabel = UILabel()
        titleLabel.text = "Week Summary"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        weekSummaryLabel.font = .systemFont(ofSize: 16, weight: .regular)
        weekSummaryLabel.textColor = .pulsePrimary
        weekSummaryLabel.numberOfLines = 0
        
        weekSummaryCard.addSubview(titleLabel)
        weekSummaryCard.addSubview(weekSummaryLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        weekSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: weekSummaryCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: weekSummaryCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: weekSummaryCard.trailingAnchor, constant: -20),
            
            weekSummaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            weekSummaryLabel.leadingAnchor.constraint(equalTo: weekSummaryCard.leadingAnchor, constant: 20),
            weekSummaryLabel.trailingAnchor.constraint(equalTo: weekSummaryCard.trailingAnchor, constant: -20),
            weekSummaryLabel.bottomAnchor.constraint(equalTo: weekSummaryCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupMemoryAnchorCard() {
        let titleLabel = UILabel()
        titleLabel.text = "Biggest Expense"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .pulsePrimary
        
        memoryAnchorLabel.font = .systemFont(ofSize: 15, weight: .regular)
        memoryAnchorLabel.textColor = .pulsePrimary
        memoryAnchorLabel.numberOfLines = 0
        
        memoryAnchorCard.addSubview(titleLabel)
        memoryAnchorCard.addSubview(memoryAnchorLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        memoryAnchorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: memoryAnchorCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: memoryAnchorCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: memoryAnchorCard.trailingAnchor, constant: -20),
            
            memoryAnchorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            memoryAnchorLabel.leadingAnchor.constraint(equalTo: memoryAnchorCard.leadingAnchor, constant: 20),
            memoryAnchorLabel.trailingAnchor.constraint(equalTo: memoryAnchorCard.trailingAnchor, constant: -20),
            memoryAnchorLabel.bottomAnchor.constraint(equalTo: memoryAnchorCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTimeline() {
        // Удаляем только day nodes, оставляем карточки
        let dayNodes = contentStack.arrangedSubviews.filter { $0 is DayNodeView }
        dayNodes.forEach { $0.removeFromSuperview() }
        
        if records.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Start tracking expenses to see your history"
            emptyLabel.font = .systemFont(ofSize: 17, weight: .regular)
            emptyLabel.textColor = .pulseTextSecondary
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            contentStack.addArrangedSubview(emptyLabel)
        } else {
            for record in records {
                let dayNode = DayNodeView(record: record)
                dayNode.delegate = self
                contentStack.addArrangedSubview(dayNode)
            }
        }
    }
    
    private func refreshTimeline() {
        loadRecords()
        updateCards()
        setupTimeline()
    }
    
    private func updateCards() {
        updateRecentExpenses()
        weekCalendarView.configure(with: records)
        moodFlowView.configure(with: records)
        updateWeekSummary()
        updateMemoryAnchor()
    }
    
    private func updateRecentExpenses() {
        recentExpensesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Получаем все траты из последних записей и сортируем по времени (новые сверху)
        let allBeats = records.prefix(7).flatMap { $0.beats }
        let sortedBeats = allBeats.sorted { $0.timestamp > $1.timestamp }
        let recentBeats = Array(sortedBeats.prefix(5))
        
        if recentBeats.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No expenses yet"
            emptyLabel.font = .systemFont(ofSize: 14, weight: .regular)
            emptyLabel.textColor = .pulseTextSecondary
            emptyLabel.textAlignment = .center
            recentExpensesStack.addArrangedSubview(emptyLabel)
        } else {
            for beat in recentBeats {
                let beatRow = createExpenseRow(beat: beat)
                recentExpensesStack.addArrangedSubview(beatRow)
            }
        }
    }
    
    private func createExpenseRow(beat: Beat) -> UIView {
        let container = UIView()
        container.backgroundColor = .pulsePrimaryLight
        container.layer.cornerRadius = 8
        
        // Category emoji
        let categoryLabel = UILabel()
        categoryLabel.text = beat.category.emoji
        categoryLabel.font = .systemFont(ofSize: 20)
        
        // Amount
        let amountLabel = UILabel()
        amountLabel.text = String(format: "$%.2f", beat.amount)
        amountLabel.font = .systemFont(ofSize: 15, weight: .bold)
        amountLabel.textColor = .pulsePrimary
        
        // Note or category name
        let noteLabel = UILabel()
        if let note = beat.note, !note.isEmpty {
            noteLabel.text = note
        } else {
            noteLabel.text = beat.category.displayName
        }
        noteLabel.font = .systemFont(ofSize: 13, weight: .regular)
        noteLabel.textColor = .pulseTextSecondary
        noteLabel.numberOfLines = 1
        
        // Feeling emoji
        let feelingLabel = UILabel()
        feelingLabel.text = beat.mood.emoji
        feelingLabel.font = .systemFont(ofSize: 16)
        
        // Time
        let timeLabel = UILabel()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: beat.timestamp)
        timeLabel.font = .systemFont(ofSize: 11, weight: .regular)
        timeLabel.textColor = .pulseTextSecondary
        
        container.addSubview(categoryLabel)
        container.addSubview(amountLabel)
        container.addSubview(noteLabel)
        container.addSubview(timeLabel)
        container.addSubview(feelingLabel)
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        feelingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            
            categoryLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            categoryLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            amountLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 12),
            amountLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            
            noteLabel.leadingAnchor.constraint(equalTo: amountLabel.leadingAnchor),
            noteLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 2),
            noteLabel.trailingAnchor.constraint(lessThanOrEqualTo: feelingLabel.leadingAnchor, constant: -8),
            
            timeLabel.leadingAnchor.constraint(equalTo: noteLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 2),
            
            feelingLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            feelingLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func updateWeekSummary() {
        let weekRecords = Array(records.prefix(7))
        guard !weekRecords.isEmpty else {
            weekSummaryLabel.text = "Start tracking to see your week summary"
            return
        }
        
        let cheapDays = weekRecords.filter { record in
            guard !record.beats.isEmpty else { return false }
            let cheapCount = record.beats.filter { $0.mood == .cheap }.count
            return cheapCount > record.beats.count / 2
        }.count
        
        let expensiveDays = weekRecords.filter { record in
            guard !record.beats.isEmpty else { return false }
            let expensiveCount = record.beats.filter { $0.mood == .expensive }.count
            return expensiveCount > record.beats.count / 2
        }.count
        
        let activeDays = weekRecords.filter { !$0.beats.isEmpty }.count
        
        var summary = ""
        
        // Emoji и основная статистика
        if cheapDays > expensiveDays {
            summary += "💵  Budget-Friendly Week\n\n"
        } else if expensiveDays > cheapDays {
            summary += "💸  High Spending Week\n\n"
        } else {
            summary += "📊  Balanced Week\n\n"
        }
        
        let weekTotal = weekRecords.reduce(0) { $0 + $1.totalAmount }
        summary += String(format: "$%.2f spent across %d active days\n", weekTotal, activeDays)
        summary += String(format: "Average: $%.2f per day\n\n", weekTotal / Double(max(activeDays, 1)))
        
        // Инсайт
        if cheapDays > 4 {
            summary += "Great job finding good deals this week"
        } else if expensiveDays > 4 {
            summary += "High spending detected - review your budget"
        } else if activeDays == 7 {
            summary += "Perfect tracking consistency!"
        } else {
            summary += "Keep tracking to build better habits"
        }
        
        weekSummaryLabel.text = summary
    }
    
    private func updateMemoryAnchor() {
        // Находим самую большую единичную трату
        let allBeats = records.flatMap { $0.beats }
        
        guard let biggestExpense = allBeats.max(by: { $0.amount < $1.amount }) else {
            memoryAnchorLabel.text = "No expenses tracked yet"
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: biggestExpense.timestamp)
        
        // Формируем текст
        var text = String(format: "%@ %@\n$%.2f", biggestExpense.category.emoji, biggestExpense.category.displayName, biggestExpense.amount)
        text += String(format: "\n%@ • %@", dateStr, biggestExpense.mood.emoji)
        
        // Добавляем заметку если есть
        if let note = biggestExpense.note, !note.isEmpty {
            text += String(format: "\n\n💭 \"%@\"", note)
        }
        
        memoryAnchorLabel.text = text
    }
}

// MARK: - DayNodeDelegate

extension FlowTimelineScreen: DayNodeDelegate {
    func didTapNode(_ node: DayNodeView, record: DailyPulseRecord) {
        PulseHaptics.selection()
        
        let detailVC = DayDetailScreen(record: record)
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .pageSheet
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navController, animated: true)
    }
}

// MARK: - DayNodeView

protocol DayNodeDelegate: AnyObject {
    func didTapNode(_ node: DayNodeView, record: DailyPulseRecord)
}

class DayNodeView: UIView {
    
    weak var delegate: DayNodeDelegate?
    
    private let record: DailyPulseRecord
    
    private let containerView = PulseSurface(style: .card)
    private let dateLabel = UILabel()
    private let beatCountLabel = UILabel()
    private let pulseIndicator = UIView()
    private let chevronIcon = UIImageView()
    
    init(record: DailyPulseRecord) {
        self.record = record
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = formatter.string(from: record.date)
        dateLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        dateLabel.textColor = .pulsePrimary
        
        // Expense info
        let totalAmount = record.totalAmount
        beatCountLabel.text = String(format: "$%.2f • %d expenses", totalAmount, record.beats.count)
        beatCountLabel.font = .systemFont(ofSize: 15, weight: .regular)
        beatCountLabel.textColor = .pulseTextSecondary
        
        // Pulse indicator
        pulseIndicator.backgroundColor = getMoodColor()
        pulseIndicator.layer.cornerRadius = 20
        
        // Chevron icon
        chevronIcon.image = UIImage(systemName: "chevron.right")
        chevronIcon.tintColor = .pulseTextSecondary
        chevronIcon.contentMode = .scaleAspectFit
        
        containerView.addSubview(pulseIndicator)
        containerView.addSubview(dateLabel)
        containerView.addSubview(beatCountLabel)
        containerView.addSubview(chevronIcon)
        
        pulseIndicator.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        beatCountLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pulseIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            pulseIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            pulseIndicator.widthAnchor.constraint(equalToConstant: 40),
            pulseIndicator.heightAnchor.constraint(equalToConstant: 40),
            
            dateLabel.leadingAnchor.constraint(equalTo: pulseIndicator.trailingAnchor, constant: 16),
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: chevronIcon.leadingAnchor, constant: -12),
            
            beatCountLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            beatCountLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            beatCountLabel.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            beatCountLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            chevronIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronIcon.widthAnchor.constraint(equalToConstant: 20),
            chevronIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nodeTapped))
        containerView.addGestureRecognizer(tapGesture)
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
    
    @objc private func nodeTapped() {
        delegate?.didTapNode(self, record: record)
    }
}
