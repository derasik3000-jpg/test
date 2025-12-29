import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuroraThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Storage")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AuroraThemeColors.pureWhite)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Storage Used")
                                        .font(.system(size: 16))
                                        .foregroundColor(AuroraThemeColors.pureWhite)
                                    
                                    Text(viewModel.storageUsageText)
                                        .font(.system(size: 14))
                                        .foregroundColor(AuroraThemeColors.lightGray)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .prismaticCard()
                            
                            Button {
                                Task {
                                    await viewModel.purgeThumbnailCache()
                                }
                            } label: {
                                HStack {
                                    Text("Clear Thumbnails Cache")
                                        .font(.system(size: 16))
                                        .foregroundColor(AuroraThemeColors.pureWhite)
                                    Spacer()
                                    Image(systemName: "trash")
                                        .foregroundColor(AuroraThemeColors.lightGray)
                                }
                                .padding()
                                .prismaticCard()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Data Management")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AuroraThemeColors.pureWhite)
                            
                            Button {
                                viewModel.presentResetConfirm = true
                            } label: {
                                HStack {
                                    Text("Reset All Data")
                                        .font(.system(size: 16))
                                        .foregroundColor(.red)
                                    Spacer()
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AuroraThemeColors.pureWhite)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "App Name", value: "TheBrozone:GentleDen")
                                InfoRow(title: "Version", value: "1.0.0")
                                InfoRow(title: "iOS Version", value: "16.0+")
                            }
                            .padding()
                            .prismaticCard()
                        }
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding()
                                .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                                .cornerRadius(8)
                        }
                        
                        if let success = viewModel.successMessage {
                            Text(success)
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                                .padding()
                                .background(AuroraThemeColors.deepCharcoal.opacity(0.6))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.refreshSettingsDiagnostics()
            }
            .alert("Reset All Data", isPresented: $viewModel.presentResetConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    Task {
                        await viewModel.wipeAllUserData()
                    }
                }
            } message: {
                Text("This will delete all your progress photos and data. This action cannot be undone.")
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(AuroraThemeColors.lightGray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AuroraThemeColors.pureWhite)
        }
    }
}

