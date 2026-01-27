import SwiftUI

struct TargetActualRingView: View {
    let data: CycleTargetActualRingData?
    
    var body: some View {
        VStack(spacing: 8) {
            if let data = data {
                ZStack {
                    Circle()
                        .stroke(AppTheme.dividerTint, lineWidth: 20)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(data.achievedRate) / 100.0)
                        .stroke(AppTheme.accentBright, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: data.achievedRate)
                    
                    VStack(spacing: 4) {
                        Text("–\(data.achievedRate)%")
                            .font(.title2.bold())
                            .foregroundColor(AppTheme.textPrimary)
                        if data.verdictText != "No workouts completed" {
                            Text(data.verdictText)
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.textSecondary)
                            .frame(width: 8, height: 8)
                        Text("Target –\(data.targetRate)%")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.accentBright)
                            .frame(width: 8, height: 8)
                        Text("Actual –\(data.achievedRate)%")
                            .font(.caption)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            } else {
                Text("No data yet")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(data.map { "Target minus \($0.targetRate) percent, Actual minus \($0.achievedRate) percent, \($0.verdictText)" } ?? "No data")
    }
}

struct WeeklyBarsView: View {
    let data: CycleBarsSnapshot?
    let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Reduction")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            if let data = data {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(data.records) { record in
                        VStack(spacing: 4) {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.dividerTint)
                                    .frame(width: 30, height: max(4, CGFloat(record.plannedTime) * 0.5))
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(record.hasCompletion ? AppTheme.accentBright : AppTheme.textSecondary.opacity(0.5))
                                    .frame(width: 30, height: max(4, CGFloat(record.easedTime) * 0.5))
                            }
                            
                            Text(dayNames[record.slotIndex])
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            if record.hasCompletion {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.successGreen)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(dayNames[record.slotIndex]), planned \(record.plannedTime) minutes, reduced to \(record.easedTime) minutes, \(record.hasCompletion ? "completed" : "not completed")")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
            } else {
                Text("Add workouts to see bars")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.glassCardBackground)
        .cornerRadius(12)
    }
}

struct CompletionBarsView: View {
    let data: CycleFinishBarsSnapshot?
    let dayNames = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if let data = data {
                ForEach(data.records) { record in
                    VStack(spacing: 4) {
                        Text("\(record.finishedCount)/\(record.totalCount)")
                            .font(.caption2)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppTheme.dividerTint)
                                .frame(width: 24, height: 40)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppTheme.successGreen)
                                .frame(width: 24, height: record.totalCount > 0 ? CGFloat(record.finishedCount) / CGFloat(record.totalCount) * 40 : 0)
                        }
                        
                        Text(dayNames[record.slotIndex])
                            .font(.caption2)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct TrendTimelineView: View {
    let data: TrendTimelineSnapshot?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Deload History")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            if let data = data, !data.markers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(data.markers) { marker in
                            VStack(spacing: 8) {
                                VStack(spacing: 4) {
                                    Text("–\(marker.achievedRate)%")
                                        .font(.title3.bold())
                                        .foregroundColor(AppTheme.accentBright)
                                    Text("Target –\(marker.targetRate)%")
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                .padding(12)
                                .background(AppTheme.glassCardBackground)
                                .cornerRadius(8)
                                
                                Text(marker.cycleKickoff, style: .date)
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Text(marker.verdictLabel)
                                    .font(.caption2)
                                    .foregroundColor(marker.verdictLabel == "On Target" ? AppTheme.successGreen : AppTheme.warnYellow)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(marker.verdictLabel == "On Target" ? AppTheme.successGreen.opacity(0.2) : AppTheme.warnYellow.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No deload weeks yet")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.glassCardBackground)
        .cornerRadius(12)
    }
}

