import SwiftUI

struct GamingSpawnView: View {
    @StateObject private var viewModel: GamingSpawnViewModel
    @StateObject private var profileViewModel: GamingProfileViewModel
    @StateObject private var ideasViewModel: GamingIdeasViewModel
    @State private var showingAddRecord: Bool = false
    @State private var searchText: String = ""
    @State private var selectedPhotoRecord: GamingRecord?
    
    init(
        viewModel: GamingSpawnViewModel,
        profileViewModel: GamingProfileViewModel,
        ideasViewModel: GamingIdeasViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _profileViewModel = StateObject(wrappedValue: profileViewModel)
        _ideasViewModel = StateObject(wrappedValue: ideasViewModel)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    GamingScreenHeader("Spawn", subtitle: "Your gaming hub")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    // Stats Row
                    HStack(spacing: 12) {
                        // Points Card
                        GamingGlassmorphismCard {
                            VStack(spacing: 8) {
                                Image(systemName: "star")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(GamingColorPalette.secondaryCyan)
                                Text("\(viewModel.points)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                Text("Points")
                                    .font(.system(size: 12))
                                    .foregroundColor(GamingColorPalette.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Badge Card
                        GamingGlassmorphismCard {
                            VStack(spacing: 8) {
                                Image(systemName: "trophy")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(GamingColorPalette.primaryMagenta)
                                Text(profileViewModel.getBadgeTier())
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                    .lineLimit(1)
                                Text("Tier")
                                    .font(.system(size: 12))
                                    .foregroundColor(GamingColorPalette.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Programs Count
                        GamingGlassmorphismCard {
                            VStack(spacing: 8) {
                                Image(systemName: "gamecontroller")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(GamingColorPalette.primaryPurple)
                                Text("\(viewModel.programs.count)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                Text("Programs")
                                    .font(.system(size: 12))
                                    .foregroundColor(GamingColorPalette.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Today's Photos Section
                    let todaysPhotos = viewModel.records.filter { record in
                        guard let imageData = record.imageData, !imageData.isEmpty else { return false }
                        guard let date = record.recordDate else { return true }
                        return Calendar.current.isDateInToday(date)
                    }
                    
                    if !todaysPhotos.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundColor(GamingColorPalette.secondaryCyan)
                                Text("Today's Photos")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                Spacer()
                                Text("\(todaysPhotos.count)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(GamingColorPalette.textSecondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(GamingColorPalette.secondaryCyan.opacity(0.2))
                                    )
                            }
                            .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(todaysPhotos, id: \.id) { record in
                                        if let imageData = record.imageData,
                                           let uiImage = UIImage(data: imageData) {
                                            Button(action: {
                                                selectedPhotoRecord = record
                                            }) {
                                                ZStack(alignment: .bottomLeading) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 140, height: 140)
                                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                                    
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.clear,
                                                            Color.black.opacity(0.6)
                                                        ]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                    .frame(height: 60)
                                                    .clipShape(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .path(in: CGRect(x: 0, y: 80, width: 140, height: 60))
                                                    )
                                                    
                                                    Text(record.text)
                                                        .font(.system(size: 11, weight: .medium))
                                                        .foregroundColor(.white)
                                                        .lineLimit(2)
                                                        .padding(10)
                                                }
                                                .shadow(color: GamingColorPalette.primaryPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                    // Recent Ideas Section
                    if !viewModel.records.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb")
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundColor(GamingColorPalette.primaryMagenta)
                                Text("Recent Ideas")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
                            ForEach(viewModel.records.prefix(3), id: \.id) { record in
                                GamingGlassmorphismCard {
                                    HStack(spacing: 12) {
                                        // Show image if available
                                        if let imageData = record.imageData,
                                           let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        } else {
                                            Image(systemName: "lightbulb")
                                                .font(.system(size: 20, weight: .light))
                                                .foregroundColor(GamingColorPalette.primaryMagenta)
                                                .frame(width: 50, height: 50)
                                                .background(
                                                    Circle()
                                                        .fill(GamingColorPalette.primaryMagenta.opacity(0.15))
                                                )
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(record.text)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(GamingColorPalette.textPrimary)
                                                .lineLimit(2)
                                            
                                            if let date = record.recordDate {
                                                Text(date, style: .date)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(GamingColorPalette.textSecondary)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                    // Gaming Icons Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(GamingColorPalette.primaryPurple)
                            Text("Gaming Icons")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(GamingColorPalette.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        GamingGlassmorphismPanel {
                            VStack(alignment: .leading, spacing: 20) {
                                GamingBubblesView(
                                    iconCount: viewModel.iconCount,
                                    iconColor: Color(hex: profileViewModel.preference.iconColorHex),
                                    iconType: profileViewModel.preference.iconViewType,
                                    useFixedPositions: false
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Recent Programs Section
                    if !viewModel.programs.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "gamecontroller")
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundColor(GamingColorPalette.primaryPurple)
                                Text("Recent Programs")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
                            ForEach(viewModel.programs.prefix(3), id: \.id) { program in
                                GamingGlassmorphismCard {
                                    HStack(spacing: 12) {
                                        Image(systemName: "gamecontroller")
                                            .font(.system(size: 20, weight: .light))
                                            .foregroundColor(GamingColorPalette.primaryPurple)
                                            .frame(width: 40, height: 40)
                                            .background(
                                                Circle()
                                                    .fill(GamingColorPalette.primaryPurple.opacity(0.15))
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(program.name)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(GamingColorPalette.textPrimary)
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "list.bullet")
                                                    .font(.system(size: 12, weight: .light))
                                                    .foregroundColor(GamingColorPalette.textSecondary)
                                                Text("\(program.steps.count) steps")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(GamingColorPalette.textSecondary)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                    // Add Button - Full Width with purple gradient
                    Button(action: {
                        showingAddRecord = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 20, weight: .light))
                            Text("Add New Idea")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(GamingColorPalette.textOnAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
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
                        .cornerRadius(16)
                        .shadow(color: GamingColorPalette.primaryPurple.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            viewModel.loadData()
            profileViewModel.loadData()
            ideasViewModel.loadRecords()
        }
        .refreshable {
            viewModel.refresh()
        }
        .sheet(isPresented: $showingAddRecord, onDismiss: {
            viewModel.loadData()
        }) {
            GamingAddRecordView(viewModel: ideasViewModel)
        }
        .sheet(item: $selectedPhotoRecord) { record in
            GamingPhotoDetailView(record: record)
        }
    }
}

// MARK: - Photo Detail View

struct GamingPhotoDetailView: View {
    let record: GamingRecord
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                    
                    Spacer()
                    
                    if let date = record.recordDate {
                        Text(date, style: .date)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Photo
                if let imageData = record.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { value in
                                    lastScale = scale
                                    if scale < 1.0 {
                                        withAnimation {
                                            scale = 1.0
                                            lastScale = 1.0
                                        }
                                    }
                                    if scale > 4.0 {
                                        withAnimation {
                                            scale = 4.0
                                            lastScale = 4.0
                                        }
                                    }
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation {
                                if scale > 1.0 {
                                    scale = 1.0
                                    lastScale = 1.0
                                } else {
                                    scale = 2.0
                                    lastScale = 2.0
                                }
                            }
                        }
                }
                
                Spacer()
                
                // Caption
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.text)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}
