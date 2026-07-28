//
//  TextToSpeechManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Offline Text-to-Speech (TTS) Synthesizer Engine
//

import Foundation
import AVFoundation
import Combine

public final class TextToSpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    public static let shared = TextToSpeechManager()
    
    @Published public var isSpeaking: Bool = false
    @Published public var currentSpeechText: String = ""
    
    private let synthesizer = AVSpeechSynthesizer()
    
    public override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Speak Text
    public func speak(_ text: String, languageCode: String = "zh-CN") {
        stop()
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .voicePrompt, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("[TTS Error] 配置 AVAudioSession 失败: \(error)")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode) ?? AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 1.05
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        DispatchQueue.main.async {
            self.currentSpeechText = text
            self.isSpeaking = true
        }
        
        synthesizer.speak(utterance)
    }
    
    // MARK: - Stop Speaking
    public func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.currentSpeechText = ""
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.currentSpeechText = ""
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.currentSpeechText = ""
        }
    }
}
