import SwiftUI

struct GamingCalendarView: View {
    @StateObject private var viewModel: GamingCalendarViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var selectedPhotoRecord: GamingRecord?
    @State private var showingPhotoDetail: Bool = false
    
    init(viewModel: GamingCalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var plansForSelectedDate: [GamingPlan] {
        viewModel.plansForDate(selectedDate)
    }
    
    private var totalPlans: Int {
        viewModel.plans.count
    }
    
    private var plansThisMonth: Int {
        let calendar = Calendar.current
        return viewModel.plans.filter { plan in
            calendar.isDate(plan.planDate, equalTo: currentMonth, toGranularity: .month)
        }.count
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: GamingColorPalette.primaryPurple))
                    .scaleEffect(1.2)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        GamingScreenHeader("Calendar", subtitle: "Plan your games")
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        
                        // Stats Card
                        GamingGlassmorphismCard {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total Plans")
                                        .font(.system(size: 12))
                                        .foregroundColor(GamingColorPalette.textSecondary)
                                    Text("\(totalPlans)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(GamingColorPalette.textPrimary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("This Month")
                                        .font(.system(size: 12))
                                        .foregroundColor(GamingColorPalette.textSecondary)
                                    Text("\(plansThisMonth)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(GamingColorPalette.primaryPurple)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Calendar Card
                        HStack {
                            Spacer()
                            VStack(spacing: 0) {
                                // Month Header
                                HStack {
                                    Text(monthYearString)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(GamingColorPalette.textPrimary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation {
                                            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                                        }
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 16, weight: .light))
                                            .foregroundColor(GamingColorPalette.primaryPurple)
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                                        }
                                    }) {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .light))
                                            .foregroundColor(GamingColorPalette.primaryPurple)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .padding(.bottom, 12)
                                
                                // Days of week
                                HStack(spacing: 0) {
                                    ForEach(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], id: \.self) { day in
                                        Text(day)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                                
                                // Calendar Grid
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                                    ForEach(calendarDays, id: \.self) { date in
                                        if let date = date {
                                            CalendarDayView(
                                                date: date,
                                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                                hasPlan: hasPlan(for: date),
                                                isCurrentMonth: Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
                                            )
                                            .onTapGesture {
                                                selectedDate = date
                                            }
                                        } else {
                                            Color.clear
                                                .frame(height: 40)
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.bottom, 16)
                            }
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(GamingColorPalette.cardBackground)
                                    
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    GamingColorPalette.primaryPurple.opacity(0.5),
                                                    GamingColorPalette.primaryMagenta.opacity(0.4)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                        .blur(radius: 0.3)
                                }
                                .shadow(color: GamingColorPalette.primaryPurple.opacity(0.2), radius: 20, x: 0, y: 10)
                                .shadow(color: GamingColorPalette.primaryMagenta.opacity(0.1), radius: 15, x: 0, y: 5)
                            )
                            .frame(width: 340)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        // Photos for selected date
                        let photosForDate = viewModel.recordsWithPhotosForDate(selectedDate)
                        if !photosForDate.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "photo.stack")
                                        .font(.system(size: 18, weight: .light))
                                        .foregroundColor(GamingColorPalette.secondaryCyan)
                                    Text("Photos")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(GamingColorPalette.textPrimary)
                                    Spacer()
                                    Text("\(photosForDate.count)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(GamingColorPalette.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(GamingColorPalette.secondaryCyan.opacity(0.2))
                                        )
                                }
                                .padding(.horizontal, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(photosForDate, id: \.id) { record in
                                            if let imageData = record.imageData,
                                               let uiImage = UIImage(data: imageData) {
                                                Button(action: {
                                                    selectedPhotoRecord = record
                                                    showingPhotoDetail = true
                                                }) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(
                                                                    LinearGradient(
                                                                        gradient: Gradient(colors: [
                                                                            GamingColorPalette.primaryPurple.opacity(0.5),
                                                                            GamingColorPalette.primaryMagenta.opacity(0.3)
                                                                        ]),
                                                                        startPoint: .topLeading,
                                                                        endPoint: .bottomTrailing
                                                                    ),
                                                                    lineWidth: 2
                                                                )
                                                        )
                                                        .shadow(color: GamingColorPalette.primaryPurple.opacity(0.2), radius: 6, x: 0, y: 3)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        // Plans for selected date
                        if plansForSelectedDate.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 80, weight: .ultraLight))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                GamingColorPalette.primaryPurple.opacity(0.5),
                                                GamingColorPalette.primaryMagenta.opacity(0.3)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Text("No plans for this date")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                Text("Tap + to add a plan")
                                    .font(.system(size: 16))
                                    .foregroundColor(GamingColorPalette.textSecondary)
                            }
                            .padding(.vertical, 40)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                // Plans Header
                                HStack {
                                    Image(systemName: "list.bullet.rectangle")
                                        .font(.system(size: 18, weight: .light))
                                        .foregroundColor(GamingColorPalette.primaryPurple)
                                    Text(selectedDate, style: .date)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(GamingColorPalette.textPrimary)
                                    Spacer()
                                    Text("\(plansForSelectedDate.count)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(GamingColorPalette.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(GamingColorPalette.primaryPurple.opacity(0.2))
                                        )
                                }
                                .padding(.horizontal, 16)
                                
                                LazyVStack(spacing: 16) {
                                    ForEach(plansForSelectedDate, id: \.id) { plan in
                                        GamingGlassmorphismCard {
                                            VStack(alignment: .leading, spacing: 12) {
                                                HStack {
                                                    // Control buttons on the left
                                                    HStack(spacing: 8) {
                                                        Button(action: {
                                                            viewModel.startEdit(plan)
                                                        }) {
                                                            Image(systemName: "pencil")
                                                                .font(.system(size: 14, weight: .light))
                                                                .foregroundColor(GamingColorPalette.primaryPurple)
                                                                .frame(width: 32, height: 32)
                                                                .background(
                                                                    Circle()
                                                                        .fill(GamingColorPalette.primaryPurple.opacity(0.1))
                                                                )
                                                        }
                                                        
                                                        Button(action: {
                                                            try? viewModel.deletePlan(plan)
                                                        }) {
                                                            Image(systemName: "trash")
                                                                .font(.system(size: 14, weight: .light))
                                                                .foregroundColor(GamingColorPalette.primaryMagenta)
                                                                .frame(width: 32, height: 32)
                                                                .background(
                                                                    Circle()
                                                                        .fill(GamingColorPalette.primaryMagenta.opacity(0.1))
                                                                )
                                                        }
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    // Icon and type on the right
                                                    HStack(spacing: 6) {
                                                        Image(systemName: plan.planType == "program" ? "gamecontroller" : "lightbulb")
                                                            .font(.system(size: 16, weight: .light))
                                                            .foregroundColor(plan.planType == "program" ? GamingColorPalette.primaryPurple : GamingColorPalette.primaryMagenta)
                                                        Text(plan.planType == "program" ? "Program" : "Record")
                                                            .font(.system(size: 13, weight: .medium))
                                                            .foregroundColor(GamingColorPalette.textSecondary)
                                                    }
                                                }
                                                
                                                // Show thumbnail for records with photos
                                                if plan.planType == "record",
                                                   let record = viewModel.getRecord(for: plan),
                                                   let imageData = record.imageData,
                                                   let uiImage = UIImage(data: imageData) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 100)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                }
                                                
                                                // Show thumbnail for programs with photos
                                                if plan.planType == "program",
                                                   let program = viewModel.getProgram(for: plan),
                                                   let imageData = program.imageData,
                                                   let uiImage = UIImage(data: imageData) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 100)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                }
                                                
                                                Text(plan.planType == "program" ? viewModel.getProgramName(for: plan) : viewModel.getRecordText(for: plan))
                                                    .font(.system(size: 17, weight: .semibold))
                                                    .foregroundColor(GamingColorPalette.textPrimary)
                                                
                                                HStack {
                                                    Image(systemName: "clock")
                                                        .font(.system(size: 12, weight: .light))
                                                        .foregroundColor(GamingColorPalette.textSecondary)
                                                    Text(plan.planDate, style: .date)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(GamingColorPalette.textSecondary)
                                                    Text("•")
                                                        .foregroundColor(GamingColorPalette.textSecondary)
                                                    Text(plan.planDate, style: .time)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(GamingColorPalette.textSecondary)
                                                }
                                                
                                                if let note = plan.note {
                                                    Text(note)
                                                        .font(.system(size: 15))
                                                        .foregroundColor(GamingColorPalette.textSecondary)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            viewModel.loadPlans()
        }
        .onChange(of: selectedDate) { newDate in
            viewModel.selectedDate = newDate
        }
        .sheet(isPresented: $viewModel.showingAddModal) {
            GamingAddPlanView(viewModel: viewModel)
        }
        .overlay(alignment: .bottomTrailing) {
            GamingFABButton(icon: "plus") {
                viewModel.editingPlan = nil
                viewModel.showingAddModal = true
            }
            .padding(.trailing, 24)
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $showingPhotoDetail) {
            if let record = selectedPhotoRecord {
                GamingPhotoDetailView(record: record)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var calendarDays: [Date?] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstDayOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start else {
            return []
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Convert to Monday = 0 format
        let adjustedWeekday = (firstDayWeekday + 5) % 7
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 0..<adjustedWeekday {
            days.append(nil)
        }
        
        // Add all days of the month
        var currentDate = firstDayOfMonth
        while calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Fill remaining cells to complete the grid (6 rows * 7 days = 42 cells)
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasPlan(for date: Date) -> Bool {
        return viewModel.plans.contains { plan in
            Calendar.current.isDate(plan.planDate, inSameDayAs: date)
        }
    }
}

// MARK: - Calendar Day View

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasPlan: Bool
    let isCurrentMonth: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    GamingColorPalette.primaryPurple,
                                    GamingColorPalette.primaryMagenta
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 32, height: 32)
                }
                
                Text(dayNumber)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : (isCurrentMonth ? GamingColorPalette.textPrimary : GamingColorPalette.textSecondary))
            }
            
            if hasPlan {
                Circle()
                    .fill(GamingColorPalette.primaryMagenta)
                    .frame(width: 4, height: 4)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 50)
    }
}
