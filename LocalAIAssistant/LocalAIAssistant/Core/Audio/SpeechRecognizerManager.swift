//
//  SpeechRecognizerManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Offline Speech-to-Text (STT) + VAD Audio Metering
//

import Foundation
import Speech
import AVFoundation
import Combine

public final class SpeechRecognizerManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    // MARK: - Published Properties
    @Published public var recognizedText: String = ""
    @Published public var isListening: Bool = false
    @Published public var audioLevel: Float = 0.0
    @Published public var errorMessage: String? = nil
    
    // MARK: - Core Speech & Audio Engine
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // 静音检测与断句 (VAD 模拟)
    private var silenceTimer: Timer?
    private let silenceThresholdSeconds: TimeInterval = 1.2
    public var onSpeechEnded: ((String) -> Void)?
    
    public override init() {
        super.init()
        speechRecognizer?.delegate = self
    }
    
    // MARK: - Request Permissions
    public func requestPermissions() {
        // 增加安全防崩溃检测：防止 Info.plist 未添加 Key 时导致系统内核触发 __abort_with_payload 强退
        guard Bundle.main.object(forInfoDictionaryKey: "NSSpeechRecognitionUsageDescription") != nil,
              Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") != nil else {
            DispatchQueue.main.async {
                self.errorMessage = "请在 Xcode Info 中添加 NSSpeechRecognitionUsageDescription 和 NSMicrophoneUsageDescription 权限声明"
                print("[SpeechRecognizerManager Warning] 缺少 Info.plist 权限配置，已进行安全拦截防崩")
            }
            return
        }
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    if #available(iOS 17.0, *) {
                        AVAudioApplication.requestRecordPermission { granted in
                            if !granted {
                                DispatchQueue.main.async {
                                    self.errorMessage = "麦克风权限未授予"
                                }
                            }
                        }
                    } else {
                        AVAudioSession.sharedInstance().requestRecordPermission { granted in
                            if !granted {
                                DispatchQueue.main.async {
                                    self.errorMessage = "麦克风权限未授予"
                                }
                            }
                        }
                    }
                case .denied, .restricted, .notDetermined:
                    self.errorMessage = "语音识别权限未授予"
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - Start Listening
    public func startListening() {
        requestPermissions()
        guard !audioEngine.isRunning else { return }
        
        recognizedText = ""
        errorMessage = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "音频会话启动失败: \(error.localizedDescription)"
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        // 关键：强制 100% 本地端侧识别 (App Store 隐私合规 & 零延迟)
        if speechRecognizer?.supportsOnDeviceRecognition == true {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // 监听音频振幅与采样流
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.calculateAudioLevel(buffer: buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            errorMessage = "无法启动 Audio Engine: \(error.localizedDescription)"
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let latestText = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.recognizedText = latestText
                    self.resetSilenceTimer()
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self.stopListeningInternal()
            }
        }
    }
    
    // MARK: - Stop Listening
    public func stopListening() {
        silenceTimer?.invalidate()
        let finalText = recognizedText
        stopListeningInternal()
        if !finalText.isEmpty {
            onSpeechEnded?(finalText)
        }
    }
    
    private func stopListeningInternal() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        DispatchQueue.main.async {
            self.isListening = false
            self.audioLevel = 0.0
        }
    }
    
    // MARK: - Audio Level Calculation (for 波形 UI)
    private func calculateAudioLevel(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataValue = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        var rms: Float = 0
        for sample in channelDataValue {
            rms += sample * sample
        }
        rms = sqrt(rms / Float(buffer.frameLength))
        
        // 归一化到 0.0 ~ 1.0
        let normalizedLevel = min(max(rms * 5.0, 0.0), 1.0)
        DispatchQueue.main.async {
            self.audioLevel = normalizedLevel
        }
    }
    
    // MARK: - VAD Silence Timer
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceThresholdSeconds, repeats: false) { [weak self] _ in
            // 当用户停止说话超时，自动触发断句并进入 LLM 意图解析
            self?.stopListening()
        }
    }
}
