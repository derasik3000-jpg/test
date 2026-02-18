// ──────────────────────────────────────────────
// BasketAggregator.swift
// с8 – "Menu of 12 Dishes"
//
// Builds a GroceryRoll (shopping list) from a
// FeastWeek by aggregating, deduplicating,
// converting units, rounding, and grouping
// ingredients by store aisle.
// ──────────────────────────────────────────────

import Foundation

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🧺 BasketAggregator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class BasketAggregator {

    // ── Dependencies ─────────────────────────

    private let vault: CellarVault

    init(vault: CellarVault = .shared) {
        self.vault = vault
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Public: Build Shopping List
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Assembles a complete GroceryRoll for the given week plan.
    func harvestBasket(for week: FeastWeek) -> GroceryRoll {
        let config = vault.config
        let allEntrees = vault.entrees
        let pantry = vault.pantryItems
        let aliases = vault.aliases

        // ── Step 1: Collect raw ingredient occurrences ──
        var rawGatherings: [RawGathering] = []

        for slot in week.slots {
            guard let entreeID = slot.entreeID,
                  let entree = allEntrees.first(where: { $0.id == entreeID }) else { continue }

            for pinch in entree.ingredients {
                let gathering = RawGathering(
                    entreeID: entree.id,
                    entreeName: entree.title,
                    ingredientName: pinch.originalName,
                    normalizedName: resolveNormalized(pinch.normalizedName, aliases: aliases),
                    amount: pinch.amount * week.servingsMultiplier,
                    unit: pinch.unit,
                    aisleID: pinch.aisleID,
                    isOptional: pinch.isOptional
                )
                rawGatherings.append(gathering)
            }
        }

        // ── Step 2: Group by (normalizedName + compatible unit) ──
        let buckets = bucketize(rawGatherings)

        // ── Step 3: Merge each bucket into a GroceryTicket ──
        let ownedSet = Set(pantry.filter { $0.isOwned }.map { $0.normalizedName })

        var tickets: [GroceryTicket] = buckets.compactMap { bucket in
            let totalAmount = bucket.entries.reduce(0.0) { $0 + $1.amount }
            let roundedAmount = roundIfNeeded(
                amount: totalAmount,
                unit: bucket.unit,
                config: config
            )

            let sources: [TicketOrigin] = bucket.entries.map { entry in
                TicketOrigin(
                    id: UUID(),
                    entreeID: entry.entreeID,
                    entreeTitleSnapshot: entry.entreeName,
                    ingredientNameSnapshot: entry.ingredientName,
                    amount: entry.amount,
                    unit: entry.unit
                )
            }

            let isOwned = ownedSet.contains(bucket.normalizedName)

            // Display name: pick the most common original spelling
            let displayName = mostFrequentSpelling(in: bucket.entries)
            
            // Skip empty items - filter them out at creation time
            guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
                return nil
            }

            return GroceryTicket(
                id: UUID(),
                normalizedName: bucket.normalizedName,
                displayName: displayName,
                amount: roundedAmount,
                unit: bucket.unit,
                isChecked: false,
                isOwned: isOwned,
                isManual: false,
                manualNote: nil,
                aisleID: bucket.aisleID,
                sources: sources,
                sortKey: buildSortKey(
                    aisleName: vault.aisleName(for: bucket.aisleID),
                    displayName: displayName
                ),
                refreshedAt: Date()
            )
        }

        // ── Step 4: Sort by aisle rank, then name ──
        let aisleRanks = buildAisleRankMap()
        tickets.sort { a, b in
            let rankA = aisleRanks[a.aisleID ?? UUID()] ?? 999
            let rankB = aisleRanks[b.aisleID ?? UUID()] ?? 999
            if rankA != rankB { return rankA < rankB }
            return a.displayName.localizedCaseInsensitiveCompare(b.displayName) == .orderedAscending
        }

        // ── Step 5: Preserve manual items from old roll ──
        if let existingRoll = vault.groceryRoll(forWeek: week.id) {
            let manualItems = existingRoll.items.filter { 
                $0.isManual && !$0.displayName.trimmingCharacters(in: .whitespaces).isEmpty
            }
            tickets.append(contentsOf: manualItems)
        }
        
        // ── Step 6: Final filter to remove any empty items ──
        tickets = tickets.filter { !$0.displayName.trimmingCharacters(in: .whitespaces).isEmpty }

        return GroceryRoll(
            id: UUID(),
            weekPlanID: week.id,
            assembledAt: Date(),
            refreshedAt: Date(),
            items: tickets
        )
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Public: Add Manual Item
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Creates a manually added grocery ticket.
    func brewManualTicket(
        name: String,
        amount: Double = 1,
        unit: PortionUnit = .piece,
        aisleID: UUID? = nil,
        note: String? = nil
    ) -> GroceryTicket {
        GroceryTicket(
            id: UUID(),
            normalizedName: Pinch.normalize(name),
            displayName: name,
            amount: amount,
            unit: unit,
            isChecked: false,
            isOwned: false,
            isManual: true,
            manualNote: note,
            aisleID: aisleID,
            sources: [],
            sortKey: buildSortKey(
                aisleName: vault.aisleName(for: aisleID),
                displayName: name
            ),
            refreshedAt: Date()
        )
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Public: Grouped For Display
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Groups tickets by aisle for section-based UI display.
    func groupByAisle(_ roll: GroceryRoll, showOnlyUnchecked: Bool = false) -> [MarketSection] {
        var filtered = roll.items

        if showOnlyUnchecked {
            filtered = filtered.filter { !$0.isChecked && !$0.isOwned }
        }

        let grouped = Dictionary(grouping: filtered) { ticket -> UUID in
            ticket.aisleID ?? UUID() // nil → unique key per orphan
        }

        let aisleList = vault.aisles

        var sections: [MarketSection] = []

        for aisle in aisleList {
            guard let items = grouped[aisle.id], !items.isEmpty else { continue }
            sections.append(MarketSection(
                aisleID: aisle.id,
                aisleTitle: aisle.title,
                sortRank: aisle.sortRank,
                tickets: items
            ))
        }

        // Collect orphan items (nil aisleID or unknown aisle)
        let knownIDs = Set(aisleList.map { $0.id })
        let orphans = filtered.filter { ticket in
            guard let aid = ticket.aisleID else { return true }
            return !knownIDs.contains(aid)
        }
        if !orphans.isEmpty {
            sections.append(MarketSection(
                aisleID: UUID(),
                aisleTitle: "Other",
                sortRank: 999,
                tickets: orphans
            ))
        }

        sections.sort { $0.sortRank < $1.sortRank }
        return sections
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Public: Statistics
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Quick stats for the shopping list header.
    func basketStats(_ roll: GroceryRoll) -> BasketStats {
        let total = roll.items.filter { !$0.isManual || true }.count
        let checked = roll.items.filter { $0.isChecked }.count
        let owned = roll.items.filter { $0.isOwned && !$0.isChecked }.count
        let remaining = total - checked - owned
        let progress: Double = total > 0 ? Double(checked) / Double(total) : 0

        return BasketStats(
            totalCount: total,
            checkedCount: checked,
            ownedCount: owned,
            remainingCount: max(remaining, 0),
            completionProgress: progress
        )
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 📦 Supporting Types
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// A grouped section for the shopping list UI.
struct MarketSection {
    let aisleID: UUID
    let aisleTitle: String
    let sortRank: Int
    let tickets: [GroceryTicket]

    var uncheckedCount: Int {
        tickets.filter { !$0.isChecked && !$0.isOwned }.count
    }
}

/// Quick numerical summary for the basket header.
struct BasketStats {
    let totalCount: Int
    let checkedCount: Int
    let ownedCount: Int
    let remainingCount: Int
    let completionProgress: Double   // 0…1

    var summaryText: String {
        if remainingCount == 0 && totalCount > 0 {
            return "All done! 🎉"
        }
        return "\(remainingCount) item\(remainingCount == 1 ? "" : "s") remaining"
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🔧 Private Internals
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ── Raw Gathering (pre-merge) ────────────────

private struct RawGathering {
    let entreeID: UUID
    let entreeName: String
    let ingredientName: String
    let normalizedName: String
    let amount: Double
    let unit: PortionUnit
    let aisleID: UUID?
    let isOptional: Bool
}

// ── Merge Bucket ─────────────────────────────

private struct MergeBucket {
    let normalizedName: String
    let unit: PortionUnit
    let aisleID: UUID?
    var entries: [RawGathering]
}

// ── Private Helpers ──────────────────────────

extension BasketAggregator {

    /// Resolve aliases: "tomato" → "tomatoes" etc.
    private func resolveNormalized(_ name: String, aliases: [FlavorAlias]) -> String {
        if let alias = aliases.first(where: { $0.fromNormalized == name }) {
            return alias.toNormalized
        }
        return name
    }

    /// Group raw gatherings into merge buckets by (normalizedName + convertible unit).
    private func bucketize(_ gatherings: [RawGathering]) -> [MergeBucket] {
        var bucketMap: [String: MergeBucket] = [:]

        for g in gatherings {
            // Try to find existing bucket with same name
            if var existing = bucketMap[g.normalizedName] {
                // Check unit compatibility
                if g.unit == existing.unit || g.unit.canConvert(to: existing.unit) {
                    // Convert amount to bucket's base unit if needed
                    var adjusted = g
                    if g.unit != existing.unit {
                        adjusted = convertToUnit(g, targetUnit: existing.unit)
                    }
                    existing.entries.append(adjusted)
                    bucketMap[g.normalizedName] = existing
                } else {
                    // Incompatible unit — create separate bucket
                    let key = "\(g.normalizedName)_\(g.unit.rawValue)"
                    if var altBucket = bucketMap[key] {
                        altBucket.entries.append(g)
                        bucketMap[key] = altBucket
                    } else {
                        bucketMap[key] = MergeBucket(
                            normalizedName: g.normalizedName,
                            unit: g.unit,
                            aisleID: g.aisleID,
                            entries: [g]
                        )
                    }
                }
            } else {
                bucketMap[g.normalizedName] = MergeBucket(
                    normalizedName: g.normalizedName,
                    unit: g.unit,
                    aisleID: g.aisleID,
                    entries: [g]
                )
            }
        }

        return Array(bucketMap.values)
    }

    /// Convert a gathering's amount to a target compatible unit.
    private func convertToUnit(_ gathering: RawGathering, targetUnit: PortionUnit) -> RawGathering {
        let sourceBase = gathering.amount * gathering.unit.toBaseFactor
        let converted = sourceBase / targetUnit.toBaseFactor

        // We rebuild with same properties but adjusted amount/unit
        return RawGathering(
            entreeID: gathering.entreeID,
            entreeName: gathering.entreeName,
            ingredientName: gathering.ingredientName,
            normalizedName: gathering.normalizedName,
            amount: converted,
            unit: targetUnit,
            aisleID: gathering.aisleID,
            isOptional: gathering.isOptional
        )
    }

    /// Smart rounding based on user config.
    private func roundIfNeeded(amount: Double, unit: PortionUnit, config: KitchenConfig) -> Double {
        guard config.roundingEnabled else { return amount }

        switch unit {
        case .piece:
            return ceil(amount)

        case .gram, .milliliter:
            let step: Double
            if unit == .gram {
                step = Double(config.roundingStepGrams)
            } else {
                step = Double(config.roundingStepMilliliters)
            }
            guard step > 0 else { return amount }
            return ceil(amount / step) * step

        case .kilogram, .liter:
            // Round to nearest 0.1
            return (amount * 10).rounded(.up) / 10.0

        case .tablespoon, .teaspoon:
            // Round to nearest 0.5
            return (amount * 2).rounded(.up) / 2.0
        }
    }

    /// Pick the most frequent original spelling from gatherings for display name.
    private func mostFrequentSpelling(in entries: [RawGathering]) -> String {
        // Filter out empty ingredient names
        let nonEmptyEntries = entries.filter { !$0.ingredientName.trimmingCharacters(in: .whitespaces).isEmpty }
        
        guard !nonEmptyEntries.isEmpty else {
            return "" // Return empty string if all entries are empty
        }
        
        var freq: [String: Int] = [:]
        for e in nonEmptyEntries {
            freq[e.ingredientName, default: 0] += 1
        }
        return freq.max(by: { $0.value < $1.value })?.key
            ?? nonEmptyEntries.first?.ingredientName
            ?? ""
    }

    /// Build a sort key for stable ordering: "003_butter" style.
    private func buildSortKey(aisleName: String, displayName: String) -> String {
        let aisleRanks = buildAisleRankMap()
        // Find rank by name since we don't always have the ID here
        let rank = vault.aisles
            .first(where: { $0.title == aisleName })
            .map { aisleRanks[$0.id] ?? 999 } ?? 999
        return String(format: "%03d_%@", rank, displayName.lowercased())
    }

    /// Map aisleID → sortRank for quick lookups.
    private func buildAisleRankMap() -> [UUID: Int] {
        Dictionary(uniqueKeysWithValues: vault.aisles.map { ($0.id, $0.sortRank) })
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🏪 Store Mode Formatter
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Provides formatted strings optimised for the large "store mode" display.
enum StoreModeFormatter {

    /// "200 g" or "1 pcs" or "0.5 l"
    static func formatAmount(_ ticket: GroceryTicket) -> String {
        let amt = ticket.amount
        let unit = ticket.unit.shortLabel

        if ticket.unit == .piece && amt == amt.rounded() {
            return "\(Int(amt)) \(unit)"
        }

        if amt >= 1000 && (ticket.unit == .gram || ticket.unit == .milliliter) {
            let converted = amt / 1000.0
            let bigUnit = ticket.unit == .gram ? "kg" : "l"
            if converted == converted.rounded() {
                return "\(Int(converted)) \(bigUnit)"
            }
            return String(format: "%.1f %@", converted, bigUnit)
        }

        if amt == amt.rounded() {
            return "\(Int(amt)) \(unit)"
        }
        return String(format: "%.1f %@", amt, unit)
    }

    /// Compact source attribution: "from Pasta, Salad +1 more"
    static func sourceLabel(_ ticket: GroceryTicket) -> String? {
        guard !ticket.sources.isEmpty else { return nil }

        let names = Array(Set(ticket.sources.map { $0.entreeTitleSnapshot }))
        switch names.count {
        case 1:
            return "from \(names[0])"
        case 2:
            return "from \(names[0]), \(names[1])"
        default:
            let extra = names.count - 2
            return "from \(names[0]), \(names[1]) +\(extra) more"
        }
    }
}
