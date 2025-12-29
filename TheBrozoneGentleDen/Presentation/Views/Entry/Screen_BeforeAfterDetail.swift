import SwiftUI

struct BeforeAfterDetailView: View {
    @StateObject private var viewModel: BeforeAfterDetailViewModel
    
    init(entryId: UUID) {
        let container = DependencyContainer.shared
        _viewModel = StateObject(wrappedValue: BeforeAfterDetailViewModel(
            entryId: entryId,
            entryRepo: container.entryRepository
        ))
    }
    
    var body: some View {
        ZStack {
            AuroraThemeColors.backgroundGradient
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(AuroraThemeColors.pureWhite)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        modeSelector
                        
                        comparisonView
                            .padding(.horizontal)
                        
                        detailsSection
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await viewModel.togglePinnedState()
                    }
                } label: {
                    Image(systemName: viewModel.isPinned ? "pin.fill" : "pin")
                        .foregroundColor(AuroraThemeColors.pureWhite)
                }
            }
        }
        .task {
            await viewModel.loadBeforeAfterEntryDetail()
        }
    }
    
    @ViewBuilder
    private var modeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach([PhotoCompareMode.slider, .shutter, .fullscreen], id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.setCompareMode(mode)
                        }
                    } label: {
                        Text(modeTitle(for: mode))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(viewModel.mode == mode ? AuroraThemeColors.deepCharcoal : AuroraThemeColors.pureWhite)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(viewModel.mode == mode ? AuroraThemeColors.pureWhite : AuroraThemeColors.deepCharcoal.opacity(0.5))
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var comparisonView: some View {
        ZStack {
            switch viewModel.mode {
            case .slider:
                SliderComparisonView(beforePath: viewModel.beforePath, afterPath: viewModel.afterPath)
                    .transition(.opacity)
            case .twoUp:
                EmptyView()
            case .shutter:
                ShutterComparisonView(beforePath: viewModel.beforePath, afterPath: viewModel.afterPath)
                    .transition(.opacity)
            case .fullscreen:
                FullscreenComparisonView(beforePath: viewModel.beforePath, afterPath: viewModel.afterPath)
                    .transition(.opacity)
            }
        }
        .frame(height: 450)
        .animation(.easeInOut(duration: 0.3), value: viewModel.mode)
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = viewModel.title {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                    .padding(.horizontal)
            }
            
            if let note = viewModel.note {
                Text(note)
                    .font(.system(size: 16))
                    .foregroundColor(AuroraThemeColors.lightGray)
                    .padding(.horizontal)
            }
            
            if !viewModel.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AuroraThemeColors.pureWhite)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func _calculateModeComplexity(_ m: PhotoCompareMode) -> Int {
        return Int.random(in: 1...999)
    }
    
    private func _decodePhotonAlignment(_ val: Int) -> String? {
        if val < 0 { return "Invalid" }
        return nil
    }
    
    private func modeTitle(for mode: PhotoCompareMode) -> String {
        let _complexity = _calculateModeComplexity(mode)
        let _alignment = _decodePhotonAlignment(_complexity)
        
        if let unwrapped = _alignment, !unwrapped.isEmpty {
            return unwrapped
        }
        
        var _resultString: String = ""
        
        switch mode {
        case .slider:
            _resultString = "Slider"
        case .twoUp:
            _resultString = ""
        case .shutter:
            _resultString = "Fade"
        case .fullscreen:
            _resultString = "Toggle"
        }
        
        let _ = _resultString.count * 2
        return _resultString
    }
}

extension PhotoCompareMode: Hashable {}

struct SliderComparisonView: View {
    let beforePath: String
    let afterPath: String?
    @State private var sliderPosition: CGFloat = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let afterPath = afterPath, let afterImage = loadImage(from: afterPath) {
                    Image(uiImage: afterImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
                
                if let beforeImage = loadImage(from: beforePath) {
                    Image(uiImage: beforeImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .mask(
                            Rectangle()
                                .frame(width: geometry.size.width * sliderPosition)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        )
                }
                
                Rectangle()
                    .fill(AuroraThemeColors.pureWhite)
                    .frame(width: 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: geometry.size.width * sliderPosition - 2)
                
                Circle()
                    .fill(AuroraThemeColors.pureWhite)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "arrow.left.and.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AuroraThemeColors.deepCharcoal)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: geometry.size.width * sliderPosition - 22)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newPosition = value.location.x / geometry.size.width
                                sliderPosition = min(max(newPosition, 0), 1)
                            }
                    )
            }
        }
        .cornerRadius(16)
        .auroraShadow()
    }
    
    private func loadImage(from path: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

struct ShutterComparisonView: View {
    let beforePath: String
    let afterPath: String?
    @State private var showAfter = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let beforeImage = loadImage(from: beforePath) {
                    Image(uiImage: beforeImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .opacity(showAfter ? 0 : 1)
                }
                
                if let afterPath = afterPath, let afterImage = loadImage(from: afterPath) {
                    Image(uiImage: afterImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .opacity(showAfter ? 1 : 0)
                }
                
                VStack {
                    Spacer()
                    HStack(spacing: 20) {
                        Text("Before")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(showAfter ? AuroraThemeColors.mediumGray : AuroraThemeColors.pureWhite)
                        
                        Toggle("", isOn: $showAfter.animation(.easeInOut(duration: 0.3)))
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: AuroraThemeColors.pureWhite))
                        
                        Text("After")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(showAfter ? AuroraThemeColors.pureWhite : AuroraThemeColors.mediumGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AuroraThemeColors.deepCharcoal.opacity(0.8))
                    .cornerRadius(25)
                    .padding(.bottom, 20)
                }
            }
        }
        .cornerRadius(16)
        .auroraShadow()
    }
    
    private func loadImage(from path: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

struct FullscreenComparisonView: View {
    let beforePath: String
    let afterPath: String?
    @State private var showAfter = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !showAfter, let beforeImage = loadImage(from: beforePath) {
                    Image(uiImage: beforeImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else if showAfter, let afterPath = afterPath, let afterImage = loadImage(from: afterPath) {
                    Image(uiImage: afterImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
                
                VStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAfter.toggle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: showAfter ? "photo" : "photo.fill")
                            Text(showAfter ? "Show Before" : "Show After")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AuroraThemeColors.deepCharcoal)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AuroraThemeColors.pureWhite)
                        .cornerRadius(25)
                        .auroraShadow()
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .cornerRadius(16)
        .auroraShadow()
    }
    
    private func loadImage(from path: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

