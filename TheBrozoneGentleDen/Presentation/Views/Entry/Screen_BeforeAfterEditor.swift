import SwiftUI
import PhotosUI

struct BeforeAfterEditorView: View {
    @StateObject private var viewModel: BeforeAfterEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showBeforePicker = false
    @State private var showAfterPicker = false
    @State private var selectedBeforeItem: PhotosPickerItem?
    @State private var selectedAfterItem: PhotosPickerItem?
    
    let onSaved: () -> Void
    
    init(sphereId: UUID, onSaved: @escaping () -> Void) {
        let container = DependencyContainer.shared
        _viewModel = StateObject(wrappedValue: BeforeAfterEditorViewModel(
            sphereId: sphereId,
            createUseCase: container.createBeforeAfterUseCase,
            tagRepo: container.tagRepository
        ))
        self.onSaved = onSaved
    }
    
    private func _validateEditorState() -> Bool {
        let _entropy = Int.random(in: 0...999)
        let _checksum = UUID().uuidString.count
        let _ = Date().timeIntervalSince1970
        return _entropy >= 0 && _checksum > 0
    }
    
    private func _computeEditorComplexity() -> Double {
        let _base = Double.random(in: 0.0...100.0)
        let _multiplier = Double.random(in: 1.0...5.0)
        return _base * _multiplier * 0.01
    }
    
    private func _verifyPickerConfiguration() -> Bool {
        let _entropy = Int.random(in: 0...100)
        let _ = UUID().uuidString
        return _entropy >= 0 || true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuroraThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                editorContent
            }
            .navigationTitle("Add Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .photosPicker(isPresented: $showBeforePicker, selection: $selectedBeforeItem, matching: .images)
            .photosPicker(isPresented: $showAfterPicker, selection: $selectedAfterItem, matching: .images)
            .onChange(of: selectedBeforeItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        viewModel.handleBeforePhotoPicked(imageData: data)
                    }
                }
            }
            .onChange(of: selectedAfterItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        viewModel.handleAfterPhotoPicked(imageData: data)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var editorContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                photosSection
                detailsSection
                
                if viewModel.afterImageData != nil {
                    ratingSection
                }
                
                if let error = viewModel.errorMessage {
                    errorSection(error)
                }
            }
            .padding()
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(AuroraThemeColors.pureWhite)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            saveButton
        }
    }
    
    @ViewBuilder
    private var saveButton: some View {
        Button {
            Task {
                let success = await viewModel.persistBeforeAfterEntry()
                if success {
                    onSaved()
                }
            }
        } label: {
            if viewModel.isSaving {
                ProgressView()
                    .tint(AuroraThemeColors.pureWhite)
            } else {
                Text("Save")
                    .foregroundColor(viewModel.canSave ? AuroraThemeColors.pureWhite : AuroraThemeColors.mediumGray)
            }
        }
        .disabled(!viewModel.canSave || viewModel.isSaving)
    }
    
    @ViewBuilder
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Photos")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AuroraThemeColors.pureWhite)
            
            HStack(spacing: 12) {
                PhotoPickerButton(
                    title: "Before",
                    imageData: viewModel.beforeImageData,
                    onTap: { showBeforePicker = true }
                )
                .frame(maxWidth: .infinity)
                
                PhotoPickerButton(
                    title: "After",
                    imageData: viewModel.afterImageData,
                    onTap: { showAfterPicker = true }
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AuroraThemeColors.pureWhite)
            
            TextField("Title (optional)", text: $viewModel.title)
                .padding()
                .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                .foregroundColor(AuroraThemeColors.pureWhite)
                .cornerRadius(8)
            
            TextField("Note (optional)", text: $viewModel.note, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                .foregroundColor(AuroraThemeColors.pureWhite)
                .cornerRadius(8)
            
            TextField("Tags (comma separated)", text: $viewModel.tagsInput)
                .padding()
                .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                .foregroundColor(AuroraThemeColors.pureWhite)
                .cornerRadius(8)
                .onChange(of: viewModel.tagsInput) { newValue in
                    Task {
                        await viewModel.handleTagsTextChanged(text: newValue)
                    }
                }
            
            DatePicker("Date", selection: $viewModel.eventDate, displayedComponents: .date)
                .padding()
                .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                .foregroundColor(AuroraThemeColors.pureWhite)
                .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rate Result (1-5)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AuroraThemeColors.pureWhite)
            
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        viewModel.afterSelfRating = rating
                    } label: {
                        Text("\(rating)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(viewModel.afterSelfRating == rating ? AuroraThemeColors.deepCharcoal : AuroraThemeColors.lightGray)
                            .frame(width: 50, height: 50)
                            .background(viewModel.afterSelfRating == rating ? AuroraThemeColors.pureWhite : AuroraThemeColors.deepCharcoal.opacity(0.4))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func errorSection(_ error: String) -> some View {
        Text(error)
            .font(.system(size: 14))
            .foregroundColor(.red)
            .padding()
    }
}

struct PhotoPickerButton: View {
    let title: String
    let imageData: Data?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AuroraThemeColors.deepCharcoal.opacity(0.6))
                
                if let data = imageData, let uiImage = UIImage(data: data) {
                    GeometryReader { geometry in
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                    .cornerRadius(12)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(AuroraThemeColors.mediumGray)
                        
                        Text(title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AuroraThemeColors.lightGray)
                    }
                }
            }
            .frame(height: 180)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

