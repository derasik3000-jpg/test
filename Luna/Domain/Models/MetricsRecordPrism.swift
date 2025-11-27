import Foundation

struct MetricsRecordPrism: Identifiable, Codable {
    let chronoMark: Date
    let averagePhaseLength: Double
    let sessionCorrelationValue: Double
    
    var id: Date { chronoMark }
}

