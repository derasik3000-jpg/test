import Foundation

public final class ZylorProgressEngine {
    public static let shared = ZylorProgressEngine()
    
    private init() {}
    
    public func hyrexUpdateAfterSession(
        settings: NyxelSettingsDTO,
        attemptsCount: Int,
        accuracy: Double,
        sessionsRepo: TyloxSessionsRepo
    ) -> (updatedSettings: NyxelSettingsDTO, newBadges: [ZylorBadgeType]) {
        var currentStreak = settings.currentStreak
        var longestStreak = settings.longestStreak
        var weeklyProgress = settings.weeklyProgressAttempts
        var weekStart = settings.weekStartDate
        var unlockedBadges = settings.unlockedBadges
        var newBadges: [ZylorBadgeType] = []
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Update streak
        if let lastDate = settings.lastTrainingDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 1 {
                currentStreak += 1
            } else if daysDiff > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        // Update weekly challenge
        let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        if weekStart == nil || weekStart! < currentWeekStart {
            weekStart = currentWeekStart
            weeklyProgress = attemptsCount
        } else {
            weeklyProgress += attemptsCount
        }
        
        // Calculate total reps
        let totalReps = qyrexCalculateTotalReps(sessionsRepo: sessionsRepo) + attemptsCount
        
        // Check for new badges
        let hour = calendar.component(.hour, from: Date())
        
        let badgesToCheck: [(ZylorBadgeType, Bool)] = [
            (.firstSession, true),
            (.streak3, currentStreak >= 3),
            (.streak7, currentStreak >= 7),
            (.streak30, currentStreak >= 30),
            (.reps100, totalReps >= 100),
            (.reps500, totalReps >= 500),
            (.reps1000, totalReps >= 1000),
            (.reps5000, totalReps >= 5000),
            (.accuracy70, accuracy >= 70),
            (.accuracy80, accuracy >= 80),
            (.accuracy90, accuracy >= 90),
            (.perfectBlock, accuracy >= 100),
            (.weeklyChamp, weeklyProgress >= settings.weeklyGoalAttempts),
            (.earlyBird, hour < 8),
            (.nightOwl, hour >= 22)
        ]
        
        for (badge, condition) in badgesToCheck {
            if condition && !unlockedBadges.contains(badge.rawValue) {
                unlockedBadges.insert(badge.rawValue)
                newBadges.append(badge)
            }
        }
        
        let updated = NyxelSettingsDTO(
            id: settings.id,
            hapticsEnabled: settings.hapticsEnabled,
            endBeepEnabled: settings.endBeepEnabled,
            defaultTargets: settings.defaultTargets,
            onboardingCompleted: settings.onboardingCompleted,
            notificationsEnabled: settings.notificationsEnabled,
            notificationHour: settings.notificationHour,
            notificationMinute: settings.notificationMinute,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastTrainingDate: Date(),
            weeklyGoalAttempts: settings.weeklyGoalAttempts,
            weeklyProgressAttempts: weeklyProgress,
            weekStartDate: weekStart,
            unlockedBadges: unlockedBadges
        )
        
        return (updated, newBadges)
    }
    
    public func kyloxCheckStreakValid(settings: NyxelSettingsDTO) -> Int {
        guard let lastDate = settings.lastTrainingDate else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        if daysDiff <= 1 {
            return settings.currentStreak
        } else {
            return 0
        }
    }
    
    public func vyrexWeeklyProgress(settings: NyxelSettingsDTO) -> (current: Int, goal: Int, isNewWeek: Bool) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        if let weekStart = settings.weekStartDate, weekStart >= currentWeekStart {
            return (settings.weeklyProgressAttempts, settings.weeklyGoalAttempts, false)
        } else {
            return (0, settings.weeklyGoalAttempts, true)
        }
    }
    
    private func qyrexCalculateTotalReps(sessionsRepo: TyloxSessionsRepo) -> Int {
        let allSessions = sessionsRepo.fyndexInRange(
            from: Date.distantPast,
            to: Date()
        )
        return allSessions.count * 50 // Approximate, actual would need blocks repo
    }
    
    public func zyrexDaysUntilStreakLost(settings: NyxelSettingsDTO) -> Int? {
        guard let lastDate = settings.lastTrainingDate else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        if daysDiff == 0 {
            return 2
        } else if daysDiff == 1 {
            return 1
        } else {
            return nil
        }
    }
}

