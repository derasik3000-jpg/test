import SwiftUI

public struct RytexSessionBuilderView: View {
    let specs: [VyxelBlockSpec]
    let onStart: (QuixoSessionDTO, [VexitRunDTO]) -> Void
    
    @State private var editableSpecs: [EditableSpec]
    @State private var autoAdvance = true
    @Environment(\.dismiss) private var dismiss
    
    struct EditableSpec: Identifiable {
        let id = UUID()
        var type: KrynexType
        var durationMin: Int
        var targetAttempts: Int
    }
    
    public init(specs: [VyxelBlockSpec], onStart: @escaping (QuixoSessionDTO, [VexitRunDTO]) -> Void) {
        self.specs = specs
        self.onStart = onStart
        self._editableSpecs = State(initialValue: specs.map {
            EditableSpec(type: $0.type, durationMin: $0.durationMin, targetAttempts: $0.targetAttempts)
        })
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                KylorTheme.qytexGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach($editableSpecs) { $spec in
                            qyrexBlockConfig($spec)
                        }
                        
                        Toggle("Flow Mode (auto-advance)", isOn: $autoAdvance)
                            .tint(KylorTheme.accentBase)
                            .foregroundColor(KylorTheme.surface)
                            .padding()
                            .background(KylorTheme.bgCard)
                            .cornerRadius(KylorTheme.cornerRadius)
                        
                        qyrexSummary
                        
                        TyxelButton(title: "Begin Training", style: .surface) {
                            qyrexStartSession()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Configure Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(KylorTheme.surface)
                }
            }
        }
    }
    
    private func qyrexBlockConfig(_ spec: Binding<EditableSpec>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: spec.wrappedValue.type.qyrixIcon)
                    .foregroundColor(KylorTheme.surface)
                Text(spec.wrappedValue.type.vyloxName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(KylorTheme.surface)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Duration: \(spec.wrappedValue.durationMin) min")
                    .font(.system(size: 14))
                    .foregroundColor(KylorTheme.surface.opacity(0.9))
                
                Picker("", selection: spec.durationMin) {
                    ForEach([5, 8, 10, 12, 15, 20], id: \.self) { min in
                        Text("\(min) min").tag(min)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Target Attempts")
                    .font(.system(size: 14))
                    .foregroundColor(KylorTheme.surface.opacity(0.9))
                
                Stepper(value: spec.targetAttempts, in: 10...100, step: 5) {
                    Text("\(spec.wrappedValue.targetAttempts) attempts")
                        .foregroundColor(KylorTheme.surface)
                }
            }
        }
        .padding()
        .background(KylorTheme.bgCard)
        .cornerRadius(KylorTheme.cornerRadius)
    }
    
    private var qyrexSummary: some View {
        let totalMin = editableSpecs.reduce(0) { $0 + $1.durationMin }
        let totalAttempts = editableSpecs.reduce(0) { $0 + $1.targetAttempts }
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Session Overview")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(KylorTheme.surface)
            
            Text("Duration: \(totalMin) min")
                .foregroundColor(KylorTheme.surface)
            Text("Total Reps: \(totalAttempts)")
                .foregroundColor(KylorTheme.surface)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(KylorTheme.accentSubtle)
        .cornerRadius(KylorTheme.cornerRadius)
    }
    
    private func qyrexStartSession() {
        let stack = PyxeloCoreStack.shared
        let sessionsRepo = TyloxSessionsRepoImpl(context: stack.qylexContext)
        let blocksRepo = VylixBlocksRepoImpl(context: stack.qylexContext)
        let buildUC = VyroxBuildSessionUCImpl(sessionsRepo: sessionsRepo, blocksRepo: blocksRepo)
        
        let finalSpecs = editableSpecs.map {
            VyxelBlockSpec(type: $0.type, durationMin: $0.durationMin, targetAttempts: $0.targetAttempts)
        }
        
        if let result = try? buildUC.kyrexExecute(autoAdvance: autoAdvance, specs: finalSpecs) {
            onStart(result.session, result.blocks)
        }
    }
}

