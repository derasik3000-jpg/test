import SwiftUI

struct PrismNexusView: View {
    @ObservedObject var viewModel: PrismNexusViewModel
    @ObservedObject var orchestrator: CelestialNavigationOrchestrator
    @AppStorage("nightModeActivated") private var nightModeActivated = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.celestialBackdrop(isDark: nightModeActivated)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Evening Ritual")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.6))
                            
                            Text(viewModel.greetingPhrase)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(Color.adaptiveText(nightModeActivated))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Button(action: {
                            orchestrator.navigateTo(.breathSession(viewModel.recommendedFlow))
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Start Session")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.pureEssence)
                                    
                                    Text("Recommended: \(viewModel.recommendedFlow.displayNomenclature)")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.pureEssence.opacity(0.9))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.pureEssence)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.adaptiveAccent(nightModeActivated),
                                        Color.adaptiveAccent(nightModeActivated).opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(18)
                            .shadow(color: Color.adaptiveAccent(nightModeActivated).opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Practices")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.adaptiveText(nightModeActivated))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 14) {
                                ForEach(viewModel.availableFlows, id: \.category.rawValue) { flow in
                                    Button(action: {
                                        orchestrator.navigateTo(.breathSession(flow.category))
                                    }) {
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.adaptiveAccent(nightModeActivated).opacity(0.2))
                                                    .frame(width: 50, height: 50)
                                                
                                                Image(systemName: getIconForCategory(flow.category))
                                                    .font(.system(size: 22))
                                                    .foregroundColor(Color.adaptiveAccent(nightModeActivated))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(flow.title)
                                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                                    .foregroundColor(Color.adaptiveText(nightModeActivated))
                                                
                                                Text(flow.subtitle)
                                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                                    .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.7))
                                            }
                                            
                                            Spacer()
                                            
                                            Text(flow.duration)
                                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                                .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.6))
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.4))
                                        }
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 16)
                                        .background(Color.adaptiveCard(nightModeActivated))
                                        .cornerRadius(16)
                                        .shadow(color: Color.adaptiveSecondary(nightModeActivated).opacity(0.2), radius: 8, x: 0, y: 4)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        if !viewModel.recentSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Sessions")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.adaptiveText(nightModeActivated))
                                    .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.recentSessions.prefix(5)) { session in
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(BreathFlowCategory(rawValue: session.rhythmCategory)?.displayNomenclature ?? "Session")
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(Color.adaptiveText(nightModeActivated))
                                                
                                                Text("\(session.durationPhase) min")
                                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                                    .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.6))
                                                
                                                Text(session.chronoStamp, style: .date)
                                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                                    .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.5))
                                            }
                                            .padding(12)
                                            .frame(width: 130)
                                            .background(Color.adaptiveSecondary(nightModeActivated).opacity(0.3))
                                            .cornerRadius(12)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, 10)
                        }
                        
                        Spacer(minLength: 80)
                    }
                }
                
                VStack {
                    Spacer()
                    
                    HStack(spacing: 4) {
                        NavigationTabButton(icon: "house.fill", title: "Home", isSelected: true, isDark: nightModeActivated) {
                        }
                        
                        NavigationTabButton(icon: "moon.fill", title: "Diary", isSelected: false, isDark: nightModeActivated) {
                            orchestrator.navigateTo(.sleepDiary)
                        }
                        
                        NavigationTabButton(icon: "chart.bar.fill", title: "Stats", isSelected: false, isDark: nightModeActivated) {
                            orchestrator.navigateTo(.statistics)
                        }
                        
                        NavigationTabButton(icon: "gearshape.fill", title: "Settings", isSelected: false, isDark: nightModeActivated) {
                            orchestrator.navigateTo(.settings)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        ZStack {
                            // Глянцевый эффект
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.adaptiveCard(nightModeActivated).opacity(0.95))
                            
                            // Градиент сверху для глубины
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.adaptiveAccent(nightModeActivated).opacity(0.05),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            // Тонкая рамка
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(
                                    Color.adaptiveAccent(nightModeActivated).opacity(0.1),
                                    lineWidth: 1
                                )
                        }
                    )
                    .shadow(color: Color.adaptiveText(nightModeActivated).opacity(0.08), radius: 20, x: 0, y: -5)
                    .shadow(color: Color.adaptiveAccent(nightModeActivated).opacity(0.1), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.synthesizeRecommendations()
        }
    }
    
    private func getIconForCategory(_ category: BreathFlowCategory) -> String {
        switch category {
        case .swiftRelief: return "bolt.fill"
        case .deepSerenity: return "moon.stars.fill"
        case .tranquilEssence: return "leaf.fill"
        }
    }
}

struct NavigationTabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let isDark: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    // Фоновый круг для выбранной вкладки
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.adaptiveAccent(isDark).opacity(0.15),
                                        Color.adaptiveAccent(isDark).opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .scaleEffect(isPressed ? 0.85 : 1.0)
                            .transition(.scale.combined(with: .opacity))
                        
                        // Пульсирующее кольцо
                        Circle()
                            .stroke(Color.adaptiveAccent(isDark).opacity(0.2), lineWidth: 2)
                            .frame(width: 50, height: 50)
                            .scaleEffect(isPressed ? 0.85 : 1.0)
                    }
                    
                    // Иконка
                    Image(systemName: icon)
                        .font(.system(size: isSelected ? 24 : 20, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? Color.adaptiveAccent(isDark) : Color.adaptiveText(isDark).opacity(0.5))
                        .scaleEffect(isPressed ? 0.85 : 1.0)
                        .rotationEffect(.degrees(isPressed ? -5 : 0))
                        .shadow(
                            color: isSelected ? Color.adaptiveAccent(isDark).opacity(0.3) : .clear,
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                }
                .frame(height: 50)
                
                // Текст
                Text(title)
                    .font(.system(size: isSelected ? 11 : 10, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? Color.adaptiveAccent(isDark) : Color.adaptiveText(isDark).opacity(0.5))
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                // Индикатор снизу
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.adaptiveAccent(isDark),
                                    Color.adaptiveAccent(isDark).opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 30, height: 3)
                        .shadow(color: Color.adaptiveAccent(isDark).opacity(0.5), radius: 3, x: 0, y: 1)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 30, height: 3)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
