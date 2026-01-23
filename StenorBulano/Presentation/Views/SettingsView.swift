import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @State private var showingPrivacyPolicy = false
    @State private var showingOnboarding = false
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 0) {
                header
                
                ScrollView {
                    VStack(spacing: 24) {
                        boundaryHourSection
                        actionsSection
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.load()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView(isPresented: $showingOnboarding)
        }
    }
    
    private var header: some View {
        HStack {
            Text("Settings")
                .font(Typography.h1())
                .foregroundColor(ColorTheme.Text.inverse)
            Spacer()
        }
        .padding()
    }
    
    private var boundaryHourSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Day Boundary Hour")
                .font(Typography.h2())
                .foregroundColor(ColorTheme.Text.primary)
            
            Text("Entries before this hour count as previous day")
                .font(Typography.caption())
                .foregroundColor(ColorTheme.Text.secondary)
            
            Stepper("\(viewModel.boundaryHour):00", value: $viewModel.boundaryHour, in: 0...6)
                .font(Typography.body())
                .foregroundColor(ColorTheme.Text.primary)
                .onChange(of: viewModel.boundaryHour) { _ in
                    viewModel.save()
                }
        }
        .padding()
        .background(ColorTheme.Background.raised)
        .cornerRadius(16)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingOnboarding = true
            }) {
                HStack {
                    Image(systemName: "book.fill")
                    Text("View Onboarding")
                        .font(Typography.body())
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(ColorTheme.Text.primary)
                .padding()
                .background(ColorTheme.Background.raised)
                .cornerRadius(12)
            }
            
            Button(action: {
                showingPrivacyPolicy = true
            }) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                    Text("Privacy Policy")
                        .font(Typography.body())
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(ColorTheme.Text.primary)
                .padding()
                .background(ColorTheme.Background.raised)
                .cornerRadius(12)
            }
        }
    }
}

