import SwiftUI

struct OnboardingWelcomeScreen: View {
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                Text("TheBrozone:GentleDen")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                Text("Visual Progress of Life")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AuroraThemeColors.lightGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: onContinue) {
                    Text("Start")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AuroraThemeColors.deepCharcoal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AuroraThemeColors.pureWhite)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
            .padding(.top, 60)
        }
    }
}

struct OnboardingSpheresScreen: View {
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 16) {
                    SphereIconView(title: "Home", icon: "house.fill")
                    SphereIconView(title: "Style", icon: "theatermasks.fill")
                    SphereIconView(title: "Health", icon: "heart.fill")
                    SphereIconView(title: "Hobby", icon: "paintbrush.fill")
                }
                
                Text("Collect improvements by spheres - like personal albums")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AuroraThemeColors.lightGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                
                Spacer()
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AuroraThemeColors.deepCharcoal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AuroraThemeColors.pureWhite)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
            .padding(.top, 60)
        }
    }
}

struct SphereIconView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AuroraThemeColors.pureWhite)
                .frame(width: 50, height: 50)
                .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                .cornerRadius(12)
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AuroraThemeColors.pureWhite)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

struct OnboardingBeforeAfterScreen: View {
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AuroraThemeColors.deepCharcoal.opacity(0.6))
                        .frame(width: 140, height: 180)
                        .overlay(
                            Text("Before")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AuroraThemeColors.lightGray)
                        )
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AuroraThemeColors.pureWhite)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AuroraThemeColors.deepCharcoal.opacity(0.6))
                        .frame(width: 140, height: 180)
                        .overlay(
                            Text("After")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AuroraThemeColors.lightGray)
                        )
                }
                
                Text("Fix changes not only body, but environment and habits")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AuroraThemeColors.lightGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                
                Spacer()
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AuroraThemeColors.deepCharcoal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AuroraThemeColors.pureWhite)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
            .padding(.top, 60)
        }
    }
}

struct OnboardingRadarScreen: View {
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                Circle()
                    .strokeBorder(AuroraThemeColors.lightGray.opacity(0.3), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 48))
                                .foregroundColor(AuroraThemeColors.pureWhite)
                            Text("Radar")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AuroraThemeColors.lightGray)
                        }
                    )
                
                Text("One glance - and you see balance of improvements")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AuroraThemeColors.lightGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                
                Spacer()
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AuroraThemeColors.deepCharcoal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AuroraThemeColors.pureWhite)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
            .padding(.top, 60)
        }
    }
}

struct OnboardingPhotoAccessScreen: View {
    let onRequestAccess: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 64))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                
                Text("Access to Photos")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                
                Text("We need access to save your progress photos locally")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AuroraThemeColors.lightGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: onRequestAccess) {
                        Text("Allow Photo Access")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AuroraThemeColors.deepCharcoal)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AuroraThemeColors.pureWhite)
                            .cornerRadius(12)
                    }
                    
                    Button(action: onSkip) {
                        Text("Continue Without Access")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AuroraThemeColors.lightGray)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
            .padding(.top, 60)
        }
    }
}

struct OnboardingSetupSpheresScreen: View {
    let onUseDefaults: () -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                
                Text("Initial Setup")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                
                Text("We created 4 basic spheres for you")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AuroraThemeColors.lightGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: onUseDefaults) {
                    Text("Use Default Spheres")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AuroraThemeColors.deepCharcoal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AuroraThemeColors.pureWhite)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
            .padding(.top, 60)
        }
    }
}

struct OnboardingFinishScreen: View {
    let onFinish: () -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                
                Text("Ready")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                
                Text("Start with your first improvement")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AuroraThemeColors.lightGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: onFinish) {
                    Text("Add First Photo")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AuroraThemeColors.deepCharcoal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AuroraThemeColors.pureWhite)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
            .padding(.top, 60)
        }
    }
}

