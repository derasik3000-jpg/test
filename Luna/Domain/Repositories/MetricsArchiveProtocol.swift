import Foundation

protocol MetricsArchiveProtocol {
    func retrieveMetrics() -> [MetricsRecordPrism]
    func appendMetric(_ prism: MetricsRecordPrism)
}

