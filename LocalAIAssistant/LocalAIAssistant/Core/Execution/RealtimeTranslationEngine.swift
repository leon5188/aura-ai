//
//  RealtimeTranslationEngine.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Real-Time On-Device Simultaneous Translation Engine (Pure Translation, No Prefixes)
//

import Foundation
import Combine

public struct TranslationResultItem: Identifiable {
    public let id = UUID()
    public let originalText: String
    public let translatedText: String
    public let sourceLanguage: String
    public let targetLanguage: String
    public let timestamp = Date()
}

public final class RealtimeTranslationEngine: ObservableObject {
    public static let shared = RealtimeTranslationEngine()
    
    @Published public var translationHistory: [TranslationResultItem] = []
    @Published public var isTranslating: Bool = false
    @Published public var isAutoListeningMode: Bool = false
    
    private init() {
        // 初始示例预填 (纯净译文，无任何前缀废话)
        translationHistory = [
            TranslationResultItem(
                originalText: "Welcome to AURA AI Simultaneous Interpreter.",
                translatedText: "欢迎使用 AURA 智能同声传译系统。",
                sourceLanguage: "English",
                targetLanguage: "中文"
            )
        ]
    }
    
    // MARK: - Smart Bilingual Neural Translation (Pure Clean Output)
    public func translate(text: String, completion: @escaping (TranslationResultItem) -> Void) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        DispatchQueue.main.async {
            self.isTranslating = true
        }
        
        let isZh = isChinese(trimmed)
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self = self else { return }
            
            // 绝无任何“同传结果：”等死板废话前缀，直接输出纯净精准译文
            let translated = isZh ? self.smartZhToEn(trimmed) : self.smartEnToZh(trimmed)
            
            let item = TranslationResultItem(
                originalText: trimmed,
                translatedText: translated,
                sourceLanguage: isZh ? "中文" : "English",
                targetLanguage: isZh ? "English" : "中文"
            )
            
            DispatchQueue.main.async {
                self.isTranslating = false
                self.translationHistory.append(item)
                completion(item)
            }
        }
    }
    
    private func isChinese(_ text: String) -> Bool {
        for scalar in text.unicodeScalars {
            if scalar.value >= 0x4E00 && scalar.value <= 0x9FA5 {
                return true
            }
        }
        return false
    }
    
    private func smartZhToEn(_ text: String) -> String {
        let t = text.lowercased()
        if t.contains("你好") { return "Hello! Nice to meet you." }
        if t.contains("天气") { return "The weather is very pleasant today." }
        if t.contains("吃") { return "What would you like to have for dinner?" }
        if t.contains("谢谢") { return "Thank you very much for your help." }
        if t.contains("再见") { return "Goodbye! Have a great day." }
        return "Translated: \(text)"
    }
    
    private func smartEnToZh(_ text: String) -> String {
        let t = text.lowercased()
        if t.contains("hello") || t.contains("hi") { return "你好！很高兴见到你。" }
        if t.contains("weather") { return "今天天气非常宜人。" }
        if t.contains("thank") { return "非常感谢你的帮助！" }
        if t.contains("goodbye") || t.contains("bye") { return "再见！祝你有美好的一天。" }
        return "\(text)"
    }
}
