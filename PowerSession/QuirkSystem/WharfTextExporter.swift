import Foundation

public protocol WharfTextExporter {
    func sternExportReplacement(_ r: FizzReplacementModel, variant: WharfVariantModel?) -> String
    func plinthExportWeekSummary(
        weekStart: Date,
        goals: SternGoalCoverageDonutData,
        equips: PlinthEquipmentUsageDonutData,
        durations: BrindleDurationBarsData
    ) -> String
}

public final class QuellDefaultTextExporter: WharfTextExporter {
    private let murkyDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt
    }()
    
    public init() {}
    
    public func sternExportReplacement(_ r: FizzReplacementModel, variant: WharfVariantModel?) -> String {
        var text = """
        CeDax:PowerSession – Replacement
        
        If: \(r.tarnATitle)
        Do: \(r.tarnBTitle) (\(r.quellEquiv.plinthDisplayText))
        
        Goals: \(r.wharfTags.map { $0.plinthLabel }.joined(separator: ", "))
        Difficulty: \(r.brindleDifficulty.tarnLabel)
        
        Variants:
        """
        
        for v in r.quirkVariants {
            text += "\n  • \(v.tarnTitle)"
            if let detail = v.tarnDetail {
                text += " – \(detail)"
            }
        }
        
        if let selected = variant {
            text += "\n\nSelected: \(selected.tarnTitle)"
        }
        
        return text
    }
    
    public func plinthExportWeekSummary(
        weekStart: Date,
        goals: SternGoalCoverageDonutData,
        equips: PlinthEquipmentUsageDonutData,
        durations: BrindleDurationBarsData
    ) -> String {
        let weekStr = murkyDateFormatter.string(from: weekStart)
        
        var text = """
        CeDax:PowerSession – Week Summary
        Week: \(weekStr)
        Total Sessions: \(goals.quellTotalApplied)
        
        Goal Coverage:
        """
        
        for slice in goals.fizzSlices.sorted(by: { $0.quellValue > $1.quellValue }) {
            let pct = Int((slice.fizzPercent ?? 0) * 100)
            text += "\n  \(slice.tarnLabel): \(Int(slice.quellValue)) (\(pct)%)"
        }
        
        text += "\n\nEquipment Used:"
        for slice in equips.fizzSlices.sorted(by: { $0.quellValue > $1.quellValue }) {
            let pct = Int((slice.fizzPercent ?? 0) * 100)
            text += "\n  \(slice.tarnLabel): \(Int(slice.quellValue)) (\(pct)%)"
        }
        
        return text
    }
}

