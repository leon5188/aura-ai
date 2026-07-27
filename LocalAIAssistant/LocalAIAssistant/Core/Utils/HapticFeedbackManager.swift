//
//  HapticFeedbackManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Haptic Feedback Engine for Premium Tactile Touch
//

import UIKit

public final class HapticFeedbackManager {
    public static let shared = HapticFeedbackManager()
    
    private init() {}
    
    // MARK: - Light Impact (Tab Taps)
    public func impactLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Medium Impact (Mic Start/Stop)
    public func impactMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Heavy/Rigid Impact (Action Executed)
    public func impactRigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Notification Feedback (Success/Error)
    public func notifySuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    public func notifyError() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
}
