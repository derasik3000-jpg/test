import SwiftUI

struct SpheresHomeView: View {
    @StateObject private var viewModel: SpheresHomeViewModel
    init() {
        let container = DependencyContainer.shared
        _viewModel = StateObject(wrappedValue: SpheresHomeViewModel(
            sphereRepo: container.sphereRepository,
            entryRepo: container.entryRepository,
            initDefaults: container.initializeDefaultSpheresUseCase
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuroraThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(AuroraThemeColors.pureWhite)
                } else if viewModel.emptyStateVisible {
                    VStack(spacing: 20) {
                        Text("No Spheres Yet")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AuroraThemeColors.pureWhite)
                        
                        Text("Create your first sphere")
                            .font(.system(size: 16))
                            .foregroundColor(AuroraThemeColors.lightGray)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.spheres) { sphere in
                                NavigationLink {
                                    SphereDetailView(sphereId: sphere.id)
                                } label: {
                                    SphereCardView(sphere: sphere)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Spheres")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.handleHomeScreenAppear()
            }
            .refreshable {
                await viewModel.reloadHomeSpheres()
            }
        }
    }
}

struct SphereCardView: View {
    let sphere: SphereCardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imagePath = sphere.coverImagePath, let uiImage = loadImage(from: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AuroraThemeColors.deepCharcoal.opacity(0.6))
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(AuroraThemeColors.mediumGray)
                    )
            }
            
            Text(sphere.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AuroraThemeColors.pureWhite)
            
            HStack {
                Text(sphere.microProgressHint)
                    .font(.system(size: 14))
                    .foregroundColor(AuroraThemeColors.lightGray)
                
                Spacer()
                
                Text(sphere.lastUpdatedText)
                    .font(.system(size: 12))
                    .foregroundColor(AuroraThemeColors.mediumGray)
            }
        }
        .padding(16)
        .prismaticCard()
    }
    
    private func loadImage(from path: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

struct SphereSelectorView: View {
    let spheres: [SphereCardViewModel]
    let onSelectSphere: (UUID) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuroraThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(spheres) { sphere in
                            Button {
                                onSelectSphere(sphere.id)
                            } label: {
                                HStack(spacing: 16) {
                                    if let imagePath = sphere.coverImagePath, let uiImage = loadImage(from: imagePath) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipped()
                                            .cornerRadius(8)
                                    } else {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(AuroraThemeColors.deepCharcoal.opacity(0.6))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(AuroraThemeColors.mediumGray)
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(sphere.title)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(AuroraThemeColors.pureWhite)
                                        
                                        Text(sphere.microProgressHint)
                                            .font(.system(size: 14))
                                            .foregroundColor(AuroraThemeColors.lightGray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(AuroraThemeColors.mediumGray)
                                }
                                .padding(16)
                                .prismaticCard()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Sphere")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AuroraThemeColors.pureWhite)
                }
            }
        }
    }
    
    private func loadImage(from path: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

