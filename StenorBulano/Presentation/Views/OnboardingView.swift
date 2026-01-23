import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "3 Envelopes",
            description: "Track your spending across 3 simple envelopes. No complex categories, just easy weekly budgeting.",
            icon: "envelope.fill",
            color: ColorTheme.Balance.ok
        ),
        OnboardingPage(
            title: "Quick Entry",
            description: "Add expenses in 3 seconds. Enter amount, tap envelope, done!",
            icon: "bolt.fill",
            color: ColorTheme.Balance.medium
        ),
        OnboardingPage(
            title: "Stay Balanced",
            description: "Keep spending balanced across envelopes. Get smart advice when things get skewed.",
            icon: "chart.pie.fill",
            color: ColorTheme.Accent.accent500
        ),
        OnboardingPage(
            title: "Earn Badges",
            description: "Complete weekly missions and earn badges for balanced spending habits.",
            icon: "medal.fill",
            color: ColorTheme.Balance.ok
        )
    ]
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 40) {
                HStack {
                    Spacer()
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        isPresented = false
                    }) {
                        Text("Skip")
                            .font(Typography.body())
                            .foregroundColor(ColorTheme.Text.inverse)
                    }
                }
                .padding()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                if currentPage == pages.count - 1 {
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        isPresented = false
                    }) {
                        Text("Get Started")
                            .font(Typography.body())
                            .foregroundColor(ColorTheme.Button.text)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(ColorTheme.Button.fill)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                } else {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                            .font(Typography.body())
                            .foregroundColor(ColorTheme.Button.text)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(ColorTheme.Button.fill)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(Typography.h1())
                    .foregroundColor(ColorTheme.Text.inverse)
                
                Text(page.description)
                    .font(Typography.body())
                    .foregroundColor(ColorTheme.Text.secondaryInverse)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

