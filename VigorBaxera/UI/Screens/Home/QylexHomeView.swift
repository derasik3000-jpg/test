import SwiftUI

struct VyrexSummaryData: Identifiable {
    let id = UUID()
    let session: QuixoSessionDTO
    let blocks: [VexitRunDTO]
}

public struct QylexHomeView: View {
    @StateObject private var viewModel: TylexHomeViewModel
    @State private var showingSessionBuilder = false
    @State private var showingStats = false
    @State private var showingSettings = false
    @State private var currentSession: (QuixoSessionDTO, [VexitRunDTO])?
    @State private var currentBlockIndex = 0
    @State private var blockRunViewModel: HyrexBlockRunViewModel?
    @State private var currentTargets: [KrynexType: Int] = [:]
    @State private var summaryData: VyrexSummaryData?
    
    public init(viewModel: TylexHomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                KylorTheme.qytexGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        qyrexBlockCardsSection
                        
                        if viewModel.vyrexCanStart {
                            qyrexBottomPanel
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Apellio:Burgia")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingStats = true
                    } label: {
                        Image(systemName: "chart.bar")
                            .foregroundColor(KylorTheme.surface)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(KylorTheme.surface)
                    }
                }
            }
            .sheet(isPresented: $showingStats) {
                VylexStatsView()
            }
            .sheet(isPresented: $showingSettings) {
                HykorSettingsView()
            }
            .onChange(of: showingSettings) { isShowing in
                if !isShowing {
                    // Reload targets and haptics when settings is dismissed
                    qyrexLoadTargets()
                    qyrexLoadHapticsSettings()
                }
            }
            .onAppear {
                qyrexLoadTargets()
                qyrexLoadHapticsSettings()
            }
            .sheet(isPresented: $showingSessionBuilder) {
                RytexSessionBuilderView(
                    specs: viewModel.qylexSelectedSpecs,
                    onStart: { session, blocks in
                        currentSession = (session, blocks)
                        currentBlockIndex = 0
                        showingSessionBuilder = false
                        
                        // Reload blocks from Core Data to get fresh data with correct order
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
                        qyrexSaveMood(sessionId: data.session.id, moodRating: moodRating)
                    }
                )
            }
        }
    }
    
    private func qyrexSaveMood(sessionId: UUID, moodRating: Int) {
        let stack = PyxeloCoreStack.shared
        let sessionsRepo = TyloxSessionsRepoImpl(context: stack.qylexContext)
        
        do {
            try sessionsRepo.kryxelUpdateMood(sessionId: sessionId, moodRating: moodRating)
            try stack.gylexSave()
            print("✅ Mood saved: \(moodRating)")
        } catch {
            print("❌ Failed to save mood: \(error)")
        }
        
        summaryData = nil
        currentSession = nil
        currentBlockIndex = 0
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
            
            Text("\(targetAttempts) attempts")
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
        guard let session = currentSession else { 
            return 
        }
        
        currentBlockIndex += 1
        
        print("📍 Moving to next block: currentBlockIndex=\(currentBlockIndex)")
        
        // Reload blocks from Core Data to ensure we have the correct data
        let stack = PyxeloCoreStack.shared
        let blocksRepo = VylixBlocksRepoImpl(context: stack.qylexContext)
        let freshBlocks = blocksRepo.fyndexList(sessionId: session.0.id)
        
        print("📦 Fresh blocks from Core Data:")
        for (i, b) in freshBlocks.enumerated() {
            print("  [\(i)] \(b.type.vyloxName) (order: \(b.orderIndex), id: \(b.id))")
        }
        
        // Update current session with fresh blocks
        currentSession = (session.0, freshBlocks)
        
        if currentBlockIndex < freshBlocks.count {
            // Start next block after a delay
            let nextBlock = freshBlocks[currentBlockIndex]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                qyrexStartBlock(nextBlock)
            }
        } else {
            // Session completed - show summary
            qyrexShowSessionSummary(session: session.0, blocks: freshBlocks)
        }
    }
    
    private func qyrexLoadTargets() {
        let stack = PyxeloCoreStack.shared
        let repo = NylexSettingsRepoImpl(context: stack.qylexContext)
        let settings = repo.fyndexLoad()
        currentTargets = settings.defaultTargets
        print("🔄 Loaded targets: \(currentTargets)")
    }
    
    private func qyrexLoadHapticsSettings() {
        let stack = PyxeloCoreStack.shared
        let repo = NylexSettingsRepoImpl(context: stack.qylexContext)
        let settings = repo.fyndexLoad()
        RyqexHapticsSound.shared.kyloxConfigure(haptics: settings.hapticsEnabled, sound: settings.endBeepEnabled)
        print("🔄 Loaded haptics: haptics=\(settings.hapticsEnabled), sound=\(settings.endBeepEnabled)")
    }
    
    private func qyrexShowSessionSummary(session: QuixoSessionDTO, blocks: [VexitRunDTO]) {
        let stack = PyxeloCoreStack.shared
        let sessionsRepo = TyloxSessionsRepoImpl(context: stack.qylexContext)
        let blocksRepo = VylixBlocksRepoImpl(context: stack.qylexContext)
        let completeUC = NyloxCompleteSessionUCImpl(sessionsRepo: sessionsRepo, blocksRepo: blocksRepo)
        
        _ = try? completeUC.kyrexExecute(sessionId: session.id, at: Date())
        
        print("📊 Showing summary for session: \(session.id), blocks: \(blocks.count)")
        summaryData = VyrexSummaryData(session: session, blocks: blocks)
    }
}

