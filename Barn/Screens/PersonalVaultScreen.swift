//
//  PersonalVaultScreen.swift
//  DAYTRACE
//
//  Profile tab - reflection & personalization
//

import UIKit

final class PersonalVaultScreen: UIViewController {
    
    private var avatar = TraceStorage.shared.loadAvatar()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Header with avatar
    private let headerCard: ProfileHeaderCard = {
        let card = ProfileHeaderCard()
        return card
    }()
    
    // Stats grid
    private let statsGrid: StatsGridView = {
        let grid = StatsGridView()
        return grid
    }()
    
    // Category breakdown
    private let categoryCard: CategoryBreakdownCard = {
        let card = CategoryBreakdownCard()
        return card
    }()
    
    // Achievements
    private let achievementsCard: AchievementsCard = {
        let card = AchievementsCard()
        return card
    }()
    
    // Insights
    private let insightsCard: InsightsCard = {
        let card = InsightsCard()
        return card
    }()
    
    // Share
    private let shareCard: ShareSnapshotCard = {
        let card = ShareSnapshotCard()
        return card
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.background
        setupUI()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSummary()
        animateEntrance()
    }
    
    private func animateEntrance() {
        let cards = [headerCard, statsGrid, categoryCard, achievementsCard, insightsCard, shareCard]
        
        for (index, card) in cards.enumerated() {
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 30)
            
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [],
                animations: {
                    card.alpha = 1
                    card.transform = .identity
                }
            )
        }
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(headerCard)
        contentStack.addArrangedSubview(statsGrid)
        contentStack.addArrangedSubview(categoryCard)
        contentStack.addArrangedSubview(achievementsCard)
        contentStack.addArrangedSubview(insightsCard)
        contentStack.addArrangedSubview(shareCard)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        headerCard.onAvatarTapped = { [weak self] in
            self?.showAvatarPicker()
        }
        
        shareCard.onShareTapped = { [weak self] in
            self?.shareSnapshot()
        }
    }
    
    private func updateSummary() {
        let traces = TraceStorage.shared.loadTraces()
        let avatar = TraceStorage.shared.loadAvatar()
        
        headerCard.configure(avatar: avatar, totalDays: traces.count)
        statsGrid.updateWithTraces(traces)
        categoryCard.updateWithTraces(traces)
        achievementsCard.updateWithTraces(traces)
        insightsCard.updateWithTraces(traces)
    }
    
    private func showAvatarPicker() {
        let picker = AvatarPickerSheet()
        picker.currentEmoji = avatar.emoji
        picker.onEmojiSelected = { [weak self] emoji in
            self?.avatar.emoji = emoji
            TraceStorage.shared.saveAvatar(UserAvatar(emoji: emoji))
            self?.updateSummary()
        }
        
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(picker, animated: true)
    }
    
    private func shareSnapshot() {
        let traces = TraceStorage.shared.loadTraces()
        guard let todayTrace = traces.first(where: { Calendar.current.isDateInToday($0.date) }) else {
            return
        }
        
        let renderer = SnapshotComposer()
        let image = renderer.generateSnapshot(for: todayTrace, avatar: avatar)
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
