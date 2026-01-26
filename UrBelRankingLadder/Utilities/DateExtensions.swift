import Foundation

extension String {
    static func dayIdentifierFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    static func todayIdentifier() -> String {
        return dayIdentifierFromDate(Date())
    }
}

extension Date {
    func currentTimeSlot() -> String {
        let hour = Calendar.current.component(.hour, from: self)
        
        if hour >= 5 && hour < 11 {
            return "morning"
        } else if hour >= 11 && hour < 17 {
            return "noon"
        } else if hour >= 17 && hour < 23 {
            return "evening"
        } else {
            return "snack"
        }
    }
}

