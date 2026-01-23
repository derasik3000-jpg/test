import Foundation

public struct VylorFormatters {
    public static func gyrexMMSS(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
    
    public static func gyrexPercent(_ value: Double?) -> String {
        guard let value = value else { return "—" }
        return String(format: "%.0f%%", value * 100)
    }
    
    public static func gyrexPace(_ value: Double?) -> String {
        guard let value = value else { return "—" }
        return String(format: "%.1f /min", value)
    }
    
    public static func gyrexAttemptsFraction(_ current: Int, _ target: Int) -> String {
        return "\(current) / \(target)"
    }
    
    public static func gyrexDuration(_ minutes: Int) -> String {
        return "\(minutes) min"
    }
    
    public static func gyrexDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

