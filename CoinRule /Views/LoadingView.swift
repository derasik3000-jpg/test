//
//  LoadingView.swift
//  Coin Rule
//
//  Loading screen shown until all flow checks complete.
//

import SwiftUI

struct LoadingView: View {
    @State private var progress: CGFloat = 0
    @State private var animated = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack(spacing: 32) {
                ZStack {
                    sunMoonView
                    cloudsView
                }
                .frame(height: 140)
                Text("Coin Rule")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(uiColor: .pulsePrimary))
                Text("Preparing your adventure...")
                    .font(.subheadline)
                    .foregroundColor(Color(uiColor: .pulseTextSecondary))
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(Color(uiColor: .pulsePrimary))
                    .frame(maxWidth: 260)
                    .padding(.top, 8)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                progress = 0.7
            }
        }
    }
    
    private var sunMoonView: some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: .pulsePrimary).opacity(0.3))
                .frame(width: 80, height: 80)
                .scaleEffect(animated ? 1.1 : 1.0)
            Circle()
                .stroke(Color(uiColor: .pulsePrimary), lineWidth: 3)
                .frame(width: 60, height: 60)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { animated = true }
        }
    }
    
    private var cloudsView: some View {
        HStack(spacing: 24) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 24, height: 24)
            }
        }
        .offset(y: 30)
    }
}

#Preview {
    LoadingView()
}
