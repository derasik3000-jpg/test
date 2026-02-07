//
//  TodayTraceScreen.swift
//  DAYTRACE
//
//  Today tab - Enhanced daily input screen with streak, progress, and animations
//

import UIKit

final class TodayTraceScreen: UIViewController {
    
    // MARK: - Properties
    
    private var currentTrace: DailyTrace = TraceStorage.shared.getTraceForToday()
    private var currentAvatar: UserAvatar = TraceStorage.shared.loadAvatar()
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.keyboardDismissMode = .interactive
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Top greeting section
    private let greetingCard: GreetingCard = {
        let card = GreetingCard()
        return card
    }()
    
    // Stats row (streak + progress)
    private let statsRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let streakCard: StreakCard = {
        let card = StreakCard()
        return card
    }()
    
    private let progressCard: DayProgressCard = {
        let card = DayProgressCard()
        return card
    }()
    
    // Mood section
    private let moodCard: EnhancedMoodPickerCard = {
        let card = EnhancedMoodPickerCard()
        return card
    }()
    
    // Actions section header
    private let actionsSectionHeader: SectionHeaderView = {
        let header = SectionHeaderView()
        header.configure(title: "Today's Actions", icon: "checklist")
        return header
    }()
    
    // Actions list
    private let actionsTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.register(ActionCell.self, forCellReuseIdentifier: ActionCell.identifier)
        return table
    }()
    
    private var actionsTableHeightConstraint: NSLayoutConstraint!
    
    // Empty state
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.configure(
            emoji: "✨",
            title: "Ready to track your day?",
            subtitle: "Tap the yellow ➕ button to create your first action\n\nYou can add:\n• Category & Priority\n• Time estimate\n• Notes & Emotion"
        )
        view.isHidden = true
        return view
    }()
    
    // Input container - золотой фон
    private let inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 12
        return view
    }()
    
    private let inputHintLabel: UILabel = {
        let label = UILabel()
        label.text = "✨ Tap ➕ to create detailed action"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let addButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        btn.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = ColorPalette.primary
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 8
        return btn
    }()
    
    // Celebration overlay
    private let celebrationView: CelebrationOverlay = {
        let view = CelebrationOverlay()
        view.isHidden = true
        return view
    }()
    
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.background
        setupUI()
        setupActions()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentTrace = TraceStorage.shared.getTraceForToday()
        currentAvatar = TraceStorage.shared.loadAvatar()
        updateUI()
        animateEntrance()
        
        // Pulse add button if no actions yet
        if currentTrace.actions.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.pulseAddButton()
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(inputContainer)
        view.addSubview(celebrationView)
        
        scrollView.addSubview(contentStack)
        
        // Build content stack
        contentStack.addArrangedSubview(greetingCard)
        
        statsRow.addArrangedSubview(streakCard)
        statsRow.addArrangedSubview(progressCard)
        contentStack.addArrangedSubview(statsRow)
        
        contentStack.addArrangedSubview(moodCard)
        contentStack.addArrangedSubview(actionsSectionHeader)
        contentStack.addArrangedSubview(emptyStateView)
        contentStack.addArrangedSubview(actionsTableView)
        
        // Add spacing after mood card
        contentStack.setCustomSpacing(24, after: moodCard)
        
        // Input container
        inputContainer.addSubview(inputHintLabel)
        inputContainer.addSubview(addButton)
        
        // Constraints
        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        actionsTableHeightConstraint = actionsTableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            
            statsRow.heightAnchor.constraint(equalToConstant: 100),
            
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint,
            inputContainer.heightAnchor.constraint(equalToConstant: 90),
            
            inputHintLabel.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            inputHintLabel.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 20),
            inputHintLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -16),
            
            addButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -20),
            addButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 64),
            addButton.heightAnchor.constraint(equalToConstant: 64),
            
            actionsTableHeightConstraint,
            
            celebrationView.topAnchor.constraint(equalTo: view.topAnchor),
            celebrationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            celebrationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            celebrationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Table view setup
        actionsTableView.delegate = self
        actionsTableView.dataSource = self
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addActionTapped), for: .touchUpInside)
        
        // Add button touch feedback
        addButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        moodCard.onMoodSelected = { [weak self] mood in
            self?.currentTrace.mood = mood
            self?.saveTrace()
            self?.updateProgressCard()
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        greetingCard.onAvatarTapped = { [weak self] in
            self?.showAvatarPicker()
        }
    }
    
    
    // MARK: - Actions
    
    @objc private func addActionTapped() {
        // Show enhanced action creation sheet
        let sheet = AddActionSheet()
        sheet.onActionCreated = { [weak self] action in
            self?.currentTrace.actions.append(action)
            self?.saveTrace()
            self?.updateUI()
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // Scroll to show new item
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard let self = self else { return }
                let lastIndex = IndexPath(row: self.currentTrace.actions.count - 1, section: 0)
                self.actionsTableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
            }
        }
        
        if let sheetController = sheet.sheetPresentationController {
            sheetController.detents = [.large()]
            sheetController.prefersGrabberVisible = true
        }
        
        present(sheet, animated: true)
    }
    
    @objc private func buttonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.addButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    @objc private func buttonTouchUp() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            self.addButton.transform = .identity
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        // Update greeting
        greetingCard.configure(avatar: currentAvatar.emoji, date: currentTrace.date)
        
        // Update streak
        let streak = calculateStreak()
        streakCard.configure(streak: streak)
        
        // Update progress
        updateProgressCard()
        
        // Update mood
        moodCard.setMood(currentTrace.mood)
        
        // Update actions
        let hasActions = !currentTrace.actions.isEmpty
        emptyStateView.isHidden = hasActions
        actionsTableView.isHidden = !hasActions
        
        actionsTableView.reloadData()
        updateTableHeight()
    }
    
    private func updateProgressCard() {
        let total = currentTrace.actions.count
        let completed = currentTrace.actions.filter { $0.state == .done }.count
        // Mood doesn't affect progress - only completed actions matter
        progressCard.configure(completed: completed, total: total, hasMood: false)
    }
    
    private func updateTableHeight() {
        let rowHeight: CGFloat = 72
        let count = CGFloat(currentTrace.actions.count)
        actionsTableHeightConstraint.constant = count * rowHeight
    }
    
    private func animateEntrance() {
        let views = [greetingCard, statsRow, moodCard, actionsSectionHeader]
        
        for (index, view) in views.enumerated() {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 20)
            
            UIView.animate(
                withDuration: 0.5,
                delay: Double(index) * 0.1,
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
    
    private func pulseAddButton() {
        // Pulse animation to draw attention
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: {
                self.addButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
        )
        
        // Stop after 3 cycles
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
            self.addButton.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.2) {
                self.addButton.transform = .identity
            }
        }
    }
    
    // MARK: - Data
    
    private func saveTrace() {
        TraceStorage.shared.addOrUpdateTrace(currentTrace)
    }
    
    private func calculateStreak() -> Int {
        let traces = TraceStorage.shared.loadTraces()
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()
        
        // Check if today has any completed actions
        let todayTrace = traces.first { calendar.isDateInToday($0.date) }
        if let today = todayTrace, today.actions.contains(where: { $0.state == .done }) {
            streak = 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        // Count consecutive days with completed actions
        while let previousDate = calendar.date(byAdding: .day, value: -1, to: checkDate) {
            if let trace = traces.first(where: { calendar.isDate($0.date, inSameDayAs: previousDate) }),
               trace.actions.contains(where: { $0.state == .done }) {
                streak += 1
                checkDate = previousDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func checkForCelebration() {
        let total = currentTrace.actions.count
        let completed = currentTrace.actions.filter { $0.state == .done }.count
        
        if total > 0 && completed == total {
            showCelebration()
        }
    }
    
    private func showCelebration() {
        celebrationView.isHidden = false
        celebrationView.animate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.celebrationView.isHidden = true
        }
    }
    
    private func showAvatarPicker() {
        let picker = AvatarPickerSheet()
        picker.currentEmoji = currentAvatar.emoji
        picker.onEmojiSelected = { [weak self] emoji in
            self?.currentAvatar.emoji = emoji
            TraceStorage.shared.saveAvatar(UserAvatar(emoji: emoji))
            self?.greetingCard.configure(avatar: emoji, date: self?.currentTrace.date ?? Date())
        }
        
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(picker, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension TodayTraceScreen: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTrace.actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier, for: indexPath) as? ActionCell else {
            return UITableViewCell()
        }
        
        let action = currentTrace.actions[indexPath.row]
        cell.configure(with: action)
        
        cell.onStateChanged = { [weak self] newState in
            self?.currentTrace.actions[indexPath.row].state = newState
            self?.saveTrace()
            self?.updateProgressCard()
            self?.checkForCelebration()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let skipAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            self?.toggleSkipAction(at: indexPath)
            completion(true)
        }
        
        let isSkipped = currentTrace.actions[indexPath.row].state == .skipped
        skipAction.image = UIImage(systemName: isSkipped ? "arrow.uturn.backward" : "forward.end.fill")
        skipAction.backgroundColor = .systemOrange
        skipAction.title = isSkipped ? "Undo" : "Skip"
        
        return UISwipeActionsConfiguration(actions: [skipAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            self?.deleteAction(at: indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func toggleSkipAction(at indexPath: IndexPath) {
        let currentState = currentTrace.actions[indexPath.row].state
        let newState: ActionState = currentState == .skipped ? .pending : .skipped
        
        currentTrace.actions[indexPath.row].state = newState
        saveTrace()
        
        actionsTableView.reloadRows(at: [indexPath], with: .automatic)
        updateProgressCard()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func deleteAction(at indexPath: IndexPath) {
        currentTrace.actions.remove(at: indexPath.row)
        saveTrace()
        
        actionsTableView.performBatchUpdates {
            actionsTableView.deleteRows(at: [indexPath], with: .fade)
        } completion: { _ in
            self.updateUI()
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

