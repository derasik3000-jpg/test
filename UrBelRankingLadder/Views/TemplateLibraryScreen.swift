import SwiftUI

// MARK: - Template Library Screen
struct TemplateLibraryScreen: View {
    @StateObject var viewModel: TemplateLibraryViewModel
    @State private var showingCreateSheet = false
    @State private var newTemplateName = ""
    @State private var newTemplateNote = ""
    @State private var newTemplateSlot = Date().currentTimeSlot()
    @State private var searchText = ""
    @State private var selectedFilter: TemplateFilter = .all
    @State private var selectedTemplateForDetail: SavedTemplateDTO? = nil
    @State private var showToast = false
    
    var filteredTemplates: [SavedTemplateDTO] {
        var templates = viewModel.templates
        
        // Filter by selected filter
        if selectedFilter != .all {
            let slotRaw = slotRawForFilter(selectedFilter)
            templates = templates.filter { template in
                template.timeSlotRaw == slotRaw
            }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            templates = templates.filter {
                $0.templateTitle.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return templates
    }
    
    private func slotRawForFilter(_ filter: TemplateFilter) -> String {
        switch filter {
        case .all:
            return ""
        case .morning:
            return "morning"
        case .noon:
            return "noon"
        case .evening:
            return "evening"
        case .snack:
            return "snack"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackgroundView()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Navigation Bar with Create Button
                    HStack {
                        Text("Templates")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.appTextPrimary)
                        
                        Spacer()
                        
                        createButton
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 50)
                    
                    // Search & Filter
                    searchAndFilterSection()
                        .padding(.horizontal, 50)
                    
                    // Content
                    if viewModel.templates.isEmpty {
                        EmptyTemplatesView()
                            .frame(maxHeight: .infinity)
                    } else if filteredTemplates.isEmpty {
                        NoResultsView(searchText: searchText)
                            .frame(maxHeight: .infinity)
                    } else {
                        templatesListView()
                            .frame(maxHeight: .infinity)
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .task {
            await viewModel.loadTemplates()
        }
        .onChange(of: viewModel.successMessage) { newValue in
            if newValue != nil {
                showToast = true
                // Clear success message after showing toast
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    viewModel.successMessage = nil
                    showToast = false
                }
            }
        }
        .overlay(alignment: .top) {
            if showToast, let message = viewModel.successMessage {
                ToastView(message: message)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000)
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateTemplateSheet(
                templateName: $newTemplateName,
                templateNote: $newTemplateNote,
                selectedSlot: $newTemplateSlot,
                onCreate: {
                    Task {
                        await viewModel.createTemplateFromSlotDetailed(
                            title: newTemplateName,
                            note: newTemplateNote,
                            dayIdentifier: String.todayIdentifier(),
                            timeSlotRaw: newTemplateSlot
                        )
                        resetForm()
                    }
                }
            )
        }
        .sheet(item: $selectedTemplateForDetail) { template in
            TemplateDetailSheet(template: template)
        }
    }
    
    // MARK: - Search & Filter Section
    private func searchAndFilterSection() -> some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appTextTertiary)
                
                TextField("Search templates...", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.appTextPrimary)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.appTextTertiary)
                    }
                }
            }
            .padding(12)
            .background(Color.appCardBackground)
            .cornerRadius(12)
            
            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TemplateFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            filter: filter,
                            isSelected: selectedFilter == filter,
                            count: countForFilter(filter)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
       
    }
    
    // MARK: - Templates List
    private func templatesListView() -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 12) {
                ForEach(filteredTemplates) { template in
                    TemplateCardView(
                        template: template,
                        onTap: {
                            hapticFeedback(.light)
                            selectedTemplateForDetail = template
                        },
                        onApply: {
                            hapticFeedback(.medium)
                            Task {
                                await viewModel.applyTemplate(
                                    template,
                                    dayIdentifier: String.todayIdentifier(),
                                    timeSlotRaw: Date().currentTimeSlot()
                                )
                            }
                        },
                        onDelete: {
                            hapticFeedback(.light)
                            Task {
                                await viewModel.deleteTemplate(templateId: template.id)
                            }
                        }
                    )
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 100)
            .padding(.horizontal, 50)
        }
    }
    
    // MARK: - Create Button
    private var createButton: some View {
        Button(action: {
            hapticFeedback(.light)
            prepareNewTemplate()
            showingCreateSheet = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 32, height: 32)
                .background(
                    LinearGradient(
                        colors: [.appAccentYellow, .appAccentOrange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
        }
    }
    
    // MARK: - Helpers
    private func countForFilter(_ filter: TemplateFilter) -> Int {
        let templates = viewModel.templates
        
        // Filter by search if active
        var filtered = templates
        if !searchText.isEmpty {
            filtered = templates.filter {
                $0.templateTitle.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by selected filter
        switch filter {
        case .all:
            return filtered.count
        case .morning:
            return filtered.filter { $0.timeSlotRaw == "morning" }.count
        case .noon:
            return filtered.filter { $0.timeSlotRaw == "noon" }.count
        case .evening:
            return filtered.filter { $0.timeSlotRaw == "evening" }.count
        case .snack:
            return filtered.filter { $0.timeSlotRaw == "snack" }.count
        }
    }
    
    private func prepareNewTemplate() {
        let df = DateFormatter()
        df.dateFormat = "MMM d, HH:mm"
        newTemplateName = "Plate \(df.string(from: Date()))"
        newTemplateNote = ""
        newTemplateSlot = Date().currentTimeSlot()
    }
    
    private func resetForm() {
        newTemplateName = ""
        newTemplateNote = ""
        newTemplateSlot = Date().currentTimeSlot()
        showingCreateSheet = false
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Template Filter
enum TemplateFilter: String, CaseIterable {
    case all
    case morning
    case noon
    case evening
    case snack
    
    var title: String {
        switch self {
        case .all: return "All"
        case .morning: return "Morning"
        case .noon: return "Noon"
        case .evening: return "Evening"
        case .snack: return "Snack"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .morning: return "sunrise.fill"
        case .noon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .snack: return "leaf.fill"
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let filter: TemplateFilter
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(filter.title)
                    .font(.system(size: 13, weight: .medium))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isSelected ? .black.opacity(0.6) : .appTextTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.black.opacity(0.15) : Color.appBackgroundSecondary)
                        )
                }
            }
            .foregroundColor(isSelected ? .black : .appTextSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
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
            .cornerRadius(20)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Template Card
struct TemplateCardView: View {
    let template: SavedTemplateDTO
    let onTap: () -> Void
    let onApply: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    private var slotInfo: (icon: String, color: Color) {
        guard let slotRaw = template.timeSlotRaw else {
            return ("bookmark.fill", Color.appAccentYellow)
        }
        
        switch slotRaw {
        case "morning":
            return ("sunrise.fill", Color.appAccentYellow)
        case "noon":
            return ("sun.max.fill", Color.appAccentOrange)
        case "evening":
            return ("sunset.fill", Color.appAccentOrange)
        case "snack":
            return ("leaf.fill", Color.green)
        default:
            return ("bookmark.fill", Color.appAccentYellow)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
                // Header - clickable area
                Button(action: onTap) {
                    VStack(spacing: 0) {
                        HStack(alignment: .top, spacing: 14) {
                            // Slot icon
                            Circle()
                                .fill(slotInfo.color.opacity(0.15))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: slotInfo.icon)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(slotInfo.color)
                                )
                            
                            // Info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.templateTitle)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.appTextPrimary)
                                    .lineLimit(1)
                                
                                HStack(spacing: 8) {
                                    Label(
                                        formatDate(template.creationTimestamp),
                                        systemImage: "calendar"
                                    )
                                    .font(.system(size: 12))
                                    .foregroundColor(.appTextSecondary)
                                    
                                    if template.itemsCollection.count > 0 {
                                        Label(
                                            "\(template.itemsCollection.count) items",
                                            systemImage: "fork.knife"
                                        )
                                        .font(.system(size: 12))
                                        .foregroundColor(.appTextSecondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Chevron icon
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appTextTertiary)
                        }
                        
                        // Note preview (if exists)
                        if let note = template.noteText, !note.isEmpty {
                            HStack {
                                Text(note)
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextTertiary)
                                    .lineLimit(2)
                                    .padding(.top, 10)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Divider
                Rectangle()
                    .fill(Color.appDivider)
                    .frame(height: 1)
                    .padding(.vertical, 14)
                
                // Actions
                HStack(spacing: 12) {
                    // Apply button
                    Button(action: onApply) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.doc.fill")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text("Apply Now")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [.appAccentYellow, .appAccentOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Delete button
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "#FF453A"))
                            .cornerRadius(10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(16)
            .background(Color.appCardBackground)
            .cornerRadius(16)
            .confirmationDialog(
                "Delete this template?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        onDelete()
                    }
                }
            }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Empty State
struct EmptyTemplatesView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.appAccentOrange.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                // Icon circle
                Circle()
                    .fill(Color.appCardBackground)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.appAccentYellow, .appAccentOrange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            
            VStack(spacing: 12) {
                Text("No Templates Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                
                Text("Save your favorite plate combinations\nfor quick access later")
                    .font(.system(size: 16))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            // Hint
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.appAccentYellow)
                
                Text("Create a plate, then save it as a template")
                    .font(.system(size: 14))
                    .foregroundColor(.appTextTertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.appCardBackground)
            .cornerRadius(12)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - No Results View
struct NoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.appTextTertiary)
            
            VStack(spacing: 8) {
                Text("No Results")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                Text("No templates found for \"\(searchText)\"")
                    .font(.system(size: 15))
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Create Template Sheet
struct CreateTemplateSheet: View {
    @Binding var templateName: String
    @Binding var templateNote: String
    @Binding var selectedSlot: String
    let onCreate: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, note
    }
    
    var isValid: Bool {
        templateName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }
    
    let slots: [(id: String, title: String, icon: String)] = [
        ("morning", "Morning", "sunrise.fill"),
        ("noon", "Noon", "sun.max.fill"),
        ("evening", "Evening", "sunset.fill"),
        ("snack", "Snack", "leaf.fill")
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                
                ZStack {
                    AppBackgroundView()
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header Icon
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
                                    Image(systemName: "square.grid.2x2.fill")
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundColor(.black)
                                )
                                .padding(.top, 24)
                            
                            // Form
                            VStack(spacing: 20) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Template Name")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.appTextSecondary)
                                
                                TextField("My favorite breakfast", text: $templateName)
                                    .font(.system(size: 17))
                                    .foregroundColor(.appTextPrimary)
                                    .padding(16)
                                    .background(Color.appCardBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                focusedField == .name
                                                    ? Color.appAccentYellow
                                                    : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                    .focused($focusedField, equals: .name)
                            }
                            
                            // Slot Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Meal Slot")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.appTextSecondary)
                                
                                HStack(spacing: 8) {
                                    ForEach(slots, id: \.id) { slot in
                                        SlotPickerButton(
                                            title: slot.title,
                                            icon: slot.icon,
                                            isSelected: selectedSlot == slot.id
                                        ) {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedSlot = slot.id
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Note Field
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Note")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.appTextSecondary)
                                    
                                    Text("(optional)")
                                        .font(.caption)
                                        .foregroundColor(.appTextTertiary)
                                }
                                
                                TextEditor(text: $templateNote)
                                    .font(.system(size: 16))
                                    .foregroundColor(.appTextPrimary)
                                    .frame(minHeight: 100)
                                    .padding(12)
                                    .background(Color.appCardBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                focusedField == .note
                                                    ? Color.appAccentYellow
                                                    : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                    .focused($focusedField, equals: .note)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                if isValid {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    onCreate()
                                }
                            }) {
                                Text("Create Template")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(isValid ? .black : .appTextTertiary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        Group {
                                            if isValid {
                                                LinearGradient(
                                                    colors: [.appAccentYellow, .appAccentOrange],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            } else {
                                                Color.appCardBackground
                                            }
                                        }
                                    )
                                    .cornerRadius(14)
                            }
                            .disabled(!isValid)
                            
                            Button(action: { dismiss() }) {
                                Text("Cancel")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.appTextSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                        }
                        .frame(width: screenWidth - 48)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                    .frame(width: screenWidth)
                }
                .frame(width: screenWidth)
            }
            .frame(width: screenWidth)
            .navigationBarHidden(true)
        }
        }
    }
}

// MARK: - Slot Picker Button
struct SlotPickerButton: View {
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
            .padding(.vertical, 14)
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

// MARK: - Toast View
struct ToastView: View {
    let message: String
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.green)
            
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.appTextPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Color.appCardBackground
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -50)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Template Detail Sheet
struct TemplateDetailSheet: View {
    let template: SavedTemplateDTO
    @Environment(\.dismiss) var dismiss
    @StateObject private var ingredientsViewModel = DependencyContainer.shared.makeIngredientsViewModel()
    @State private var ingredients: [FoodIngredientDTO] = []
    
    private var slotInfo: (icon: String, color: Color, title: String) {
        guard let slotRaw = template.timeSlotRaw else {
            return ("bookmark.fill", Color.appAccentYellow, "General")
        }
        
        switch slotRaw {
        case "morning":
            return ("sunrise.fill", Color.appAccentYellow, "Morning")
        case "noon":
            return ("sun.max.fill", Color.appAccentOrange, "Noon")
        case "evening":
            return ("sunset.fill", Color.appAccentOrange, "Evening")
        case "snack":
            return ("leaf.fill", Color.green, "Snack")
        default:
            return ("bookmark.fill", Color.appAccentYellow, "General")
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                
                ZStack {
                    AppBackgroundView()
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header Icon
                            Circle()
                                .fill(slotInfo.color.opacity(0.15))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: slotInfo.icon)
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(slotInfo.color)
                                )
                                .padding(.top, 24)
                            
                            // Title
                            VStack(spacing: 8) {
                                Text(template.templateTitle)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.appTextPrimary)
                                    .multilineTextAlignment(.center)
                                
                                HStack(spacing: 12) {
                                    Label(slotInfo.title, systemImage: slotInfo.icon)
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextSecondary)
                                    
                                    Label(
                                        formatDate(template.creationTimestamp),
                                        systemImage: "calendar"
                                    )
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextSecondary)
                                }
                            }
                            
                            // Note (if exists)
                            if let note = template.noteText, !note.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Note")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.appTextSecondary)
                                    
                                    Text(note)
                                        .font(.system(size: 15))
                                        .foregroundColor(.appTextPrimary)
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.appCardBackground)
                                        .cornerRadius(12)
                                }
                                .frame(width: screenWidth - 48)
                            }
                            
                            // Ingredients List
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Ingredients")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appTextPrimary)
                                
                                if ingredients.isEmpty && !template.itemsCollection.isEmpty {
                                    Text("Loading ingredients...")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextSecondary)
                                        .padding(.vertical, 20)
                                } else if template.itemsCollection.isEmpty {
                                    Text("No ingredients in this template")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextSecondary)
                                        .padding(.vertical, 20)
                                } else {
                                    ForEach(template.itemsCollection, id: \.ingredientRef) { item in
                                        if let ingredient = ingredients.first(where: { $0.id == item.ingredientRef }) {
                                            IngredientDetailRow(
                                                ingredient: ingredient,
                                                portionAmount: item.portionAmount
                                            )
                                        } else {
                                            // Fallback for ingredients not found
                                            HStack(spacing: 12) {
                                                Circle()
                                                    .fill(Color.appAccentYellow.opacity(0.15))
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        Image(systemName: "circle.fill")
                                                            .font(.system(size: 16, weight: .semibold))
                                                            .foregroundColor(.appAccentYellow)
                                                    )
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Ingredient ID: \(item.ingredientRef.uuidString.prefix(8))...")
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundColor(.appTextPrimary)
                                                    
                                                    Text("Portion: \(String(format: "%.1f", item.portionAmount))")
                                                        .font(.system(size: 13))
                                                        .foregroundColor(.appTextSecondary)
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(12)
                                            .background(Color.appCardBackground)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            .frame(width: screenWidth - 48)
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                    .frame(width: screenWidth)
                }
                .frame(width: screenWidth)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.appAccentYellow)
                }
            }
        }
        .task {
            await ingredientsViewModel.loadAllIngredients()
            await MainActor.run {
                ingredients = ingredientsViewModel.vegetables + ingredientsViewModel.proteins + ingredientsViewModel.carbs
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Ingredient Detail Row
struct IngredientDetailRow: View {
    let ingredient: FoodIngredientDTO
    let portionAmount: Double
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Circle()
                .fill(categoryColor.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: categoryIcon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(categoryColor)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.titleText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                
                if let description = ingredient.descriptionHint {
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Portion
            Text(String(format: "%.1f", portionAmount))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.appAccentYellow)
        }
        .padding(12)
        .background(Color.appCardBackground)
        .cornerRadius(10)
    }
    
    private var categoryColor: Color {
        switch ingredient.categoryRaw {
        case "vegetable":
            return .green
        case "protein":
            return .red
        case "carb":
            return .orange
        default:
            return .appAccentYellow
        }
    }
    
    private var categoryIcon: String {
        switch ingredient.categoryRaw {
        case "vegetable":
            return "leaf.fill"
        case "protein":
            return "flame.fill"
        case "carb":
            return "bolt.fill"
        default:
            return "circle.fill"
        }
    }
}
