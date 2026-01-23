import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @State private var showingSetup = false
    @State private var showingManageEnvelopes = false
    @State private var showingCloseWeek = false
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 0) {
                header
                
                ScrollView {
                    VStack(spacing: 20) {
                        weekInfoSection
                        envelopesSection
                        adviceSection
                    }
                    .padding()
                }
                
                amountDisplay
                numpad
            }
        }
        .onAppear {
            viewModel.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("EnvelopesUpdated"))) { _ in
            viewModel.load()
        }
        .sheet(isPresented: $showingSetup) {
            SetupView(viewModel: AppDependencies.shared.makeSetupViewModel())
        }
        .sheet(isPresented: $showingManageEnvelopes) {
            ManageEnvelopesView(viewModel: AppDependencies.shared.makeManageEnvelopesViewModel())
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                if let week = viewModel.week {
                    Text("Week \(week.isoWeek) · 3 Envelopes")
                        .font(Typography.h1())
                        .foregroundColor(ColorTheme.Text.inverse)
                }
            }
            
            Spacer()
            
            Menu {
                Button("Rename Envelopes") {
                    showingSetup = true
                }
                Button("Manage Envelopes") {
                    showingManageEnvelopes = true
                }
                Button("Close Week") {
                    showingCloseWeek = true
                }
                Button("Undo Last Entry") {
                    viewModel.undo()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 24))
                    .foregroundColor(ColorTheme.Text.inverse)
            }
        }
        .padding()
    }
    
    private var weekInfoSection: some View {
        VStack(spacing: 12) {
            if let snapshot = viewModel.skewSnapshot {
                HStack {
                    Text("Total: \(AppDependencies.shared.currencyFormatter.string(fromCents: snapshot.totalCents))")
                        .font(Typography.h2())
                        .foregroundColor(ColorTheme.Text.primary)
                    
                    Spacer()
                    
                    HStack {
                        Circle()
                            .fill(statusColor(snapshot.status))
                            .frame(width: 12, height: 12)
                        Text(statusLabel(snapshot.status))
                            .font(Typography.caption())
                            .foregroundColor(ColorTheme.Text.secondary)
                    }
                }
                .padding()
                .background(ColorTheme.Background.raised)
                .cornerRadius(12)
            }
        }
    }
    
    private var envelopesSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.envelopes.enumerated()), id: \.element.id) { index, envelope in
                if let snapshot = viewModel.skewSnapshot {
                    // Для совместимости с существующей системой, используем slot если есть
                    let slot = EnvelopeSlot(rawValue: index)
                    let delta = slot != nil ? (snapshot.deltasPct[slot!] ?? 0) : 0
                    
                    EnvelopeCardView(
                        envelope: envelope,
                        skewDelta: delta,
                        skewStatus: snapshot.status,
                        formatter: AppDependencies.shared.currencyFormatter
                    ) {
                        // Используем фактический index для добавления
                        if let validSlot = slot {
                            viewModel.add(to: validSlot)
                        } else {
                            viewModel.addToEnvelope(at: index)
                        }
                    }
                }
            }
        }
    }
    
    private var adviceSection: some View {
        Group {
            if let advice = viewModel.advice {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(ColorTheme.Balance.medium)
                    Text(advice)
                        .font(Typography.body())
                        .foregroundColor(ColorTheme.Text.primary)
                }
                .padding()
                .background(ColorTheme.Background.raised)
                .cornerRadius(12)
            }
        }
    }
    
    private var amountDisplay: some View {
        HStack {
            Text("Amount:")
                .font(Typography.body())
                .foregroundColor(ColorTheme.Text.inverse)
            
            Text(viewModel.currentAmount)
                .font(Typography.numbers())
                .foregroundColor(ColorTheme.Text.inverse)
            
            Spacer()
        }
        .padding()
        .background(ColorTheme.Background.sunken)
    }
    
    private var numpad: some View {
        NumpadView(
            onDigit: { digit in
                viewModel.addDigit(digit)
            },
            onDecimal: {
                viewModel.addDecimal()
            },
            onBackspace: {
                viewModel.backspace()
            }
        )
    }
    
    private func statusColor(_ status: SkewStatus) -> Color {
        switch status {
        case .ok: return ColorTheme.Balance.ok
        case .medium: return ColorTheme.Balance.medium
        case .bad: return ColorTheme.Balance.bad
        }
    }
    
    private func statusLabel(_ status: SkewStatus) -> String {
        switch status {
        case .ok: return "Balanced"
        case .medium: return "Moderate Skew"
        case .bad: return "High Skew"
        }
    }
}

