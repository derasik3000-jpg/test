import SwiftUI

struct OnboardingJourneyView: View {
    @ObservedObject var orchestrator: CelestialNavigationOrchestrator
    @State private var currentPage = 0
    @State private var selectedGoals: Set<String> = []
    
    private let pages = [
        OnboardingPage(title: "Welcome to Luna", description: "Your companion for peaceful nights and restful sleep", imageName: "moon.stars"),
        OnboardingPage(title: "Breathe & Relax", description: "Guided breathing practices designed to calm your mind before sleep", imageName: "wind"),
        OnboardingPage(title: "Track Your Rest", description: "Monitor sleep patterns and discover what helps you rest best", imageName: "bed.double"),
        OnboardingPage(title: "Set Your Goals", description: "What would you like to achieve?", imageName: "target")
    ]
    
    private let goals = ["Deep Relaxation", "Fall Asleep Faster", "Better Sleep Quality", "Reduce Stress"]
    
    var body: some View {
        ZStack {
            LinearGradient.celestialBackdrop
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 25) {
                            Spacer()
                            
                            Image(systemName: pages[index].imageName)
                                .font(.system(size: 70))
                                .foregroundColor(.nebulaBlossom)
                                .padding(.bottom, 20)
                            
                            Text(pages[index].title)
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .foregroundColor(.shadowText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                            
                            Text(pages[index].description)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.shadowText.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if index == pages.count - 1 {
                                VStack(spacing: 12) {
                                    ForEach(goals, id: \.self) { goal in
                                        Button(action: {
                                            if selectedGoals.contains(goal) {
                                                selectedGoals.remove(goal)
                                            } else {
                                                selectedGoals.insert(goal)
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: selectedGoals.contains(goal) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(selectedGoals.contains(goal) ? .nebulaBlossom : .shadowText.opacity(0.4))
                                                
                                                Text(goal)
                                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                                    .foregroundColor(.shadowText)
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 12)
                                            .background(Color.pureEssence.opacity(0.5))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal, 40)
                                .padding(.top, 15)
                            }
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.nebulaBlossom : Color.shadowText.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        orchestrator.completeOnboarding()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Start Journey")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.pureEssence)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.nebulaBlossom)
                        .cornerRadius(14)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

