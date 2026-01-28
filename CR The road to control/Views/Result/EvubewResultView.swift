import SwiftUI

struct EvubewResultView: View {
    let session: AxemobSessionModel
    let onDismiss: () -> Void
    
    @State private var degubaAnimationProgress: CGFloat = 0
    @ObservedObject var cuqavuThemeManager = CuqavuThemeManager.shared
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 40)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(cuqavuThemeManager.degubaCurrentTheme.evubewPrimary)
                        .scaleEffect(degubaAnimationProgress)
                        .opacity(Double(degubaAnimationProgress))
                        .shadow(color: cuqavuThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.5), radius: 20, x: 0, y: 0)
                    
                    VStack(spacing: 8) {
                        Text("Session Saved!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(cuqavuThemeManager.degubaCurrentTheme.evubewPrimary)
                        
                        Text("Great work on staying productive")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(cuqavuThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                    }
                    .opacity(Double(degubaAnimationProgress))
                    
                    VStack(spacing: 20) {
                        CuqavuResultStatCard(
                            icon: "clock.fill",
                            title: "Duration",
                            value: AxemobTimeFormatter.shared.evubewFormatMinutes(session.durationMin),
                            color: cuqavuThemeManager.degubaCurrentTheme.evubewPrimary,
                            themeManager: cuqavuThemeManager
                        )
                        
                        CuqavuResultStatCard(
                            icon: "bolt.fill",
                            title: "Energy Level",
                            value: "\(session.energyLevel)/10",
                            color: cuqavuThemeManager.degubaCurrentTheme.cuqavuSecondary,
                            themeManager: cuqavuThemeManager
                        )
                        
                        CuqavuResultStatCard(
                            icon: "star.fill",
                            title: "Efficiency Score",
                            value: String(format: "%.1f", session.degubaEfficiencyScore),
                            color: cuqavuThemeManager.degubaCurrentTheme.evubewPrimary,
                            themeManager: cuqavuThemeManager
                        )
                    }
                    .padding(.horizontal)
                    .opacity(Double(degubaAnimationProgress))
                    
                    EhonohMoodEnergySection(energy: Int(session.energyLevel), mood: Int(session.mood), themeManager: cuqavuThemeManager)
                        .opacity(Double(degubaAnimationProgress))
                    
                    Button(action: {
                        onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 18))
                            
                            Text("Back to Home")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [cuqavuThemeManager.degubaCurrentTheme.evubewPrimary, cuqavuThemeManager.degubaCurrentTheme.cuqavuSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: cuqavuThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.4), radius: 15, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .opacity(Double(degubaAnimationProgress))
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                degubaAnimationProgress = 1.0
            }
        }
    }
}

struct CuqavuResultStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let themeManager: CuqavuThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(
                        colors: [color.opacity(0.3), color.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            ZStack {
                // Более светлый фон для контраста
                Color(red: 0.2, green: 0.2, blue: 0.22)
                
                // Легкий градиент с золотым оттенком
                LinearGradient(
                    colors: [
                        themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                            themeManager.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

struct EhonohMoodEnergySection: View {
    let energy: Int
    let mood: Int
    let themeManager: CuqavuThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Mood & Energy")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.degubaCurrentTheme.evubewPrimary)
            
            CuqavuBarChart(
                degubaDataPoints: [("Session", Double(energy), Double(mood))],
                evubewMaxValue: 10
            )
            .frame(height: 150)
        }
        .padding()
        .background(
            ZStack {
                // Более светлый фон для контраста
                Color(red: 0.2, green: 0.2, blue: 0.22)
                
                // Легкий градиент с золотым оттенком
                LinearGradient(
                    colors: [
                        themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                            themeManager.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.2), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}

