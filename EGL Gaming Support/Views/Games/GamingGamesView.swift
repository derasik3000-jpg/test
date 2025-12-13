import SwiftUI

struct GamingGamesView: View {
    @StateObject private var viewModel: GamingGamesViewModel
    @State private var searchText: String = ""
    
    init(viewModel: GamingGamesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var totalSteps: Int {
        viewModel.programs.reduce(0) { $0 + $1.steps.count }
    }
    
    private var groupedPrograms: [String: [GamingProgram]] {
        var groups: [String: [GamingProgram]] = [:]
        
        for program in viewModel.programs {
            let stepCount = program.steps.count
            let group: String
            if stepCount == 0 {
                group = "Empty"
            } else if stepCount <= 3 {
                group = "Quick"
            } else if stepCount <= 7 {
                group = "Medium"
            } else {
                group = "Extended"
            }
            groups[group, default: []].append(program)
        }
        
        return groups
    }
    
    private var sortedGroupKeys: [String] {
        let order = ["Quick", "Medium", "Extended", "Empty"]
        return order.filter { groupedPrograms.keys.contains($0) }
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: GamingColorPalette.primaryPurple))
                    .scaleEffect(1.2)
            } else if viewModel.programs.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 80, weight: .ultraLight))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    GamingColorPalette.primaryPurple.opacity(0.5),
                                    GamingColorPalette.primaryMagenta.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("No programs yet")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(GamingColorPalette.textPrimary)
                    Text("Tap + to create your first program")
                        .font(.system(size: 16))
                        .foregroundColor(GamingColorPalette.textSecondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        GamingScreenHeader("Games", subtitle: "Your programs")
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        
                        // Stats Card
                        GamingGlassmorphismCard {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total Programs")
                                        .font(.system(size: 12))
                                        .foregroundColor(GamingColorPalette.textSecondary)
                                    Text("\(viewModel.programs.count)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(GamingColorPalette.textPrimary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Total Steps")
                                        .font(.system(size: 12))
                                        .foregroundColor(GamingColorPalette.textSecondary)
                                    Text("\(totalSteps)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(GamingColorPalette.primaryPurple)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Search Bar
                        GamingSearchBarView(text: $searchText, placeholder: "Search programs...")
                            .padding(.horizontal, 16)
                        
                        // Grouped Programs
                        VStack(spacing: 20) {
                            ForEach(sortedGroupKeys, id: \.self) { groupKey in
                                if let programs = groupedPrograms[groupKey] {
                                    VStack(alignment: .leading, spacing: 12) {
                                        // Group Header
                                        HStack {
                                            Image(systemName: groupKey == "Quick" ? "bolt" :
                                                  groupKey == "Medium" ? "clock" :
                                                  groupKey == "Extended" ? "list.bullet.rectangle" : "exclamationmark.circle")
                                                .font(.system(size: 16, weight: .light))
                                                .foregroundColor(groupKey == "Quick" ? GamingColorPalette.secondaryCyan :
                                                                 groupKey == "Medium" ? GamingColorPalette.primaryPurple :
                                                                 groupKey == "Extended" ? GamingColorPalette.primaryMagenta :
                                                                 GamingColorPalette.textSecondary)
                                            Text(groupKey)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(GamingColorPalette.textPrimary)
                                            Spacer()
                                            Text("\(programs.count)")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(GamingColorPalette.textSecondary)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(
                                                    Capsule()
                                                        .fill(GamingColorPalette.primaryPurple.opacity(0.2))
                                                )
                                        }
                                        .padding(.horizontal, 16)
                                        
                                        // Programs in Group
                                        ForEach(programs, id: \.id) { program in
                                            ZStack(alignment: .topLeading) {
                                                GamingGlassmorphismCard {
                                                    VStack(alignment: .leading, spacing: 16) {
                                                        HStack {
                                                            Spacer()
                                                            
                                                            // Icon and type on the right
                                                            HStack(spacing: 6) {
                                                                Image(systemName: "gamecontroller")
                                                                    .font(.system(size: 16, weight: .light))
                                                                    .foregroundColor(GamingColorPalette.primaryPurple)
                                                                Text("Program")
                                                                    .font(.system(size: 13, weight: .medium))
                                                                    .foregroundColor(GamingColorPalette.textSecondary)
                                                            }
                                                        }
                                                        
                                                        // Cover Image
                                                        if let imageData = program.imageData,
                                                           let uiImage = UIImage(data: imageData) {
                                                            Image(uiImage: uiImage)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(maxWidth: .infinity)
                                                                .frame(height: 140)
                                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        }
                                                        
                                                        Text(program.name)
                                                            .font(.system(size: 20, weight: .bold))
                                                            .foregroundColor(GamingColorPalette.textPrimary)
                                                        
                                                        HStack(spacing: 8) {
                                                            Image(systemName: "list.bullet")
                                                                .font(.system(size: 12, weight: .light))
                                                                .foregroundColor(GamingColorPalette.textSecondary)
                                                            Text("\(program.steps.count) steps")
                                                                .font(.system(size: 15))
                                                                .foregroundColor(GamingColorPalette.textSecondary)
                                                        }
                                                        
                                                        if !program.steps.isEmpty {
                                                            HStack(spacing: 4) {
                                                                Text("Preview:")
                                                                    .font(.system(size: 13))
                                                                    .foregroundColor(GamingColorPalette.textSecondary)
                                                                Text("\(program.steps.first?.level ?? "") - \(program.steps.first?.rank ?? "")")
                                                                    .font(.system(size: 13, weight: .medium))
                                                                    .foregroundColor(GamingColorPalette.textPrimary)
                                                            }
                                                        }
                                                        
                                                        // Start button with purple gradient
                                                        Button {
                                                            viewModel.startProgram(program)
                                                        } label: {
                                                            HStack(spacing: 6) {
                                                                Image(systemName: "play")
                                                                    .font(.system(size: 14, weight: .medium))
                                                                Text("Start")
                                                                    .font(.system(size: 16, weight: .semibold))
                                                            }
                                                            .foregroundColor(GamingColorPalette.textOnAccent)
                                                            .frame(maxWidth: .infinity)
                                                            .padding(.vertical, 12)
                                                            .background(
                                                                LinearGradient(
                                                                    gradient: Gradient(colors: [
                                                                        GamingColorPalette.primaryPurple,
                                                                        GamingColorPalette.primaryMagenta
                                                                    ]),
                                                                    startPoint: .leading,
                                                                    endPoint: .trailing
                                                                )
                                                            )
                                                            .cornerRadius(12)
                                                            .shadow(color: GamingColorPalette.primaryPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                                                        }
                                                        .buttonStyle(BorderlessButtonStyle())
                                                    }
                                                }
                                                
                                                // Control buttons overlay - positioned absolutely
                                                HStack(spacing: 8) {
                                                    Image(systemName: "pencil")
                                                        .font(.system(size: 14, weight: .light))
                                                        .foregroundColor(GamingColorPalette.primaryPurple)
                                                        .frame(width: 32, height: 32)
                                                        .background(
                                                            Circle()
                                                                .fill(GamingColorPalette.primaryPurple.opacity(0.1))
                                                        )
                                                        .contentShape(Circle())
                                                        .highPriorityGesture(
                                                            TapGesture()
                                                                .onEnded { _ in
                                                                    print("Edit button tapped for program: \(program.name)")
                                                                    viewModel.startEdit(program)
                                                                }
                                                        )
                                                    
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 14, weight: .light))
                                                        .foregroundColor(GamingColorPalette.primaryMagenta)
                                                        .frame(width: 32, height: 32)
                                                        .background(
                                                            Circle()
                                                                .fill(GamingColorPalette.primaryMagenta.opacity(0.1))
                                                        )
                                                        .contentShape(Circle())
                                                        .highPriorityGesture(
                                                            TapGesture()
                                                                .onEnded { _ in
                                                                    print("Delete button tapped for program: \(program.name)")
                                                                    try? viewModel.deleteProgram(program)
                                                                }
                                                        )
                                                }
                                                .padding(16)
                                                .zIndex(1000)
                                                .allowsHitTesting(true)
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadPrograms()
        }
        .onChange(of: searchText) { newValue in
            viewModel.searchText = newValue
            viewModel.loadPrograms()
        }
        .sheet(isPresented: $viewModel.showingAddModal) {
            GamingAddProgramView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingProgramMode) {
            GamingProgramModeView(viewModel: viewModel)
        }
        .overlay(alignment: .bottomTrailing) {
            GamingFABButton(icon: "plus") {
                viewModel.showingAddModal = true
            }
            .padding(.trailing, 24)
            .padding(.bottom, 100)
        }
    }
}
