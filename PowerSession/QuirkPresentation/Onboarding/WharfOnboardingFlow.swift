import SwiftUI

public struct WharfOnboardingFlow: View {
    @AppStorage("murkyHasCompletedOnboarding") private var vexHasCompleted = false
    @State private var plinthCurrentPage = 0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            SternGradientBackground()
            
            TabView(selection: $plinthCurrentPage) {
                QuirkOnboardingPage1()
                    .tag(0)
                
                TarnOnboardingPage2()
                    .tag(1)
                
                FizzOnboardingPage3()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                HStack {
                    Spacer()
                    
                    if plinthCurrentPage < 2 {
                        Button(action: {
                            vexHasCompleted = true
                        }) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(VexColorPalette.quellAccent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)
                
                Spacer()
                
                if plinthCurrentPage == 2 {
                    MurkyPrimaryButton(quellTitle: "Get Started") {
                        vexHasCompleted = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct QuirkOnboardingPage1: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "repeat.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(VexColorPalette.quellAccent)
            
            Text("Plan B in 30 Seconds")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(VexColorPalette.wharfTextPrimary)
                .multilineTextAlignment(.center)
            
            Text("Weather ruins outdoor plans? Quickly find indoor alternatives tailored to your goals and available equipment.")
                .font(.system(size: 16))
                .foregroundColor(VexColorPalette.wharfTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding()
    }
}

struct TarnOnboardingPage2: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 80))
                .foregroundColor(VexColorPalette.quellAccent)
            
            Text("Smart Filters")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(VexColorPalette.wharfTextPrimary)
                .multilineTextAlignment(.center)
            
            Text("Filter by goals (END, STR, POW, MOB...), available equipment, and session length to match your needs instantly.")
                .font(.system(size: 16))
                .foregroundColor(VexColorPalette.wharfTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding()
    }
}

struct FizzOnboardingPage3: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(VexColorPalette.quellAccent)
            
            Text("Track & Stay Consistent")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(VexColorPalette.wharfTextPrimary)
                .multilineTextAlignment(.center)
            
            Text("Mark sessions as applied, add notes, and review your weekly progress to maintain momentum.")
                .font(.system(size: 16))
                .foregroundColor(VexColorPalette.wharfTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding()
    }
}

