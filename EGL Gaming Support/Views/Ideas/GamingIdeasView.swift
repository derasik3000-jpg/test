import SwiftUI

struct GamingIdeasView: View {
    @StateObject private var viewModel: GamingIdeasViewModel
    @State private var searchText: String = ""
    @State private var selectedPhotoRecord: GamingRecord?
    @State private var showingPhotoDetail: Bool = false
    
    init(viewModel: GamingIdeasViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var groupedRecords: [String: [GamingRecord]] {
        let calendar = Calendar.current
        let now = Date()
        
        var groups: [String: [GamingRecord]] = [:]
        
        for record in viewModel.records {
            guard let date = record.recordDate else {
                groups["Other", default: []].append(record)
                continue
            }
            
            if calendar.isDateInToday(date) {
                groups["Today", default: []].append(record)
            } else if calendar.isDateInYesterday(date) {
                groups["Yesterday", default: []].append(record)
            } else if calendar.dateInterval(of: .weekOfYear, for: now)?.contains(date) == true {
                groups["This Week", default: []].append(record)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                let key = formatter.string(from: date)
                groups[key, default: []].append(record)
            }
        }
        
        return groups
    }
    
    private var sortedGroupKeys: [String] {
        let order = ["Today", "Yesterday", "This Week"]
        let keys = groupedRecords.keys.sorted { key1, key2 in
            if let index1 = order.firstIndex(of: key1), let index2 = order.firstIndex(of: key2) {
                return index1 < index2
            }
            if order.contains(key1) { return true }
            if order.contains(key2) { return false }
            return key1 > key2
        }
        return keys
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: GamingColorPalette.primaryPurple))
                    .scaleEffect(1.2)
            } else if viewModel.records.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "lightbulb")
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
                    Text("No ideas yet")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(GamingColorPalette.textPrimary)
                    Text("Tap + to add your first idea")
                        .font(.system(size: 16))
                        .foregroundColor(GamingColorPalette.textSecondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        GamingScreenHeader("Ideas", subtitle: "Your thoughts & plans")
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        
                        // Stats Card
                        GamingGlassmorphismCard {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total Ideas")
                                        .font(.system(size: 12))
                                        .foregroundColor(GamingColorPalette.textSecondary)
                                    Text("\(viewModel.records.count)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(GamingColorPalette.textPrimary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    if let latestRecord = viewModel.records.first {
                                        Text("Latest")
                                            .font(.system(size: 12))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        if let date = latestRecord.recordDate {
                                            Text(date, style: .relative)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(GamingColorPalette.primaryPurple)
                                        } else {
                                            Text("No date")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(GamingColorPalette.textSecondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Search Bar
                        GamingSearchBarView(text: $searchText, placeholder: "Search ideas...")
                            .padding(.horizontal, 16)
                        
                        // Grouped Records
                        LazyVStack(spacing: 20) {
                            ForEach(sortedGroupKeys, id: \.self) { groupKey in
                                if let records = groupedRecords[groupKey] {
                                    VStack(alignment: .leading, spacing: 12) {
                                        // Group Header
                                        HStack {
                                            Image(systemName: groupKey == "Today" ? "sparkles" : 
                                                  groupKey == "Yesterday" ? "clock" : 
                                                  groupKey == "This Week" ? "calendar" : "calendar.badge.clock")
                                                .font(.system(size: 16, weight: .light))
                                                .foregroundColor(groupKey == "Today" ? GamingColorPalette.secondaryCyan : 
                                                                 groupKey == "Yesterday" ? GamingColorPalette.primaryPurple :
                                                                 GamingColorPalette.primaryMagenta)
                                            Text(groupKey)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(GamingColorPalette.textPrimary)
                                            Spacer()
                                            Text("\(records.count)")
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
                                        
                                        // Records in Group
                                        ForEach(records, id: \.id) { record in
                                            GamingGlassmorphismCard {
                                                VStack(alignment: .leading, spacing: 12) {
                                                    HStack {
                                                        // Control buttons on the left
                                                        HStack(spacing: 8) {
                                                            Button(action: {
                                                                viewModel.startEdit(record)
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
                                                                try? viewModel.deleteRecord(record)
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
                                                        
                                                        // Idea icon on the right
                                                        Image(systemName: "lightbulb")
                                                            .font(.system(size: 18, weight: .light))
                                                            .foregroundColor(GamingColorPalette.primaryMagenta)
                                                            .frame(width: 36, height: 36)
                                                            .background(
                                                                Circle()
                                                                    .fill(GamingColorPalette.primaryMagenta.opacity(0.15))
                                                            )
                                                    }
                                                    
                                                    // Show image if available
                                                    if let imageData = record.imageData,
                                                       let uiImage = UIImage(data: imageData) {
                                                        Button(action: {
                                                            selectedPhotoRecord = record
                                                            showingPhotoDetail = true
                                                        }) {
                                                            Image(uiImage: uiImage)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(maxWidth: .infinity)
                                                                .frame(height: 150)
                                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        }
                                                    }
                                                    
                                                    Text(record.text)
                                                        .font(.system(size: 16, weight: .medium))
                                                        .foregroundColor(GamingColorPalette.textPrimary)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .lineSpacing(4)
                                                    
                                                    if let date = record.recordDate {
                                                        HStack(spacing: 6) {
                                                            Image(systemName: "clock")
                                                                .font(.system(size: 11, weight: .light))
                                                                .foregroundColor(GamingColorPalette.textSecondary)
                                                            Text(date, style: .date)
                                                                .font(.system(size: 12))
                                                                .foregroundColor(GamingColorPalette.textSecondary)
                                                            Text("•")
                                                                .foregroundColor(GamingColorPalette.textSecondary)
                                                            Text(date, style: .time)
                                                                .font(.system(size: 12))
                                                                .foregroundColor(GamingColorPalette.textSecondary)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadRecords()
        }
        .onChange(of: searchText) { newValue in
            viewModel.searchText = newValue
            viewModel.loadRecords()
        }
        .sheet(isPresented: $viewModel.showingAddModal) {
            GamingAddRecordView(viewModel: viewModel)
        }
        .overlay(alignment: .bottomTrailing) {
            GamingFABButton(icon: "plus") {
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
}
