import SwiftUI

public struct SprocketJournalScreen: View {
    @StateObject private var quirkVM: TarnJournalViewModel
    
    public init(quirkVM: TarnJournalViewModel) {
        _quirkVM = StateObject(wrappedValue: quirkVM)
    }
    
    private var murkyDateFormatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return fmt
    }
    
    private var plinthWeekFormatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return fmt
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                SternGradientBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Journal")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(VexColorPalette.quellAccent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        
                        HStack {
                            Button(action: {
                                quirkVM.murkyShiftWeek(-1)
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VexColorPalette.quellAccent)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(VexColorPalette.fizzGlassCard)
                                    )
                            }
                            
                            Spacer()
                            
                            Text("Week of \(plinthWeekFormatter.string(from: quirkVM.quirkWeekStart))")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(VexColorPalette.wharfTextPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                quirkVM.murkyShiftWeek(1)
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VexColorPalette.quellAccent)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(VexColorPalette.fizzGlassCard)
                                    )
                            }
                        }
                        
                        if let goalsDonut = quirkVM.plinthGoalsDonut, goalsDonut.quellTotalApplied > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Goal Coverage")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VexColorPalette.wharfTextPrimary)
                                
                                VStack(spacing: 8) {
                                    ForEach(goalsDonut.fizzSlices) { slice in
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(Color(hex: slice.wharfColorHex))
                                                .frame(width: 12, height: 12)
                                            
                                            Text(slice.tarnLabel)
                                                .font(.system(size: 14))
                                                .foregroundColor(VexColorPalette.wharfTextPrimary)
                                            
                                            Spacer()
                                            
                                            Text("\(Int(slice.quellValue)) (\(Int((slice.fizzPercent ?? 0) * 100))%)")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(VexColorPalette.wharfTextSecondary)
                                        }
                                    }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(VexColorPalette.fizzGlassCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(VexColorPalette.vexGlassBorder, lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        if let equipDonut = quirkVM.brindleEquipDonut, equipDonut.quellTotalApplied > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Equipment Used")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VexColorPalette.wharfTextPrimary)
                                
                                VStack(spacing: 8) {
                                    ForEach(equipDonut.fizzSlices) { slice in
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(VexColorPalette.quellAccent)
                                                .frame(width: 12, height: 12)
                                            
                                            Text(slice.tarnLabel)
                                                .font(.system(size: 14))
                                                .foregroundColor(VexColorPalette.wharfTextPrimary)
                                            
                                            Spacer()
                                            
                                            Text("\(Int(slice.quellValue)) (\(Int((slice.fizzPercent ?? 0) * 100))%)")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(VexColorPalette.wharfTextSecondary)
                                        }
                                    }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(VexColorPalette.fizzGlassCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(VexColorPalette.vexGlassBorder, lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        if quirkVM.vexLogs.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 40))
                                    .foregroundColor(VexColorPalette.wharfTextSecondary)
                                
                                Text("No sessions this week")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(VexColorPalette.wharfTextSecondary)
                            }
                            .padding(.top, 40)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Sessions")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(VexColorPalette.wharfTextPrimary)
                                
                                ForEach(quirkVM.vexLogs) { log in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(murkyDateFormatter.string(from: log.plinthDate))
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(VexColorPalette.quellAccent)
                                            
                                            Spacer()
                                            
                                            ForEach(Array(log.quirkReplacement.wharfTags.prefix(2)), id: \.self) { tag in
                                                Text(tag.plinthLabel)
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundColor(VexColorPalette.brindleBrandDark)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 3)
                                                    .background(
                                                        Capsule()
                                                            .fill(VexColorPalette.plinthGoalColor(tag))
                                                    )
                                            }
                                        }
                                        
                                        Text(log.quirkReplacement.tarnBTitle)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(VexColorPalette.wharfTextPrimary)
                                            .lineLimit(2)
                                        
                                        if let note = log.tarnNote, !note.isEmpty {
                                            Text(note)
                                                .font(.system(size: 12))
                                                .foregroundColor(VexColorPalette.wharfTextSecondary)
                                                .lineLimit(2)
                                        }
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(VexColorPalette.fizzGlassCard)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(VexColorPalette.vexGlassBorder, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                quirkVM.vexReload()
            }
        }
    }
}

