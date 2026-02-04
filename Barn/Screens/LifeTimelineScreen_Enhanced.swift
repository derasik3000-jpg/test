//
//  LifeTimelineScreen.swift
//  DAYTRACE
//
//  Enhanced Timeline tab - historical view with calendar heatmap and statistics
//

import UIKit

final class LifeTimelineScreen: UIViewController {
    
    // MARK: - Properties
    
    private var traces: [DailyTrace] = []
    private var filteredTraces: [DailyTrace] = []
    private var groupedTraces: [(month: String, traces: [DailyTrace])] = []
    
    private var currentFilter: TimelineFilter = .all
    private var isCalendarExpanded = true
    
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
    private let headerView: TimelineHeaderView = {
        let view = TimelineHeaderView()
        return view
    }()
    
    // Stats cards row
    private let statsRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let totalDaysCard: StatCard = {
        let card = StatCard()
        return card
    }()
    
    private let completionRateCard: StatCard = {
        let card = StatCard()
        return card
    }()
    
    private let currentStreakCard: StatCard = {
        let card = StatCard()
        return card
    }()
    
    // Calendar heatmap
    private let calendarCard: CalendarHeatmapCard = {
        let card = CalendarHeatmapCard()
        return card
    }()
    
    // Filter section
    private let filterSection: FilterChipsView = {
        let view = FilterChipsView()
        return view
    }()
    
    // Timeline section header
    private let timelineSectionHeader: SectionHeaderView = {
        let header = SectionHeaderView()
        header.configure(title: "Your Journey", icon: "clock.arrow.circlepath")
        return header
    }()
    
    // Timeline table
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var tableHeightConstraint: NSLayoutConstraint!
    
    // Empty state
    private let emptyStateView: TimelineEmptyStateView = {
        let view = TimelineEmptyStateView()
        view.isHidden = true
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.background
        setupUI()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTraces()
        animateEntrance()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        // Build stats row
        statsRow.addArrangedSubview(totalDaysCard)
        statsRow.addArrangedSubview(completionRateCard)
        statsRow.addArrangedSubview(currentStreakCard)
        
        // Build content stack
        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(statsRow)
        contentStack.addArrangedSubview(calendarCard)
        contentStack.addArrangedSubview(filterSection)
        contentStack.addArrangedSubview(timelineSectionHeader)
        contentStack.addArrangedSubview(emptyStateView)
        contentStack.addArrangedSubview(tableView)
        
        // Custom spacing
        contentStack.setCustomSpacing(16, after: headerView)
        contentStack.setCustomSpacing(24, after: calendarCard)
        
        // Table setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EnhancedTimelineCell.self, forCellReuseIdentifier: EnhancedTimelineCell.identifier)
        
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -100),
            
            statsRow.heightAnchor.constraint(equalToConstant: 90),
            
            tableHeightConstraint
        ])
    }
    
    private func setupActions() {
        filterSection.onFilterChanged = { [weak self] filter in
            self?.currentFilter = filter
            self?.applyFilter()
        }
        
        calendarCard.onDateSelected = { [weak self] date in
            self?.scrollToDate(date)
        }
        
        calendarCard.onToggleExpansion = { [weak self] isExpanded in
            self?.isCalendarExpanded = isExpanded
        }
    }
    
    // MARK: - Data Loading
    
    private func loadTraces() {
        traces = TraceStorage.shared.loadTraces()
        applyFilter()
        updateStats()
        updateCalendar()
    }
    
    private func applyFilter() {
        switch currentFilter {
        case .all:
            filteredTraces = traces
        case .completed:
            filteredTraces = traces.filter { trace in
                let total = trace.actions.count
                let done = trace.actions.filter { $0.state == .done }.count
                return total > 0 && done == total
            }
        case .partial:
            filteredTraces = traces.filter { trace in
                let total = trace.actions.count
                let done = trace.actions.filter { $0.state == .done }.count
                // Show days with actions that are not 100% completed
                return total > 0 && done < total
            }
        case .withMood:
            filteredTraces = traces.filter { $0.mood != .neutral }
        }
        
        groupTracesByMonth()
        updateUI()
    }
    
    private func groupTracesByMonth() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        var groups: [String: [DailyTrace]] = [:]
        
        for trace in filteredTraces {
            let monthKey = formatter.string(from: trace.date)
            if groups[monthKey] == nil {
                groups[monthKey] = []
            }
            groups[monthKey]?.append(trace)
        }
        
        // Sort by date descending
        groupedTraces = groups.map { (month: $0.key, traces: $0.value) }
            .sorted { group1, group2 in
                guard let date1 = group1.traces.first?.date,
                      let date2 = group2.traces.first?.date else { return false }
                return date1 > date2
            }
    }
    
    private func updateStats() {
        // Total days tracked
        totalDaysCard.configure(
            value: "\(traces.count)",
            label: "Days Tracked",
            icon: "calendar",
            color: ColorPalette.primary
        )
        
        // Completion rate
        let completedDays = traces.filter { trace in
            let total = trace.actions.count
            let done = trace.actions.filter { $0.state == .done }.count
            return total > 0 && done == total
        }.count
        
        let rate = traces.isEmpty ? 0 : Int((Double(completedDays) / Double(traces.count)) * 100)
        completionRateCard.configure(
            value: "\(rate)%",
            label: "Completion",
            icon: "chart.pie.fill",
            color: ColorPalette.surface
        )
        
        // Current streak
        let streak = calculateStreak()
        currentStreakCard.configure(
            value: "\(streak)",
            label: "Day Streak",
            icon: "flame.fill",
            color: streak >= 7 ? .systemOrange : ColorPalette.primary
        )
    }
    
    private func updateCalendar() {
        calendarCard.configure(with: traces)
    }
    
    private func updateUI() {
        let hasTraces = !filteredTraces.isEmpty
        emptyStateView.isHidden = hasTraces
        tableView.isHidden = !hasTraces
        
        tableView.reloadData()
        updateTableHeight()
    }
    
    private func updateTableHeight() {
        var totalHeight: CGFloat = 0
        
        for section in 0..<groupedTraces.count {
            totalHeight += 44 // Section header height
            totalHeight += CGFloat(groupedTraces[section].traces.count) * 100 // Cell height
        }
        
        tableHeightConstraint.constant = totalHeight
    }
    
    private func calculateStreak() -> Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()
        
        let sortedTraces = traces.sorted { $0.date > $1.date }
        
        for trace in sortedTraces {
            if calendar.isDate(trace.date, inSameDayAs: checkDate) ||
               calendar.isDate(trace.date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: checkDate)!) {
                
                if trace.actions.contains(where: { $0.state == .done }) {
                    streak += 1
                    checkDate = trace.date
                } else {
                    break
                }
            } else if trace.date < calendar.date(byAdding: .day, value: -1, to: checkDate)! {
                break
            }
        }
        
        return streak
    }
    
    private func scrollToDate(_ date: Date) {
        let calendar = Calendar.current
        
        for (sectionIndex, group) in groupedTraces.enumerated() {
            for (rowIndex, trace) in group.traces.enumerated() {
                if calendar.isDate(trace.date, inSameDayAs: date) {
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                    
                    // Highlight the cell briefly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let cell = self.tableView.cellForRow(at: indexPath) as? EnhancedTimelineCell {
                            cell.highlight()
                        }
                    }
                    return
                }
            }
        }
    }
    
    private func animateEntrance() {
        let views = [headerView, statsRow, calendarCard, filterSection]
        
        for (index, view) in views.enumerated() {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 20)
            
            UIView.animate(
                withDuration: 0.5,
                delay: Double(index) * 0.08,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [],
                animations: {
                    view.alpha = 1
                    view.transform = .identity
                }
            )
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension LifeTimelineScreen: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedTraces.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedTraces[section].traces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EnhancedTimelineCell.identifier, for: indexPath) as? EnhancedTimelineCell else {
            return UITableViewCell()
        }
        
        let trace = groupedTraces[indexPath.section].traces[indexPath.row]
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == groupedTraces[indexPath.section].traces.count - 1
        
        cell.configure(with: trace, isFirst: isFirst, isLast: isLast)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = TimelineSectionHeader()
        header.configure(title: groupedTraces[section].month)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let trace = groupedTraces[indexPath.section].traces[indexPath.row]
        showTraceDetail(trace)
    }
    
    private func showTraceDetail(_ trace: DailyTrace) {
        let detailVC = TraceDetailSheet(trace: trace)
        
        if let sheet = detailVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(detailVC, animated: true)
    }
}

// MARK: - Filter Enum

enum TimelineFilter: String, CaseIterable {
    case all = "All"
    case completed = "Completed"
    case partial = "In Progress"
    case withMood = "With Mood"
}
