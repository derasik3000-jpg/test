import SwiftUI

struct ChronologicalDisplay: View {
    @StateObject private var viewModel: TimelineViewModel
    
    init() {
        let container = DependencyContainer.shared
        _viewModel = StateObject(wrappedValue: TimelineViewModel(
            analyticsRepo: container.analyticsRepository
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
                        Image(systemName: "clock")
                            .font(.system(size: 64))
                            .foregroundColor(AuroraThemeColors.pureWhite)
                        
                        Text("No progress in timeline")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AuroraThemeColors.lightGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Text("Add improvement to see it here")
                            .font(.system(size: 16))
                            .foregroundColor(AuroraThemeColors.mediumGray)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.items) { item in
                                    TimelineItemView(item: item)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadTimelineItems()
            }
            .refreshable {
                await viewModel.loadTimelineItems()
            }
        }
    }
}

struct TimelineItemView: View {
    let item: TimelineItemViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.typeIcon)
                .font(.system(size: 20))
                .foregroundColor(AuroraThemeColors.pureWhite)
                .frame(width: 44, height: 44)
                .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                .cornerRadius(22)
            
            if let imagePath = item.previewPhotoPath, let uiImage = loadImage(from: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AuroraThemeColors.deepCharcoal.opacity(0.4))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.sphereTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AuroraThemeColors.mediumGray)
                
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                    .lineLimit(1)
                
                Text(item.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundColor(AuroraThemeColors.lightGray)
            }
            
            Spacer()
        }
        .padding(12)
        .prismaticCard()
    }
    
    private func loadImage(from path: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

