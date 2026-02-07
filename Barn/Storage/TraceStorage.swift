//
//  TraceStorage.swift
//  DAYTRACE
//
//  Local storage manager for traces
//

import Foundation

final class TraceStorage {
    
    static let shared = TraceStorage()
    
    private let tracesKey = "daytrace.traces"
    private let avatarKey = "daytrace.avatar"
    private let onboardingKey = "daytrace.onboarding.completed"
    
    private init() {}
    
    // MARK: - Onboarding
    
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingKey) }
    }
    
    // MARK: - Traces
    
    func saveTraces(_ traces: [DailyTrace]) {
        if let encoded = try? JSONEncoder().encode(traces) {
            UserDefaults.standard.set(encoded, forKey: tracesKey)
        }
    }
    
    func loadTraces() -> [DailyTrace] {
        guard let data = UserDefaults.standard.data(forKey: tracesKey),
              let traces = try? JSONDecoder().decode([DailyTrace].self, from: data) else {
            return []
        }
        return traces
    }
    
    func addOrUpdateTrace(_ trace: DailyTrace) {
        var traces = loadTraces()
        if let index = traces.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: trace.date) }) {
            traces[index] = trace
        } else {
            traces.append(trace)
        }
        traces.sort { $0.date > $1.date }
        saveTraces(traces)
    }
    
    func getTraceForToday() -> DailyTrace {
        let traces = loadTraces()
        if let todayTrace = traces.first(where: { Calendar.current.isDateInToday($0.date) }) {
            return todayTrace
        }
        return DailyTrace()
    }
    
    // MARK: - Avatar
    
    func saveAvatar(_ avatar: UserAvatar) {
        if let encoded = try? JSONEncoder().encode(avatar) {
            UserDefaults.standard.set(encoded, forKey: avatarKey)
        }
    }
    
    func loadAvatar() -> UserAvatar {
        guard let data = UserDefaults.standard.data(forKey: avatarKey),
              let avatar = try? JSONDecoder().decode(UserAvatar.self, from: data) else {
            return UserAvatar()
        }
        return avatar
    }
}
