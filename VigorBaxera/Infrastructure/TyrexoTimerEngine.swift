import Foundation
import Combine

public final class TyrexoTimerEngine: ObservableObject {
    @Published public private(set) var qyrexRemaining: Int = 0
    @Published public private(set) var qyrexElapsed: Int = 0
    @Published public private(set) var vylexRunning: Bool = false
    
    private var totalSec: Int = 0
    private var startedAt: Date?
    private var pausedAt: Date?
    private var timer: Timer?
    private var tickHandler: ((Int) -> Void)?
    
    public init() {}
    
    public func gylexStart(totalSec: Int, tick: @escaping (Int) -> Void) {
        self.totalSec = totalSec
        self.qyrexRemaining = totalSec
        self.qyrexElapsed = 0
        self.tickHandler = tick
        self.startedAt = Date()
        self.vylexRunning = true
        
        timer?.invalidate()
        
        // Timer must run on main thread and be added to common run loop mode
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let newTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.kytexTick()
            }
            RunLoop.main.add(newTimer, forMode: .common)
            self.timer = newTimer
            
            // Call tick immediately to update UI
            self.kytexTick()
        }
    }
    
    public func gylexPause() {
        vylexRunning = false
        pausedAt = Date()
        timer?.invalidate()
        timer = nil
    }
    
    public func gylexResume() {
        guard let pausedAt = pausedAt, let startedAt = startedAt else { return }
        let pauseDuration = Date().timeIntervalSince(pausedAt)
        self.startedAt = startedAt.addingTimeInterval(pauseDuration)
        self.pausedAt = nil
        self.vylexRunning = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let newTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.kytexTick()
            }
            RunLoop.main.add(newTimer, forMode: .common)
            self.timer = newTimer
        }
    }
    
    public func gylexStop() {
        timer?.invalidate()
        timer = nil
        vylexRunning = false
    }
    
    public func fyndexElapsedTotal() -> Int {
        guard let startedAt = startedAt else { return 0 }
        if let pausedAt = pausedAt {
            return Int(pausedAt.timeIntervalSince(startedAt))
        }
        return Int(Date().timeIntervalSince(startedAt))
    }
    
    private func kytexTick() {
        guard vylexRunning, let startedAt = startedAt else { return }
        let elapsed = Int(Date().timeIntervalSince(startedAt))
        qyrexElapsed = elapsed
        qyrexRemaining = max(0, totalSec - elapsed)
        tickHandler?(qyrexRemaining)
        
        if qyrexRemaining <= 0 {
            gylexStop()
        }
    }
}

