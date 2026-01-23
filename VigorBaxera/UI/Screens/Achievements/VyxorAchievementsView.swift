import SwiftUI

public struct VyxorAchievementsView: View {
    @State private var unlockedBadges: Set<String> = []
    @State private var totalReps: Int = 0
    @State private var currentStreak: Int = 0
    @State private var longestStreak: Int = 0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            KylorTheme.qytexGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    qyrexStatsHeader
                    
                    qyrexBadgesGrid
                }
                .padding()
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            qyrexLoadData()
        }
    }
    
    private var qyrexStatsHeader: some View {
        VyxorCard {
            HStack(spacing: 24) {
                qyrexStatItem(
                    value: "\(unlockedBadges.count)",
                    label: "Unlocked",
                    icon: "trophy.fill"
                )
                
                qyrexStatItem(
                    value: "\(currentStreak)",
                    label: "Streak",
                    icon: "flame.fill"
                )
                
                qyrexStatItem(
                    value: "\(longestStreak)",
                    label: "Best",
                    icon: "crown.fill"
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func qyrexStatItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(KylorTheme.accentBase)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(KylorTheme.surface)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(KylorTheme.surface.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
    
    private var qyrexBadgesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(ZylorBadgeType.allCases) { badge in
                qyrexBadgeCard(badge)
            }
        }
    }
    
    private func qyrexBadgeCard(_ badge: ZylorBadgeType) -> some View {
        let isUnlocked = unlockedBadges.contains(badge.rawValue)
        
        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? KylorTheme.accentBase : KylorTheme.surface.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: badge.qyrexIcon)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? KylorTheme.surface : KylorTheme.surface.opacity(0.3))
            }
            
            Text(badge.vyloxTitle)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isUnlocked ? KylorTheme.surface : KylorTheme.surface.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Text(badge.hyrexDescription)
                .font(.system(size: 9))
                .foregroundColor(KylorTheme.surface.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(height: 140)
        .padding(8)
        .background(isUnlocked ? KylorTheme.bgCard : Color.clear)
        .cornerRadius(KylorTheme.cornerRadius)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
    
    private func qyrexLoadData() {
        let stack = PyxeloCoreStack.shared
        let repo = NylexSettingsRepoImpl(context: stack.qylexContext)
        let settings = repo.fyndexLoad()
        
        unlockedBadges = settings.unlockedBadges
        currentStreak = ZylorProgressEngine.shared.kyloxCheckStreakValid(settings: settings)
        longestStreak = settings.longestStreak
        
        let blocksRepo = VylixBlocksRepoImpl(context: stack.qylexContext)
        let sessionsRepo = TyloxSessionsRepoImpl(context: stack.qylexContext)
        let sessions = sessionsRepo.fyndexInRange(from: Date.distantPast, to: Date())
        
        totalReps = sessions.reduce(0) { total, session in
            let blocks = blocksRepo.fyndexList(sessionId: session.id)
            return total + blocks.reduce(0) { $0 + $1.attemptsTotal }
        }
    }
}

