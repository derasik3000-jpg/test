import SwiftUI
import Combine

struct BlueprintTabView: View {
    @StateObject var viewModel: BlueprintViewModel
    @State private var sliderValue: Double = 20
    @State private var showSuccessMessage = false
    @State private var showingProfileEdit = false
    @State private var userProfile = UserProfile()
    
    private let profileRepository = UserProfileRepository()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundDeep
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom navigation bar
                    HStack {
                        Spacer()
                        
                        Text("Rules")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                    }
                    .frame(height: 44)
                    .background(AppTheme.surfaceDark)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            profileSection
                            
                            headerSection
                            
                            activeRuleCard
                            
                            presetsSection
                            
                            styleSelector
                            
                            customSection
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .top) {
                if showSuccessMessage {
                    SuccessBanner(message: "Rule Applied Successfully!")
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                }
            }
            .sheet(isPresented: $showingProfileEdit) {
                ProfileEditView(profile: $userProfile, repository: profileRepository)
            }
            .onAppear {
                sliderValue = Double(viewModel.customRate)
                loadProfile()
            }
            .onChange(of: showingProfileEdit) { isShowing in
                if !isShowing {
                    // Reload profile when sheet closes
                    loadProfile()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func loadProfile() {
        print("BlueprintTabView: Loading profile...")
        profileRepository.loadProfile()
            .receive(on: DispatchQueue.main)
            .sink { profile in
                print("BlueprintTabView: Profile loaded - name: \(profile.name)")
                userProfile = profile
            }
            .store(in: &viewModel.cancellables)
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        Button(action: { showingProfileEdit = true }) {
            HStack(spacing: 16) {
                // Profile photo
                ZStack {
                    Circle()
                        .fill(AppTheme.goldPrimary.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    if let photo = userProfile.photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.goldPrimary.opacity(0.5), lineWidth: 2)
                            )
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.goldPrimary)
                    }
                }
                
                // Name and edit prompt
                VStack(alignment: .leading, spacing: 4) {
                    if userProfile.name.isEmpty {
                        Text("Tap to set up profile")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Add your name")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    } else {
                        Text(userProfile.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Tap to edit profile")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.surfaceDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [AppTheme.goldDark.opacity(0.3), AppTheme.goldDark.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Deload Settings")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Configure your recovery rules")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    // MARK: - Active Rule Card
    
    private var activeRuleCard: some View {
        VStack(spacing: 0) {
            if let active = viewModel.activeBlueprint {
                HStack(alignment: .center, spacing: 16) {
                    // Left: Percentage ring
                    ZStack {
                        Circle()
                            .stroke(AppTheme.goldDark.opacity(0.3), lineWidth: 6)
                            .frame(width: 72, height: 72)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(active.reductionRate) / 50)
                            .stroke(
                                AppTheme.goldGradient,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 72, height: 72)
                            .rotationEffect(.degrees(-90))
                        
                        Text("–\(active.reductionRate)%")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.goldPrimary)
                    }
                    
                    // Middle: Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Active Rule")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textMuted)
                        
                        Text(active.cutbackStyle.displayName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(active.label ?? "Custom")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Right: Status
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.successGreen, AppTheme.successGreen.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        Text("Active")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.successGreen)
                    }
                }
                .padding(20)
            } else {
                EmptyRuleState()
                    .padding(20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [AppTheme.goldDark.opacity(0.4), AppTheme.goldDark.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal)
    }
    
    // MARK: - Presets Section
    
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Quick Presets", icon: "sparkles")
            
            VStack(spacing: 10) {
                ForEach(viewModel.presets) { preset in
                    PresetCard(
                        preset: preset,
                        isActive: viewModel.activeBlueprint?.reductionRate == preset.reductionRate,
                        isRecommended: preset.reductionRate == 20
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            var updated = preset
                            updated.cutbackStyle = viewModel.selectedBlueprint.cutbackStyle
                            viewModel.selectedBlueprint = updated
                            viewModel.applyBlueprint(updated) {
                                viewModel.loadActiveBlueprint()
                                
                                // Show success feedback
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    showSuccessMessage = true
                                }
                                
                                // Hide after 2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showSuccessMessage = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Style Selector
    
    private var styleSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Reduction Type", icon: "slider.horizontal.3")
            
            VStack(spacing: 10) {
                StyleOptionCard(
                    title: "Volume",
                    description: "Reduce training duration by \(viewModel.selectedBlueprint.reductionRate)%",
                    icon: "clock.fill",
                    isSelected: viewModel.selectedBlueprint.cutbackStyle == .volume
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        var updated = viewModel.selectedBlueprint
                        updated.cutbackStyle = .volume
                        viewModel.selectedBlueprint = updated
                    }
                }
                
                StyleOptionCard(
                    title: "Intensity",
                    description: "Lower effort level and reduce reps",
                    icon: "bolt.fill",
                    isSelected: viewModel.selectedBlueprint.cutbackStyle == .intensity
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        var updated = viewModel.selectedBlueprint
                        updated.cutbackStyle = .intensity
                        viewModel.selectedBlueprint = updated
                    }
                }
                
                StyleOptionCard(
                    title: "Combined",
                    description: "Reduce both volume and intensity",
                    icon: "circle.grid.2x2.fill",
                    isSelected: viewModel.selectedBlueprint.cutbackStyle == .both
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        var updated = viewModel.selectedBlueprint
                        updated.cutbackStyle = .both
                        viewModel.selectedBlueprint = updated
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Custom Section
    
    private var customSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Custom Rule", icon: "tuningfork")
            
            VStack(spacing: 20) {
                // Value display
                HStack(alignment: .bottom, spacing: 4) {
                    Text("–\(Int(sliderValue))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.goldPrimary)
                    
                    Text("%")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.goldDark)
                        .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity)
                
                // Custom slider
                CustomSlider(value: $sliderValue, range: 10...40, step: 5)
                    .onChange(of: sliderValue) { newValue in
                        viewModel.customRate = Int(newValue)
                    }
                
                // Scale labels
                HStack {
                    Text("10%")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textMuted)
                    
                    Spacer()
                    
                    Text("Mild")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textMuted)
                    
                    Spacer()
                    
                    Text("40%")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textMuted)
                }
                .padding(.horizontal, 4)
                
                // Warning
                if sliderValue > 30 {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.warnYellow)
                        
                        Text("Rates above 30% are rarely necessary")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.warnYellow)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.warnYellow.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppTheme.warnYellow.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Apply button
                Button(action: applyCustom) {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                        
                        Text("Apply –\(Int(sliderValue))% Rule")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.backgroundDeep)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(AppTheme.goldGradient)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.surfaceDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.dividerTint, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal)
    }
    
    private func applyCustom() {
        let custom = viewModel.createCustomBlueprint(
            rate: Int(sliderValue),
            style: viewModel.selectedBlueprint.cutbackStyle
        )
        viewModel.selectedBlueprint = custom
        viewModel.applyBlueprint(custom) {
            viewModel.loadActiveBlueprint()
            
            // Show success feedback
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showSuccessMessage = true
            }
            
            // Hide after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showSuccessMessage = false
                }
            }
        }
    }
}

// MARK: - Empty Rule State

struct EmptyRuleState: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(AppTheme.dividerTint, lineWidth: 6)
                    .frame(width: 72, height: 72)
                
                Image(systemName: "questionmark")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("No Active Rule")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Select a preset or create custom")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preset Card

struct PresetCard: View {
    let preset: TaperBlueprint
    let isActive: Bool
    let isRecommended: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Percentage badge
                Text("–\(preset.reductionRate)%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isActive ? AppTheme.backgroundDeep : AppTheme.goldPrimary)
                    .frame(width: 64)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isActive ? AppTheme.goldGradient : LinearGradient(colors: [AppTheme.goldPrimary.opacity(0.15)], startPoint: .leading, endPoint: .trailing))
                    )
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(preset.label ?? "Custom")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        if isRecommended {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                Text("Recommended")
                                    .font(.system(size: 10, weight: .semibold))
                                    .lineLimit(1)
                            }
                            .foregroundColor(AppTheme.goldPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(AppTheme.goldPrimary.opacity(0.15))
                            )
                            .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    
                    Text(presetDescription)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                // Checkmark
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.successGreen)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isActive ? AppTheme.goldPrimary.opacity(0.08) : AppTheme.surfaceDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isActive ? AppTheme.goldPrimary.opacity(0.4) : AppTheme.dividerTint,
                                lineWidth: isActive ? 1.5 : 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var presetDescription: String {
        switch preset.reductionRate {
        case 10: return "Light recovery, maintain fitness"
        case 20: return "Balanced recovery for most athletes"
        case 30: return "Deep recovery after intense blocks"
        default: return "Custom reduction level"
        }
    }
}

// MARK: - Style Option Card

struct StyleOptionCard: View {
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.goldPrimary.opacity(0.2) : AppTheme.backgroundElevated)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? AppTheme.goldPrimary : AppTheme.textMuted)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppTheme.goldPrimary : AppTheme.textMuted.opacity(0.5), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(AppTheme.goldPrimary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AppTheme.goldPrimary.opacity(0.08) : AppTheme.surfaceDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected ? AppTheme.goldPrimary.opacity(0.4) : AppTheme.dividerTint,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Custom Slider

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let progress = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
            let thumbX = width * CGFloat(progress)
            
            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(AppTheme.backgroundElevated)
                    .frame(height: 8)
                
                // Active track
                Capsule()
                    .fill(AppTheme.goldGradient)
                    .frame(width: thumbX, height: 8)
                
                // Tick marks
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { i in
                        Circle()
                            .fill(AppTheme.textMuted.opacity(0.3))
                            .frame(width: 4, height: 4)
                        
                        if i < 6 {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 12)
                
                // Thumb
                Circle()
                    .fill(AppTheme.goldPrimary)
                    .frame(width: isDragging ? 28 : 24, height: isDragging ? 28 : 24)
                    .shadow(color: AppTheme.goldPrimary.opacity(0.4), radius: isDragging ? 8 : 4)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.goldLight, lineWidth: 2)
                    )
                    .offset(x: thumbX - (isDragging ? 14 : 12))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isDragging = true
                                let newProgress = gesture.location.x / width
                                let clamped = min(max(newProgress, 0), 1)
                                let newValue = range.lowerBound + Double(clamped) * (range.upperBound - range.lowerBound)
                                value = (newValue / step).rounded() * step
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isDragging = false
                                }
                            }
                    )
            }
        }
        .frame(height: 28)
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Success Banner

struct SuccessBanner: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.successGreen)
            
            Text(message)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.successGreen.opacity(0.5), lineWidth: 2)
                )
                .shadow(color: AppTheme.successGreen.opacity(0.2), radius: 12, y: 4)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Profile Edit View

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var profile: UserProfile
    let repository: UserProfileRepositoryProtocol
    
    @State private var name: String
    @State private var showingSaveSuccess = false
    @State private var cancellables = Set<AnyCancellable>()
    
    init(profile: Binding<UserProfile>, repository: UserProfileRepositoryProtocol) {
        self._profile = profile
        self.repository = repository
        self._name = State(initialValue: profile.wrappedValue.name)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundDeep
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom navigation bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("Edit Profile")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Button(action: saveProfile) {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.goldPrimary)
                        }
                        .padding(.trailing, 20)
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1)
                    }
                    .frame(height: 44)
                    .background(AppTheme.surfaceDark)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) {
                            // Name section
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.goldPrimary)
                                    
                                    Text("Name")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                .padding(.top, 40)
                                
                                TextField("Enter your name", text: $name)
                                    .font(.system(size: 17))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(AppTheme.surfaceDark)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(name.isEmpty ? AppTheme.dangerRed.opacity(0.5) : AppTheme.dividerTint, lineWidth: 1)
                                            )
                                    )
                                
                                if name.isEmpty {
                                    Text("Name is required")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.dangerRed)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            Spacer(minLength: 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(alignment: .top) {
                if showingSaveSuccess {
                    SuccessBanner(message: "Profile Saved!")
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func saveProfile() {
        var updatedProfile = profile
        updatedProfile.name = name
        
        print("ProfileEditView: Saving profile - name: \(updatedProfile.name)")
        
        repository.saveProfile(updatedProfile)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print("ProfileEditView: Profile saved successfully, updating binding")
                profile = updatedProfile
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showingSaveSuccess = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showingSaveSuccess = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }
            }
            .store(in: &cancellables)
    }
}
