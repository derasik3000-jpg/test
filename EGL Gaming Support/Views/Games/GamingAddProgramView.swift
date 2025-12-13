import SwiftUI

struct GamingAddProgramView: View {
    @ObservedObject var viewModel: GamingGamesViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var steps: [GamingStep] = []
    @State private var showingAddStep: Bool = false
    @State private var editingStepIndex: Int?
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
                        viewModel.editingProgram = nil
                        dismiss()
                    }
                    .foregroundColor(GamingColorPalette.primaryPurple)
                    .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    Text(viewModel.editingProgram != nil ? "Edit Program" : "New Program")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(GamingColorPalette.textPrimary)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveProgram()
                    }
                    .foregroundColor(GamingColorPalette.primaryPurple)
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(name.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Program Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PROGRAM DETAILS")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(GamingColorPalette.textSecondary)
                                .textCase(.uppercase)
                            
                            GamingGlassmorphismCard {
                                TextField("Program Name", text: $name)
                                    .font(.system(size: 16))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Cover Image Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("COVER IMAGE")
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
                                                .frame(height: 180)
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
                                            Text(selectedImage == nil ? "Add Cover Photo" : "Change Cover Photo")
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
                        
                        // Steps Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("STEPS")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(GamingColorPalette.textSecondary)
                                    .textCase(.uppercase)
                                Spacer()
                            }
                            
                            if steps.isEmpty {
                                GamingGlassmorphismCard {
                                    VStack(spacing: 12) {
                                        Text("No steps yet")
                                            .font(.system(size: 16))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        
                                        Button(action: {
                                            editingStepIndex = nil
                                            showingAddStep = true
                                        }) {
                                            HStack {
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 16, weight: .light))
                                                Text("Add Step")
                                            }
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(GamingColorPalette.primaryPurple)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                }
                            } else {
                                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                    GamingGlassmorphismCard {
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack {
                                                Text("Step \(index + 1)")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(GamingColorPalette.textPrimary)
                                                Spacer()
                                                
                                                Button(action: {
                                                    editingStepIndex = index
                                                    showingAddStep = true
                                                }) {
                                                    Image(systemName: "pencil")
                                                        .foregroundColor(GamingColorPalette.primaryPurple)
                                                        .font(.system(size: 16, weight: .light))
                                                }
                                                
                                                Button(action: {
                                                    let removeIndex: Int = index
                                                    withAnimation {
                                                        steps.remove(at: removeIndex)
                                                    }
                                                }) {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(GamingColorPalette.primaryMagenta)
                                                        .font(.system(size: 16, weight: .light))
                                                }
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack {
                                                    Text("Level:")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(GamingColorPalette.textSecondary)
                                                    Text(step.level)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(GamingColorPalette.textPrimary)
                                                }
                                                
                                                HStack {
                                                    Text("Rank:")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(GamingColorPalette.textSecondary)
                                                    Text(step.rank)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(GamingColorPalette.textPrimary)
                                                }
                                                
                                                HStack {
                                                    Text("Action:")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(GamingColorPalette.textSecondary)
                                                    Text(step.action)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(GamingColorPalette.textPrimary)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    editingStepIndex = nil
                                    showingAddStep = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 16, weight: .light))
                                        Text("Add Step")
                                    }
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(GamingColorPalette.primaryPurple)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
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
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if let program = viewModel.editingProgram {
                name = program.name
                steps = program.steps
                if let imageData = program.imageData {
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
        .sheet(isPresented: $showingAddStep) {
            GamingAddStepView(
                step: editingStepIndex != nil ? steps[editingStepIndex!] : nil,
                onSave: { step in
                    if let index = editingStepIndex {
                        steps[index] = step
                        editingStepIndex = nil
                    } else {
                        steps.append(step)
                    }
                    showingAddStep = false
                }
            )
        }
    }
    
    private func saveProgram() {
        do {
            let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
            
            if let program = viewModel.editingProgram {
                try viewModel.updateProgram(program, name: name, steps: steps, imageData: imageData)
            } else {
                try viewModel.addProgram(name: name, steps: steps, imageData: imageData)
            }
            viewModel.editingProgram = nil
            dismiss()
        } catch {
            print("Error saving program: \(error)")
        }
    }
}

struct GamingAddStepView: View {
    let step: GamingStep?
    let onSave: (GamingStep) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var level: String = ""
    @State private var rank: String = ""
    @State private var action: String = ""
    
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
                    
                    Text(step != nil ? "Edit Step" : "New Step")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(GamingColorPalette.textPrimary)
                    
                    Spacer()
                    
                    Button("Save") {
                        let completed = step?.completed ?? false
                        let newStep = GamingStep(level: level, rank: rank, action: action, completed: completed)
                        onSave(newStep)
                        dismiss()
                    }
                    .foregroundColor(GamingColorPalette.primaryPurple)
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(level.isEmpty || rank.isEmpty || action.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Step Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("STEP DETAILS")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(GamingColorPalette.textSecondary)
                                .textCase(.uppercase)
                            
                            GamingGlassmorphismCard {
                                VStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Level")
                                            .font(.system(size: 12))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        TextField("", text: $level)
                                            .font(.system(size: 16))
                                            .foregroundColor(GamingColorPalette.textPrimary)
                                    }
                                    
                                    Divider()
                                        .background(GamingColorPalette.textSecondary.opacity(0.2))
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Rank")
                                            .font(.system(size: 12))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        TextField("", text: $rank)
                                            .font(.system(size: 16))
                                            .foregroundColor(GamingColorPalette.textPrimary)
                                    }
                                    
                                    Divider()
                                        .background(GamingColorPalette.textSecondary.opacity(0.2))
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Action")
                                            .font(.system(size: 12))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        TextField("", text: $action)
                                            .font(.system(size: 16))
                                            .foregroundColor(GamingColorPalette.textPrimary)
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
            if let step = step {
                level = step.level
                rank = step.rank
                action = step.action
            }
        }
    }
}
