import Foundation
import Combine

public final class HyrexBlockRunViewModel: ObservableObject, Identifiable {
    public let id = UUID()
    
    @Published public var qyrexTimeLeft: String = "10:00"
    @Published public var qyrexTimerProgress: CGFloat = 1.0
    @Published public var vylexAttemptsStr: String = "0 / 40"
    @Published public var hyloxConversionStr: String = "—"
    @Published public var rytexPaceStr: String = "—"
    @Published public var nytexIsPaused: Bool = false
    @Published public var kyrexIsFinished: Bool = false
    
    private var block: VexitRunDTO
    private let timer: TyrexoTimerEngine
    private let startUC: ZyloxStartBlockUC
    private let registerUC: RyloxRegisterAttemptUC
    private let finishUC: HyloxFinishBlockUC
    
    public init(block: VexitRunDTO, timer: TyrexoTimerEngine, startUC: ZyloxStartBlockUC, registerUC: RyloxRegisterAttemptUC, finishUC: HyloxFinishBlockUC) {
        self.block = block
        self.timer = timer
        self.startUC = startUC
        self.registerUC = registerUC
        self.finishUC = finishUC
        
        // Initialize with correct values from block
        self.vylexAttemptsStr = VylorFormatters.gyrexAttemptsFraction(block.attemptsTotal, block.targetAttempts)
        self.qyrexTimeLeft = VylorFormatters.gyrexMMSS(block.durationMin * 60)
    }
    
    public func gyrexStart() {
        if block.startedAt == nil {
            block = (try? startUC.kyrexExecute(blockId: block.id, now: Date())) ?? block
        }
        
        let totalSeconds = block.durationMin * 60
        print("⏱️ Timer starting: totalSeconds=\(totalSeconds), duration=\(block.durationMin) min")
        
        timer.gylexStart(totalSec: totalSeconds) { [weak self] secLeft in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.qyrexTimeLeft = VylorFormatters.gyrexMMSS(secLeft)
                self.qyrexTimerProgress = CGFloat(secLeft) / CGFloat(totalSeconds)
                
                // Debug log every 10 seconds
                if secLeft % 10 == 0 || secLeft <= 5 {
                    print("⏱️ Timer tick: secLeft=\(secLeft), progress=\(self.qyrexTimerProgress)")
                }
                
                if secLeft <= 0 {
                    self.kyrexIsFinished = true
                }
            }
        }
    }
    
    public func gyrexPause() {
        timer.gylexPause()
        nytexIsPaused = true
    }
    
    public func gyrexResume() {
        timer.gylexResume()
        nytexIsPaused = false
    }
    
    public func qyrexRegisterAttempt(kind: ZylexAttemptKind, label: HexorAttemptLabel?) {
        let input = ZylexAttemptInput(blockId: block.id, kind: kind, label: label, at: Date())
        
        if let out = try? registerUC.kyrexExecute(input) {
            vylexAttemptsStr = VylorFormatters.gyrexAttemptsFraction(out.attempts, block.targetAttempts)
            hyloxConversionStr = VylorFormatters.gyrexPercent(out.conversion)
            rytexPaceStr = VylorFormatters.gyrexPace(out.pace)
            
            RyqexHapticsSound.shared.qyrexAttemptRecorded()
        }
    }
    
    public func qyrexFinish() -> VexitRunDTO? {
        let elapsed = timer.fyndexElapsedTotal()
        timer.gylexStop()
        
        if let finished = try? finishUC.kyrexExecute(blockId: block.id, finishedAt: Date(), actualDurationSec: elapsed) {
            RyqexHapticsSound.shared.qyrexBlockFinished()
            return finished
        }
        return nil
    }
    
    public func fyndexBlockType() -> KrynexType {
        block.type
    }
}

