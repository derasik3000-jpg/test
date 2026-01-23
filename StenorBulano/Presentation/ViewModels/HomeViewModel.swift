import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var week: Week?
    @Published var envelopes: [WeekEnvelope] = []
    @Published var currentAmount: String = ""
    @Published var lastSelectedSlot: EnvelopeSlot = .a
    @Published var advice: String?
    @Published var skewSnapshot: SkewSnapshot?
    
    private let setupUC: SetupWeekUseCase
    private let addUC: UpsertEntryUseCase
    private let balance: BalanceCalculator
    private let formatter: CurrencyFormatter
    
    init(setupUC: SetupWeekUseCase, addUC: UpsertEntryUseCase, balance: BalanceCalculator, formatter: CurrencyFormatter) {
        self.setupUC = setupUC
        self.addUC = addUC
        self.balance = balance
        self.formatter = formatter
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("EnvelopesUpdated"), object: nil, queue: .main) { [weak self] _ in
            self?.load()
        }
    }
    
    func load() {
        if let (w, env) = try? setupUC.currentWeek() {
            week = w
            envelopes = env
            refreshSkew()
        }
    }
    
    func addDigit(_ digit: String) {
        if currentAmount == "0" || currentAmount.isEmpty {
            currentAmount = digit
        } else {
            currentAmount += digit
        }
    }
    
    func addDecimal() {
        if !currentAmount.contains(".") && !currentAmount.contains(",") {
            currentAmount += "."
        }
    }
    
    func backspace() {
        if !currentAmount.isEmpty {
            currentAmount.removeLast()
        }
        if currentAmount.isEmpty {
            currentAmount = "0"
        }
    }
    
    func clearAmount() {
        currentAmount = "0"
    }
    
    func add(to slot: EnvelopeSlot) {
        let cleanedAmount = currentAmount.replacingOccurrences(of: " ", with: "")
        guard let cents = formatter.cents(fromString: cleanedAmount), cents > 0 else { 
            print("DEBUG: Failed to parse amount: \(currentAmount)")
            return 
        }
        
        print("DEBUG: Adding \(cents) cents to slot \(slot)")
        do {
            _ = try addUC.add(amountCents: cents, envelopeSlot: slot)
            lastSelectedSlot = slot
            currentAmount = "0"
            load()
        } catch {
            print("DEBUG: Error adding entry: \(error)")
        }
    }
    
    func addToEnvelope(at index: Int) {
        guard index < envelopes.count else { return }
        let envelope = envelopes[index]
        
        let cleanedAmount = currentAmount.replacingOccurrences(of: " ", with: "")
        guard let cents = formatter.cents(fromString: cleanedAmount), cents > 0 else {
            print("DEBUG: Failed to parse amount: \(currentAmount)")
            return
        }
        
        print("DEBUG: Adding \(cents) cents to envelope at index \(index)")
        do {
            guard let weekId = week?.id else { return }
            _ = try addUC.addToEnvelope(amountCents: cents, envelopeId: envelope.id, weekId: weekId)
            currentAmount = "0"
            load()
        } catch {
            print("DEBUG: Error adding entry to envelope: \(error)")
        }
    }
    
    func undo() {
        try? addUC.undoLast()
        load()
    }
    
    private func refreshSkew() {
        let snapshot = balance.weeklySkew(envelopes: envelopes)
        skewSnapshot = snapshot
        
        if let (slot, amount) = balance.adviceToRebalance(envelopes: envelopes) {
            let slotName = envelopes.first { EnvelopeSlot(rawValue: Int($0.orderIndex)) == slot }?.name ?? ""
            advice = "Move ~\(formatter.string(fromCents: amount)) from \"\(slotName)\" today"
        } else {
            advice = nil
        }
    }
}

