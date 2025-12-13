import SwiftUI
import PhotosUI

struct GamingAddRecordView: View {
    @ObservedObject var viewModel: GamingIdeasViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var text: String = ""
    @State private var selectedDate: Date = Date()
    @State private var hasDate: Bool = false
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker: Bool = false
    @State private var showingSourceSelector: Bool = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        ZStack {
            GamingGradientBackgroundView()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        viewModel.editingRecord = nil
                        dismiss()
                    }
                    .foregroundColor(GamingColorPalette.primaryPurple)
                    .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    Text(viewModel.editingRecord != nil ? "Edit Idea" : "New Idea")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(GamingColorPalette.textPrimary)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveRecord()
                    }
                    .foregroundColor(GamingColorPalette.primaryPurple)
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(text.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Idea Text Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("IDEA TEXT")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(GamingColorPalette.textSecondary)
                                .textCase(.uppercase)
                            
                            GamingGlassmorphismCard {
                                TextEditor(text: $text)
                                    .font(.system(size: 16))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                    .frame(minHeight: 120)
                                    .scrollContentBackground(.hidden)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Image Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("IMAGE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(GamingColorPalette.textSecondary)
                                .textCase(.uppercase)
                            
                            GamingGlassmorphismCard {
                                VStack(spacing: 16) {
                                    if let image = selectedImage {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 200)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                            Button(action: {
                                                withAnimation {
                                                    selectedImage = nil
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.white)
                                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                            }
                                            .padding(8)
                                        }
                                    }
                                    
                                    Button(action: {
                                        showingSourceSelector = true
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: selectedImage == nil ? "photo.badge.plus" : "photo.badge.arrow.down")
                                                .font(.system(size: 20, weight: .light))
                                            Text(selectedImage == nil ? "Add Photo" : "Change Photo")
                                                .font(.system(size: 16, weight: .medium))
                                        }
                                        .foregroundColor(GamingColorPalette.primaryPurple)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            GamingColorPalette.primaryPurple.opacity(0.5),
                                                            GamingColorPalette.primaryMagenta.opacity(0.4)
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DETAILS")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(GamingColorPalette.textSecondary)
                                .textCase(.uppercase)
                            
                            GamingGlassmorphismCard {
                                VStack(spacing: 16) {
                                    HStack {
                                        Text("Add Date")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(GamingColorPalette.textPrimary)
                                        Spacer()
                                        Toggle("", isOn: $hasDate)
                                            .tint(GamingColorPalette.primaryPurple)
                                    }
                                    
                                    if hasDate {
                                        Divider()
                                            .background(GamingColorPalette.textSecondary.opacity(0.2))
                                        
                                        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                                            .accentColor(GamingColorPalette.primaryPurple)
                                            .colorScheme(.dark)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if let record = viewModel.editingRecord {
                text = record.text
                if let date = record.recordDate {
                    selectedDate = date
                    hasDate = true
                }
                if let imageData = record.imageData {
                    selectedImage = UIImage(data: imageData)
                }
            }
        }
        .confirmationDialog("Select Image Source", isPresented: $showingSourceSelector, titleVisibility: .visible) {
            Button("Camera") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePickerSource = .camera
                    showingImagePicker = true
                }
            }
            Button("Photo Library") {
                imagePickerSource = .photoLibrary
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: imagePickerSource)
        }
    }
    
    private func saveRecord() {
        do {
            let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
            
            if let record = viewModel.editingRecord {
                try viewModel.updateRecord(record, text: text, date: hasDate ? selectedDate : nil, imageData: imageData)
            } else {
                try viewModel.addRecord(text: text, date: hasDate ? selectedDate : nil, imageData: imageData)
            }
            viewModel.editingRecord = nil
            dismiss()
        } catch {
            print("Error saving record: \(error)")
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
