import Foundation

protocol CurrencyFormatter {
    func string(fromCents: Int64) -> String
    func cents(fromString: String) -> Int64?
    func updateCurrency(code: String)
}

final class CurrencyFormatterImpl: CurrencyFormatter {
    private var formatter: NumberFormatter
    private let settingsRepo: SettingRepository
    
    init(currencyCode: String = "GBP", settingsRepo: SettingRepository) {
        self.settingsRepo = settingsRepo
        self.formatter = NumberFormatter()
        self.formatter.numberStyle = .decimal
        self.formatter.minimumFractionDigits = 2
        self.formatter.maximumFractionDigits = 2
        self.formatter.groupingSeparator = " "
        self.formatter.decimalSeparator = "."
    }
    
    func updateCurrency(code: String) {
        // Метод оставлен для совместимости, но не используется
    }
    
    func string(fromCents: Int64) -> String {
        let amount = Double(fromCents) / 100.0
        return formatter.string(from: NSNumber(value: amount)) ?? "0.00"
    }
    
    func cents(fromString: String) -> Int64? {
        let cleaned = fromString.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        
        guard let value = Double(cleaned) else { return nil }
        return Int64((value * 100.0).rounded())
    }
}

