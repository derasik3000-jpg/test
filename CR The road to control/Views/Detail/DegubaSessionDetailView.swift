import SwiftUI
import CoreData

struct DegubaSessionDetailView: View {
    let session: AxemobSessionModel
    @Environment(\.dismiss) private var evubewDismiss
    @State private var cuqavuAnimationProgress: CGFloat = 0
    @ObservedObject var axemobThemeManager = CuqavuThemeManager.shared
    @State private var ehonohShowDeleteAlert = false
    @State private var degubaShowEditSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок и кнопка Done
                        HStack {
                            Text("Session Detail")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(axemobThemeManager.degubaCurrentTheme.evubewPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                evubewDismiss()
                            }) {
                                Text("Done")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [axemobThemeManager.degubaCurrentTheme.evubewPrimary, axemobThemeManager.degubaCurrentTheme.cuqavuSecondary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(20)
                                    .shadow(color: axemobThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.4), radius: 8, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        AxemobHeaderSection(session: session)
                            .padding(.horizontal)
                            .opacity(Double(cuqavuAnimationProgress))
                        
                        EhonohStatsSection(session: session)
                            .padding(.horizontal)
                            .opacity(Double(cuqavuAnimationProgress))
                        
                        CuqavuTimelineSection(session: session)
                            .padding(.horizontal)
                            .opacity(Double(cuqavuAnimationProgress))
                        
                        DegubaMetricsChartSection(session: session)
                            .padding(.horizontal)
                            .opacity(Double(cuqavuAnimationProgress))
                        
                        if let note = session.note, !note.isEmpty {
                            EvubewNotesSection(note: note)
                                .padding(.horizontal)
                                .opacity(Double(cuqavuAnimationProgress))
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                degubaShowEditSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Text("Edit")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [axemobThemeManager.degubaCurrentTheme.evubewPrimary, axemobThemeManager.degubaCurrentTheme.cuqavuSecondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                ehonohShowDeleteAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Text("Delete")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        .opacity(Double(cuqavuAnimationProgress))
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
            .alert("Delete Session", isPresented: $ehonohShowDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    cuqavuDeleteSession()
                }
            } message: {
                Text("Are you sure you want to delete this session? This action cannot be undone.")
            }
            .sheet(isPresented: $degubaShowEditSheet) {
                EvubewEditSessionView(session: session, onDismiss: {
                    evubewDismiss()
                })
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    cuqavuAnimationProgress = 1.0
                }
            }
        }
    }
    
    private func cuqavuDeleteSession() {
        let context = DegubaPersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<EvubewProductivitySession> = EvubewProductivitySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        
        do {
            let sessions = try context.fetch(fetchRequest)
            if let sessionToDelete = sessions.first {
                context.delete(sessionToDelete)
                try context.save()
                
                let calculateSummary = DegubaCalculateSummaryUseCase(context: context)
                _ = calculateSummary.evubewExecuteForDate(session.createdAt)
                
                NotificationCenter.default.post(name: NSNotification.Name("SessionsUpdated"), object: nil)
            }
        } catch {
            print("Error deleting session: \(error)")
        }
        
        evubewDismiss()
    }
}

struct AxemobHeaderSection: View {
    let session: AxemobSessionModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: session.type.evubewIcon)
                    .font(.system(size: 40))
                    .foregroundColor(session.type.cuqavuColor)
                    .frame(width: 80, height: 80)
                    .background(session.type.cuqavuColor.opacity(0.15))
                    .cornerRadius(20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.type.degubaTitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(session.type.cuqavuColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(session.type.cuqavuColor.opacity(0.15))
                        .cornerRadius(8)
                    
                    Text(session.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.1),
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
                            CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                            CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

struct EhonohStatsSection: View {
    let session: AxemobSessionModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                DegubaStatCard(
                    icon: "clock.fill",
                    title: "Duration",
                    value: AxemobTimeFormatter.shared.evubewFormatMinutes(session.durationMin),
                    unit: "",
                    color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary
                )
                
                DegubaStatCard(
                    icon: "bolt.fill",
                    title: "Energy",
                    value: "\(session.energyLevel)",
                    unit: "/10",
                    color: CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary
                )
            }
            
            HStack(spacing: 16) {
                DegubaStatCard(
                    icon: "face.smiling",
                    title: "Mood",
                    value: "\(session.mood)",
                    unit: "/5",
                    color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary
                )
                
                DegubaStatCard(
                    icon: "star.fill",
                    title: "Efficiency",
                    value: String(format: "%.1f", session.degubaEfficiencyScore),
                    unit: "",
                    color: CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary
                )
            }
        }
    }
}

struct DegubaStatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                    }
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        color.opacity(0.1),
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
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 2)
        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 1)
    }
}

struct CuqavuTimelineSection: View {
    let session: AxemobSessionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Timeline")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "clock.arrow.2.circlepath")
                        .font(.system(size: 16))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Created")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                        
                        Text(axemobFormatDate(session.createdAt))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3))
                
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start Time")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                        
                        Text(axemobFormatTime(session.startTime))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3))
                
                HStack {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("End Time")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                        
                        Text(axemobFormatTime(session.endTime))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.1),
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
                            CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                            CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2), radius: 8, x: 0, y: 2)
    }
    
    private func axemobFormatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func axemobFormatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DegubaMetricsChartSection: View {
    let session: AxemobSessionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Metrics")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            
            CuqavuBarChart(
                degubaDataPoints: [(label: "Session", energy: Double(session.energyLevel), mood: Double(session.mood))],
                evubewMaxValue: 10
            )
            .frame(height: 180)
            
            HStack(spacing: 20) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary, CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 12, height: 12)
                    
                    Text("Energy")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary, CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 12, height: 12)
                    
                    Text("Mood")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.1),
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
                            CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                            CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

struct EvubewNotesSection: View {
    let note: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 16))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Text("Notes")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Spacer()
            }
            
            Text(note)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.1),
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
                            CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                            CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}


