import Foundation

enum SkewStatus: Int, Codable, Equatable {
    case ok
    case medium
    case bad
    
    var color: String {
        switch self {
        case .ok: return "#2ECC71"
        case .medium: return "#FF9F0A"
        case .bad: return "#8A0C19"
        }
    }
}

struct SkewSnapshot: Equatable {
    let totalCents: Int64
    let deltasPct: [EnvelopeSlot: Double]
    let maxDeltaPct: Double
    let status: SkewStatus
}

protocol BalanceCalculator {
    func weeklySkew(envelopes: [WeekEnvelope]) -> SkewSnapshot
    func dailySkew(entriesOfDay: [Entry], envelopes: [WeekEnvelope]) -> SkewSnapshot
    func adviceToRebalance(envelopes: [WeekEnvelope]) -> (from: EnvelopeSlot, amountCents: Int64)?
}

final class BalanceCalculatorImpl: BalanceCalculator {
    
    func weeklySkew(envelopes: [WeekEnvelope]) -> SkewSnapshot {
        let total = envelopes.reduce(0) { $0 + $1.sumCents }
        guard total > 0, !envelopes.isEmpty else {
            return SkewSnapshot(totalCents: 0, deltasPct: [:], maxDeltaPct: 0, status: .ok)
        }
        
        let count = envelopes.count
        let avg = Double(total) / Double(count)
        var deltas: [EnvelopeSlot: Double] = [:]
        var maxDelta: Double = 0
        
        for env in envelopes {
            // Используем фактический индекс для расчёта
            let actualSum = Double(env.sumCents)
            let delta = ((actualSum - avg) / avg) * 100.0
            
            // Сохраняем в deltas только если есть соответствующий slot
            if let slot = EnvelopeSlot(rawValue: Int(env.orderIndex)) {
                deltas[slot] = delta
            }
            
            maxDelta = max(maxDelta, abs(delta))
        }
        
        let status: SkewStatus
        if maxDelta <= 10 {
            status = .ok
        } else if maxDelta <= 20 {
            status = .medium
        } else {
            status = .bad
        }
        
        return SkewSnapshot(totalCents: total, deltasPct: deltas, maxDeltaPct: maxDelta, status: status)
    }
    
    func dailySkew(entriesOfDay: [Entry], envelopes: [WeekEnvelope]) -> SkewSnapshot {
        var sums: [UUID: Int64] = [:]
        for entry in entriesOfDay {
            sums[entry.envelopeId, default: 0] += entry.amountCents
        }
        
        let total = sums.values.reduce(0, +)
        guard total > 0, !envelopes.isEmpty else {
            return SkewSnapshot(totalCents: 0, deltasPct: [:], maxDeltaPct: 0, status: .ok)
        }
        
        let count = envelopes.count
        let avg = Double(total) / Double(count)
        var deltas: [EnvelopeSlot: Double] = [:]
        var maxDelta: Double = 0
        
        for env in envelopes {
            let sum = sums[env.id] ?? 0
            let actualSum = Double(sum)
            let delta = ((actualSum - avg) / avg) * 100.0
            
            // Сохраняем в deltas только если есть соответствующий slot
            if let slot = EnvelopeSlot(rawValue: Int(env.orderIndex)) {
                deltas[slot] = delta
            }
            
            maxDelta = max(maxDelta, abs(delta))
        }
        
        let status: SkewStatus
        if maxDelta <= 10 {
            status = .ok
        } else if maxDelta <= 20 {
            status = .medium
        } else {
            status = .bad
        }
        
        return SkewSnapshot(totalCents: total, deltasPct: deltas, maxDeltaPct: maxDelta, status: status)
    }
    
    func adviceToRebalance(envelopes: [WeekEnvelope]) -> (from: EnvelopeSlot, amountCents: Int64)? {
        let snapshot = weeklySkew(envelopes: envelopes)
        guard snapshot.status != .ok, !envelopes.isEmpty else { return nil }
        
        var maxDeltaSlot: EnvelopeSlot?
        var maxDeltaValue: Double = 0
        
        for (slot, delta) in snapshot.deltasPct {
            if abs(delta) > abs(maxDeltaValue) {
                maxDeltaValue = delta
                maxDeltaSlot = slot
            }
        }
        
        guard let slot = maxDeltaSlot, maxDeltaValue > 0 else { return nil }
        
        let env = envelopes.first { EnvelopeSlot(rawValue: Int($0.orderIndex)) == slot }
        guard let envelope = env else { return nil }
        
        let count = envelopes.count
        let avg = Double(snapshot.totalCents) / Double(count)
        let excess = Double(envelope.sumCents) - avg
        let advice = Int64((excess / 2.0).rounded())
        
        return (slot, max(advice, 0))
    }
}

