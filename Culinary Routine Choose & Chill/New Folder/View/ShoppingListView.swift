import SwiftUI
import Combine

struct ShoppingListView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    
    var body: some View {
        let _ = print("🎨 [Shopping] ShoppingListView body rendered, isEmpty: \(viewModel.isEmpty), groupedItems count: \(viewModel.groupedItems.count)")
        return ZStack {
            Color(hex: 0x111111) // SaffronPalette.crust
                .ignoresSafeArea()
            
            contentView
        }
        .navigationTitle("Shopping")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewModel.showHelp() }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(Color(hex: 0xC5A253)) // honeyComb
                }
            }
        }
        .onAppear {
            print("👀 [Shopping] ShoppingListView onAppear")
            viewModel.loadShoppingList()
        }
        .onChange(of: viewModel.currentWeekStart) { _ in
            print("👀 [Shopping] ShoppingListView onChange currentWeekStart")
            viewModel.loadShoppingList()
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Week navigation - always visible
                weekNavigationView
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                if viewModel.isEmpty {
                    // Empty state - but navigation is still visible above
                    emptyStateView
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                        .padding(.bottom, 32)
                } else {
                    // Filter toggle
                    filterToggleView
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    // Store mode button
                    storeModeButtonView
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    // Items list
                    itemsListView
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("No shopping list yet")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color(hex: 0xAEAEB2)) // steamGrey
            
            Text("Go to 'Week Plan' and generate a week to automatically create your shopping list from the meal ingredients.")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color(hex: 0xAEAEB2))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    private var weekNavigationView: some View {
        HStack {
            Button(action: { viewModel.moveWeek(by: -1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(hex: 0xC5A253))
                    .font(.system(size: 16, weight: .semibold))
            }
            
            Spacer()
            
            Text(viewModel.weekTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { viewModel.moveWeek(by: 1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: 0xC5A253))
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .padding(.vertical, 12)
        .background(Color(hex: 0x1C1C1E)) // brioche
        .cornerRadius(10)
    }
    
    private var filterToggleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Show only unchecked")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $viewModel.showOnlyUnchecked)
                    .tint(Color(hex: 0xC5A253))
            }
            
            Text("Hide items you've checked or marked as owned")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: 0xAEAEB2))
        }
        .padding(16)
        .background(Color(hex: 0x1C1C1E))
        .cornerRadius(10)
    }
    
    private var storeModeButtonView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { viewModel.openStoreMode() }) {
                HStack {
                    Text("Store Mode")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: 0xAEAEB2), lineWidth: 1.5)
                )
            }
            
            Text("Full-screen optimized view for shopping")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: 0xAEAEB2))
        }
    }
    
    private var itemsListView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.groupedItems) { group in
                ShoppingAisleSectionView(
                    group: group,
                    showOnlyUnchecked: viewModel.showOnlyUnchecked,
                    onItemToggled: { ticket in
                        // Always get the latest ticket from currentRoll
                        viewModel.toggleItemWithID(ticket.id)
                    },
                    onOwnedToggled: { ticket in
                        // Always get the latest ticket from currentRoll
                        viewModel.toggleOwnedWithID(ticket.id)
                    }
                )
            }
        }
    }
}

// MARK: - Aisle Section View

struct ShoppingAisleSectionView: View {
    let group: AisleGroup
    let showOnlyUnchecked: Bool
    let onItemToggled: (GroceryTicket) -> Void
    let onOwnedToggled: (GroceryTicket) -> Void
    
    private var displayItems: [GroceryTicket] {
        let validItems = group.items.filter { !$0.displayName.trimmingCharacters(in: .whitespaces).isEmpty }
        let result = showOnlyUnchecked
            ? validItems.filter { !$0.isChecked && !$0.isOwned }
            : validItems
        print("👁️ [Shopping] ShoppingAisleSectionView '\(group.aisle.title)' displayItems: \(result.count) items (showOnlyUnchecked: \(showOnlyUnchecked), validItems: \(validItems.count))")
        for item in result {
            print("👁️ [Shopping]   - '\(item.displayName)' id: \(item.id) isChecked: \(item.isChecked) isOwned: \(item.isOwned)")
        }
        return result
    }
    
    var body: some View {
        let _ = print("🎨 [Shopping] ShoppingAisleSectionView body rendered for '\(group.aisle.title)'")
        return VStack(alignment: .leading, spacing: 8) {
            Text(group.aisle.title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            VStack(spacing: 8) {
                ForEach(displayItems) { ticket in
                    GroceryItemRowView(
                        ticket: ticket,
                        onPurchasedToggled: {
                            print("👆 [Shopping] Purchased button tapped for '\(ticket.displayName)' id: \(ticket.id) current isChecked: \(ticket.isChecked)")
                            onItemToggled(ticket)
                        },
                        onOwnedToggled: {
                            print("👆 [Shopping] Owned button tapped for '\(ticket.displayName)' id: \(ticket.id) current isOwned: \(ticket.isOwned)")
                            onOwnedToggled(ticket)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(hex: 0x1C1C1E))
        .cornerRadius(10)
        .shadow(color: Color(hex: 0xC5A253).opacity(0.12), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Grocery Item Row View

struct GroceryItemRowView: View {
    let ticket: GroceryTicket
    let onPurchasedToggled: () -> Void
    let onOwnedToggled: () -> Void
    
    var body: some View {
        let _ = print("🎨 [Shopping] GroceryItemRowView body rendered for '\(ticket.displayName)' id: \(ticket.id) isChecked: \(ticket.isChecked) isOwned: \(ticket.isOwned)")
        return HStack(spacing: 12) {
            // Icon (left)
            Image(systemName: "circle.fill")
                .foregroundColor(Color(hex: 0xC5A253))
                .font(.system(size: 8))
            
            // Name
            Text(ticket.displayName)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(ticket.isChecked || ticket.isOwned ? Color(hex: 0x636366) : .white)
                .strikethrough(ticket.isChecked || ticket.isOwned)
                .lineLimit(1)
            
            Spacer()
            
            // Amount
            Text(formatAmount(ticket.amount) + " " + ticket.unit.shortLabel)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: 0xAEAEB2))
            
            // Owned button
            Button(action: onOwnedToggled) {
                Image(systemName: ticket.isOwned ? "house.fill" : "house")
                    .foregroundColor(ticket.isOwned ? Color(hex: 0x30D158) : Color(hex: 0xAEAEB2))
                    .font(.system(size: 20))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Purchased button
            Button(action: onPurchasedToggled) {
                Text("Bought")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(ticket.isChecked ? .white : Color(hex: 0xAEAEB2))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(ticket.isChecked ? Color(hex: 0x30D158) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(ticket.isChecked ? Color(hex: 0x30D158) : Color(hex: 0xAEAEB2), lineWidth: 1)
                    )
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", amount)
        } else {
            return String(format: "%.1f", amount)
        }
    }
}

// MARK: - View Model

@MainActor
class ShoppingListViewModel: ObservableObject {
    @Published var currentRoll: GroceryRoll?
    @Published var groupedItems: [AisleGroup] = []
    @Published var showOnlyUnchecked = false
    @Published var currentWeekStart: Date = Date().startOfFeastWeek()
    
    var isEmpty: Bool {
        currentRoll == nil || currentRoll?.items.isEmpty == true
    }
    
    var weekTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: currentWeekStart) ?? currentWeekStart
        return "\(formatter.string(from: currentWeekStart)) - \(formatter.string(from: endDate))"
    }
    
    private let vault = CellarVault.shared
    private var ledgerToken: NSObjectProtocol?
    weak var coordinatorDelegate: KitchenNavigable?
    var onShowHelp: (() -> Void)?
    var onOpenStoreMode: ((GroceryRoll) -> Void)?
    
    init() {
        print("🚀 [Shopping] ShoppingListViewModel init()")
        observeLedger()
    }
    
    deinit {
        if let token = ledgerToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func loadShoppingList() {
        print("📋 [Shopping] loadShoppingList() called, currentWeekStart: \(currentWeekStart)")
        guard let week = vault.currentFeastWeek(),
              Calendar.current.isDate(week.weekStartDate, inSameDayAs: currentWeekStart) else {
            print("📋 [Shopping] Current week doesn't match, searching for week")
            // Try to find week for currentWeekStart
            if let foundWeek = vault.feastWeekHistory.first(where: { week in
                Calendar.current.isDate(week.weekStartDate, inSameDayAs: currentWeekStart)
            }) {
                print("📋 [Shopping] Found week: \(foundWeek.id)")
                currentRoll = vault.groceryRoll(forWeek: foundWeek.id)
                if currentRoll == nil {
                    print("📋 [Shopping] No roll found, generating new one")
                    let aggregator = BasketAggregator()
                    let roll = aggregator.harvestBasket(for: foundWeek)
                    vault.saveGroceryRoll(roll)
                    currentRoll = roll
                    print("📋 [Shopping] Generated roll with \(roll.items.count) items")
                } else {
                    print("📋 [Shopping] Loaded roll with \(currentRoll?.items.count ?? 0) items")
                }
            } else {
                print("📋 [Shopping] No week found, setting currentRoll to nil")
                currentRoll = nil
            }
            rebuildItems()
            return
        }
        
        print("📋 [Shopping] Using current week: \(week.id)")
        currentRoll = vault.groceryRoll(forWeek: week.id)
        if currentRoll == nil {
            print("📋 [Shopping] No roll found, generating new one")
            let aggregator = BasketAggregator()
            let roll = aggregator.harvestBasket(for: week)
            vault.saveGroceryRoll(roll)
            currentRoll = roll
            print("📋 [Shopping] Generated roll with \(roll.items.count) items")
        } else {
            print("📋 [Shopping] Loaded roll with \(currentRoll?.items.count ?? 0) items")
        }
        
        rebuildItems()
    }
    
    func moveWeek(by offset: Int) {
        print("📅 [Shopping] moveWeek(by: \(offset)) called, currentWeekStart: \(currentWeekStart)")
        guard let newDate = Calendar.current.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart) else {
            print("📅 [Shopping] ERROR: Could not calculate new date")
            return
        }
        let newWeekStart = newDate.startOfFeastWeek()
        print("📅 [Shopping] Moving to new week: \(newWeekStart)")
        currentWeekStart = newWeekStart
        loadShoppingList()
    }
    
    func toggleItem(_ ticket: GroceryTicket) {
        toggleItemWithID(ticket.id)
    }
    
    func toggleItemWithID(_ ticketID: UUID) {
        print("🛒 [Shopping] toggleItemWithID called for ticketID: \(ticketID)")
        guard var roll = currentRoll else {
            print("🛒 [Shopping] ERROR: currentRoll is nil")
            return
        }
        
        guard let idx = roll.items.firstIndex(where: { $0.id == ticketID }) else {
            print("🛒 [Shopping] ERROR: ticket not found in roll.items, ticketID: \(ticketID)")
            print("🛒 [Shopping] Available IDs: \(roll.items.map { $0.id })")
            return
        }
        
        // Get current state from roll
        let currentItem = roll.items[idx]
        print("🛒 [Shopping] Found ticket at index \(idx): '\(currentItem.displayName)', isChecked: \(currentItem.isChecked)")
        
        let isEmpty = currentItem.displayName.trimmingCharacters(in: .whitespaces).isEmpty
        
        if isEmpty {
            print("🛒 [Shopping] Removing empty item")
            roll.items.remove(at: idx)
        } else {
            // Toggle using current state from roll - ensure we use the actual current state
            let wasChecked = roll.items[idx].isChecked
            print("🛒 [Shopping] Toggling from \(wasChecked) to \(!wasChecked)")
            roll.items[idx].isChecked = !wasChecked
            roll.items[idx].refreshedAt = Date()
            print("🛒 [Shopping] After toggle - roll.items[\(idx)].isChecked = \(roll.items[idx].isChecked)")
        }
        roll.refreshedAt = Date()
        vault.saveGroceryRoll(roll)
        print("🛒 [Shopping] Saved to vault")
        
        // Update currentRoll BEFORE rebuildItems to ensure fresh data
        currentRoll = roll
        print("🛒 [Shopping] Updated currentRoll, calling rebuildItems()")
        
        // Rebuild items with updated data - this will trigger UI update
        rebuildItems()
        
        print("🛒 [Shopping] rebuildItems() completed, groupedItems count: \(groupedItems.count)")
        if let otherGroup = groupedItems.first(where: { $0.aisle.title == "Other" }) {
            print("🛒 [Shopping] Other group has \(otherGroup.items.count) items")
            for item in otherGroup.items {
                print("🛒 [Shopping]   - '\(item.displayName)' isChecked: \(item.isChecked)")
            }
        }
        
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }
    
    func toggleOwned(_ ticket: GroceryTicket) {
        toggleOwnedWithID(ticket.id)
    }
    
    func toggleOwnedWithID(_ ticketID: UUID) {
        guard var roll = currentRoll else { return }
        
        guard let idx = roll.items.firstIndex(where: { $0.id == ticketID }) else {
            return
        }
        
        let currentTicket = roll.items[idx]
        roll.items[idx].isOwned.toggle()
        roll.items[idx].refreshedAt = Date()
        roll.refreshedAt = Date()
        vault.saveGroceryRoll(roll)
        currentRoll = roll
        
        if roll.items[idx].isOwned {
            vault.markAsOwned(
                normalizedName: currentTicket.normalizedName,
                displayName: currentTicket.displayName,
                aisleID: currentTicket.aisleID
            )
        } else {
            vault.removeFromPantry(normalizedName: currentTicket.normalizedName)
        }
        
        rebuildItems()
    }
    
    func showHelp() {
        onShowHelp?()
    }
    
    func openStoreMode() {
        guard let roll = currentRoll else { return }
        onOpenStoreMode?(roll)
    }
    
    private func rebuildItems() {
        print("🔄 [Shopping] rebuildItems() called")
        guard let roll = currentRoll, !roll.items.isEmpty else {
            print("🔄 [Shopping] No roll or empty items, clearing groupedItems")
            groupedItems = []
            return
        }
        
        print("🔄 [Shopping] Starting rebuild with \(roll.items.count) total items")
        let validItems = roll.items.filter { !$0.displayName.trimmingCharacters(in: .whitespaces).isEmpty }
        print("🔄 [Shopping] After filtering empty: \(validItems.count) valid items")
        for (idx, item) in validItems.enumerated() {
            print("🔄 [Shopping]   [\(idx)] '\(item.displayName)' id: \(item.id) isChecked: \(item.isChecked) isOwned: \(item.isOwned)")
        }
        
        var groups: [AisleGroup] = []
        let aisles = vault.aisles
        print("🔄 [Shopping] Found \(aisles.count) aisles")
        
        // Group by known aisles
        for aisle in aisles {
            let items = validItems.filter { $0.aisleID == aisle.id }
            if !items.isEmpty {
                print("🔄 [Shopping] Aisle '\(aisle.title)': \(items.count) items")
                groups.append(AisleGroup(aisle: aisle, items: items))
            }
        }
        
        // Other category - use consistent UUID to avoid recreation issues
        let otherItems = validItems.filter { item in
            guard let aisleID = item.aisleID else { return true }
            return !aisles.contains(where: { $0.id == aisleID })
        }
        print("🔄 [Shopping] Other category: \(otherItems.count) items")
        
        if !otherItems.isEmpty {
            // Use a consistent UUID for "Other" category
            let otherAisleID = UUID(uuidString: "00000000-0000-0000-0000-000000000999") ?? UUID()
            let otherAisle = AisleCategory(
                id: otherAisleID,
                title: "Other",
                sortRank: 999,
                isHidden: false,
                bakedAt: Date(),
                refreshedAt: Date()
            )
            groups.append(AisleGroup(aisle: otherAisle, items: otherItems))
        }
        
        // Sort groups by sortRank
        groups.sort { $0.aisle.sortRank < $1.aisle.sortRank }
        
        print("🔄 [Shopping] Final groups count: \(groups.count)")
        for group in groups {
            print("🔄 [Shopping]   Group '\(group.aisle.title)': \(group.items.count) items")
            for item in group.items {
                print("🔄 [Shopping]     - '\(item.displayName)' id: \(item.id) isChecked: \(item.isChecked) isOwned: \(item.isOwned)")
            }
        }
        
        groupedItems = groups
        print("🔄 [Shopping] groupedItems set, count: \(groupedItems.count)")
    }
    
    private func observeLedger() {
        print("👂 [Shopping] Setting up ledger observer")
        ledgerToken = NotificationCenter.default.addObserver(
            forName: CellarVault.ledgerDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("📢 [Shopping] ledgerDidUpdate notification received")
            self?.updateShoppingListIfNeeded()
        }
    }
    
    private func updateShoppingListIfNeeded() {
        print("🔄 [Shopping] updateShoppingListIfNeeded() called")
        let savedFilterState = showOnlyUnchecked
        print("🔄 [Shopping] Saved filter state: \(savedFilterState)")
        
        guard let week = vault.currentFeastWeek(),
              Calendar.current.isDate(week.weekStartDate, inSameDayAs: currentWeekStart) else {
            print("🔄 [Shopping] Current week doesn't match, searching for week")
            if let foundWeek = vault.feastWeekHistory.first(where: { week in
                Calendar.current.isDate(week.weekStartDate, inSameDayAs: currentWeekStart)
            }) {
                // Try to load existing roll first
                if let existingRoll = vault.groceryRoll(forWeek: foundWeek.id) {
                    print("🔄 [Shopping] Found existing roll for week, loading it")
                    currentRoll = existingRoll
                    showOnlyUnchecked = savedFilterState
                    rebuildItems()
                } else {
                    print("🔄 [Shopping] No existing roll, regenerating basket")
                    let aggregator = BasketAggregator()
                    let roll = aggregator.harvestBasket(for: foundWeek)
                    vault.saveGroceryRoll(roll)
                    currentRoll = roll
                    print("🔄 [Shopping] Regenerated roll with \(roll.items.count) items")
                    showOnlyUnchecked = savedFilterState
                    rebuildItems()
                }
            } else {
                print("🔄 [Shopping] No matching week found")
            }
            return
        }
        
        // Try to load existing roll first - don't regenerate if it exists
        if let existingRoll = vault.groceryRoll(forWeek: week.id) {
            print("🔄 [Shopping] Found existing roll for current week, loading it (preserving checked states)")
            currentRoll = existingRoll
            showOnlyUnchecked = savedFilterState
            rebuildItems()
        } else {
            print("🔄 [Shopping] No existing roll, regenerating basket for current week")
            let aggregator = BasketAggregator()
            let roll = aggregator.harvestBasket(for: week)
            vault.saveGroceryRoll(roll)
            currentRoll = roll
            print("🔄 [Shopping] Regenerated roll with \(roll.items.count) items")
            showOnlyUnchecked = savedFilterState
            rebuildItems()
        }
    }
}

// MARK: - Extensions

extension AisleGroup: Identifiable {
    public var id: UUID {
        aisle.id
    }
}

// GroceryTicket already conforms to Identifiable

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
