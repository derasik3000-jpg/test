import Foundation
import Combine
import AVFoundation

class BreathFlowConductorViewModel: ObservableObject {
    @Published var currentPhaseIndex: Int = 0
    @Published var phaseProgress: Double = 0
    @Published var totalElapsedSeconds: Int = 0
    @Published var isActiveCeremony: Bool = false
    @Published var isPausedState: Bool = false
    @Published var currentInstruction: String = "Prepare to begin"
    @Published var breathCycleScale: CGFloat = 1.0
    @Published var soundEnabled: Bool
    @Published var selectedAmbientSound: AmbientSoundType = .none
    
    let flowCategory: BreathFlowCategory
    
    private var chronoTimer: Timer?
    private var audioAmbiance: AVAudioPlayer?
    private let vaporArchive: VaporFlowArchiveProtocol
    private var sessionStartTime: Date?
    private let configArchive: ConfigurationArchiveProtocol
    
    private let breathPattern: [(inhale: Int, hold: Int, exhale: Int)] = [
        (4, 4, 6),
        (4, 7, 8),
        (5, 5, 5)
    ]
    
    var totalDurationSeconds: Int {
        flowCategory.phaseLength * 60
    }
    
    var progressPercentage: Double {
        guard totalDurationSeconds > 0 else { return 0 }
        return Double(totalElapsedSeconds) / Double(totalDurationSeconds)
    }
    
    init(flowCategory: BreathFlowCategory, soundEnabled: Bool, vaporArchive: VaporFlowArchiveProtocol, configArchive: ConfigurationArchiveProtocol) {
        self.flowCategory = flowCategory
        self.soundEnabled = soundEnabled
        self.vaporArchive = vaporArchive
        self.configArchive = configArchive
    }
    
    func initiateFlow() {
        isActiveCeremony = true
        isPausedState = false
        sessionStartTime = Date()
        currentPhaseIndex = 0
        totalElapsedSeconds = 0
        
        chronoTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.progressTimeline()
        }
        
        if soundEnabled && selectedAmbientSound != .none {
            playAmbientSound()
        }
    }
    
    func togglePauseState() {
        isPausedState.toggle()
        
        if isPausedState {
            audioAmbiance?.pause()
        } else {
            audioAmbiance?.play()
        }
    }
    
    func toggleSound() {
        soundEnabled.toggle()
        
        if soundEnabled && isActiveCeremony && selectedAmbientSound != .none {
            playAmbientSound()
        } else {
            audioAmbiance?.stop()
            audioAmbiance = nil
        }
    }
    
    func changeAmbientSound(_ sound: AmbientSoundType) {
        selectedAmbientSound = sound
        
        if isActiveCeremony && soundEnabled {
            audioAmbiance?.stop()
            audioAmbiance = nil
            
            if sound != .none {
                playAmbientSound()
            }
        }
    }
    
    func concludeFlow() {
        chronoTimer?.invalidate()
        chronoTimer = nil
        audioAmbiance?.stop()
        audioAmbiance = nil
        
        let session = VaporFlowPrism(
            rhythmCategory: flowCategory.rawValue,
            durationPhase: flowCategory.phaseLength,
            chronoStamp: sessionStartTime ?? Date(),
            soundActivated: soundEnabled
        )
        
        vaporArchive.appendQuantum(session)
        isActiveCeremony = false
    }
    
    private func progressTimeline() {
        guard !isPausedState else { return }
        
        totalElapsedSeconds += 1
        
        let patternIndex = currentPhaseIndex % breathPattern.count
        let pattern = breathPattern[patternIndex]
        let cycleLength = pattern.inhale + pattern.hold + pattern.exhale
        let positionInCycle = totalElapsedSeconds % cycleLength
        
        if positionInCycle < pattern.inhale {
            currentInstruction = "Breathe in slowly"
            breathCycleScale = 1.0 + (Double(positionInCycle) / Double(pattern.inhale)) * 0.5
        } else if positionInCycle < pattern.inhale + pattern.hold {
            currentInstruction = "Hold gently"
            breathCycleScale = 1.5
        } else {
            currentInstruction = "Breathe out fully"
            let exhalePos = positionInCycle - pattern.inhale - pattern.hold
            breathCycleScale = 1.5 - (Double(exhalePos) / Double(pattern.exhale)) * 0.5
        }
        
        if positionInCycle == 0 && totalElapsedSeconds > 0 {
            currentPhaseIndex += 1
        }
        
        if totalElapsedSeconds >= totalDurationSeconds {
            concludeFlow()
        }
    }
    
    private func playAmbientSound() {
        // Получаем громкость из настроек
        let config = configArchive.retrieveConfiguration()
        let volume = config.amplitudeLevel
        
        // Генерируем синтезированный ambient звук
        generateAmbientTone(frequency: selectedAmbientSound.frequency, volume: volume)
    }
    
    private func generateAmbientTone(frequency: Double, volume: Float) {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            // Создаем синтезированный тон
            let sampleRate = 44100.0
            let duration = 2.0
            let amplitude = 0.3 * Double(volume)
            
            let frameCount = Int(duration * sampleRate)
            var samples = [Float](repeating: 0, count: frameCount)
            
            for i in 0..<frameCount {
                let time = Double(i) / sampleRate
                samples[i] = Float(sin(2.0 * .pi * frequency * time) * amplitude)
            }
            
            // Создаем PCM буфер
            let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: AVAudioFrameCount(frameCount)) else { return }
            
            buffer.frameLength = AVAudioFrameCount(frameCount)
            let channelData = buffer.floatChannelData?[0]
            for i in 0..<frameCount {
                channelData?[i] = samples[i]
            }
            
            // Используем AVAudioEngine для воспроизведения
            let engine = AVAudioEngine()
            let playerNode = AVAudioPlayerNode()
            
            engine.attach(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: audioFormat)
            
            try engine.start()
            playerNode.play()
            
            // Зацикливаем звук
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops) { }
            
        } catch {
            print("Audio setup error: \(error)")
        }
    }
}

enum AmbientSoundType: String, CaseIterable, Identifiable {
    case none = "None"
    case ocean = "Ocean Waves"
    case rain = "Rain"
    case whitenoise = "White Noise"
    case nature = "Nature"
    
    var id: String { rawValue }
    
    var frequency: Double {
        switch self {
        case .none: return 0
        case .ocean: return 110.0
        case .rain: return 220.0
        case .whitenoise: return 440.0
        case .nature: return 165.0
        }
    }
}

