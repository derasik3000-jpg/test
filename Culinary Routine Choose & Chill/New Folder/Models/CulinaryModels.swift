

import Foundation
import UIKit

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🥄 Enums & Small Value Types
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Types of meals that can be scheduled into a day.
enum CourseKind: Int, Codable, CaseIterable, Hashable {
    case breakfast = 0
    case lunch     = 1
    case dinner    = 2
    case snack     = 3

    var displayLabel: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch:     return "Lunch"
        case .dinner:    return "Dinner"
        case .snack:     return "Snack"
        }
    }

    var sfIcon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch:     return "sun.max.fill"
        case .dinner:    return "moon.stars.fill"
        case .snack:     return "sparkles"
        }
    }

    var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch:     return "☀️"
        case .dinner:    return "🌙"
        case .snack:     return "⭐️"
        }
    }

    var tintColor: UIColor {
        switch self {
        case .breakfast: return UIColor(hex: 0xFFD60A)
        case .lunch:     return UIColor(hex: 0xFF9F0A)
        case .dinner:    return UIColor(hex: 0xBF5AF2)
        case .snack:     return UIColor(hex: 0x64D2FF)
        }
    }

    /// Bitmask value for compact storage.
    var bitmask: Int { 1 << rawValue }
}

// ────────────────────────────────────────────

/// Measurement units for ingredients.
enum PortionUnit: Int, Codable, CaseIterable {
    case gram       = 0
    case kilogram   = 1
    case milliliter = 2
    case liter      = 3
    case piece      = 4
    case tablespoon = 5
    case teaspoon   = 6

    var shortLabel: String {
        switch self {
        case .gram:       return "g"
        case .kilogram:   return "kg"
        case .milliliter: return "ml"
        case .liter:      return "l"
        case .piece:      return "pcs"
        case .tablespoon: return "tbsp"
        case .teaspoon:   return "tsp"
        }
    }

    /// Can this unit be converted to the other?
    func canConvert(to other: PortionUnit) -> Bool {
        switch (self, other) {
        case (.gram, .kilogram), (.kilogram, .gram):       return true
        case (.milliliter, .liter), (.liter, .milliliter):  return true
        default: return self == other
        }
    }

    /// Factor to convert `self` → base unit (g or ml).
    var toBaseFactor: Double {
        switch self {
        case .gram, .milliliter:   return 1.0
        case .kilogram, .liter:    return 1000.0
        default:                   return 1.0
        }
    }
}

// ────────────────────────────────────────────

/// Satiety level for "avoid heavy dinners in a row" rule.
enum SatietyGrade: Int, Codable, CaseIterable {
    case light   = 1
    case regular = 2
    case hearty  = 3

    var displayLabel: String {
        switch self {
        case .light:   return "Light"
        case .regular: return "Regular"
        case .hearty:  return "Hearty"
        }
    }

    var emoji: String {
        switch self {
        case .light:   return "🍃"
        case .regular: return "🍽"
        case .hearty:  return "🔥"
        }
    }
}

// ────────────────────────────────────────────

/// Week generation mode.
enum BlendMode: Int, Codable {
    case randomShuffle = 0
    case rulesBased    = 1

    var displayLabel: String {
        switch self {
        case .randomShuffle: return "Random"
        case .rulesBased:    return "Smart Rules"
        }
    }
}

// ────────────────────────────────────────────

/// How "owned" items behave in the shopping list.
enum PantryDisplayStyle: Int, Codable {
    case hideCompletely  = 0
    case showStrikethrough = 1
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🥘 Ingredient Category (store aisle)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct AisleCategory: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String          // e.g. "Vegetables", "Dairy"
    var sortRank: Int
    var isHidden: Bool
    var bakedAt: Date          // createdAt
    var refreshedAt: Date      // updatedAt

    static func defaultAisles() -> [AisleCategory] {
        let names = [
            "Vegetables & Fruits",
            "Dairy",
            "Meat & Fish",
            "Bakery",
            "Grains & Pasta",
            "Spices",
            "Frozen",
            "Beverages",
            "Other"
        ]
        return names.enumerated().map { idx, name in
            AisleCategory(
                id: UUID(),
                title: name,
                sortRank: idx,
                isHidden: false,
                bakedAt: Date(),
                refreshedAt: Date()
            )
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🧅 Ingredient
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct Pinch: Codable, Identifiable, Equatable {
    var id: UUID
    var originalName: String       // as typed by user
    var normalizedName: String     // lowercased, trimmed
    var amount: Double
    var unit: PortionUnit
    var aisleID: UUID?             // FK → AisleCategory
    var remark: String?            // "to taste", etc.
    var isOptional: Bool
    var position: Int
    var bakedAt: Date
    var refreshedAt: Date

    /// Builds normalised key from user input.
    static func normalize(_ raw: String) -> String {
        raw.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "  ", with: " ")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 👨‍🍳 Cook Step
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SimmerStep: Codable, Identifiable, Equatable {
    var id: UUID
    var instruction: String
    var position: Int
    var bakedAt: Date
    var refreshedAt: Date
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍲 Dish (one of the 12)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct Entree: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String                   // dish name
    var memo: String?                   // notes
    var courseTagsMask: Int             // bitmask of CourseKind
    var isFavorite: Bool
    var satiety: SatietyGrade
    var ingredients: [Pinch]
    var steps: [SimmerStep]
    var isActive: Bool                  // always true in v1
    var slotIndex: Int                  // 0…11 position in the grid
    var bakedAt: Date
    var refreshedAt: Date

    // ── Helpers ──────────────────────────────

    /// Returns the set of course kinds this dish is tagged with.
    var courseTags: Set<CourseKind> {
        var tags = Set<CourseKind>()
        for kind in CourseKind.allCases where (courseTagsMask & kind.bitmask) != 0 {
            tags.insert(kind)
        }
        return tags
    }

    /// Toggle a specific meal tag on/off.
    mutating func toggleTag(_ kind: CourseKind) {
        courseTagsMask ^= kind.bitmask
    }

    /// Is the dish fully valid for generation?
    var isReadyToServe: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && courseTagsMask > 0
        && !ingredients.isEmpty
    }

    /// Creates a blank placeholder for an empty slot.
    static func emptyPlate(at index: Int) -> Entree {
        Entree(
            id: UUID(),
            title: "",
            memo: nil,
            courseTagsMask: 0,
            isFavorite: false,
            satiety: .regular,
            ingredients: [],
            steps: [],
            isActive: true,
            slotIndex: index,
            bakedAt: Date(),
            refreshedAt: Date()
        )
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 📅 Meal Slot (one cell in the week grid)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct ServingSlot: Codable, Identifiable, Equatable {
    var id: UUID
    var dayDate: Date                  // normalised to midnight
    var course: CourseKind
    var positionInDay: Int             // for future "second snack"
    var isLocked: Bool
    var entreeID: UUID?                // nil = empty slot
    var refreshedAt: Date

    /// Day-of-week index (1 = Sunday … 7 = Saturday) for display.
    var weekdayIndex: Int {
        Calendar.current.component(.weekday, from: dayDate)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🗓 Week Plan
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct FeastWeek: Codable, Identifiable, Equatable {
    var id: UUID
    var weekStartDate: Date            // Monday 00:00
    var randomSeed: Int
    var blendMode: BlendMode
    var servingsMultiplier: Double     // 0.5 / 1.0 / 2.0
    var slots: [ServingSlot]
    var isSavedTemplate: Bool
    var nickname: String?              // optional label
    var bakedAt: Date
    var refreshedAt: Date

    // ── Convenience ──────────────────────────

    /// All slots for a given day.
    func slotsForDay(_ date: Date) -> [ServingSlot] {
        slots.filter { Calendar.current.isDate($0.dayDate, inSameDayAs: date) }
            .sorted { $0.course.rawValue < $1.course.rawValue }
    }

    /// Seven calendar dates of this week (Mon-Sun).
    var calendarDays: [Date] {
        (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: weekStartDate)
        }
    }

    /// Unlocked slots count.
    var unlockedCount: Int {
        slots.filter { !$0.isLocked }.count
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🛒 Shopping List
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct GroceryRoll: Codable, Identifiable, Equatable {
    var id: UUID
    var weekPlanID: UUID
    var assembledAt: Date
    var refreshedAt: Date
    var items: [GroceryTicket]
}

// ────────────────────────────────────────────

struct GroceryTicket: Codable, Identifiable, Equatable {
    var id: UUID
    var normalizedName: String
    var displayName: String
    var amount: Double
    var unit: PortionUnit
    var isChecked: Bool               // bought
    var isOwned: Bool                 // "have at home"
    var isManual: Bool                // user added manually
    var manualNote: String?
    var aisleID: UUID?
    var sources: [TicketOrigin]
    var sortKey: String
    var refreshedAt: Date
}

// ────────────────────────────────────────────

/// Traces which dish(es) contributed to a shopping item.
struct TicketOrigin: Codable, Identifiable, Equatable {
    var id: UUID
    var entreeID: UUID
    var entreeTitleSnapshot: String
    var ingredientNameSnapshot: String
    var amount: Double
    var unit: PortionUnit
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🏠 Pantry Item ("have at home")
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct CellarStock: Codable, Identifiable, Equatable {
    var id: UUID
    var originalName: String?
    var normalizedName: String
    var displayName: String
    var isOwned: Bool
    var aisleID: UUID?
    var refreshedAt: Date
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🔗 Ingredient Alias (synonyms)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct FlavorAlias: Codable, Identifiable, Equatable {
    var id: UUID
    var fromNormalized: String
    var toNormalized: String
    var bakedAt: Date
    var refreshedAt: Date
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 📊 Cook Event (analytics fact)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SauteEvent: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var course: CourseKind
    var entreeID: UUID
    var weekPlanID: UUID?
    var recordedAt: Date
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - ⚙️ Generation Rules
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct RecipeRulebook: Codable, Equatable {
    var noConsecutiveSameInCourse: Bool
    var maxRepeatsPerWeek: Int           // 1…5
    var noSameDishSameDay: Bool
    var favoritesWeightPercent: Int      // 0…100
    var allowCrossTagFallback: Bool
    var fallbackPriorityMask: Int
    var avoidHeavyDinnersInRow: Bool
    var refreshedAt: Date

    static func defaultRecipe() -> RecipeRulebook {
        RecipeRulebook(
            noConsecutiveSameInCourse: true,
            maxRepeatsPerWeek: 2,
            noSameDishSameDay: true,
            favoritesWeightPercent: 30,
            allowCrossTagFallback: false,
            fallbackPriorityMask: 0,
            avoidHeavyDinnersInRow: false,
            refreshedAt: Date()
        )
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🧑‍🍳 User Settings (local profile)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct KitchenConfig: Codable, Equatable {
    var id: UUID
    var enabledCoursesMask: Int           // bitmask
    var defaultServings: Int              // 1…8
    var roundingEnabled: Bool
    var roundingStepGrams: Int            // 50 / 100
    var roundingStepMilliliters: Int      // 50 / 100
    var pantryDisplayStyle: PantryDisplayStyle
    var defaultBlendMode: BlendMode
    var rules: RecipeRulebook
    var avatarEmoji: String               // user-chosen emoji avatar
    var hasCompletedOnboarding: Bool
    var bakedAt: Date
    var refreshedAt: Date

    // ── Helpers ──────────────────────────────

    var enabledCourses: [CourseKind] {
        CourseKind.allCases.filter { (enabledCoursesMask & $0.bitmask) != 0 }
    }

    mutating func toggleCourse(_ kind: CourseKind) {
        enabledCoursesMask ^= kind.bitmask
    }

    static func freshInstall() -> KitchenConfig {
        let mask = CourseKind.breakfast.bitmask
                 | CourseKind.lunch.bitmask
                 | CourseKind.dinner.bitmask   // snack off by default
        return KitchenConfig(
            id: UUID(),
            enabledCoursesMask: mask,
            defaultServings: 2,
            roundingEnabled: true,
            roundingStepGrams: 50,
            roundingStepMilliliters: 50,
            pantryDisplayStyle: .hideCompletely,
            defaultBlendMode: .randomShuffle,
            rules: .defaultRecipe(),
            avatarEmoji: "🧑‍🍳",
            hasCompletedOnboarding: false,
            bakedAt: Date(),
            refreshedAt: Date()
        )
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🗃 Top-Level Vault (all persisted data)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Root container that holds the entire local database.
/// Serialised to a single JSON file via `CellarVault`.
struct KitchenLedger: Codable {
    var config: KitchenConfig
    var entrees: [Entree]                 // always 12 slots
    var aisles: [AisleCategory]
    var aliases: [FlavorAlias]
    var cellarStock: [CellarStock]        // pantry
    var feastWeeks: [FeastWeek]
    var groceryRolls: [GroceryRoll]
    var sauteEvents: [SauteEvent]

    // ── Bootstrap ────────────────────────────

    static func brandNew() -> KitchenLedger {
        let emptyEntrees = (0..<12).map { Entree.emptyPlate(at: $0) }
        return KitchenLedger(
            config: .freshInstall(),
            entrees: emptyEntrees,
            aisles: AisleCategory.defaultAisles(),
            aliases: [],
            cellarStock: [],
            feastWeeks: [],
            groceryRolls: [],
            sauteEvents: []
        )
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🧰 Convenience Extensions
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension Date {

    /// Returns the Monday 00:00 of the week containing this date.
    func startOfFeastWeek() -> Date {
        var cal = Calendar.current
        cal.firstWeekday = 2  // Monday
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return cal.date(from: comps) ?? self
    }

    /// Short display "Mon 12" style.
    func shortDayLabel() -> String {
        let df = DateFormatter()
        df.dateFormat = "EEE d"
        return df.string(from: self)
    }

    /// "Jan 12 – Jan 18" range label.
    func weekRangeLabel() -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM d"
        let start = self.startOfFeastWeek()
        guard let end = Calendar.current.date(byAdding: .day, value: 6, to: start) else {
            return df.string(from: start)
        }
        return "\(df.string(from: start)) – \(df.string(from: end))"
    }
}

// ────────────────────────────────────────────

extension Array where Element == Entree {

    /// Returns only dishes ready for week generation.
    func readyEntrees() -> [Entree] {
        filter { $0.isReadyToServe && $0.isActive }
    }

    /// Dishes matching a specific course tag.
    func entrees(for course: CourseKind) -> [Entree] {
        filter { $0.courseTags.contains(course) && $0.isActive }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🎮 Gamification Stats Snapshot
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Lightweight snapshot computed from ledger data, used on Stats screen.
struct TasteScore: Equatable {
    let totalWeeksPlanned: Int
    let totalSlotsGenerated: Int
    let uniqueDishesUsed: Int
    let shoppingListsCompleted: Int     // all items checked
    let currentStreak: Int              // consecutive weeks planned
    let earnedBadges: [String]          // trophy icon names

    static let empty = TasteScore(
        totalWeeksPlanned: 0,
        totalSlotsGenerated: 0,
        uniqueDishesUsed: 0,
        shoppingListsCompleted: 0,
        currentStreak: 0,
        earnedBadges: []
    )
}

