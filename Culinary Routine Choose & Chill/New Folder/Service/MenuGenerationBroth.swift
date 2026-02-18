// ──────────────────────────────────────────────
// MenuGenerationBroth.swift
// с8 – "Menu of 12 Dishes"
//
// The core algorithm that fills a FeastWeek
// with dishes from the user's 12-entree set.
// Supports Random and Rules-Based modes,
// locked slots, seed-reproducibility.
// ──────────────────────────────────────────────

import Foundation

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍜 Generation Result
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Wraps the generated week + any warnings for the UI.
struct BrothResult {
    let feastWeek: FeastWeek
    let warnings: [BrothWarning]
}

struct BrothWarning: Equatable {
    let slotID: UUID          // which slot had an issue
    let message: String       // human-readable reason
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🥣 MenuGenerationBroth
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class MenuGenerationBroth {

    // ── Dependencies ─────────────────────────

    private let vault: CellarVault

    init(vault: CellarVault = .shared) {
        self.vault = vault
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Public: Generate Full Week
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Build a brand-new week plan from scratch.
    /// - Parameters:
    ///   - weekStart: Monday 00:00 of the target week.
    ///   - mode: Random or Rules-based.
    ///   - newSeed: If true, generates a fresh random seed.
    ///   - existingWeek: Optional existing plan (to preserve locked slots).
    func cookWeek(
        weekStart: Date,
        mode: BlendMode,
        newSeed: Bool = true,
        existingWeek: FeastWeek? = nil
    ) -> BrothResult {

        let config = vault.config
        let entrees = vault.entrees.filter { $0.isReadyToServe }
        let courses = config.enabledCourses
        let rules = config.rules

        // ── Seed ─────────────────────────────
        let seed: Int
        if newSeed {
            seed = Int.random(in: 1...Int.max)
        } else {
            seed = existingWeek?.randomSeed ?? Int.random(in: 1...Int.max)
        }
        var rng = SeededLadle(seed: UInt64(seed))

        // ── Build empty slot scaffold ────────
        let monday = weekStart.startOfFeastWeek()
        let days = (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: monday) }

        var slots: [ServingSlot] = []
        for day in days {
            for (posIdx, course) in courses.enumerated() {
                // Reuse locked slot if available
                if let existing = existingWeek?.slots.first(where: {
                    Calendar.current.isDate($0.dayDate, inSameDayAs: day)
                    && $0.course == course
                    && $0.isLocked
                }) {
                    slots.append(existing)
                } else {
                    slots.append(ServingSlot(
                        id: UUID(),
                        dayDate: day,
                        course: course,
                        positionInDay: posIdx,
                        isLocked: false,
                        entreeID: nil,
                        refreshedAt: Date()
                    ))
                }
            }
        }

        // ── Fill unlocked slots ──────────────
        var warnings: [BrothWarning] = []

        switch mode {
        case .randomShuffle:
            fillRandom(slots: &slots, entrees: entrees, rng: &rng, warnings: &warnings)
        case .rulesBased:
            fillWithRules(slots: &slots, entrees: entrees, rules: rules,
                          config: config, rng: &rng, warnings: &warnings)
        }

        // ── Assemble FeastWeek ───────────────
        let week = FeastWeek(
            id: existingWeek?.id ?? UUID(),
            weekStartDate: monday,
            randomSeed: seed,
            blendMode: mode,
            servingsMultiplier: existingWeek?.servingsMultiplier ?? Double(config.defaultServings),
            slots: slots,
            isSavedTemplate: existingWeek?.isSavedTemplate ?? false,
            nickname: existingWeek?.nickname,
            bakedAt: existingWeek?.bakedAt ?? Date(),
            refreshedAt: Date()
        )

        return BrothResult(feastWeek: week, warnings: warnings)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Public: Regenerate Only Unlocked
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Re-fill only unlocked slots, keeping locked ones untouched.
    func reheatUnlocked(existing: FeastWeek) -> BrothResult {
        return cookWeek(
            weekStart: existing.weekStartDate,
            mode: existing.blendMode,
            newSeed: true,
            existingWeek: existing
        )
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Public: Swap Single Slot
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Returns a ranked list of dishes suitable for replacing a given slot.
    func swapCandidates(
        for slot: ServingSlot,
        inWeek week: FeastWeek
    ) -> [Entree] {
        let entrees = vault.entrees.filter { $0.isReadyToServe }
        let rules = vault.config.rules

        // Already used dish IDs this week (for repeat awareness)
        let usedIDs = Set(week.slots.compactMap { $0.entreeID })

        // Primary: matching course tag
        var primary = entrees.filter { $0.courseTags.contains(slot.course) }

        // Secondary: cross-tag fallback (if enabled)
        var secondary: [Entree] = []
        if rules.allowCrossTagFallback {
            secondary = entrees.filter { !$0.courseTags.contains(slot.course) }
        }

        // Sort: prefer dishes not yet on the week, then favorites first
        let sorter: (Entree, Entree) -> Bool = { a, b in
            let aUsed = usedIDs.contains(a.id)
            let bUsed = usedIDs.contains(b.id)
            if aUsed != bUsed { return !aUsed }
            if a.isFavorite != b.isFavorite { return a.isFavorite }
            return a.title < b.title
        }

        primary.sort(by: sorter)
        secondary.sort(by: sorter)

        return primary + secondary
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Private: Random Fill
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func fillRandom(
        slots: inout [ServingSlot],
        entrees: [Entree],
        rng: inout SeededLadle,
        warnings: inout [BrothWarning]
    ) {
        for i in slots.indices where !slots[i].isLocked {
            let course = slots[i].course
            var candidates = entrees.filter { $0.courseTags.contains(course) }

            if candidates.isEmpty {
                // fallback: any dish
                candidates = entrees
            }

            if candidates.isEmpty {
                warnings.append(BrothWarning(
                    slotID: slots[i].id,
                    message: "No dishes available for \(course.displayLabel)."
                ))
                continue
            }

            let pick = candidates[Int(rng.next() % UInt64(candidates.count))]
            slots[i].entreeID = pick.id
            slots[i].refreshedAt = Date()
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Private: Rules-Based Fill
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func fillWithRules(
        slots: inout [ServingSlot],
        entrees: [Entree],
        rules: RecipeRulebook,
        config: KitchenConfig,
        rng: inout SeededLadle,
        warnings: inout [BrothWarning]
    ) {
        // Track usage counts across the week for repeat limits.
        var weekUsage: [UUID: Int] = [:]

        // Pre-count locked slots
        for slot in slots where slot.isLocked {
            if let eid = slot.entreeID {
                weekUsage[eid, default: 0] += 1
            }
        }

        // Process slots in chronological order
        let sortedIndices = slots.indices.sorted { a, b in
            if slots[a].dayDate != slots[b].dayDate {
                return slots[a].dayDate < slots[b].dayDate
            }
            return slots[a].course.rawValue < slots[b].course.rawValue
        }

        for idx in sortedIndices {
            guard !slots[idx].isLocked else { continue }

            let course = slots[idx].course
            let day = slots[idx].dayDate

            // Step 1: Gather candidates by tag
            var candidates = entrees.filter { $0.courseTags.contains(course) }

            // Step 2: Apply max repeats per week
            candidates = candidates.filter { entree in
                (weekUsage[entree.id] ?? 0) < rules.maxRepeatsPerWeek
            }

            // Step 3: No same dish same day
            if rules.noSameDishSameDay {
                let sameDayIDs = slots
                    .filter { Calendar.current.isDate($0.dayDate, inSameDayAs: day) && $0.entreeID != nil }
                    .compactMap { $0.entreeID }
                let sameDaySet = Set(sameDayIDs)
                candidates = candidates.filter { !sameDaySet.contains($0.id) }
            }

            // Step 4: No consecutive same dish in same course
            if rules.noConsecutiveSameInCourse {
                let previousSlot = findPreviousSlot(
                    for: course,
                    before: day,
                    in: slots
                )
                if let prevID = previousSlot?.entreeID {
                    candidates = candidates.filter { $0.id != prevID }
                }
            }

            // Step 5: Avoid heavy dinners in a row
            if rules.avoidHeavyDinnersInRow && course == .dinner {
                let prevDinner = findPreviousSlot(for: .dinner, before: day, in: slots)
                if let prevEID = prevDinner?.entreeID,
                   let prevEntree = entrees.first(where: { $0.id == prevEID }),
                   prevEntree.satiety == .hearty {
                    // Remove hearty candidates
                    let filtered = candidates.filter { $0.satiety != .hearty }
                    if !filtered.isEmpty {
                        candidates = filtered
                    }
                    // If all remaining are hearty, allow them anyway (soft rule)
                }
            }

            // Step 6: Cross-tag fallback if no candidates
            if candidates.isEmpty && rules.allowCrossTagFallback {
                let fallbackCourses = neighborCourses(for: course)
                for fallbackCourse in fallbackCourses {
                    candidates = entrees.filter { $0.courseTags.contains(fallbackCourse) }
                    candidates = candidates.filter { (weekUsage[$0.id] ?? 0) < rules.maxRepeatsPerWeek }
                    if !candidates.isEmpty { break }
                }
            }

            // Step 7: Pick with weighted randomness (favorites boost)
            if candidates.isEmpty {
                warnings.append(BrothWarning(
                    slotID: slots[idx].id,
                    message: "Need more \(course.displayLabel) dishes."
                ))
                continue
            }

            let chosen = weightedPick(
                from: candidates,
                favoritesWeight: rules.favoritesWeightPercent,
                rng: &rng
            )

            slots[idx].entreeID = chosen.id
            slots[idx].refreshedAt = Date()
            weekUsage[chosen.id, default: 0] += 1
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Private: Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Find the slot of the same course type on the previous day.
    private func findPreviousSlot(
        for course: CourseKind,
        before day: Date,
        in slots: [ServingSlot]
    ) -> ServingSlot? {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: day) else {
            return nil
        }
        return slots.first {
            Calendar.current.isDate($0.dayDate, inSameDayAs: yesterday)
            && $0.course == course
            && $0.entreeID != nil
        }
    }

    /// Neighbor courses for cross-tag fallback ordering.
    private func neighborCourses(for course: CourseKind) -> [CourseKind] {
        switch course {
        case .breakfast: return [.snack, .lunch]
        case .lunch:     return [.dinner, .snack]
        case .dinner:    return [.lunch, .snack]
        case .snack:     return [.breakfast, .lunch]
        }
    }

    /// Weighted random pick favoring favorite dishes.
    private func weightedPick(
        from candidates: [Entree],
        favoritesWeight: Int,
        rng: inout SeededLadle
    ) -> Entree {
        guard candidates.count > 1 else { return candidates[0] }

        // Build weight array
        let baseWeight: Double = 100.0
        let favoriteBoost = Double(favoritesWeight) // 0…100 extra weight

        var weights: [Double] = candidates.map { entree in
            entree.isFavorite ? baseWeight + favoriteBoost : baseWeight
        }

        let totalWeight = weights.reduce(0, +)
        let roll = Double(rng.next() % 10_000) / 10_000.0 * totalWeight

        var cumulative: Double = 0
        for (i, w) in weights.enumerated() {
            cumulative += w
            if roll <= cumulative {
                return candidates[i]
            }
        }

        return candidates.last!
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🎲 SeededLadle (deterministic RNG)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Xorshift64-based PRNG for reproducible week generation.
/// Same seed + same dish set → same result.
struct SeededLadle {

    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }

    /// Shuffle an array in-place using this seeded RNG.
    mutating func shuffle<T>(_ array: inout [T]) {
        guard array.count > 1 else { return }
        for i in stride(from: array.count - 1, through: 1, by: -1) {
            let j = Int(next() % UInt64(i + 1))
            array.swapAt(i, j)
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🔄 Week Duplication Helper
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension MenuGenerationBroth {

    /// Clone an existing week plan onto a new target week.
    /// Slots are copied (IDs regenerated), locks preserved.
    func duplicateWeek(
        source: FeastWeek,
        toWeekStart target: Date
    ) -> FeastWeek {
        let targetMonday = target.startOfFeastWeek()
        let sourceMonday = source.weekStartDate

        let dayOffset = Calendar.current.dateComponents(
            [.day], from: sourceMonday, to: targetMonday
        ).day ?? 0

        let newSlots: [ServingSlot] = source.slots.map { slot in
            let newDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: slot.dayDate) ?? slot.dayDate
            return ServingSlot(
                id: UUID(),
                dayDate: newDate,
                course: slot.course,
                positionInDay: slot.positionInDay,
                isLocked: slot.isLocked,
                entreeID: slot.entreeID,
                refreshedAt: Date()
            )
        }

        return FeastWeek(
            id: UUID(),
            weekStartDate: targetMonday,
            randomSeed: source.randomSeed,
            blendMode: source.blendMode,
            servingsMultiplier: source.servingsMultiplier,
            slots: newSlots,
            isSavedTemplate: false,
            nickname: source.nickname.map { "\($0) (copy)" },
            bakedAt: Date(),
            refreshedAt: Date()
        )
    }

    /// Mark an existing week as a saved template.
    func templateize(_ week: FeastWeek) -> FeastWeek {
        var copy = week
        copy.isSavedTemplate = true
        copy.refreshedAt = Date()
        return copy
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 📋 Validation Report
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Pre-generation check: tells UI what's missing before we can cook a week.
struct PantryAudit {
    let totalSlots: Int
    let readyDishes: Int
    let missingTags: [CourseKind]       // courses with 0 tagged dishes
    let emptySlotIndices: [Int]         // slot indices without a dish
    let canGenerate: Bool

    var summaryText: String {
        if canGenerate {
            return "Ready to cook! \(readyDishes)/12 dishes prepared."
        }
        var lines: [String] = ["\(readyDishes)/12 dishes ready."]
        if !missingTags.isEmpty {
            let names = missingTags.map { $0.displayLabel }.joined(separator: ", ")
            lines.append("Need dishes tagged: \(names).")
        }
        if !emptySlotIndices.isEmpty {
            lines.append("\(emptySlotIndices.count) empty slot(s) in your set.")
        }
        return lines.joined(separator: " ")
    }
}

extension MenuGenerationBroth {

    /// Audit the current dish set before generation.
    func auditPantry() -> PantryAudit {
        let config = vault.config
        let entrees = vault.entrees
        let readyOnes = entrees.filter { $0.isReadyToServe }
        let courses = config.enabledCourses

        var missingTags: [CourseKind] = []
        for course in courses {
            if readyOnes.filter({ $0.courseTags.contains(course) }).isEmpty {
                missingTags.append(course)
            }
        }

        let emptyIndices = entrees
            .filter { !$0.isReadyToServe }
            .map { $0.slotIndex }

        let slotsPerWeek = 7 * courses.count

        return PantryAudit(
            totalSlots: slotsPerWeek,
            readyDishes: readyOnes.count,
            missingTags: missingTags,
            emptySlotIndices: emptyIndices,
            canGenerate: readyOnes.count >= 2 && missingTags.isEmpty
        )
    }
}
