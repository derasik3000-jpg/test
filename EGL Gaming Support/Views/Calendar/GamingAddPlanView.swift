import SwiftUI

struct GamingAddPlanView: View {
    @ObservedObject var viewModel: GamingCalendarViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDate: Date = Date()
    @State private var planType: String = "program"
    @State private var selectedProgramId: UUID?
    @State private var selectedRecordId: UUID?
    @State private var note: String = ""
    
    private let programRepository = GamingProgramRepository()
    private let recordRepository = GamingRecordRepository()
    
    var body: some View {
        ZStack {
            GamingGradientBackgroundView()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        viewModel.editingPlan = nil
                        dismiss()
                    }
                    .foregroundColor(GamingColorPalette.primaryPurple)
                    .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    Text(viewModel.editingPlan != nil ? "Edit Plan" : "New Plan")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(GamingColorPalette.textPrimary)
                    
                    Spacer()
                    
                    Button("Save") {
                        savePlan()
                    }
                    .foregroundColor(GamingColorPalette.primaryPurple)
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(planType == "program" && selectedProgramId == nil && planType == "record" && selectedRecordId == nil)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Plan Date Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PLAN DATE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(GamingColorPalette.textSecondary)
                                .textCase(.uppercase)
                            
                            GamingGlassmorphismCard {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Date")
                                            .font(.system(size: 12))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                            .labelsHidden()
                                            .accentColor(GamingColorPalette.primaryPurple)
                                            .colorScheme(.dark)
                                    }
                                    
                                    Divider()
                                        .frame(height: 40)
                                        .background(GamingColorPalette.textSecondary.opacity(0.2))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Time")
                                            .font(.system(size: 12))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        DatePicker("", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                                            .labelsHidden()
                                            .accentColor(GamingColorPalette.primaryPurple)
                                            .colorScheme(.dark)
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
                                    // Type Picker
                                    HStack {
                                        Text("Type")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(GamingColorPalette.textPrimary)
                                        Spacer()
                                        Picker("", selection: $planType) {
                                            Text("Program").tag("program")
                                            Text("Record").tag("record")
                                        }
                                        .pickerStyle(.menu)
                                        .accentColor(GamingColorPalette.primaryPurple)
                                    }
                                    
                                    Divider()
                                        .background(GamingColorPalette.textSecondary.opacity(0.2))
                                    
                                    // Program/Record Picker
                                    if planType == "program" {
                                        HStack {
                                            Text("Program")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(GamingColorPalette.textPrimary)
                                            Spacer()
                                            Picker("", selection: $selectedProgramId) {
                                                Text("None").tag(nil as UUID?)
                                                ForEach(programRepository.active(), id: \.id) { program in
                                                    Text(program.name).tag(program.id as UUID?)
                                                }
                                            }
                                            .pickerStyle(.menu)
                                            .accentColor(GamingColorPalette.primaryPurple)
                                        }
                                    } else {
                                        HStack {
                                            Text("Record")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(GamingColorPalette.textPrimary)
                                            Spacer()
                                            Picker("", selection: $selectedRecordId) {
                                                Text("None").tag(nil as UUID?)
                                                ForEach(recordRepository.active(), id: \.id) { record in
                                                    Text(record.text.prefix(30)).tag(record.id as UUID?)
                                                }
                                            }
                                            .pickerStyle(.menu)
                                            .accentColor(GamingColorPalette.primaryPurple)
                                        }
                                    }
                                    
                                    Divider()
                                        .background(GamingColorPalette.textSecondary.opacity(0.2))
                                    
                                    // Note
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Note (optional)")
                                            .font(.system(size: 12))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        TextField("", text: $note, axis: .vertical)
                                            .font(.system(size: 16))
                                            .foregroundColor(GamingColorPalette.textPrimary)
                                            .lineLimit(3...6)
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
            if let plan = viewModel.editingPlan {
                selectedDate = plan.planDate
                planType = plan.planType
                selectedProgramId = plan.planType == "program" ? plan.refId : nil
                selectedRecordId = plan.planType == "record" ? plan.refId : nil
                note = plan.note ?? ""
            }
        }
    }
    
    private func savePlan() {
        do {
            let refId = planType == "program" ? selectedProgramId : selectedRecordId
            let draft = GamingPlanDraft(
                planDate: selectedDate,
                planType: planType,
                refId: refId,
                note: note.isEmpty ? nil : note
            )
            
            if let plan = viewModel.editingPlan {
                try viewModel.updatePlan(plan, date: selectedDate, type: planType, refId: refId, note: note.isEmpty ? nil : note)
            } else {
                try viewModel.addPlan(date: selectedDate, type: planType, refId: refId, note: note.isEmpty ? nil : note)
            }
            
            viewModel.editingPlan = nil
            dismiss()
        } catch {
            print("Error saving plan: \(error)")
        }
    }
}
