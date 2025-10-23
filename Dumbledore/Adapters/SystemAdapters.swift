// SystemAdapters.swift
import Foundation
import Speech
import AVFoundation
import UserNotifications

// MARK: - Speech Adapter
public protocol SpeechAdapter: AnyObject {
    func startListening() async throws
    func stopListening() async
    var onPartial: ((String) -> Void)? { get set }
    var onFinal: ((String) -> Void)? { get set }
}

public class SpeechAdapterImpl: NSObject, SpeechAdapter, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    public var onPartial: ((String) -> Void)?
    public var onFinal: ((String) -> Void)?
    
    public override init() {
        super.init()
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            // Handle authorization status
        }
    }
    
    public func startListening() async throws {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechError.recognizerNotAvailable
        }
        
        // Cancel previous task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.requestNotAvailable
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                if result.isFinal {
                    self?.onFinal?(bestString)
                } else {
                    self?.onPartial?(bestString)
                }
            }
            
            if error != nil {
                self?.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self?.recognitionRequest = nil
                self?.recognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    public func stopListening() async {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

public enum SpeechError: Error {
    case recognizerNotAvailable
    case requestNotAvailable
}

// MARK: - TTS Adapter
public protocol TTSAdapter {
    func speak(_ text: String, rate: Double) async
    func stop() async
}

public class TTSAdapterImpl: NSObject, TTSAdapter {
    private let synthesizer = AVSpeechSynthesizer()
    
    public override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    public func speak(_ text: String, rate: Double) async {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = Float(rate)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        await MainActor.run {
            synthesizer.speak(utterance)
        }
    }
    
    public func stop() async {
        await MainActor.run {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

extension TTSAdapterImpl: AVSpeechSynthesizerDelegate {
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Handle completion
    }
}

// MARK: - Notification Adapter
public protocol NotificationAdapter {
    func requestAuthIfNeeded() async throws
    func presentMicroLessonPrompt(title: String, body: String) async
}

public class NotificationAdapterImpl: NotificationAdapter {
    public init() {}
    
    public func requestAuthIfNeeded() async throws {
        let center = UNUserNotificationCenter.current()
        var granted = false
        let semaphore = DispatchSemaphore(value: 0)
        center.requestAuthorization(options: [.alert, .sound, .badge]) { ok, _ in
            granted = ok
            semaphore.signal()
        }
        semaphore.wait()
        if !granted { throw NotificationError.notAuthorized }
    }
    
    public func presentMicroLessonPrompt(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "micro-lesson-prompt",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Failed to schedule notification: \(error)") }
        }
    }
}

public enum NotificationError: Error {
    case notAuthorized
}
