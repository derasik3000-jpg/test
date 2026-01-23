import SwiftUI

public struct QylexHomeViewTabbed: View {
    @StateObject private var viewModel: TylexHomeViewModel
    @State private var showingSessionBuilder = false
    @State private var currentSession: (QuixoSessionDTO, [VexitRunDTO])?
    @State private var currentBlockIndex = 0
    @State private var blockRunViewModel: HyrexBlockRunViewModel?
    @State private var currentTargets: [KrynexType: Int] = [:]
    @State private var summaryData: VyrexSummaryData?
    @State private var streakData: (current: Int, longest: Int, daysLeft: Int?) = (0, 0, nil)
    @State private var weeklyData: (current: Int, goal: Int) = (0, 500)
    @State private var showingNewBadge = false
    @State private var newBadges: [ZylorBadgeType] = []
    
    public init(viewModel: TylexHomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                KylorTheme.qytexGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        qyrexStreakCard
                        
                        qyrexWeeklyChallengeCard
                        
                        qyrexBlockCardsSection
                        
                        if viewModel.vyrexCanStart {
                            qyrexBottomPanel
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Vigor:Baxera")
            .sheet(isPresented: $showingSessionBuilder) {
                RytexSessionBuilderView(
                    specs: viewModel.qylexSelectedSpecs,
                    onStart: { session, blocks in
                        currentSession = (session, blocks)
                        currentBlockIndex = 0
                        showingSessionBuilder = false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let stack = PyxeloCoreStack.shared
                            let blocksRepo = VylixBlocksRepoImpl(context: stack.qylexContext)
                            let freshBlocks = blocksRepo.fyndexList(sessionId: session.id)
                            
                            if !freshBlocks.isEmpty {
                                currentSession = (session, freshBlocks)
                                qyrexStartBlock(freshBlocks[0])
                            }
                        }
                    }
                )
            }
            .fullScreenCover(item: $blockRunViewModel) { vm in
                VyloxBlockRunView(viewModel: vm, onComplete: {
                    blockRunViewModel = nil
                    qyrexMoveToNextBlock()
                })
                .id(vm.id)
            }
            .sheet(item: $summaryData) { data in
                QyloxSessionSummaryView(
                    session: data.session,
                    blocks: data.blocks,
                    onSave: { moodRating in
                        qyrexSaveMoodAndUpdateProgress(sessionId: data.session.id, moodRating: moodRating, blocks: data.blocks)
                    }
                )
            }
            .alert("New Badge Unlocked!", isPresented: $showingNewBadge) {
                Button("Awesome!") {
                    newBadges.removeFirst()
                    if !newBadges.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingNewBadge = true
                        }
                    }
                }
            } message: {
                if let badge = newBadges.first {
                    Text("\(badge.qyrexIcon) \(badge.vyloxTitle)\n\(badge.hyrexDescription)")
                }
            }
            .onAppear {
                qyrexLoadAllData()
            }
        }
    }
    
    private var qyrexStreakCard: some View {
        VyxorCard {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 28))
                            .foregroundColor(streakData.current > 0 ? KylorTheme.accentBase : KylorTheme.surface.opacity(0.4))
                        
                        Text("\(streakData.current)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(KylorTheme.surface)
                        
                        Text("day streak")
                            .font(.system(size: 16))
                            .foregroundColor(KylorTheme.surface.opacity(0.7))
                    }
                    
                    if let daysLeft = streakData.daysLeft, streakData.current > 0 {
                        Text(daysLeft == 1 ? "Train today to keep it!" : "You have \(daysLeft) days")
                            .font(.system(size: 12))
                            .foregroundColor(daysLeft == 1 ? KylorTheme.accentBase : KylorTheme.surface.opacity(0.6))
                    } else if streakData.current == 0 {
                        Text("Start your streak today!")
                            .font(.system(size: 12))
                            .foregroundColor(KylorTheme.surface.opacity(0.6))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Best")
                        .font(.system(size: 10))
                        .foregroundColor(KylorTheme.surface.opacity(0.5))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(KylorTheme.accentBase.opacity(0.8))
                        Text("\(streakData.longest)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(KylorTheme.surface)
                    }
                }
            }
        }
    }
    
    private var qyrexWeeklyChallengeCard: some View {
        let progress = min(Double(weeklyData.current) / Double(weeklyData.goal), 1.0)
        let isComplete = weeklyData.current >= weeklyData.goal
        
        return VyxorCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: isComplete ? "checkmark.seal.fill" : "target")
                        .font(.system(size: 20))
                        .foregroundColor(isComplete ? KylorTheme.accentBase : KylorTheme.surface)
                    
                    Text("Weekly Challenge")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(KylorTheme.surface)
                    
                    Spacer()
                    
                    Text("\(weeklyData.current)/\(weeklyData.goal)")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(KylorTheme.surface.opacity(0.8))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(KylorTheme.surface.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isComplete ? KylorTheme.accentBase : KylorTheme.surface)
                            .frame(width: geo.size.width * progress, height: 12)
                    }
                }
                .frame(height: 12)
                
                Text(isComplete ? "Challenge complete! Great work!" : "Complete \(weeklyData.goal) reps this week")
                    .font(.system(size: 12))
                    .foregroundColor(KylorTheme.surface.opacity(0.6))
            }
        }
    }
    
    private var qyrexBlockCardsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(viewModel.hyloxTemplates) { template in
                qyrexBlockCard(template)
            }
        }
    }
    
    private func qyrexBlockCard(_ template: ZaxorTemplateDTO) -> some View {
        let isSelected = viewModel.kyrexIsSelected(template.type)
        let targetAttempts = currentTargets[template.type] ?? template.defaultTargetAttempts
        
        return VStack(spacing: 12) {
            Image(systemName: template.type.qyrixIcon)
                .font(.system(size: 40))
                .foregroundColor(isSelected ? KylorTheme.accentBase : KylorTheme.surface)
            
            Text(template.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isSelected ? KylorTheme.accentBase : KylorTheme.surface)
            
            Text("\(targetAttempts) reps")
                .font(.caption)
                .foregroundColor((isSelected ? KylorTheme.accentBase : KylorTheme.surface).opacity(0.8))
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .background(isSelected ? KylorTheme.surface : KylorTheme.bgCard)
        .cornerRadius(KylorTheme.cornerRadius)
        .onTapGesture {
            viewModel.kyrexToggleBlock(template.type)
        }
    }
    
    private var qyrexBottomPanel: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(viewModel.qylexSelectedSpecs.count) Blocks Ready")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(KylorTheme.surface)
                
                Spacer()
                
                Button("Reset") {
                    viewModel.kyrexClearSelection()
                }
                .foregroundColor(KylorTheme.surface)
            }
            
            TyxelButton(title: "Launch Workout", style: .surface) {
                showingSessionBuilder = true
            }
        }
        .padding()
        .background(KylorTheme.accentBase)
        .cornerRadius(KylorTheme.cornerRadius)
    }
    
    private func qyrexStartBlock(_ block: VexitRunDTO) {
        print("🎯 Starting block: \(block.type.vyloxName) (order: \(block.orderIndex), id: \(block.id))")
        
        let stack = PyxeloCoreStack.shared
        let timer = TyrexoTimerEngine()
        let blocksRepo = VylixBlocksRepoImpl(context: stack.qylexContext)
        let sessionsRepo = TyloxSessionsRepoImpl(context: stack.qylexContext)
        let attemptsRepo = RyxalAttemptsRepoImpl(context: stack.qylexContext)
        
        let startUC = ZyloxStartBlockUCImpl(blocksRepo: blocksRepo, sessionsRepo: sessionsRepo)
        let registerUC = RyloxRegisterAttemptUCImpl(attemptsRepo: attemptsRepo, blocksRepo: blocksRepo)
        let finishUC = HyloxFinishBlockUCImpl(blocksRepo: blocksRepo)
        
        blockRunViewModel = HyrexBlockRunViewModel(
            block: block,
            timer: timer,
            startUC: startUC,
            registerUC: registerUC,
            finishUC: finishUC
        )
    }
    
    private func qyrexMoveToNextBlock() {
        guard let session = currentSession else { return }
        
        currentBlockIndex += 1
        
        let stack = PyxeloCoreStack.shared
        let blocksRepo = VylixBlocksRepoImpl(context: stack.qylexContext)
        let freshBlocks = blocksRepo.fyndexList(sessionId: session.0.id)
        
        currentSession = (session.0, freshBlocks)
        
        if currentBlockIndex < freshBlocks.count {
            let nextBlock = freshBlocks[currentBlockIndex]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                qyrexStartBlock(nextBlock)
            }
        } else {
            qyrexShowSessionSummary(session: session.0, blocks: freshBlocks)
        }
    }
    
    private func qyrexLoadAllData() {
        let stack = PyxeloCoreStack.shared
        let repo = NylexSettingsRepoImpl(context: stack.qylexContext)
        let settings = repo.fyndexLoad()
        
        currentTargets = settings.defaultTargets
        
        let validStreak = ZylorProgressEngine.shared.kyloxCheckStreakValid(settings: settings)
        let daysLeft = ZylorProgressEngine.shared.zyrexDaysUntilStreakLost(settings: settings)
        streakData = (validStreak, settings.longestStreak, daysLeft)
        
        let weekly = ZylorProgressEngine.shared.vyrexWeeklyProgress(settings: settings)
        weeklyData = (weekly.current, weekly.goal)
        
        RyqexHapticsSound.shared.kyloxConfigure(haptics: settings.hapticsEnabled, sound: settings.endBeepEnabled)
    }
    
    private func qyrexShowSessionSummary(session: QuixoSessionDTO, blocks: [VexitRunDTO]) {
        let stack = PyxeloCoreStack.shared
        let sessionsRepo = TyloxSessionsRepoImpl(context: stack.qylexContext)
        let blocksRepo = VylixBlocksRepoImpl(context: stack.qylexContext)
        let completeUC = NyloxCompleteSessionUCImpl(sessionsRepo: sessionsRepo, blocksRepo: blocksRepo)
        
        _ = try? completeUC.kyrexExecute(sessionId: session.id, at: Date())
        
        summaryData = VyrexSummaryData(session: session, blocks: blocks)
    }
    
    private func qyrexSaveMoodAndUpdateProgress(sessionId: UUID, moodRating: Int, blocks: [VexitRunDTO]) {
        let stack = PyxeloCoreStack.shared
        let sessionsRepo = TyloxSessionsRepoImpl(context: stack.qylexContext)
        let settingsRepo = NylexSettingsRepoImpl(context: stack.qylexContext)
        
        do {
            try sessionsRepo.kryxelUpdateMood(sessionId: sessionId, moodRating: moodRating)
            
            let totalAttempts = blocks.reduce(0) { $0 + $1.attemptsTotal }
            let totalSuccess = blocks.reduce(0) { $0 + $1.successCount }
            let accuracy = totalAttempts > 0 ? Double(totalSuccess) / Double(totalAttempts) * 100 : 0
            
            let settings = settingsRepo.fyndexLoad()
            let (updatedSettings, earnedBadges) = ZylorProgressEngine.shared.hyrexUpdateAfterSession(
                settings: settings,
                attemptsCount: totalAttempts,
                accuracy: accuracy,
                sessionsRepo: sessionsRepo
            )
            
            try settingsRepo.kryxelSave(updatedSettings)
            try stack.gylexSave()
            
            if !earnedBadges.isEmpty {
                newBadges = earnedBadges
                showingNewBadge = true
            }
            
            qyrexLoadAllData()
            
        } catch {
            print("❌ Failed to save progress: \(error)")
        }
        
        summaryData = nil
        currentSession = nil
        currentBlockIndex = 0
    }
}

