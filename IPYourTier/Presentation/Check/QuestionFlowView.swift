import SwiftUI

public struct QuestionFlowView: View {
    @ObservedObject var viewModel: CheckFlowVM
    let questionIndex: Int
    let total: Int
    
    public init(viewModel: CheckFlowVM, questionIndex: Int, total: Int) {
        self.viewModel = viewModel
        self.questionIndex = questionIndex
        self.total = total
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ProgressBar(progress: viewModel.progress)
                .frame(height: 4)
            
            ScrollView {
                VStack(spacing: 24) {
                    questionContent
                }
                .padding(.vertical, 24)
                .padding(.bottom, 16)
            }
            
            // Кнопки фиксированы внизу, вне ScrollView
            HStack(spacing: 12) {
                Button {
                    viewModel.previousQuestion(index: questionIndex)
                } label: {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                }
                .secondaryStyleConfig()
                
                Button {
                    viewModel.answerQuestion(index: questionIndex)
                } label: {
                    HStack {
                        Text(questionIndex == total ? "Complete" : "Next")
                        if questionIndex < total {
                            Image(systemName: "arrow.right")
                        }
                    }
                }
                .primaryStyleConfig()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(ThemeColorsConfig.backgroundDeep.opacity(0.95))
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
    
    @ViewBuilder
    private var questionContent: some View {
        switch questionIndex {
        case 1: Question1View(viewModel: viewModel)
        case 2: Question2View(viewModel: viewModel)
        case 3: Question3View(viewModel: viewModel)
        case 4: Question4View(viewModel: viewModel)
        case 5: Question5View(viewModel: viewModel)
        case 6: Question6View(viewModel: viewModel)
        case 7: Question7View(viewModel: viewModel)
        case 8: Question8View(viewModel: viewModel)
        default: EmptyView()
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                
                Rectangle()
                    .fill(ThemeColorsConfig.accentBright)
                    .frame(width: geometry.size.width * CGFloat(progress))
                    .animation(.easeOut(duration: 0.3), value: progress)
            }
        }
    }
}

struct Question1View: View {
    @ObservedObject var viewModel: CheckFlowVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Pain with Movement")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("How much pain when you move the area?")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
            }
            .padding(.horizontal, 16)
            
            ChipGridView(
                options: ["None", "Mild", "Moderate", "Severe"],
                selection: Binding(
                    get: { painMoveString() },
                    set: { newValue in
                        if let value = newValue {
                            switch value {
                            case "None": viewModel.painMove = 0
                            case "Mild": viewModel.painMove = 1
                            case "Moderate": viewModel.painMove = 2
                            case "Severe": viewModel.painMove = 3
                            default: viewModel.painMove = 0
                            }
                        }
                    }
                )
            )
            .padding(.horizontal, 16)
        }
    }
    
    private func painMoveString() -> String? {
        switch viewModel.painMove {
        case 0: return "None"
        case 1: return "Mild"
        case 2: return "Moderate"
        case 3: return "Severe"
        default: return nil
        }
    }
}

struct Question2View: View {
    @ObservedObject var viewModel: CheckFlowVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Pain at Rest")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("Do you feel pain when not moving or at night?")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
            }
            .padding(.horizontal, 16)
            
            ChipGridView(
                options: ["No", "Yes"],
                selection: Binding(
                    get: { viewModel.painRest ? "Yes" : "No" },
                    set: { newValue in
                        viewModel.painRest = (newValue == "Yes")
                    }
                )
            )
            .padding(.horizontal, 16)
        }
    }
}

struct Question3View: View {
    @ObservedObject var viewModel: CheckFlowVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Sudden Event")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("Did you hear or feel a pop, snap, or click?")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
            }
            .padding(.horizontal, 16)
            
            ChipGridView(
                options: ["No", "Yes"],
                selection: Binding(
                    get: { viewModel.popSound ? "Yes" : "No" },
                    set: { newValue in
                        viewModel.popSound = (newValue == "Yes")
                    }
                )
            )
            .padding(.horizontal, 16)
        }
    }
}

struct Question4View: View {
    @ObservedObject var viewModel: CheckFlowVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Physical Signs")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("Check all that apply:")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                ToggleRow(title: "Swelling", isOn: $viewModel.edema)
                ToggleRow(title: "Warmth/Heat", isOn: $viewModel.heat)
                ToggleRow(title: "Instability/Weakness", isOn: $viewModel.instability)
            }
            .padding(.horizontal, 16)
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button {
            isOn.toggle()
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Spacer()
                
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(isOn ? ThemeColorsConfig.accentBright : ThemeColorsConfig.primaryLight.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isOn ? 0.16 : 0.10))
            )
        }
        .accessibilityLabel(title)
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
    }
}

struct Question5View: View {
    @ObservedObject var viewModel: CheckFlowVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Range of Motion")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("Compared to normal, how much can you move?")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
            }
            .padding(.horizontal, 16)
            
            CustomSliderView(
                title: "Movement Range",
                range: 0...100,
                step: 10,
                majorMarks: [0, 25, 50, 75, 100],
                value: $viewModel.romPercent,
                unit: "%"
            )
            .padding(.horizontal, 16)
        }
    }
}

struct Question6View: View {
    @ObservedObject var viewModel: CheckFlowVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Pain Intensity")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("Rate your pain right now (0 = none, 10 = worst)")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
            }
            .padding(.horizontal, 16)
            
            CustomSliderView(
                title: "Current Pain",
                range: 0...10,
                step: 1,
                majorMarks: [0, 3, 5, 7, 10],
                value: $viewModel.painNRS,
                unit: ""
            )
            .padding(.horizontal, 16)
        }
    }
}

struct Question7View: View {
    @ObservedObject var viewModel: CheckFlowVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Morning Status")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stiff for over 30 min in morning?")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                    
                    ChipGridView(
                        options: ["No", "Yes"],
                        selection: Binding(
                            get: { viewModel.morningStiffness ? "Yes" : "No" },
                            set: { newValue in
                                viewModel.morningStiffness = (newValue == "Yes")
                            }
                        )
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Better when you reduce activity?")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                    
                    ChipGridView(
                        options: ["No", "Yes", "Unsure"],
                        selection: Binding(
                            get: {
                                switch viewModel.betterWithLoadReduction {
                                case 0: return "No"
                                case 1: return "Yes"
                                default: return "Unsure"
                                }
                            },
                            set: { newValue in
                                switch newValue {
                                case "No": viewModel.betterWithLoadReduction = 0
                                case "Yes": viewModel.betterWithLoadReduction = 1
                                default: viewModel.betterWithLoadReduction = -1
                                }
                            }
                        )
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct Question8View: View {
    @ObservedObject var viewModel: CheckFlowVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Duration")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("When did symptoms start?")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
            }
            .padding(.horizontal, 16)
            
            ChipGridView(
                options: ["Today", "Yesterday", "3+ days", "7+ days"],
                selection: Binding(
                    get: { symptomStartString() },
                    set: { newValue in
                        if let value = newValue {
                            switch value {
                            case "Today": viewModel.symptomStart = 0
                            case "Yesterday": viewModel.symptomStart = 1
                            case "3+ days": viewModel.symptomStart = 2
                            case "7+ days": viewModel.symptomStart = 3
                            default: viewModel.symptomStart = 0
                            }
                        }
                    }
                )
            )
            .padding(.horizontal, 16)
        }
    }
    
    private func symptomStartString() -> String? {
        switch viewModel.symptomStart {
        case 0: return "Today"
        case 1: return "Yesterday"
        case 2: return "3+ days"
        case 3: return "7+ days"
        default: return nil
        }
    }
}

