import SwiftUI

// MARK: - Main Screen
struct PlateConstructorScreen: View {
    @StateObject var viewModel: PlateConstructorViewModel
    @StateObject var ingredientsViewModel: IngredientsListViewModel
    @StateObject var templateViewModel: TemplateLibraryViewModel
    
    @State private var selectedCategory: IngredientCategory = .vegetables
    @State private var showingSaveTemplate = false
    @State private var templateName = ""
    @State private var showClearConfirmation = false
    @State private var showingHelp = false
    @State private var searchText = ""
    @State private var addedIngredientId: UUID?
    
    // Helper to get all ingredients as a lookup dictionary
    private var allIngredients: [UUID: FoodIngredientDTO] {
        var dict: [UUID: FoodIngredientDTO] = [:]
        for ingredient in ingredientsViewModel.vegetables {
            dict[ingredient.id] = ingredient
        }
        for ingredient in ingredientsViewModel.proteins {
            dict[ingredient.id] = ingredient
        }
        for ingredient in ingredientsViewModel.carbs {
            dict[ingredient.id] = ingredient
        }
        return dict
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                
                ZStack {
                    // Background
                    AppBackgroundView()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Plate Visualization
                            plateSection(screenWidth: screenWidth)
                            
                            // Time Slot Picker
                            TimeSlotPickerView(
                                selectedSlot: $viewModel.currentTimeSlot,
                                onSlotChange: { slot in
                                    Task { await viewModel.switchTimeSlot(to: slot) }
                                }
                            )
                            .frame(width: screenWidth)
                            
                            // Current Plate (if has items)
                            if !viewModel.slotRecords.isEmpty {
                                currentPlateSection(screenWidth: screenWidth)
                            }
                            
                            // Search Bar
                            searchBar(screenWidth: screenWidth)
                            
                            // Category Tabs
                            CategoryTabsView(selectedCategory: $selectedCategory)
                                .frame(width: screenWidth)
                            
                            // Ingredients List
                            ingredientListSection(screenWidth: screenWidth)
                        }
                        .frame(width: screenWidth)
                        .padding(.bottom, 100)
                    }
                    .frame(width: screenWidth)
                }
                .frame(width: screenWidth)
            }
            .navigationTitle("Today's Plate")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingHelp = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.appAccentYellow)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    menuButton
                }
            }
            .sheet(isPresented: $showingHelp) {
                HelpSheet()
            }
        }
        .navigationViewStyle(.stack)
        .task {
            await viewModel.loadPlate()
            await ingredientsViewModel.loadAllIngredients()
        }
        .sheet(isPresented: $showingSaveTemplate) {
            SaveTemplateSheet(
                templateName: $templateName,
                onSave: {
                    Task {
                        await templateViewModel.createTemplateFromSlot(
                            title: templateName,
                            dayIdentifier: viewModel.currentDayIdentifier,
                            timeSlotRaw: viewModel.currentTimeSlot
                        )
                        templateName = ""
                    }
                }
            )
        }
        .confirmationDialog(
            "Clear current plate?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear", role: .destructive) {
                Task { await viewModel.clearSlot() }
            }
        }
    }
    
    // MARK: - Plate Section
    private func plateSection(screenWidth: CGFloat) -> some View {
        VStack(spacing: 8) {
            if let plate = viewModel.plateVisualization {
                PlateDonutVisualizationView(
                    plateData: plate,
                    size: min(screenWidth * 0.38, 160),
                    containerWidth: screenWidth - 32
                )
                .frame(width: screenWidth - 32)
                .padding(.horizontal, 16)
                
                // Balance Score
                BalanceScoreView(score: plate.balanceMetric)
                    .frame(width: screenWidth - 32)
                    .padding(.horizontal, 16)
                
            } else {
                PlateLoadingView()
            }
        }
        .frame(width: screenWidth)
        .padding(.vertical, 16)
    }
    
    // MARK: - Menu Button
    private var menuButton: some View {
        Menu {
            Button(action: {
                if !viewModel.slotRecords.isEmpty {
                    if templateName.isEmpty {
                        let df = DateFormatter()
                        df.dateFormat = "MMM d, HH:mm"
                        templateName = "Plate \(df.string(from: Date()))"
                    }
                    showingSaveTemplate = true
                }
            }) {
                Label("Save as Template", systemImage: "bookmark.fill")
            }
            .disabled(viewModel.slotRecords.isEmpty)
            
            Divider()
            
            Button(role: .destructive, action: {
                showClearConfirmation = true
            }) {
                Label("Clear Plate", systemImage: "trash")
            }
            .disabled(viewModel.slotRecords.isEmpty)
            
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.appAccentYellow, .appAccentOrange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    // MARK: - Current Plate Section
    private func currentPlateSection(screenWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("On Your Plate")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                Text("\(viewModel.slotRecords.count) items")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.slotRecords) { record in
                        IngredientChipView(
                            record: record,
                            ingredientName: allIngredients[record.ingredientRef]?.titleText ?? "Item",
                            onRemove: {
                                let ingredientRef = record.ingredientRef
                                let portionAmount = record.portionAmount
                                Task.detached { @MainActor in
                                    await viewModel.addIngredient(
                                        ingredientRef: ingredientRef,
                                        portionDelta: -portionAmount
                                    )
                                }
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(width: screenWidth - 32)
        .padding(.vertical, 16)
        .background(Color.appCardBackground.opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Search Bar
    private func searchBar(screenWidth: CGFloat) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextTertiary)
            
            TextField("Search ingredients...", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(.appTextPrimary)
            
            if !searchText.isEmpty {
                Button(action: { 
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.appTextTertiary)
                }
            }
        }
        .padding(12)
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .frame(width: screenWidth - 32)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Ingredients Section
    private func ingredientListSection(screenWidth: CGFloat) -> some View {
        let ingredients: [FoodIngredientDTO] = {
            var items: [FoodIngredientDTO]
            switch selectedCategory {
            case .vegetables: items = ingredientsViewModel.vegetables
            case .protein: items = ingredientsViewModel.proteins
            case .carbs: items = ingredientsViewModel.carbs
            }
            
            // Filter by search text
            if !searchText.isEmpty {
                items = items.filter { ingredient in
                    ingredient.titleText.localizedCaseInsensitiveContains(searchText) ||
                    (ingredient.descriptionHint?.localizedCaseInsensitiveContains(searchText) ?? false)
                }
            }
            
            return items
        }()
        
        return LazyVStack(spacing: 10) {
            if ingredients.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.appTextTertiary)
                    
                    Text("No ingredients found")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    
                    if !searchText.isEmpty {
                        Text("Try a different search term")
                            .font(.system(size: 15))
                            .foregroundColor(.appTextTertiary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(ingredients) { ingredient in
                    IngredientRowView(
                        ingredient: ingredient,
                        category: selectedCategory,
                        isAdded: addedIngredientId == ingredient.id,
                        onTap: {
                            hapticFeedback(.light)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                addedIngredientId = ingredient.id
                            }
                            Task {
                                await viewModel.addIngredient(ingredientRef: ingredient.id, portionDelta: 1.0)
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                withAnimation {
                                    addedIngredientId = nil
                                }
                            }
                        },
                        onLongPress: {
                            hapticFeedback(.medium)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                addedIngredientId = ingredient.id
                            }
                            Task {
                                await viewModel.addIngredient(ingredientRef: ingredient.id, portionDelta: 0.5)
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                withAnimation {
                                    addedIngredientId = nil
                                }
                            }
                        }
                    )
                    .frame(width: screenWidth - 32)
                }
            }
        }
        .frame(width: screenWidth)
        .padding(.horizontal, 16)
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Ingredient Category
enum IngredientCategory: String, CaseIterable {
    case vegetables
    case protein
    case carbs
    
    var title: String {
        switch self {
        case .vegetables: return "Veggies"
        case .protein: return "Protein"
        case .carbs: return "Carbs"
        }
    }
    
    var icon: String {
        switch self {
        case .vegetables: return "leaf.fill"
        case .protein: return "flame.fill"
        case .carbs: return "bolt.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .vegetables: return Color(hex: "#30D158")
        case .protein: return Color.appAccentOrange
        case .carbs: return Color.appAccentYellow
        }
    }
    
    var ratio: String {
        switch self {
        case .vegetables: return "3"
        case .protein: return "2"
        case .carbs: return "1"
        }
    }
}

// MARK: - Balance Score View
struct BalanceScoreView: View {
    let score: Int
    
    private var scoreColor: Color {
        switch score {
        case 90...100: return Color(hex: "#30D158")
        case 70..<90: return Color.appAccentYellow
        case 50..<70: return Color.appAccentOrange
        default: return Color(hex: "#FF453A")
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Score
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(scoreColor)
                
                Text("/100")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.appTextTertiary)
            }
            
            // Divider
            Rectangle()
                .fill(Color.appDivider)
                .frame(width: 1, height: 32)
            
            // Label
            VStack(alignment: .leading, spacing: 2) {
                Text("Balance")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                
                Text(scoreLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(scoreColor)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
    
    private var scoreLabel: String {
        switch score {
        case 100: return "Perfect! 🎉"
        case 90..<100: return "Excellent!"
        case 70..<90: return "Good"
        case 50..<70: return "Getting there"
        default: return "Keep adding"
        }
    }
}

// MARK: - Plate Loading View
struct PlateLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appCardBackground, lineWidth: 12)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(
                    LinearGradient(
                        colors: [.appAccentYellow, .appAccentOrange],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Time Slot Picker
struct TimeSlotPickerView: View {
    @Binding var selectedSlot: String
    let onSlotChange: (String) -> Void
    
    let slots: [(id: String, title: String, icon: String)] = [
        ("morning", "Morning", "sunrise.fill"),
        ("noon", "Noon", "sun.max.fill"),
        ("evening", "Evening", "sunset.fill"),
        ("snack", "Snack", "leaf.fill")
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(slots, id: \.id) { slot in
                TimeSlotButton(
                    title: slot.title,
                    icon: slot.icon,
                    isSelected: selectedSlot == slot.id
                ) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedSlot = slot.id
                        onSlotChange(slot.id)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct TimeSlotButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isSelected ? .black : .appTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [.appAccentYellow, .appAccentOrange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.appCardBackground
                    }
                }
            )
            .cornerRadius(12)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Category Tabs
struct CategoryTabsView: View {
    @Binding var selectedCategory: IngredientCategory
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(IngredientCategory.allCases, id: \.self) { category in
                CategoryTabButton(
                    category: category,
                    isSelected: selectedCategory == category,
                    animation: animation
                ) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedCategory = category
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct CategoryTabButton: View {
    let category: IngredientCategory
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(category.color.opacity(0.2))
                            .frame(width: 48, height: 48)
                            .matchedGeometryEffect(id: "TAB_CIRCLE", in: animation)
                    }
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isSelected ? category.color : .appTextTertiary)
                }
                .frame(width: 48, height: 48)
                
                VStack(spacing: 2) {
                    Text(category.title)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? .appTextPrimary : .appTextSecondary)
                    
                    // Ratio indicator
                    Text("×\(category.ratio)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? category.color : .appTextTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.appCardBackgroundElevated : Color.appCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? category.color.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Ingredient Row
struct IngredientRowView: View {
    let ingredient: FoodIngredientDTO
    let category: IngredientCategory
    let isAdded: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Category indicator
            Circle()
                .fill(category.color.opacity(isAdded ? 0.4 : 0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    ZStack {
                        Image(systemName: category.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(category.color)
                            .opacity(isAdded ? 0 : 1)
                        
                        if isAdded {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(category.color)
                        }
                    }
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.titleText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                
                if let hint = ingredient.descriptionHint {
                    Text(hint)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Add buttons
            HStack(spacing: 8) {
                // Half portion
                AddButton(label: "½", size: .small, isHighlighted: isAdded) {
                    onLongPress()
                }
                
                // Full portion
                AddButton(label: "+1", size: .large, isPrimary: true, isHighlighted: isAdded) {
                    onTap()
                }
            }
        }
        .padding(14)
        .background(
            isAdded 
                ? AnyShapeStyle(category.color.opacity(0.15))
                : AnyShapeStyle(Color.appCardBackground)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isAdded ? category.color.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isAdded ? 0.98 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct AddButton: View {
    enum Size { case small, large }
    
    let label: String
    let size: Size
    var isPrimary: Bool = false
    var isHighlighted: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: size == .large ? 15 : 13, weight: .bold))
                .foregroundColor(isPrimary ? .black : .appTextSecondary)
                .frame(width: size == .large ? 44 : 36, height: 36)
                .background(
                    isPrimary
                    ? AnyShapeStyle(LinearGradient(
                        colors: isHighlighted 
                            ? [.appAccentYellow.opacity(0.7), .appAccentOrange.opacity(0.7)]
                            : [.appAccentYellow, .appAccentOrange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    : AnyShapeStyle(isHighlighted ? Color.appBackgroundSecondary.opacity(0.5) : Color.appBackgroundSecondary)
                )
                .cornerRadius(10)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Ingredient Chip
struct IngredientChipView: View {
    let record: MealSlotRecordDTO
    let ingredientName: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(ingredientName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextPrimary)
                .lineLimit(1)
            
            Text("×\(String(format: "%.1f", record.portionAmount))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.appAccentYellow)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.appTextTertiary)
                    .frame(width: 20, height: 20)
                    .background(Color.appBackgroundSecondary)
                    .clipShape(Circle())
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 10)
        .padding(.vertical, 10)
        .background(Color.appCardBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.appDivider, lineWidth: 1)
        )
    }
}

// MARK: - Save Template Sheet
struct SaveTemplateSheet: View {
    @Binding var templateName: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Icon
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.appAccentYellow, .appAccentOrange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .overlay(
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.black)
                        )
                        .padding(.top, 32)
                    
                    Text("Save as Template")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.appTextPrimary)
                    
                    // Text Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Template Name")
                            .font(.subheadline)
                            .foregroundColor(.appTextSecondary)
                        
                        TextField("", text: $templateName)
                            .font(.system(size: 17))
                            .foregroundColor(.appTextPrimary)
                            .padding()
                            .background(Color.appCardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appAccentYellow.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            if !templateName.isEmpty {
                                onSave()
                                dismiss()
                            }
                        }) {
                            Text("Save Template")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.appAccentYellow, .appAccentOrange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                        }
                        .disabled(templateName.isEmpty)
                        .opacity(templateName.isEmpty ? 0.5 : 1.0)
                        
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Help Sheet
struct HelpSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.appAccentYellow, .appAccentOrange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(.black)
                            )
                        
                        Text("How to Use")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.appTextPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                    
                    // Instructions
                    VStack(spacing: 20) {
                        HelpItem(
                            icon: "chart.pie.fill",
                            iconColor: .appAccentYellow,
                            title: "3:2:1 Balance Rule",
                            description: "Build balanced meals with 3 parts vegetables, 2 parts protein, and 1 part carbs. The donut chart shows your progress for each category."
                        )
                        
                        HelpItem(
                            icon: "hand.tap.fill",
                            iconColor: .appAccentOrange,
                            title: "Adding Ingredients",
                            description: "Tap an ingredient to add 1 full portion. Long press to add 0.5 portion. Your plate updates in real-time."
                        )
                        
                        HelpItem(
                            icon: "clock.fill",
                            iconColor: .appAccentGold,
                            title: "Time Slots",
                            description: "Switch between Morning, Noon, Evening, and Snack slots. Each slot tracks separately to help you balance throughout the day."
                        )
                        
                        HelpItem(
                            icon: "star.fill",
                            iconColor: .appAccentYellow,
                            title: "Perfect Balance",
                            description: "Reach 100/100 balance to earn a gold badge! The progress bars show exactly how many portions you need in each category."
                        )
                        
                        HelpItem(
                            icon: "xmark.circle.fill",
                            iconColor: .appTextSecondary,
                            title: "Removing Items",
                            description: "Tap the × button on ingredient chips to remove them from your plate."
                        )
                        
                        HelpItem(
                            icon: "bookmark.fill",
                            iconColor: .appAccentOrange,
                            title: "Save Templates",
                            description: "Save your favorite meal combinations as templates for quick reuse. Access them from the menu (⋯) button."
                        )
                    }
                    
                    // Close button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Got It!")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.appAccentYellow, .appAccentOrange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .appAccentOrange.opacity(0.3), radius: 12, y: 6)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Help Item
struct HelpItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                Text(description)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.appTextSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
}
