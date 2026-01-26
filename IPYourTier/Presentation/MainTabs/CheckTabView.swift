import SwiftUI

public struct CheckTabView: View {
    @StateObject private var viewModel: CheckFlowVM
    
    public init() {
        let container = ProvisionRegistry.shared
        self._viewModel = StateObject(wrappedValue: CheckFlowVM(
            startUC: container.startCheckUC,
            updateUC: container.updateAnswerUC,
            completeUC: container.completeCheckUC,
            donutUC: container.buildRiskDonutUC,
            featureUC: container.buildFeatureStackedUC
        ))
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                
                VStack(spacing: 0) {
                    // Custom navigation bar with close button
                    if case .question = viewModel.stage {
                        HStack {
                            Spacer()
                            
                            Button {
                                viewModel.reset()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(ThemeColorsConfig.primaryLight)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    switch viewModel.stage {
                    case .start:
                        CheckStartView(viewModel: viewModel)
                        
                    case .question(let index, let total):
                        QuestionFlowView(viewModel: viewModel, questionIndex: index, total: total)
                        
                    case .result(let session):
                        ResultScreenView(
                            viewModel: ResultScreenVM(
                                session: session,
                                donutUC: ProvisionRegistry.shared.buildRiskDonutUC,
                                featureUC: ProvisionRegistry.shared.buildFeatureStackedUC,
                                scheduleUC: ProvisionRegistry.shared.scheduleFollowUpUC,
                                sessionRepo: ProvisionRegistry.shared.checkSessionRepo
                            ),
                            onDismiss: {
                                viewModel.reset()
                            }
                        )
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

