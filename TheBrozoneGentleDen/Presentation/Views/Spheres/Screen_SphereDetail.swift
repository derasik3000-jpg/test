import SwiftUI

struct SphereDetailView: View {
    @StateObject private var viewModel: SphereDetailViewModel
    @State private var showEntryEditor: Bool = false
    
    init(sphereId: UUID) {
        let container = DependencyContainer.shared
        _viewModel = StateObject(wrappedValue: SphereDetailViewModel(
            sphereId: sphereId,
            sphereRepo: container.sphereRepository,
            entryRepo: container.entryRepository
        ))
    }
    
    var body: some View {
        ZStack {
            AuroraThemeColors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 12) {
                    FilterSegmentView(selectedFilter: $viewModel.filter) {
                        Task {
                            await viewModel.handleEntryFilterChange(viewModel.filter)
                        }
                    }
                    .padding(.horizontal)
                    
                    if viewModel.entries.isEmpty {
                        VStack(spacing: 20) {
                            Text("No Progress Yet")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AuroraThemeColors.pureWhite)
                            
                            Text("Add first improvement")
                                .font(.system(size: 16))
                                .foregroundColor(AuroraThemeColors.lightGray)
                            
                            Button {
                                showEntryEditor = true
                            } label: {
                                Text("Add Photo")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AuroraThemeColors.deepCharcoal)
                                    .frame(width: 200, height: 50)
                                    .background(AuroraThemeColors.pureWhite)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.entries) { entry in
                                NavigationLink {
                                    BeforeAfterDetailView(entryId: entry.id)
                                } label: {
                                    EntryRowView(entry: entry)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(AuroraThemeColors.pureWhite)
            }
        }
        .navigationTitle(viewModel.sphereTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEntryEditor = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(AuroraThemeColors.pureWhite)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
        .task {
            await viewModel.loadSphereDetailScreen()
        }
        .refreshable {
            await viewModel.reloadSphereEntries()
        }
        .sheet(isPresented: $showEntryEditor) {
            BeforeAfterEditorView(sphereId: viewModel.sphereId, onSaved: {
                Task { @MainActor in
                    await viewModel.reloadSphereEntries()
                    showEntryEditor = false
                }
            })
        }
    }
}

struct FilterSegmentView: View {
    @Binding var selectedFilter: EntryFilterCriteria
    let onChange: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach([EntryFilterCriteria.all, .pinned], id: \.self) { filter in
                Button {
                    selectedFilter = filter
                    onChange()
                } label: {
                    Text(filterTitle(for: filter))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedFilter == filter ? AuroraThemeColors.deepCharcoal : AuroraThemeColors.lightGray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedFilter == filter ? AuroraThemeColors.pureWhite : AuroraThemeColors.deepCharcoal.opacity(0.4))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func filterTitle(for filter: EntryFilterCriteria) -> String {
        switch filter {
        case .all: return "All"
        case .beforeAfter: return "Before/After"
        case .stages: return "Stages"
        case .pinned: return "Pinned"
        }
    }
}

extension EntryFilterCriteria: Hashable {}

struct EntryRowView: View {
    let entry: EntryRowViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            if let imagePath = entry.previewImagePath, let uiImage = loadImage(from: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AuroraThemeColors.deepCharcoal.opacity(0.6))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(AuroraThemeColors.mediumGray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AuroraThemeColors.pureWhite)
                        .lineLimit(1)
                    
                    if entry.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AuroraThemeColors.lightGray)
                    }
                }
                
                Text(entry.dateText)
                    .font(.system(size: 14))
                    .foregroundColor(AuroraThemeColors.lightGray)
                
                if entry.hasAfterPhoto {
                    Text("Complete")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AuroraThemeColors.pureWhite)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                        .cornerRadius(6)
                } else {
                    Text("Before Only")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AuroraThemeColors.mediumGray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AuroraThemeColors.deepCharcoal.opacity(0.3))
                        .cornerRadius(6)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AuroraThemeColors.mediumGray)
        }
        .padding(12)
        .prismaticCard()
    }
    
    private func loadImage(from path: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

