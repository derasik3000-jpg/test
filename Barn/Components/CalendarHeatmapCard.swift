//
//  CalendarHeatmapCard.swift
//  DAYTRACE
//
//  GitHub-style calendar heatmap showing activity levels
//

import UIKit

final class CalendarHeatmapCard: UIView {
    
    var onDateSelected: ((Date) -> Void)?
    var onToggleExpansion: ((Bool) -> Void)?
    
    private var traces: [DailyTrace] = []
    private var isExpanded = true
    private var dayCells: [DayCell] = []
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.surface
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Activity"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.6)
        label.textAlignment = .right
        return label
    }()
    
    private let toggleButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: "chevron.up", withConfiguration: config), for: .normal)
        btn.tintColor = .white.withAlphaComponent(0.6)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let calendarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let weekdayLabelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let gridScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let gridStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let legendStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var calendarHeightConstraint: NSLayoutConstraint!
    
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
        containerView.addSubview(headerStack)
        containerView.addSubview(calendarContainer)
        containerView.addSubview(legendStack)
        
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(UIView()) // Spacer
        headerStack.addArrangedSubview(monthLabel)
        headerStack.addArrangedSubview(toggleButton)
        
        calendarContainer.addSubview(weekdayLabelsStack)
        calendarContainer.addSubview(gridScrollView)
        gridScrollView.addSubview(gridStack)
        
        // Weekday labels
        let weekdays = ["", "M", "", "W", "", "F", ""]
        for day in weekdays {
            let label = UILabel()
            label.text = day
            label.font = .systemFont(ofSize: 10, weight: .medium)
            label.textColor = .white.withAlphaComponent(0.4)
            label.textAlignment = .center
            weekdayLabelsStack.addArrangedSubview(label)
        }
        
        // Legend
        setupLegend()
        
        calendarHeightConstraint = calendarContainer.heightAnchor.constraint(equalToConstant: 100)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            headerStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            toggleButton.widthAnchor.constraint(equalToConstant: 30),
            toggleButton.heightAnchor.constraint(equalToConstant: 30),
            
            calendarContainer.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12),
            calendarContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            calendarContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            calendarHeightConstraint,
            
            weekdayLabelsStack.topAnchor.constraint(equalTo: calendarContainer.topAnchor),
            weekdayLabelsStack.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor),
            weekdayLabelsStack.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor),
            weekdayLabelsStack.widthAnchor.constraint(equalToConstant: 16),
            
            gridScrollView.topAnchor.constraint(equalTo: calendarContainer.topAnchor),
            gridScrollView.leadingAnchor.constraint(equalTo: weekdayLabelsStack.trailingAnchor, constant: 4),
            gridScrollView.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor),
            gridScrollView.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor),
            
            gridStack.topAnchor.constraint(equalTo: gridScrollView.topAnchor),
            gridStack.leadingAnchor.constraint(equalTo: gridScrollView.leadingAnchor),
            gridStack.trailingAnchor.constraint(equalTo: gridScrollView.trailingAnchor),
            gridStack.bottomAnchor.constraint(equalTo: gridScrollView.bottomAnchor),
            gridStack.heightAnchor.constraint(equalTo: gridScrollView.heightAnchor),
            
            legendStack.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: 12),
            legendStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            legendStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        
        updateMonthLabel()
    }
    
    private func setupLegend() {
        let lessLabel = UILabel()
        lessLabel.text = "Less"
        lessLabel.font = .systemFont(ofSize: 10, weight: .medium)
        lessLabel.textColor = .white.withAlphaComponent(0.4)
        legendStack.addArrangedSubview(lessLabel)
        
        for level in 0...4 {
            let box = UIView()
            box.backgroundColor = colorForLevel(level)
            box.layer.cornerRadius = 2
            box.translatesAutoresizingMaskIntoConstraints = false
            box.widthAnchor.constraint(equalToConstant: 12).isActive = true
            box.heightAnchor.constraint(equalToConstant: 12).isActive = true
            legendStack.addArrangedSubview(box)
        }
        
        let moreLabel = UILabel()
        moreLabel.text = "More"
        moreLabel.font = .systemFont(ofSize: 10, weight: .medium)
        moreLabel.textColor = .white.withAlphaComponent(0.4)
        legendStack.addArrangedSubview(moreLabel)
    }
    
    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        monthLabel.text = formatter.string(from: Date())
    }
    
    // MARK: - Configuration
    
    func configure(with traces: [DailyTrace]) {
        self.traces = traces
        buildCalendarGrid()
    }
    
    private func buildCalendarGrid() {
        // Clear existing
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dayCells.removeAll()
        
        let calendar = Calendar.current
        let today = Date()
        
        // Show last 16 weeks (about 4 months)
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -15, to: today) else { return }
        
        // Align to start of week
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate))!
        
        var currentDate = startOfWeek
        
        // Build week columns
        while currentDate <= today {
            let weekStack = UIStackView()
            weekStack.axis = .vertical
            weekStack.spacing = 4
            weekStack.distribution = .fillEqually
            
            // Build 7 days for this week
            for _ in 0..<7 {
                let dayCell = DayCell()
                let trace = traces.first { calendar.isDate($0.date, inSameDayAs: currentDate) }
                let level = calculateActivityLevel(for: trace)
                let isFuture = currentDate > today
                
                dayCell.configure(date: currentDate, level: level, isFuture: isFuture)
                dayCell.onTap = { [weak self] date in
                    self?.onDateSelected?(date)
                }
                
                weekStack.addArrangedSubview(dayCell)
                dayCells.append(dayCell)
                
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            gridStack.addArrangedSubview(weekStack)
        }
        
        // Scroll to end (most recent)
        DispatchQueue.main.async {
            let rightOffset = CGPoint(x: max(0, self.gridScrollView.contentSize.width - self.gridScrollView.bounds.width), y: 0)
            self.gridScrollView.setContentOffset(rightOffset, animated: false)
        }
    }
    
    private func calculateActivityLevel(for trace: DailyTrace?) -> Int {
        guard let trace = trace else { return 0 }
        
        let totalActions = trace.actions.count
        let completedActions = trace.actions.filter { $0.state == .done }.count
        let hasMood = trace.mood != .neutral
        
        if totalActions == 0 && !hasMood {
            return 0
        }
        
        if totalActions == 0 && hasMood {
            return 1
        }
        
        let completionRate = Double(completedActions) / Double(totalActions)
        
        if completionRate == 1.0 && hasMood {
            return 4
        } else if completionRate == 1.0 {
            return 3
        } else if completionRate >= 0.5 {
            return 2
        } else {
            return 1
        }
    }
    
    private func colorForLevel(_ level: Int) -> UIColor {
        switch level {
        case 0: return .white.withAlphaComponent(0.1)
        case 1: return ColorPalette.primary.withAlphaComponent(0.3)
        case 2: return ColorPalette.primary.withAlphaComponent(0.5)
        case 3: return ColorPalette.primary.withAlphaComponent(0.75)
        case 4: return ColorPalette.primary
        default: return .white.withAlphaComponent(0.1)
        }
    }
    
    // MARK: - Actions
    
    @objc private func toggleTapped() {
        isExpanded.toggle()
        
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let icon = isExpanded ? "chevron.up" : "chevron.down"
        toggleButton.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.calendarHeightConstraint.constant = self.isExpanded ? 100 : 0
            self.calendarContainer.alpha = self.isExpanded ? 1 : 0
            self.legendStack.alpha = self.isExpanded ? 1 : 0
            self.superview?.layoutIfNeeded()
        }
        
        onToggleExpansion?(isExpanded)
    }
}

// MARK: - DayCell

final class DayCell: UIView {
    
    var onTap: ((Date) -> Void)?
    private var date: Date = Date()
    
    private let backgroundView: UIView = {
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
        addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            widthAnchor.constraint(equalToConstant: 12),
            heightAnchor.constraint(equalToConstant: 12)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }
    
    func configure(date: Date, level: Int, isFuture: Bool) {
        self.date = date
        
        if isFuture {
            backgroundView.backgroundColor = .clear
            backgroundView.layer.borderWidth = 1
            backgroundView.layer.borderColor = UIColor.white.withAlphaComponent(0.05).cgColor
        } else {
            backgroundView.layer.borderWidth = 0
            backgroundView.backgroundColor = colorForLevel(level)
        }
    }
    
    private func colorForLevel(_ level: Int) -> UIColor {
        switch level {
        case 0: return .white.withAlphaComponent(0.1)
        case 1: return ColorPalette.primary.withAlphaComponent(0.3)
        case 2: return ColorPalette.primary.withAlphaComponent(0.5)
        case 3: return ColorPalette.primary.withAlphaComponent(0.75)
        case 4: return ColorPalette.primary
        default: return .white.withAlphaComponent(0.1)
        }
    }
    
    @objc private func tapped() {
        AnimationKit.springScale(view: self, scale: 0.8)
        onTap?(date)
    }
}
