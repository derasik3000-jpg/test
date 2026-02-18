
import Foundation
import UIKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🏺 CellarVault (singleton persistence)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class CellarVault {

    // ── Singleton ────────────────────────────

    static let shared = CellarVault()

    // ── In-Memory Ledger ─────────────────────

    private(set) var ledger: KitchenLedger

    // ── File Path ────────────────────────────

    private let pantryFileName = "kitchen_ledger_v1.json"

    private var pantryFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(pantryFileName)
    }

    // ── Serial Queue ─────────────────────────

    /// All reads/writes happen on this queue to avoid races.
    private let ovenQueue = DispatchQueue(label: "com.c8.cellarVault.oven", qos: .userInitiated)

    // ── Debounce Timer ───────────────────────

    private var simmering: DispatchWorkItem?
    private let simmerDelay: TimeInterval = 0.4  // seconds

    // ── Observers ────────────────────────────

    /// Posted on main queue after every successful save.
    static let ledgerDidUpdate = Notification.Name("CellarVault.ledgerDidUpdate")

    // ── Init ─────────────────────────────────

    private init() {
        self.ledger = KitchenLedger.brandNew()   // temporary default
        self.ledger = loadFromPantry()            // overwrite with disk
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Public API
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Read-only snapshot (thread-safe copy).
    func peek() -> KitchenLedger {
        ovenQueue.sync { ledger }
    }

    /// Mutate the ledger and auto-save with debounce.
    /// - Parameter transform: Closure that mutates the ledger.
    func stir(_ transform: @escaping (inout KitchenLedger) -> Void) {
        ovenQueue.async { [weak self] in
            guard let self = self else { return }
            transform(&self.ledger)
            self.scheduleBake()
        }
    }

    /// Mutate + immediately save (no debounce). Use sparingly.
    func stirAndServe(_ transform: @escaping (inout KitchenLedger) -> Void) {
        ovenQueue.async { [weak self] in
            guard let self = self else { return }
            transform(&self.ledger)
            self.bakeToDisk()
        }
    }

    /// Force-save current state right now.
    func forceServe() {
        ovenQueue.async { [weak self] in
            self?.bakeToDisk()
        }
    }

    /// Completely reset to factory defaults (destructive).
    func burnKitchen() {
        ovenQueue.async { [weak self] in
            guard let self = self else { return }
            self.ledger = KitchenLedger.brandNew()
            self.bakeToDisk()
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Config Shortcuts
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    var config: KitchenConfig {
        ovenQueue.sync { ledger.config }
    }

    var hasCompletedOnboarding: Bool {
        ovenQueue.sync { ledger.config.hasCompletedOnboarding }
    }

    func markOnboardingDone() {
        stir { $0.config.hasCompletedOnboarding = true }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Entree (Dish) Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// All 12 slots (some may be empty plates).
    var entrees: [Entree] {
        ovenQueue.sync { ledger.entrees.sorted { $0.slotIndex < $1.slotIndex } }
    }

    /// Number of ready-to-serve dishes out of 12.
    var readyEntreeCount: Int {
        ovenQueue.sync { ledger.entrees.filter { $0.isReadyToServe }.count }
    }

    /// Update a single dish by id, or replace empty slot if new.
    func updateEntree(_ updated: Entree) {
        stir { ledger in
            // First try to find by id (for updates)
            if let idx = ledger.entrees.firstIndex(where: { $0.id == updated.id }) {
                ledger.entrees[idx] = updated
                ledger.entrees[idx].refreshedAt = Date()
            } else {
                // New entree - replace empty slot at same slotIndex
                if let slotIdx = ledger.entrees.firstIndex(where: { $0.slotIndex == updated.slotIndex }) {
                    ledger.entrees[slotIdx] = updated
                } else {
                    // Slot doesn't exist, add it
                    ledger.entrees.append(updated)
                    // Ensure we have exactly 12 entrees, sorted by slotIndex
                    ledger.entrees.sort { $0.slotIndex < $1.slotIndex }
                    // If we have more than 12, keep only first 12
                    if ledger.entrees.count > 12 {
                        ledger.entrees = Array(ledger.entrees.prefix(12))
                    }
                }
            }
        }
    }

    /// Clear a single slot back to empty.
    func clearSlot(at index: Int) {
        stir { ledger in
            if let idx = ledger.entrees.firstIndex(where: { $0.slotIndex == index }) {
                ledger.entrees[idx] = Entree.emptyPlate(at: index)
            }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - FeastWeek (Week Plan) Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Current (or most recent) week plan.
    func currentFeastWeek() -> FeastWeek? {
        let monday = Date().startOfFeastWeek()
        return ovenQueue.sync {
            ledger.feastWeeks.first(where: {
                Calendar.current.isDate($0.weekStartDate, inSameDayAs: monday)
            })
        }
    }

    /// Save or insert a week plan.
    func saveFeastWeek(_ week: FeastWeek) {
        stir { ledger in
            if let idx = ledger.feastWeeks.firstIndex(where: { $0.id == week.id }) {
                ledger.feastWeeks[idx] = week
            } else {
                ledger.feastWeeks.append(week)
            }
        }
    }

    /// All saved weeks sorted by date (newest first).
    var feastWeekHistory: [FeastWeek] {
        ovenQueue.sync {
            ledger.feastWeeks.sorted { $0.weekStartDate > $1.weekStartDate }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - GroceryRoll (Shopping) Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func groceryRoll(forWeek weekID: UUID) -> GroceryRoll? {
        ovenQueue.sync {
            ledger.groceryRolls.first(where: { $0.weekPlanID == weekID })
        }
    }

    func saveGroceryRoll(_ roll: GroceryRoll) {
        stir { ledger in
            if let idx = ledger.groceryRolls.firstIndex(where: { $0.id == roll.id }) {
                ledger.groceryRolls[idx] = roll
            } else {
                ledger.groceryRolls.append(roll)
            }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - CellarStock (Pantry) Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    var pantryItems: [CellarStock] {
        ovenQueue.sync { ledger.cellarStock }
    }

    func markAsOwned(normalizedName: String, displayName: String, aisleID: UUID?) {
        stir { ledger in
            if let idx = ledger.cellarStock.firstIndex(where: { $0.normalizedName == normalizedName }) {
                ledger.cellarStock[idx].isOwned = true
                ledger.cellarStock[idx].refreshedAt = Date()
            } else {
                let item = CellarStock(
                    id: UUID(),
                    originalName: displayName,
                    normalizedName: normalizedName,
                    displayName: displayName,
                    isOwned: true,
                    aisleID: aisleID,
                    refreshedAt: Date()
                )
                ledger.cellarStock.append(item)
            }
        }
    }

    func removeFromPantry(normalizedName: String) {
        stir { ledger in
            ledger.cellarStock.removeAll { $0.normalizedName == normalizedName }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - FlavorAlias (Synonyms) Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    var aliases: [FlavorAlias] {
        ovenQueue.sync { ledger.aliases }
    }

    /// Resolves a normalised ingredient name through the alias chain.
    func resolveAlias(for normalized: String) -> String {
        let map = ovenQueue.sync { ledger.aliases }
        if let alias = map.first(where: { $0.fromNormalized == normalized }) {
            return alias.toNormalized
        }
        return normalized
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - AisleCategory Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    var aisles: [AisleCategory] {
        ovenQueue.sync {
            ledger.aisles
                .filter { !$0.isHidden }
                .sorted { $0.sortRank < $1.sortRank }
        }
    }

    func aisleName(for id: UUID?) -> String {
        guard let id = id else { return "Other" }
        return ovenQueue.sync {
            ledger.aisles.first(where: { $0.id == id })?.title ?? "Other"
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - SauteEvent (Analytics) Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func recordSauteEvents(from week: FeastWeek) {
        stir { ledger in
            for slot in week.slots {
                guard let entreeID = slot.entreeID else { continue }
                let event = SauteEvent(
                    id: UUID(),
                    date: slot.dayDate,
                    course: slot.course,
                    entreeID: entreeID,
                    weekPlanID: week.id,
                    recordedAt: Date()
                )
                ledger.sauteEvents.append(event)
            }
        }
    }

    var allSauteEvents: [SauteEvent] {
        ovenQueue.sync { ledger.sauteEvents }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Gamification Score Builder
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func computeTasteScore() -> TasteScore {
        let snapshot = peek()

        let weeksPlanned = snapshot.feastWeeks.count
        let totalSlots = snapshot.feastWeeks.reduce(0) { $0 + $1.slots.filter { $0.entreeID != nil }.count }
        let uniqueDishes = Set(snapshot.sauteEvents.map { $0.entreeID }).count

        let completedLists = snapshot.groceryRolls.filter { roll in
            !roll.items.isEmpty && roll.items.allSatisfy { $0.isChecked || $0.isOwned }
        }.count

        // Streak: count consecutive weeks from now backwards
        var streak = 0
        let sortedWeeks = snapshot.feastWeeks.sorted { $0.weekStartDate > $1.weekStartDate }
        var expectedMonday = Date().startOfFeastWeek()
        for week in sortedWeeks {
            if Calendar.current.isDate(week.weekStartDate, inSameDayAs: expectedMonday) {
                streak += 1
                expectedMonday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: expectedMonday) ?? expectedMonday
            } else {
                break
            }
        }

        // Badges
        var badges: [String] = []
        if snapshot.entrees.filter({ $0.isReadyToServe }).count == 12 {
            badges.append(KitchenBadge.fullPantry.icon)
        }
        if weeksPlanned >= 1 {
            badges.append(KitchenBadge.weekChef.icon)
        }
        if completedLists >= 1 {
            badges.append(KitchenBadge.smartShopper.icon)
        }
        if uniqueDishes >= 10 {
            badges.append(KitchenBadge.varietyMaster.icon)
        }

        return TasteScore(
            totalWeeksPlanned: weeksPlanned,
            totalSlotsGenerated: totalSlots,
            uniqueDishesUsed: uniqueDishes,
            shoppingListsCompleted: completedLists,
            currentStreak: streak,
            earnedBadges: badges
        )
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Private: Disk I/O
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Load ledger from JSON file, or create brand-new if missing / corrupt.
    private func loadFromPantry() -> KitchenLedger {
        guard FileManager.default.fileExists(atPath: pantryFileURL.path) else {
            let fresh = KitchenLedger.brandNew()
            writeJSON(fresh)
            return fresh
        }

        do {
            let data = try Data(contentsOf: pantryFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let loaded = try decoder.decode(KitchenLedger.self, from: data)
            return loaded
        } catch {
            debugPrint("🍳 CellarVault: decode error – \(error). Starting fresh.")
            let fresh = KitchenLedger.brandNew()
            // backup corrupt file just in case
            backupCorruptFile()
            writeJSON(fresh)
            return fresh
        }
    }

    /// Encode and write ledger to disk.
    private func bakeToDisk() {
        writeJSON(ledger)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: CellarVault.ledgerDidUpdate, object: nil)
        }
    }

    private func writeJSON(_ object: KitchenLedger) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(object)
            try data.write(to: pantryFileURL, options: [.atomic])
        } catch {
            debugPrint("🍳 CellarVault: write error – \(error)")
        }
    }

    /// Debounced save: cancels previous timer, waits simmerDelay, then writes.
    private func scheduleBake() {
        simmering?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.bakeToDisk()
        }
        simmering = work
        ovenQueue.asyncAfter(deadline: .now() + simmerDelay, execute: work)
    }

    /// Move corrupt file to a backup name so we don't lose data silently.
    private func backupCorruptFile() {
        let backup = pantryFileURL.deletingLastPathComponent()
            .appendingPathComponent("kitchen_ledger_corrupt_\(Int(Date().timeIntervalSince1970)).json")
        try? FileManager.default.moveItem(at: pantryFileURL, to: backup)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🧊 Quick UserDefaults Layer
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Lightweight key-value cache for flags that don't belong in the ledger
/// (e.g. "has shown rating prompt", first launch date, etc.)
enum FrostBox {

    private static let suite = UserDefaults.standard

    // ── Keys ─────────────────────────────────

    private enum Spice: String {
        case firstLaunchEpoch    = "frost.firstLaunchEpoch"
        case appOpenCount        = "frost.appOpenCount"
        case lastReviewPrompt    = "frost.lastReviewPrompt"
        case reduceMotionLocal   = "frost.reduceMotionLocal"
    }

    // ── First Launch ─────────────────────────

    static var firstLaunchDate: Date {
        let epoch = suite.double(forKey: Spice.firstLaunchEpoch.rawValue)
        if epoch == 0 {
            let now = Date().timeIntervalSince1970
            suite.set(now, forKey: Spice.firstLaunchEpoch.rawValue)
            return Date(timeIntervalSince1970: now)
        }
        return Date(timeIntervalSince1970: epoch)
    }

    // ── App Opens ────────────────────────────

    static func incrementOpenCount() {
        let current = suite.integer(forKey: Spice.appOpenCount.rawValue)
        suite.set(current + 1, forKey: Spice.appOpenCount.rawValue)
    }

    static var appOpenCount: Int {
        suite.integer(forKey: Spice.appOpenCount.rawValue)
    }

    // ── Reduce Motion ────────────────────────

    static var localReduceMotion: Bool {
        get { suite.bool(forKey: Spice.reduceMotionLocal.rawValue) }
        set { suite.set(newValue, forKey: Spice.reduceMotionLocal.rawValue) }
    }

    /// Combined check: system OR local preference.
    static var shouldReduceMotion: Bool {
        UIAccessibility.isReduceMotionEnabled || localReduceMotion
    }
}
