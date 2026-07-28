//
//  TTSSpeechManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Premium Ultra-High Quality Enhanced Neural Female Voice Engine
//

import Foundation
import AVFoundation
import Combine

public final class TTSSpeechManager: NSObject, ObservableObject, @unchecked Sendable, AVSpeechSynthesizerDelegate {
    public static let shared = TTSSpeechManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    @Published public var isSpeaking: Bool = false
    
    // 自动搜寻系统最优秀的神经增强版 (Enhanced / Premium) 少女音色
    private var bestChineseVoice: AVSpeechSynthesisVoice?
    private var bestEnglishVoice: AVSpeechSynthesisVoice?
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        findBestSystemVoices()
    }
    
    // MARK: - Find Ultra-High Quality Enhanced System Voices
    private func findBestSystemVoices() {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // 查找中文增强/高保真神经音色 (如 Tingting Enhanced / Premium)
        let zhVoices = allVoices.filter { $0.language == "zh-CN" }
        bestChineseVoice = zhVoices.first { $0.quality == .premium }
            ?? zhVoices.first { $0.quality == .enhanced }
            ?? AVSpeechSynthesisVoice(language: "zh-CN")
        
        // 查找英文高保真音色
        let enVoices = allVoices.filter { $0.language == "en-US" }
        bestEnglishVoice = enVoices.first { $0.quality == .premium }
            ?? enVoices.first { $0.quality == .enhanced }
            ?? AVSpeechSynthesisVoice(language: "en-US")
        
        print("[TTSSpeechManager] 选定的最高品质中文神经音色: \(bestChineseVoice?.name ?? "Default") [Quality: \(bestChineseVoice?.quality.rawValue ?? 0)]")
    }
    
    // MARK: - Speak with Ultra-High Quality Voice Dynamics
    public func speak(text: String) {
        guard !text.isEmpty else { return }

        // 关键修复：语音识别会把音频会话切到 .record（纯录音、无播放通路）。
        // 朗读前必须切回可播放的分类，否则合成器"说话"了但设备完全没有声音输出，
        // 且 .record/.soloAmbient 默认还会被静音开关静音。
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("[TTSSpeechManager Error] 音频会话切换为播放模式失败: \(error.localizedDescription)")
        }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let sentences = splitTextIntoExpressiveSentences(text)
        
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
        
        for (index, sentence) in sentences.enumerated() {
            guard !sentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            
            let utterance = AVSpeechUtterance(string: sentence)
            
            // 赋能系统顶级高保真神经声音
            if isChineseText(sentence) {
                utterance.voice = bestChineseVoice
            } else {
                utterance.voice = bestEnglishVoice
            }
            
            // 人声级温润调校参数：
            utterance.rate = 0.48               // 最符合人类说话感节奏
            utterance.pitchMultiplier = 1.05    // 微升，展现温柔自然的清亮质感
            utterance.volume = 1.0
            
            // 标点停顿
            utterance.postUtteranceDelay = (index == sentences.count - 1) ? 0.0 : 0.25
            
            synthesizer.speak(utterance)
        }
    }
    
    public func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    private func splitTextIntoExpressiveSentences(_ text: String) -> [String] {
        let pattern = "([^。！？；,，!?;]+[。！？；,，!?;]?)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [text] }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        
        var result: [String] = []
        for match in matches {
            result.append(nsString.substring(with: match.range))
        }
        return result.isEmpty ? [text] : result
    }
    
    private func isChineseText(_ text: String) -> Bool {
        for scalar in text.unicodeScalars {
            if scalar.value >= 0x4E00 && scalar.value <= 0x9FA5 {
                return true
            }
        }
        return false
    }
    
    // MARK: - Delegate
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}
