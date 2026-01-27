import UIKit

final class HapticFeedbackService: TouchFeedback {
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    func tapSelection() {
        selectionGenerator.selectionChanged()
    }
    
    func tapSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func tapWarning() {
        notificationGenerator.notificationOccurred(.warning)
    }
}

final class PlainTextExportService: PlainTextExporter {
    func buildExport(cycle: SpanCycleModel, digest: CycleDigest) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let startStr = dateFormatter.string(from: cycle.kickoff)
        let endStr = dateFormatter.string(from: cycle.closure)
        
        var output = "JoGit:EndurancePlanner — Deload Week \(startStr)–\(endStr)\n"
        output += "Rule: –\(cycle.blueprint.reductionRate)% (\(cycle.blueprint.cutbackStyle.displayName))\n"
        output += "Summary: Target –\(digest.targetRate)% • Actual –\(digest.achievedRate)% (\(digest.verdict == .acceptable ? "On Target" : digest.verdict == .shortfall ? "Shortfall" : "Over"))\n\n"
        
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        var grouped: [Int: [WorkoutEntryModel]] = [:]
        for workout in cycle.workouts {
            grouped[workout.slotIndex, default: []].append(workout)
        }
        
        for idx in 0..<7 {
            if let workouts = grouped[idx], !workouts.isEmpty {
                output += "\(dayNames[idx]):\n"
                for workout in workouts {
                    let check = workout.markedComplete ? "✓" : "☐"
                    output += "  \(workout.heading) \(workout.scheduledDuration)' → \(workout.adjustedDuration)' \(check)\n"
                }
            }
        }
        
        return output
    }
}

