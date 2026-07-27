//
//  BundledMedia.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Central lookup for demo media shipped inside the app bundle (Resources/)
//  instead of hardcoded absolute paths on the developer's machine.
//

import Foundation

public enum BundledMedia {
    public static let heroPortraitURL: URL =
        Bundle.main.url(forResource: "AuraHeroPortrait", withExtension: "jpg") ?? URL(fileURLWithPath: "")

    public static let siriWaveformGIFURL: URL =
        Bundle.main.url(forResource: "SiriMicWaveform", withExtension: "gif") ?? URL(fileURLWithPath: "")

    public static let voiceWaveformGIFURL: URL =
        Bundle.main.url(forResource: "VoiceWaveform", withExtension: "gif") ?? URL(fileURLWithPath: "")
}
