import Foundation

public struct DailyMetricsDTO: Identifiable, Hashable, Codable {
    public var id: String { dayIdentifier }
    public let dayIdentifier: String
    public let morningMetric: Int
    public let noonMetric: Int
    public let eveningMetric: Int
    public let snackMetric: Int
    public let averageMetric: Int
    public let hasGoldStatus: Bool
    public let exportTimestamp: Date?
    
    public init(dayIdentifier: String, morningMetric: Int, noonMetric: Int, eveningMetric: Int, snackMetric: Int, averageMetric: Int, hasGoldStatus: Bool, exportTimestamp: Date?) {
        self.dayIdentifier = dayIdentifier
        self.morningMetric = morningMetric
        self.noonMetric = noonMetric
        self.eveningMetric = eveningMetric
        self.snackMetric = snackMetric
        self.averageMetric = averageMetric
        self.hasGoldStatus = hasGoldStatus
        self.exportTimestamp = exportTimestamp
    }
}

