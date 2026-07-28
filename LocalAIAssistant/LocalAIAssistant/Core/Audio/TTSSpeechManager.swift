//
//  TTSSpeechManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Transformers-Style Robotic Voice Engine (AVSpeechSynthesizer + AVAudioEngine DSP)
//

import Foundation
import AVFoundation
import Combine

public final class TTSSpeechManager: NSObject, ObservableObject, @unchecked Sendable, AVSpeechSynthesizerDelegate {
    public static let shared = TTSSpeechManager()

    private let synthesizer = AVSpeechSynthesizer()
    @Published public var isSpeaking: Bool = false

    // 自动搜寻系统最优秀的神经增强版 (Enhanced / Premium) 音色，作为机械化处理前的基底人声
    private var bestChineseVoice: AVSpeechSynthesisVoice?
    private var bestEnglishVoice: AVSpeechSynthesisVoice?

    // MARK: - "变形金刚"式机械声效链路 (AVSpeechSynthesizer 输出 PCM → AVAudioEngine DSP 加工 → 播放)
    // AVSpeechSynthesizer.write 输出的缓冲区固定为 22.05kHz / 单声道 / 32-bit Float
    private let roboticBufferFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: false)!
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let distortionEffect = AVAudioUnitDistortion()
    private let pitchEffect = AVAudioUnitTimePitch()
    private var pendingBufferPlaybackCount = 0
    private var isSynthesizingAllSentences = false

    private override init() {
        super.init()
        synthesizer.delegate = self
        findBestSystemVoices()
        configureRoboticVoiceGraph()
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

    // MARK: - Robotic DSP Graph Setup
    private func configureRoboticVoiceGraph() {
        distortionEffect.loadFactoryPreset(.speechRadioTower)
        distortionEffect.wetDryMix = 45   // 保留一定原声可懂度，叠加金属通讯质感

        pitchEffect.pitch = -300          // 降调约小三度，塑造厚重机械感

        audioEngine.attach(playerNode)
        audioEngine.attach(distortionEffect)
        audioEngine.attach(pitchEffect)

        audioEngine.connect(playerNode, to: distortionEffect, format: roboticBufferFormat)
        audioEngine.connect(distortionEffect, to: pitchEffect, format: roboticBufferFormat)
        audioEngine.connect(pitchEffect, to: audioEngine.mainMixerNode, format: roboticBufferFormat)

        audioEngine.prepare()
    }

    // MARK: - Speak with Transformers-Style Robotic Voice Dynamics
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

        stop()

        let sentences = splitTextIntoExpressiveSentences(text).filter {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        guard !sentences.isEmpty else { return }

        do {
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
        } catch {
            print("[TTSSpeechManager Error] 机械音效引擎启动失败: \(error.localizedDescription)")
            return
        }

        playerNode.play()

        DispatchQueue.main.async {
            self.isSpeaking = true
            self.isSynthesizingAllSentences = true
            self.pendingBufferPlaybackCount = 0
        }

        for (index, sentence) in sentences.enumerated() {
            let utterance = AVSpeechUtterance(string: sentence)

            // 赋能系统顶级高保真神经声音，作为机械化处理前的基底
            utterance.voice = isChineseText(sentence) ? bestChineseVoice : bestEnglishVoice

            utterance.rate = 0.46
            utterance.pitchMultiplier = 0.85    // 叠加降调，与 DSP 链路共同塑造机械厚重感
            utterance.volume = 1.0

            // 将合成结果重定向为原始 PCM 缓冲区，交给机械声效链路播放，而非系统默认输出
            synthesizer.write(utterance) { [weak self] audioBuffer in
                guard let self, let pcmBuffer = audioBuffer as? AVAudioPCMBuffer else { return }

                guard pcmBuffer.frameLength > 0 else {
                    if index == sentences.count - 1 {
                        DispatchQueue.main.async {
                            self.isSynthesizingAllSentences = false
                            self.finishPlaybackIfDone()
                        }
                    }
                    return
                }

                DispatchQueue.main.async { self.pendingBufferPlaybackCount += 1 }
                self.playerNode.scheduleBuffer(pcmBuffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
                    DispatchQueue.main.async {
                        guard let self else { return }
                        self.pendingBufferPlaybackCount -= 1
                        self.finishPlaybackIfDone()
                    }
                }
            }
        }
    }

    private func finishPlaybackIfDone() {
        guard !isSynthesizingAllSentences, pendingBufferPlaybackCount <= 0 else { return }
        isSpeaking = false
    }

    public func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        playerNode.stop()

        DispatchQueue.main.async {
            self.pendingBufferPlaybackCount = 0
            self.isSynthesizingAllSentences = false
            self.isSpeaking = false
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
        // isSpeaking 现在由机械声效播放链路（playerNode 缓冲区回调）统一管理
    }
}
