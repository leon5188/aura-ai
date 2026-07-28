//
//  WakeWordDetectorManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Siri-like On-Device Wake Word / Keyword Spotting Engine
//

import Foundation
import UIKit
import Combine

public final class WakeWordDetectorManager: ObservableObject {
    public static let shared = WakeWordDetectorManager()
    
    @Published public var isListeningForWakeWord: Bool = false
    @Published public var lastDetectedKeyword: String? = nil
    
    public var onWakeWordDetected: ((String) -> Void)?
    
    private let targetKeywords = ["aura", "hey aura", "小助手", "hey assistant", "assistant", "你好助手"]

    
    private init() {}
    
    // MARK: - Start Hotword Detection
    public func startDetection() {
        DispatchQueue.main.async {
            self.isListeningForWakeWord = true
            print("[WakeWordDetector] 离线唤醒词检测已激活（监听关键词：'小助手' / 'Hey Assistant'）")
        }
    }
    
    // MARK: - Stop Hotword Detection
    public func stopDetection() {
        DispatchQueue.main.async {
            self.isListeningForWakeWord = false
        }
    }
    
    // MARK: - Process Audio Input Stream
    public func processAudioText(_ text: String) {
        guard isListeningForWakeWord else { return }
        
        let lowercased = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        for keyword in targetKeywords {
            if lowercased.contains(keyword) {
                triggerWakeUp(keyword: keyword)
                break
            }
        }
    }
    
    private func triggerWakeUp(keyword: String) {
        DispatchQueue.main.async {
            self.lastDetectedKeyword = keyword
            self.triggerHapticFeedback()
            print("[WakeWordDetector] 捕获唤醒词: '\(keyword)'！唤醒主引擎...")
            self.onWakeWordDetected?(keyword)
        }
    }
    
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
