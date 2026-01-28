import SwiftUI

struct AxemobHistoryView: View {
    @StateObject private var degubaViewModel = CuqavuHistoryViewModel()
    @ObservedObject var evubewThemeManager = CuqavuThemeManager.shared
    @State private var cuqavuRefreshTrigger = UUID()
    @State private var ehonohShowShareSheet = false
    @State private var degubaShowExportOptions = false
    @State private var evubewShareItems: [Any] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок и кнопка экспорта
                        HStack {
                            Text("History")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(evubewThemeManager.degubaCurrentTheme.evubewPrimary)
                            
                            Spacer()
                            
                            Menu {
                                Button(action: {
                                    degubaViewModel.ehonohShareStatistics { items in
                                        DispatchQueue.main.async {
                                            evubewShareItems = items
                                            if !items.isEmpty {
                                                ehonohShowShareSheet = true
                                            }
                                        }
                                    }
                                }) {
                                    Label("Share Statistics", systemImage: "square.and.arrow.up")
                                }
                                
                                Button(action: {
                                    degubaViewModel.evubewExportToCSV { url in
                                        if let url = url {
                                            evubewShareItems = [url]
                                            ehonohShowShareSheet = true
                                        }
                                    }
                                }) {
                                    Label("Export as CSV", systemImage: "doc.text")
                                }
                                
                                Button(action: {
                                    degubaViewModel.degubaExportToJSON { url in
                                        if let url = url {
                                            evubewShareItems = [url]
                                            ehonohShowShareSheet = true
                                        }
                                    }
                                }) {
                                    Label("Export as JSON", systemImage: "doc.badge.gearshape")
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundColor(evubewThemeManager.degubaCurrentTheme.evubewPrimary)
                                    .padding(12)
                                    .background(evubewThemeManager.degubaCurrentTheme.degubaCardBackground)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        EvubewFilterSection(
                            selectedFilter: $degubaViewModel.degubaFilterType,
                            onFilterChange: { type in
                                degubaViewModel.cuqavuApplyFilter(type: type)
                            }
                        )
                        .padding(.horizontal)
                        
                        if degubaViewModel.degubaFilterType == nil && !degubaViewModel.axemobSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "chart.pie.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(evubewThemeManager.degubaCurrentTheme.evubewPrimary)
                                    
                                    Text("Activity Distribution")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(evubewThemeManager.degubaCurrentTheme.evubewPrimary)
                                }
                                .padding(.horizontal)
                                
                                EvubewInteractivePieChart(cuqavuData: degubaViewModel.cuqavuGetTypeDistribution())
                                    .padding(20)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        ZStack {
                                            // Основной фон
                                            RoundedRectangle(cornerRadius: 24)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 0.2, green: 0.2, blue: 0.22),
                                                            Color(red: 0.18, green: 0.18, blue: 0.20)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                            
                                            // Градиентный оверлей
                                            RoundedRectangle(cornerRadius: 24)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            evubewThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.15),
                                                            evubewThemeManager.degubaCurrentTheme.cuqavuSecondary.opacity(0.08),
                                                            Color.clear
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        evubewThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.4),
                                                        evubewThemeManager.degubaCurrentTheme.cuqavuSecondary.opacity(0.3),
                                                        evubewThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.2)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 6)
                                    .shadow(color: evubewThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.25), radius: 12, x: 0, y: 4)
                                    .padding(.horizontal)
                            }
                        }
                        
                        if !degubaViewModel.ehonohSummaries.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(evubewThemeManager.degubaCurrentTheme.evubewPrimary)
                                    
                                    Text("Productivity Timeline")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(evubewThemeManager.degubaCurrentTheme.evubewPrimary)
                                }
                                .padding(.horizontal)
                                
                                EhonohTimelineChart(axemobSummaries: degubaViewModel.ehonohSummaries)
                                    .frame(height: 220)
                                    .padding(20)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        ZStack {
                                            // Основной фон
                                            RoundedRectangle(cornerRadius: 24)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 0.2, green: 0.2, blue: 0.22),
                                                            Color(red: 0.18, green: 0.18, blue: 0.20)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                            
                                            // Градиентный оверлей
                                            RoundedRectangle(cornerRadius: 24)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            evubewThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.15),
                                                            evubewThemeManager.degubaCurrentTheme.cuqavuSecondary.opacity(0.08),
                                                            Color.clear
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        evubewThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.4),
                                                        evubewThemeManager.degubaCurrentTheme.cuqavuSecondary.opacity(0.3),
                                                        evubewThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.2)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 6)
                                    .shadow(color: evubewThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.25), radius: 12, x: 0, y: 4)
                                    .padding(.horizontal)
                            }
                        }
                        
            CuqavuSessionsListSection(
                sessions: degubaViewModel.axemobSessions,
                groupedSessions: degubaViewModel.degubaGroupedSessions(),
                selectedSession: $degubaViewModel.cuqavuSelectedSession,
                cuqavuRefreshTrigger: cuqavuRefreshTrigger
            )
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $degubaViewModel.cuqavuSelectedSession) { session in
                DegubaSessionDetailView(session: session)
            }
            .onAppear {
                degubaViewModel.ehonohLoadData()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TimeUnitsChanged"))) { _ in
                cuqavuRefreshTrigger = UUID()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SessionsUpdated"))) { _ in
                degubaViewModel.ehonohLoadData()
                cuqavuRefreshTrigger = UUID()
            }
            .sheet(isPresented: $ehonohShowShareSheet) {
                ShareSheet(items: evubewShareItems.isEmpty ? ["No data available"] : evubewShareItems)
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Обрабатываем элементы для шаринга
        var shareItems: [Any] = []
        
        for item in items {
            if let string = item as? String, !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                shareItems.append(string)
            } else if let url = item as? URL {
                shareItems.append(url)
            }
        }
        
        // Если нет валидных элементов, добавляем сообщение по умолчанию
        if shareItems.isEmpty {
            shareItems.append("No data available to share")
        }
        
        let controller = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        
        // Настройка для iPad
        if let popover = controller.popoverPresentationController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                popover.sourceView = rootViewController.view
                popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // UIActivityViewController не поддерживает обновление элементов после создания
    }
}

struct EvubewFilterSection: View {
    @Binding var selectedFilter: EhonohSessionType?
    let onFilterChange: (EhonohSessionType?) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter by Type")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = nil
                            onFilterChange(nil)
                        }
                    }) {
                        Text("All")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedFilter == nil ? .white : CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedFilter == nil ? CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary : CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
                            .cornerRadius(20)
                    }
                    
                    ForEach(EhonohSessionType.allCases, id: \.rawValue) { type in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedFilter = type
                                onFilterChange(type)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: type.evubewIcon)
                                    .font(.system(size: 12))
                                
                                Text(type.degubaTitle)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(selectedFilter == type ? .white : CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedFilter == type ? type.cuqavuColor : CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }
}

struct CuqavuSessionsListSection: View {
    let sessions: [AxemobSessionModel]
    let groupedSessions: [Date: [AxemobSessionModel]]
    @Binding var selectedSession: AxemobSessionModel?
    let cuqavuRefreshTrigger: UUID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sessions")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                .padding(.horizontal)
            
            if sessions.isEmpty {
                DegubaHistoryEmptyStateView()
                    .padding(.horizontal)
            } else {
                ForEach(groupedSessions.keys.sorted(by: >), id: \.self) { date in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(ehonohFormatDate(date))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            .padding(.horizontal)
                        
                        ForEach(groupedSessions[date] ?? []) { session in
                            Button(action: {
                                selectedSession = session
                            }) {
                                AxemobHistorySessionRow(session: session, refreshTrigger: cuqavuRefreshTrigger)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
    
    private func ehonohFormatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct AxemobHistorySessionRow: View {
    let session: AxemobSessionModel
    let refreshTrigger: UUID
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: session.type.evubewIcon)
                        .font(.system(size: 16))
                        .foregroundColor(session.type.cuqavuColor)
                    
                    Text(session.type.degubaTitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(session.type.cuqavuColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(session.type.cuqavuColor.opacity(0.15))
                        .cornerRadius(8)
                }
                
                Text(session.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                HStack(spacing: 16) {
                    Label(AxemobTimeFormatter.shared.evubewFormatMinutes(session.durationMin), systemImage: "clock.fill")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        .id(refreshTrigger)
                    
                    Label("Energy: \(session.energyLevel)", systemImage: "bolt.fill")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    
                    Label("Mood: \(session.mood)", systemImage: "face.smiling")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.6))
        }
        .padding(16)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.08),
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
                .stroke(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 2)
    }
}

struct DegubaHistoryEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No sessions found")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            
            Text("Start tracking your productivity to see your history")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

