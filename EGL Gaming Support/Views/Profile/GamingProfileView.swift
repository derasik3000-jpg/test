import SwiftUI

struct GamingProfileView: View {
    @StateObject private var viewModel: GamingProfileViewModel
    @State private var showingColorPicker = false
    @State private var showingIconPicker = false
    @State private var selectedPhotoRecord: GamingRecord?
    
    init(viewModel: GamingProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    GamingScreenHeader("Profile", subtitle: "Settings & stats")
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    // Stats Section
                    GamingGlassmorphismPanel {
                        VStack(spacing: 24) {
                            HStack {
                                Image(systemName: "chart.bar")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundColor(GamingColorPalette.primaryPurple)
                                Text("Your Stats")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                Spacer()
                            }
                            
                            HStack(spacing: 20) {
                                // Points Card
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        GamingColorPalette.secondaryCyan.opacity(0.3),
                                                        GamingColorPalette.secondaryCyan.opacity(0.1)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "star")
                                            .font(.system(size: 32, weight: .light))
                                            .foregroundColor(GamingColorPalette.secondaryCyan)
                                    }
                                    
                                    Text("\(viewModel.points)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(GamingColorPalette.textPrimary)
                                    
                                    Text("Points")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(GamingColorPalette.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                
                                // Badge Card
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        GamingColorPalette.primaryPurple.opacity(0.3),
                                                        GamingColorPalette.primaryMagenta.opacity(0.1)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "trophy")
                                            .font(.system(size: 32, weight: .light))
                                            .foregroundColor(GamingColorPalette.primaryMagenta)
                                    }
                                    
                                    Text(viewModel.getBadgeTier())
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(GamingColorPalette.textPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    
                                    Text("Tier")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(GamingColorPalette.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Photo Gallery Section
                    if !viewModel.allPhotos.isEmpty {
                        GamingGlassmorphismPanel {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Image(systemName: "photo.stack")
                                        .font(.system(size: 20, weight: .light))
                                        .foregroundColor(GamingColorPalette.secondaryCyan)
                                    Text("Photo Gallery")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(GamingColorPalette.textPrimary)
                                    Spacer()
                                    Text("\(viewModel.allPhotos.count)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(GamingColorPalette.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(GamingColorPalette.secondaryCyan.opacity(0.2))
                                        )
                                }
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 8),
                                    GridItem(.flexible(), spacing: 8),
                                    GridItem(.flexible(), spacing: 8)
                                ], spacing: 8) {
                                    ForEach(viewModel.allPhotos, id: \.id) { record in
                                        if let imageData = record.imageData,
                                           let uiImage = UIImage(data: imageData) {
                                            Button(action: {
                                                selectedPhotoRecord = record
                                            }) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(
                                                                LinearGradient(
                                                                    gradient: Gradient(colors: [
                                                                        GamingColorPalette.primaryPurple.opacity(0.4),
                                                                        GamingColorPalette.primaryMagenta.opacity(0.2)
                                                                    ]),
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                ),
                                                                lineWidth: 1
                                                            )
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Icon Settings Section
                    GamingGlassmorphismPanel {
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Image(systemName: "paintbrush")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundColor(GamingColorPalette.primaryMagenta)
                                Text("Icon Settings")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                Spacer()
                            }
                            
                            VStack(spacing: 20) {
                                // Icon Color
                                GamingGlassmorphismCard {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Icon Color")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(GamingColorPalette.textPrimary)
                                            Text("Choose your icon color")
                                                .font(.system(size: 13))
                                                .foregroundColor(GamingColorPalette.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            showingColorPicker = true
                                        }) {
                                            Circle()
                                                .fill(Color(hex: viewModel.preference.iconColorHex))
                                                .frame(width: 44, height: 44)
                                                .overlay(
                                                    Circle()
                                                        .stroke(GamingColorPalette.textPrimary.opacity(0.2), lineWidth: 2)
                                                )
                                                .shadow(color: Color(hex: viewModel.preference.iconColorHex).opacity(0.3), radius: 8, x: 0, y: 4)
                                        }
                                    }
                                }
                                
                                // Icon Type
                                GamingGlassmorphismCard {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Icon Type")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(GamingColorPalette.textPrimary)
                                            Text("Choose icon style")
                                                .font(.system(size: 13))
                                                .foregroundColor(GamingColorPalette.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            showingIconPicker = true
                                        }) {
                                            HStack(spacing: 8) {
                                                Text(viewModel.preference.iconViewType.capitalized)
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(GamingColorPalette.primaryPurple)
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 12, weight: .light))
                                                    .foregroundColor(GamingColorPalette.textSecondary)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                Capsule()
                                                    .fill(GamingColorPalette.primaryPurple.opacity(0.1))
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Preview Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Preview")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                
                                GamingGlassmorphismCard {
                                    GamingBubblesView(
                                        iconCount: 8,
                                        iconColor: Color(hex: viewModel.preference.iconColorHex),
                                        iconType: viewModel.preference.iconViewType,
                                        useFixedPositions: true
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .sheet(isPresented: $showingColorPicker) {
            GamingColorPickerView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingIconPicker) {
            GamingIconTypePickerView(viewModel: viewModel)
        }
        .sheet(item: $selectedPhotoRecord) { record in
            GamingPhotoDetailView(record: record)
        }
    }
    
    struct GamingColorPickerView: View {
        @ObservedObject var viewModel: GamingProfileViewModel
        @Environment(\.dismiss) var dismiss
        
        let colors = ["#6A00FF", "#B100FF", "#00E5FF", "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8"]
        
        var body: some View {
            ZStack {
                GamingGradientBackgroundView()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(GamingColorPalette.primaryPurple)
                        .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Text("Choose Color")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(GamingColorPalette.textPrimary)
                        
                        Spacer()
                        
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(GamingColorPalette.primaryPurple)
                        .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                            ForEach(colors, id: \.self) { hex in
                                Button(action: {
                                    try? viewModel.updateIconColor(hex)
                                    dismiss()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: hex))
                                            .frame(width: 70, height: 70)
                                        
                                        if viewModel.preference.iconColorHex == hex {
                                            Circle()
                                                .stroke(GamingColorPalette.textPrimary, lineWidth: 4)
                                                .frame(width: 70, height: 70)
                                            
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .shadow(
                                        color: Color(hex: hex).opacity(0.4),
                                        radius: viewModel.preference.iconColorHex == hex ? 12 : 6,
                                        x: 0,
                                        y: viewModel.preference.iconColorHex == hex ? 6 : 3
                                    )
                                    .scaleEffect(viewModel.preference.iconColorHex == hex ? 1.1 : 1.0)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
    }
    
    struct GamingIconTypePickerView: View {
        @ObservedObject var viewModel: GamingProfileViewModel
        @Environment(\.dismiss) var dismiss
        
        let iconTypes = ["joystick", "controller", "pixel"]
        
        var body: some View {
            ZStack {
                GamingGradientBackgroundView()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(GamingColorPalette.primaryPurple)
                        .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Text("Choose Icon Type")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(GamingColorPalette.textPrimary)
                        
                        Spacer()
                        
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(GamingColorPalette.primaryPurple)
                        .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(iconTypes, id: \.self) { type in
                                Button(action: {
                                    try? viewModel.updateIconViewType(type)
                                    dismiss()
                                }) {
                                    GamingGlassmorphismCard {
                                        HStack {
                                            Text(type.capitalized)
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundColor(GamingColorPalette.textPrimary)
                                            Spacer()
                                            if viewModel.preference.iconViewType == type {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(GamingColorPalette.primaryPurple)
                                                    .font(.system(size: 20))
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}
