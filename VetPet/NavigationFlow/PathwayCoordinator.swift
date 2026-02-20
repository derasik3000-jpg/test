import SwiftUI
import Combine
// MARK: - PathwayCoordinator
// Central navigation brain — MVVM+Coordinator pattern
// Manages tabs, sheets, and navigation destinations

final class PathwayCoordinator: ObservableObject {

    // MARK: - Tab Definition

    enum Realm: Int, CaseIterable, Identifiable {
        case pulse     = 0   // Dashboard / Summary
        case chronicle = 1   // Logs & Events
        case care      = 2   // Care calendar, reminders, vet visits
        case sanctum   = 3   // Settings & Stats

        var id: Int { rawValue }

        var tabTitle: String {
            switch self {
            case .pulse:     return "Pulse"
            case .chronicle: return "Chronicle"
            case .care:      return "Care"
            case .sanctum:   return "Sanctum"
            }
        }

        var tabIcon: String {
            switch self {
            case .pulse:     return "heart.text.square.fill"
            case .chronicle: return "book.closed.fill"
            case .care:      return "calendar.badge.clock"
            case .sanctum:   return "shield.lefthalf.filled"
            }
        }
    }

    // MARK: - Sheet Destinations

    enum Portal: Identifiable, Equatable {
        case addCompanion
        case editCompanion(UUID)
        case addEpisode(companionId: UUID)
        case editEpisode(UUID)
        case addReminder(companionId: UUID?)
        case addVetVisit(companionId: UUID)
        case badgeShowcase
        case avatarPicker
        case statsOverview
        case shareProgress

        var id: String {
            switch self {
            case .addCompanion:            return "add_companion"
            case .editCompanion(let uid):  return "edit_companion_\(uid)"
            case .addEpisode(let uid):     return "add_episode_\(uid)"
            case .editEpisode(let uid):    return "edit_episode_\(uid)"
            case .addReminder(let uid):    return "add_reminder_\(uid?.uuidString ?? "all")"
            case .addVetVisit(let uid):    return "add_vet_visit_\(uid)"
            case .badgeShowcase:           return "badge_showcase"
            case .avatarPicker:            return "avatar_picker"
            case .statsOverview:           return "stats_overview"
            case .shareProgress:           return "share_progress"
            }
        }
    }

    // MARK: - Push Destinations (NavigationStack)

    enum Waypoint: Hashable {
        case trendDetail(WellnessAxis)
        case trendDetailCustom(String)  // custom axis id
        case dayDetail(String)           // dateKey "yyyy-MM-dd"
        case episodeDetail(UUID)
        case companionDetail(UUID)
    }

    // MARK: - Published State

    @Published var activeRealm: Realm = .pulse
    @Published var activePortal: Portal? = nil
    @Published var pulsePath: [Waypoint] = []
    @Published var chroniclePath: [Waypoint] = []
    @Published var carePath: [Waypoint] = []
    @Published var sanctumPath: [Waypoint] = []

    /// Currently selected companion across tabs
    @Published var focusedCompanionId: UUID? = nil

    /// Toast / snackbar message
    @Published var toastMessage: String? = nil

    // MARK: - Tab Navigation

    func switchRealm(to realm: Realm) {
        activeRealm = realm
    }

    // MARK: - Sheet Navigation

    func openPortal(_ portal: Portal) {
        activePortal = portal
    }

    func closePortal() {
        activePortal = nil
    }

    // MARK: - Push Navigation

    func navigate(to waypoint: Waypoint) {
        switch activeRealm {
        case .pulse:
            pulsePath.append(waypoint)
        case .chronicle:
            chroniclePath.append(waypoint)
        case .care:
            carePath.append(waypoint)
        case .sanctum:
            sanctumPath.append(waypoint)
        }
    }

    func goBack() {
        switch activeRealm {
        case .pulse:
            if !pulsePath.isEmpty { pulsePath.removeLast() }
        case .chronicle:
            if !chroniclePath.isEmpty { chroniclePath.removeLast() }
        case .care:
            if !carePath.isEmpty { carePath.removeLast() }
        case .sanctum:
            if !sanctumPath.isEmpty { sanctumPath.removeLast() }
        }
    }

    func popToRoot() {
        switch activeRealm {
        case .pulse:     pulsePath.removeAll()
        case .chronicle: chroniclePath.removeAll()
        case .care:      carePath.removeAll()
        case .sanctum:   sanctumPath.removeAll()
        }
    }

    // MARK: - Companion Focus

    func focusCompanion(_ id: UUID?) {
        focusedCompanionId = id
    }

    // MARK: - Toast

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            if self?.toastMessage == message {
                self?.toastMessage = nil
            }
        }
    }

    // MARK: - Quick Actions (cross-tab shortcuts)

    func quickAddEpisode() {
        guard let companionId = resolvedCompanionId else {
            showToast("Add a companion first")
            return
        }
        openPortal(.addEpisode(companionId: companionId))
    }

    func quickOpenStats() {
        openPortal(.statsOverview)
    }

    func quickOpenBadges() {
        openPortal(.badgeShowcase)
    }

    // MARK: - Helpers

    /// Returns focused companion or first available
    var resolvedCompanionId: UUID? {
        if let focused = focusedCompanionId,
           GroveStorage.shared.companions.contains(where: { $0.id == focused }) {
            return focused
        }
        return GroveStorage.shared.companions.first?.id
    }

    /// Whether onboarding is needed
    var needsOnboarding: Bool {
        !GroveStorage.shared.onboarding.hasCompletedOnboarding
    }

    /// Whether we have at least one companion
    var hasCompanions: Bool {
        !GroveStorage.shared.companions.isEmpty
    }
}
