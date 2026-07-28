//
//  OfficeCodeAnalyzer.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Office Meeting Notes, Excel Analysis & Code Bug Debugging Engine
//

import Foundation

public final class OfficeCodeAnalyzer {
    public static let shared = OfficeCodeAnalyzer()

    private init() {}

    // MARK: - Debug Code Snippets & Analyze Office Content (真实端侧 LLM 推理，非固定文案)
    public func analyzeCodeOrOffice(input: String, completion: @escaping (String) -> Void) {
        let isZh = LocalizationHelper.isChineseSystem

        let systemPrompt = isZh ?
            "你是一名经验丰富的 iOS/Swift 工程师兼办公文档分析助手。请针对用户提供的代码片段或办公问题描述，给出简明扼要（3-5 句话以内）的诊断结果和具体修复建议，不要输出多余的客套话。" :
            "You are an experienced iOS/Swift engineer and office document analyst. Give a concise (3-5 sentences) diagnosis and concrete fix suggestion for the user's code snippet or office question. Skip pleasantries."

        Task {
            let response = await LLMManager.shared.generateRawText(systemPrompt: systemPrompt, userInput: input)
            await MainActor.run {
                completion(response)
            }
        }
    }
}
